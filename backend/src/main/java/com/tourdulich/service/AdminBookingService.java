package com.tourdulich.service;

import com.tourdulich.dto.admin.BookingPaymentRequest;
import com.tourdulich.dto.admin.BookingStatusRequest;
import com.tourdulich.dto.booking.BookingDetail;
import com.tourdulich.dto.booking.BookingSummary;
import com.tourdulich.dto.common.PageResponse;
import com.tourdulich.entity.Booking;
import com.tourdulich.entity.enums.BookingStatus;
import com.tourdulich.entity.enums.PaymentMethod;
import com.tourdulich.entity.enums.PaymentStatus;
import com.tourdulich.exception.ApiException;
import com.tourdulich.repository.BookingRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.Map;

/** Quản lý và duyệt đơn đặt tour (UC-14). */
@Service
@RequiredArgsConstructor
public class AdminBookingService {

    private final BookingRepository bookingRepository;
    private final BookingService bookingService;
    private final BookingMapper mapper;
    private final MailService mailService;

    @Transactional(readOnly = true)
    public PageResponse<BookingSummary> list(int page, int size, String keyword, BookingStatus bookingStatus,
                                             PaymentStatus paymentStatus, LocalDate from, LocalDate to) {
        Page<Booking> result = bookingRepository.findAll(
                BookingSpecs.filter(null, keyword, bookingStatus, paymentStatus, from, to),
                com.tourdulich.util.Pages.of(page, size,
                        Sort.by(Sort.Order.desc("createdAt"), Sort.Order.desc("id"))));
        return PageResponse.of(result, mapper.toSummaries(result.getContent(), true));
    }

    @Transactional(readOnly = true)
    public BookingDetail get(Long id) {
        Booking b = bookingRepository.findWithUserById(id)
                .orElseThrow(() -> ApiException.notFound(BookingService.ERR_NOT_FOUND));
        return mapper.toDetail(b, true);
    }

    /** PENDING -> CONFIRMED -> COMPLETED; hủy được khi chưa COMPLETED (hoàn chỗ, PAID -> REFUNDED); không đi lùi. */
    @Transactional
    public BookingDetail updateStatus(Long id, BookingStatusRequest req) {
        Booking b = bookingRepository.lockById(id)
                .orElseThrow(() -> ApiException.notFound(BookingService.ERR_NOT_FOUND));
        BookingStatus from = b.getBookingStatus();
        BookingStatus to = req.status();
        boolean valid = (from == BookingStatus.PENDING && to == BookingStatus.CONFIRMED)
                || (from == BookingStatus.CONFIRMED && to == BookingStatus.COMPLETED)
                || ((from == BookingStatus.PENDING || from == BookingStatus.CONFIRMED) && to == BookingStatus.CANCELLED);
        if (!valid) {
            throw ApiException.badRequest("Luồng chuyển trạng thái đơn hàng không hợp lệ!");
        }
        if (to == BookingStatus.CANCELLED) {
            String reason = req.reason() == null || req.reason().isBlank() ? "Quản trị viên hủy đơn" : req.reason();
            bookingService.applyCancellation(b, reason);
            mailService.sendBookingCancelled(b.getContactEmail(), b.getContactName(), b.getBookingCode(), reason);
        } else {
            b.setBookingStatus(to);
            bookingRepository.save(b);
        }
        return mapper.toDetail(b, true);
    }

    /** Admin thu tiền tại văn phòng (OFFICE) hoặc bỏ đánh dấu đã thu. */
    @Transactional
    public BookingDetail updatePayment(Long id, BookingPaymentRequest req) {
        Booking b = bookingRepository.lockById(id)
                .orElseThrow(() -> ApiException.notFound(BookingService.ERR_NOT_FOUND));
        PaymentStatus target = req.paymentStatus();
        if (target == PaymentStatus.REFUNDED) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "Dữ liệu không hợp lệ",
                    Map.of("paymentStatus", "Chỉ chấp nhận UNPAID hoặc PAID (hoàn tiền tự động khi hủy đơn đã thanh toán)"));
        }
        if (b.getBookingStatus() == BookingStatus.CANCELLED || b.getPaymentStatus() == PaymentStatus.REFUNDED) {
            throw ApiException.conflict("Đơn đã bị hủy, không thể đổi trạng thái thanh toán!");
        }
        if (target == b.getPaymentStatus()) {
            return mapper.toDetail(b, true);
        }
        if (target == PaymentStatus.PAID) {
            bookingService.markPaid(b, PaymentMethod.OFFICE, "Thu tại văn phòng");
            mailService.sendPaymentSuccess(b.getContactEmail(), b.getContactName(), b.getBookingCode());
        } else {
            b.setPaymentStatus(PaymentStatus.UNPAID);
            b.setPaidAt(null);
            b.setPaymentMethod(null);
            b.setPaymentNote("Admin bỏ đánh dấu đã thanh toán");
            bookingRepository.save(b);
        }
        return mapper.toDetail(b, true);
    }
}
