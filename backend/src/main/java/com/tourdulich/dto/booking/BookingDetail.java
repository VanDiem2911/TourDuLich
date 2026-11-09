package com.tourdulich.dto.booking;

import com.tourdulich.entity.enums.BookingStatus;
import com.tourdulich.entity.enums.PaymentMethod;
import com.tourdulich.entity.enums.PaymentStatus;

import java.time.LocalDateTime;
import java.util.List;

/** BookingSummary + thông tin liên hệ, thanh toán và danh sách tour. customerName/Email chỉ có ở admin. */
public record BookingDetail(
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
        String customerEmail,
        String contactName,
        String contactPhone,
        String contactEmail,
        String specialRequest,
        PaymentMethod paymentMethod,
        LocalDateTime paidAt,
        String cancelReason,
        boolean canCancel,
        List<BookingItemResponse> items) {
}
