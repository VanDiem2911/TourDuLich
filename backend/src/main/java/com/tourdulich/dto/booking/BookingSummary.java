package com.tourdulich.dto.booking;

import com.tourdulich.entity.enums.BookingStatus;
import com.tourdulich.entity.enums.PaymentStatus;

import java.time.LocalDateTime;

/** customerName/customerEmail chỉ có ở phía admin (null thì không xuất hiện trong JSON). */
public record BookingSummary(
        Long id,
        String bookingCode,
        LocalDateTime createdAt,
        long totalAmount,
        PaymentStatus paymentStatus,
        BookingStatus bookingStatus,
        int itemCount,
        String firstTourName,
        String firstTourImage,
        String customerName,
        String customerEmail) {
}
