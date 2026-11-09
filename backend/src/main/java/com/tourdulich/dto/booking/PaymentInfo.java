package com.tourdulich.dto.booking;

import com.tourdulich.entity.enums.BookingStatus;
import com.tourdulich.entity.enums.PaymentStatus;

import java.time.LocalDateTime;

public record PaymentInfo(
        Long bookingId,
        String bookingCode,
        long amount,
        String paymentCode,
        String bankName,
        String accountNumber,
        String accountName,
        String transferContent,
        String qrUrl,
        PaymentStatus paymentStatus,
        BookingStatus bookingStatus,
        LocalDateTime paidAt,
        boolean simulateEnabled) {
}
