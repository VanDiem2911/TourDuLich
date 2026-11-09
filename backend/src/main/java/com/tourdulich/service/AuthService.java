package com.tourdulich.service;

import com.tourdulich.dto.auth.*;
import com.tourdulich.entity.User;
import com.tourdulich.entity.enums.Role;
import com.tourdulich.entity.enums.UserStatus;
import com.tourdulich.exception.ApiException;
import com.tourdulich.repository.UserRepository;
import com.tourdulich.security.JwtService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Locale;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class AuthService {

    private static final String BAD_CREDENTIALS = "Email hoặc mật khẩu không đúng!";

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final MailService mailService;

    @Transactional
    public UserResponse register(RegisterRequest req) {
        if (!req.password().equals(req.confirmPassword())) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "Dữ liệu không hợp lệ",
                    Map.of("confirmPassword", "Xác nhận mật khẩu không khớp"));
        }
        String email = normalizeEmail(req.email());
        if (userRepository.existsByEmail(email)) {
            throw new ApiException(HttpStatus.CONFLICT, "Email này đã được đăng ký tài khoản!",
                    Map.of("email", "Email này đã được đăng ký tài khoản!"));
        }

        User user = new User();
        user.setFullName(req.fullName().trim());
        user.setEmail(email);
        user.setPhone(blankToNull(req.phone()));
        user.setAddress(blankToNull(req.address()));
        user.setPasswordHash(passwordEncoder.encode(req.password()));
        user.setRole(Role.ROLE_CUSTOMER);
        user.setStatus(UserStatus.ACTIVE);
        userRepository.save(user);

        mailService.sendRegistrationSuccess(user);
        return UserResponse.from(user);
    }

    @Transactional(readOnly = true)
    public AuthResponse login(LoginRequest req) {
        User user = userRepository.findByEmail(normalizeEmail(req.email()))
                .orElseThrow(() -> ApiException.unauthorized(BAD_CREDENTIALS));
        if (!passwordEncoder.matches(req.password(), user.getPasswordHash())) {
            throw ApiException.unauthorized(BAD_CREDENTIALS);
        }
        // Chỉ báo "bị khóa" sau khi đã đúng mật khẩu để không lộ email nào tồn tại
        if (user.getStatus() != UserStatus.ACTIVE) {
            throw ApiException.forbidden("Tài khoản của bạn đã bị khóa. Vui lòng liên hệ quản trị viên!");
        }
        return issueTokens(user);
    }

    @Transactional(readOnly = true)
    public AuthResponse refresh(RefreshRequest req) {
        Long userId = jwtService.parseUserId(req.refreshToken(), JwtService.TYPE_REFRESH)
                .orElseThrow(() -> ApiException.unauthorized("Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại"));
        User user = userRepository.findById(userId)
                .filter(u -> u.getStatus() == UserStatus.ACTIVE)
                .orElseThrow(() -> ApiException.unauthorized("Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại"));
        return issueTokens(user);
    }

    @Transactional(readOnly = true)
    public UserResponse me(Long userId) {
        return userRepository.findById(userId)
                .map(UserResponse::from)
                .orElseThrow(() -> ApiException.unauthorized("Vui lòng đăng nhập để tiếp tục"));
    }

    @Transactional
    public UserResponse updateProfile(Long userId, UpdateProfileRequest req) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> ApiException.unauthorized("Vui lòng đăng nhập để tiếp tục"));
        user.setFullName(req.fullName().trim());
        user.setPhone(blankToNull(req.phone()));
        user.setAddress(blankToNull(req.address()));
        return UserResponse.from(userRepository.save(user));
    }

    @Transactional
    public void changePassword(Long userId, ChangePasswordRequest req) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> ApiException.unauthorized("Vui lòng đăng nhập để tiếp tục"));
        if (!passwordEncoder.matches(req.currentPassword(), user.getPasswordHash())) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "Dữ liệu không hợp lệ",
                    Map.of("currentPassword", "Mật khẩu hiện tại không đúng"));
        }
        if (req.currentPassword().equals(req.newPassword())) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "Dữ liệu không hợp lệ",
                    Map.of("newPassword", "Mật khẩu mới phải khác mật khẩu hiện tại"));
        }
        user.setPasswordHash(passwordEncoder.encode(req.newPassword()));
        userRepository.save(user);
    }

    private AuthResponse issueTokens(User user) {
        return new AuthResponse(
                jwtService.generateAccessToken(user),
                jwtService.generateRefreshToken(user),
                "Bearer",
                jwtService.getAccessExpirationSeconds(),
                UserResponse.from(user));
    }

    private static String normalizeEmail(String email) {
        return email.trim().toLowerCase(Locale.ROOT);
    }

    private static String blankToNull(String s) {
        return (s == null || s.isBlank()) ? null : s.trim();
    }
}
