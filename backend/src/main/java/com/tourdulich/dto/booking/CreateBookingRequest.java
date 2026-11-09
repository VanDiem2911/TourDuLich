package com.tourdulich.dto.booking;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public record CreateBookingRequest(
        @NotBlank(message = "Vui lòng nhập họ tên người liên hệ")
        @Size(max = 100, message = "Họ tên tối đa 100 ký tự")
        String contactName,

        @NotBlank(message = "Vui lòng nhập số điện thoại")
        @Pattern(regexp = "^0\\d{9}$", message = "Số điện thoại phải gồm 10 chữ số, bắt đầu bằng 0")
        String contactPhone,

        @NotBlank(message = "Vui lòng nhập email")
        @Email(message = "Email không đúng định dạng")
        @Size(max = 150, message = "Email tối đa 150 ký tự")
        String contactEmail,

        @Size(max = 1000, message = "Yêu cầu đặc biệt tối đa 1000 ký tự")
        String specialRequest) {
}
