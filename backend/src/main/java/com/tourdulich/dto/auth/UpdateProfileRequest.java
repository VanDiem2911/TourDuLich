package com.tourdulich.dto.auth;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public record UpdateProfileRequest(
        @NotBlank(message = "Vui lòng nhập họ tên")
        @Size(max = 100, message = "Họ tên tối đa 100 ký tự")
        String fullName,

        @Pattern(regexp = "^$|^0\\d{9}$", message = "Số điện thoại phải gồm 10 chữ số, bắt đầu bằng 0")
        String phone,

        @Size(max = 255, message = "Địa chỉ tối đa 255 ký tự")
        String address) {
}
