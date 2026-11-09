package com.tourdulich.config;

import com.tourdulich.entity.User;
import com.tourdulich.entity.enums.Role;
import com.tourdulich.entity.enums.UserStatus;
import com.tourdulich.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.core.annotation.Order;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

/** Tạo tài khoản Admin mặc định ở lần chạy đầu (mật khẩu được BCrypt, không lưu plain text). */
@Slf4j
@Order(1)
@Component
@RequiredArgsConstructor
public class DataInitializer implements CommandLineRunner {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final AppProperties props;

    @Override
    public void run(String... args) {
        AppProperties.Seed seed = props.seed();
        String email = seed.adminEmail().trim().toLowerCase();
        if (userRepository.existsByEmail(email)) {
            return;
        }
        User admin = new User();
        admin.setFullName(seed.adminFullName());
        admin.setEmail(email);
        admin.setPasswordHash(passwordEncoder.encode(seed.adminPassword()));
        admin.setRole(Role.ROLE_ADMIN);
        admin.setStatus(UserStatus.ACTIVE);
        userRepository.save(admin);
        log.warn("Đã tạo tài khoản Admin mặc định: {} - hãy đổi mật khẩu (ADMIN_PASSWORD) khi triển khai thật!", email);
    }
}
