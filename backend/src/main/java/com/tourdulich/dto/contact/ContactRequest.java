package com.tourdulich.dto.contact;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public record ContactRequest(
        @NotBlank(message = "Vui lòng nhập họ tên")
        @Size(max = 100, message = "Họ tên tối đa 100 ký tự")
        String fullName,

        @NotBlank(message = "Vui lòng nhập email")
        @Email(message = "Email không đúng định dạng")
        @Size(max = 150, message = "Email tối đa 150 ký tự")
        String email,

        @Pattern(regexp = "^$|^0\\d{9}$", message = "Số điện thoại phải gồm 10 chữ số, bắt đầu bằng 0")
        String phone,

        @NotBlank(message = "Vui lòng nhập tiêu đề")
        @Size(max = 200, message = "Tiêu đề tối đa 200 ký tự")
        String subject,

        @NotBlank(message = "Vui lòng nhập nội dung liên hệ")
        @Size(min = 10, max = 5000, message = "Nội dung liên hệ phải từ 10 đến 5000 ký tự")
        String message) {
}
