package com.tourdulich.controller;

import com.tourdulich.dto.auth.*;
import com.tourdulich.security.UserPrincipal;
import com.tourdulich.service.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping("/register")
    public ResponseEntity<UserResponse> register(@Valid @RequestBody RegisterRequest req) {
        return ResponseEntity.status(HttpStatus.CREATED).body(authService.register(req));
    }

    @PostMapping("/login")
    public AuthResponse login(@Valid @RequestBody LoginRequest req) {
        return authService.login(req);
    }

    @PostMapping("/refresh")
    public AuthResponse refresh(@Valid @RequestBody RefreshRequest req) {
        return authService.refresh(req);
    }

    /**
     * JWT là stateless nên server không giữ phiên để hủy; client xóa token. Endpoint vẫn có để
     * client gọi thống nhất theo đặc tả, và là điểm mở rộng nếu sau này thêm danh sách thu hồi token.
     */
    @PostMapping("/logout")
    public ResponseEntity<Void> logout() {
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/me")
    public UserResponse me(@AuthenticationPrincipal UserPrincipal principal) {
        return authService.me(principal.id());
    }

    @PutMapping("/me")
    public UserResponse updateProfile(@AuthenticationPrincipal UserPrincipal principal,
                                      @Valid @RequestBody UpdateProfileRequest req) {
        return authService.updateProfile(principal.id(), req);
    }

    @PutMapping("/password")
    public ResponseEntity<Void> changePassword(@AuthenticationPrincipal UserPrincipal principal,
                                               @Valid @RequestBody ChangePasswordRequest req) {
        authService.changePassword(principal.id(), req);
        return ResponseEntity.noContent().build();
    }
}
