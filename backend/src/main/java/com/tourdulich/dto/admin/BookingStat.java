package com.tourdulich.dto.admin;

import com.tourdulich.entity.enums.BookingStatus;
import com.tourdulich.entity.enums.PaymentStatus;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/** Dòng dữ liệu thô dùng gom thống kê doanh thu theo tháng. */
public record BookingStat(LocalDateTime createdAt, BigDecimal totalAmount,
                          PaymentStatus paymentStatus, BookingStatus bookingStatus) {
}
