package com.tourdulich.dto.auth;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public record RegisterRequest(
        @NotBlank(message = "Vui lòng nhập họ tên")
        @Size(max = 100, message = "Họ tên tối đa 100 ký tự")
        String fullName,

        @NotBlank(message = "Vui lòng nhập email")
        @Email(message = "Email không đúng định dạng")
        @Size(max = 150, message = "Email tối đa 150 ký tự")
        String email,

        @Pattern(regexp = "^$|^0\\d{9}$", message = "Số điện thoại phải gồm 10 chữ số, bắt đầu bằng 0")
        String phone,

        @Size(max = 255, message = "Địa chỉ tối đa 255 ký tự")
        String address,

        // BCrypt chỉ xét tối đa 72 byte nên giới hạn độ dài tại đây
        @NotBlank(message = "Vui lòng nhập mật khẩu")
        @Size(min = 6, max = 72, message = "Mật khẩu phải từ 6 đến 72 ký tự")
        String password,

        @NotBlank(message = "Vui lòng xác nhận mật khẩu")
        String confirmPassword) {
}
