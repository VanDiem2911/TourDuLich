package com.tourdulich.dto.admin;

import com.tourdulich.entity.enums.PaymentStatus;
import jakarta.validation.constraints.NotNull;

public record BookingPaymentRequest(
        @NotNull(message = "Vui lòng chọn trạng thái thanh toán") PaymentStatus paymentStatus) {
}
