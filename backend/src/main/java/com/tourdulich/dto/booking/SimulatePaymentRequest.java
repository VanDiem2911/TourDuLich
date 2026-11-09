package com.tourdulich.dto.booking;

import jakarta.validation.constraints.NotNull;

public record SimulatePaymentRequest(@NotNull(message = "Thiếu mã đơn đặt tour") Long bookingId) {
}
