package com.tourdulich.dto.auth;

import jakarta.validation.constraints.NotBlank;

public record LoginRequest(
        @NotBlank(message = "Vui lòng nhập đầy đủ Email và Mật khẩu") String email,
        @NotBlank(message = "Vui lòng nhập đầy đủ Email và Mật khẩu") String password) {
}
