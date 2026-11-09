package com.tourdulich.dto.booking;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record CancelBookingRequest(
        @NotBlank(message = "Vui lòng nhập lý do hủy đơn")
        @Size(max = 500, message = "Lý do hủy tối đa 500 ký tự")
        String reason) {
}
