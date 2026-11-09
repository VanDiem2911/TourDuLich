package com.tourdulich.dto.admin;

import com.tourdulich.entity.enums.BookingStatus;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record BookingStatusRequest(
        @NotNull(message = "Vui lòng chọn trạng thái đơn") BookingStatus status,
        @Size(max = 500, message = "Lý do tối đa 500 ký tự") String reason) {
}
