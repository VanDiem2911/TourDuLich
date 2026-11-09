package com.tourdulich.controller.admin;

import com.tourdulich.dto.admin.BookingPaymentRequest;
import com.tourdulich.dto.admin.BookingStatusRequest;
import com.tourdulich.dto.booking.BookingDetail;
import com.tourdulich.dto.booking.BookingSummary;
import com.tourdulich.dto.common.PageResponse;
import com.tourdulich.entity.enums.BookingStatus;
import com.tourdulich.entity.enums.PaymentStatus;
import com.tourdulich.service.AdminBookingService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;

@RestController
@RequestMapping("/api/admin/bookings")
@RequiredArgsConstructor
public class AdminBookingController {

    private final AdminBookingService service;

    @GetMapping
    public PageResponse<BookingSummary> list(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) BookingStatus bookingStatus,
            @RequestParam(required = false) PaymentStatus paymentStatus,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to) {
        return service.list(page, size, keyword, bookingStatus, paymentStatus, from, to);
    }

    @GetMapping("/{id}")
    public BookingDetail get(@PathVariable Long id) {
        return service.get(id);
    }

    @PutMapping("/{id}/status")
    public BookingDetail updateStatus(@PathVariable Long id, @Valid @RequestBody BookingStatusRequest req) {
        return service.updateStatus(id, req);
    }

    @PutMapping("/{id}/payment")
    public BookingDetail updatePayment(@PathVariable Long id, @Valid @RequestBody BookingPaymentRequest req) {
        return service.updatePayment(id, req);
    }
}
