package com.tourdulich.dto.auth;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record ChangePasswordRequest(
        @NotBlank(message = "Vui lòng nhập mật khẩu hiện tại") String currentPassword,

        @NotBlank(message = "Vui lòng nhập mật khẩu mới")
        @Size(min = 6, max = 72, message = "Mật khẩu phải từ 6 đến 72 ký tự")
        String newPassword) {
}
