package com.tourdulich.config;

import com.tourdulich.security.JwtAuthFilter;
import com.tourdulich.security.RestSecurityHandlers;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.context.RequestAttributeSecurityContextRepository;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.List;

@Configuration
@EnableWebSecurity
@EnableMethodSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    private final JwtAuthFilter jwtAuthFilter;
    private final RestSecurityHandlers securityHandlers;
    private final AppProperties props;

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
                // API stateless dùng Bearer token nên không cần CSRF
                .csrf(csrf -> csrf.disable())
                .cors(Customizer.withDefaults())
                // Xác thực bằng JWT (stateless). Chỉ tạo HTTP Session khi cần, cho Session Cart (/api/cart).
                .sessionManagement(s -> s.sessionCreationPolicy(SessionCreationPolicy.IF_REQUIRED))
                // Không lưu SecurityContext vào HTTP Session: danh tính chỉ lấy từ JWT của từng request
                // (nếu không, đổi tài khoản trên cùng trình duyệt sẽ bị giữ danh tính cũ trong JSESSIONID)
                .securityContext(sc -> sc.securityContextRepository(new RequestAttributeSecurityContextRepository()))
                .exceptionHandling(e -> e
                        .authenticationEntryPoint(securityHandlers)
                        .accessDeniedHandler(securityHandlers))
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers(HttpMethod.OPTIONS, "/**").permitAll()
                        .requestMatchers("/error", "/api/health").permitAll()

                        // Auth: me bắt buộc đăng nhập, còn lại công khai (logout phải chạy được cả khi token hết hạn)
                        .requestMatchers("/api/auth/me", "/api/auth/password").authenticated()
                        .requestMatchers("/api/auth/**").permitAll()

                        // Public: xem tour, danh mục, ảnh upload, giỏ tour (Session), gửi liên hệ
                        .requestMatchers(HttpMethod.GET, "/api/tours/**", "/api/categories/**", "/uploads/**").permitAll()
                        .requestMatchers("/api/cart/**").permitAll()
                        .requestMatchers(HttpMethod.POST, "/api/contacts").permitAll()
                        // Trợ lý AI và ghi nhận hành vi người dùng: công khai (có giới hạn tốc độ theo IP)
                        .requestMatchers(HttpMethod.GET, "/api/ai/status").permitAll()
                        .requestMatchers(HttpMethod.POST, "/api/ai/chat", "/api/tracking/events").permitAll()
                        // Webhook ngân hàng: xác thực bằng API key riêng trong controller, không dùng JWT
                        .requestMatchers(HttpMethod.POST, "/api/payments/webhook").permitAll()

                        // Admin
                        .requestMatchers("/api/admin/**").hasAuthority("ROLE_ADMIN")

                        // Đặt tour, lịch sử đơn, hủy đơn: Customer hoặc Admin đã đăng nhập
                        .requestMatchers("/api/bookings/**", "/api/payments/**")
                        .hasAnyAuthority("ROLE_CUSTOMER", "ROLE_ADMIN")

                        .anyRequest().authenticated())
                .addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class);
        return http.build();
    }

    /** Filter đã nằm trong chuỗi Spring Security; tắt đăng ký lần hai ở servlet container. */
    @Bean
    public FilterRegistrationBean<JwtAuthFilter> jwtAuthFilterRegistration(JwtAuthFilter filter) {
        FilterRegistrationBean<JwtAuthFilter> registration = new FilterRegistrationBean<>(filter);
        registration.setEnabled(false);
        return registration;
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration cfg = new CorsConfiguration();
        cfg.setAllowedOrigins(props.cors().allowedOrigins());
        cfg.setAllowedMethods(List.of("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"));
        cfg.setAllowedHeaders(List.of("*"));
        cfg.setExposedHeaders(List.of("Retry-After"));
        cfg.setAllowCredentials(true); // cần cho cookie JSESSIONID của Session Cart
        cfg.setMaxAge(3600L);
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/api/**", cfg);
        return source;
    }
}
