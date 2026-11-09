package com.tourdulich.security;

import com.tourdulich.entity.enums.UserStatus;
import com.tourdulich.repository.UserRepository;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.List;

/**
 * Đọc "Authorization: Bearer ...", kiểm tra chữ ký + thời hạn, nạp người dùng từ DB.
 * Tài khoản bị khóa (INACTIVE) thì token cũ cũng không còn tác dụng.
 */
@Component
@RequiredArgsConstructor
public class JwtAuthFilter extends OncePerRequestFilter {

    private static final String BEARER = "Bearer ";

    private final JwtService jwtService;
    private final UserRepository userRepository;

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain chain)
            throws ServletException, IOException {
        String header = request.getHeader("Authorization");
        if (header != null && header.startsWith(BEARER)
                && SecurityContextHolder.getContext().getAuthentication() == null) {
            String token = header.substring(BEARER.length()).trim();
            jwtService.parseUserId(token, JwtService.TYPE_ACCESS)
                    .flatMap(userRepository::findById)
                    .filter(user -> user.getStatus() == UserStatus.ACTIVE)
                    .ifPresent(user -> {
                        UserPrincipal principal = UserPrincipal.from(user);
                        var auth = new UsernamePasswordAuthenticationToken(
                                principal, null, List.of(new SimpleGrantedAuthority(user.getRole().name())));
                        auth.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                        SecurityContextHolder.getContext().setAuthentication(auth);
                    });
        }
        chain.doFilter(request, response);
    }
}
