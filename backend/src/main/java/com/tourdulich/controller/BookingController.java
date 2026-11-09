package com.tourdulich.controller;

import com.tourdulich.dto.booking.*;
import com.tourdulich.dto.common.PageResponse;
import com.tourdulich.entity.enums.BookingStatus;
import com.tourdulich.security.UserPrincipal;
import com.tourdulich.service.BookingService;
import com.tourdulich.service.CartService;
import com.tourdulich.service.PaymentService;
import jakarta.servlet.http.HttpSession;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

/** Đặt tour, đơn của tôi, hủy đơn, thông tin thanh toán (Customer hoặc Admin đã đăng nhập). */
@RestController
@RequestMapping("/api/bookings")
@RequiredArgsConstructor
public class BookingController {

    private final BookingService bookingService;
    private final CartService cartService;
    private final PaymentService paymentService;

    @PostMapping
    public ResponseEntity<BookingDetail> create(@AuthenticationPrincipal UserPrincipal principal,
                                                @Valid @RequestBody CreateBookingRequest req,
                                                HttpSession session) {
        BookingDetail detail = bookingService.create(principal.id(), cartService.lines(session), req);
        cartService.clear(session); // chỉ chạy khi transaction đã commit thành công
        return ResponseEntity.status(HttpStatus.CREATED).body(detail);
    }

    @GetMapping("/my-bookings")
    public PageResponse<BookingSummary> myBookings(@AuthenticationPrincipal UserPrincipal principal,
                                                   @RequestParam(defaultValue = "1") int page,
                                                   @RequestParam(defaultValue = "10") int size,
                                                   @RequestParam(required = false) BookingStatus status) {
        return bookingService.myBookings(principal.id(), page, size, status);
    }

    @GetMapping("/my-bookings/{id}")
    public BookingDetail myBooking(@AuthenticationPrincipal UserPrincipal principal, @PathVariable Long id) {
        return bookingService.myBooking(principal.id(), id);
    }

    @PutMapping("/{id}/cancel")
    public BookingDetail cancel(@AuthenticationPrincipal UserPrincipal principal, @PathVariable Long id,
                                @Valid @RequestBody CancelBookingRequest req) {
        return bookingService.cancelMine(principal.id(), id, req.reason());
    }

    @GetMapping("/{id}/payment-info")
    public PaymentInfo paymentInfo(@AuthenticationPrincipal UserPrincipal principal, @PathVariable Long id) {
        return paymentService.paymentInfo(principal.id(), id);
    }
}
