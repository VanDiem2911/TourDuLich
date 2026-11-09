package com.tourdulich.service;

import com.tourdulich.dto.booking.BookingDetail;
import com.tourdulich.dto.booking.BookingSummary;
import com.tourdulich.dto.booking.CreateBookingRequest;
import com.tourdulich.dto.common.PageResponse;
import com.tourdulich.entity.Booking;
import com.tourdulich.entity.BookingItem;
import com.tourdulich.entity.Tour;
import com.tourdulich.entity.enums.BookingStatus;
import com.tourdulich.entity.enums.PaymentStatus;
import com.tourdulich.entity.enums.TourStatus;
import com.tourdulich.exception.ApiException;
import com.tourdulich.repository.BookingRepository;
import com.tourdulich.repository.TourRepository;
import com.tourdulich.repository.UserRepository;
import com.tourdulich.util.Money;
import com.tourdulich.util.Pages;
import com.tourdulich.util.Texts;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionTemplate;

import java.math.BigDecimal;
import java.security.SecureRandom;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.concurrent.locks.ReentrantLock;

/** Đặt tour từ giỏ, xem đơn của tôi, hủy đơn; kèm các hàm dùng chung cho admin (hoàn chỗ khi hủy). */
@Slf4j
@Service
@RequiredArgsConstructor
public class BookingService {

    private static final ZoneId VN = ZoneId.of("Asia/Ho_Chi_Minh");
    private static final String CODE_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    private static final SecureRandom RANDOM = new SecureRandom();

    public static final String ERR_NOT_FOUND = "Không tìm thấy đơn đặt tour";
    static final String ERR_SEATS = "Rất tiếc, số chỗ trống của tour không còn đủ đáp ứng. Vui lòng kiểm tra lại số vé!";

    private final BookingRepository bookingRepository;
    private final TourRepository tourRepository;
    private final UserRepository userRepository;
    private final BookingMapper mapper;
    private final MailService mailService;
    private final PlatformTransactionManager txManager;

    /** Tuần tự hóa việc sinh mã đơn trong 1 instance; khóa dòng tour (PESSIMISTIC_WRITE) lo phần tranh chấp chỗ. */
    private final ReentrantLock createLock = new ReentrantLock();

    // ------------------------------------------------------------------ Tạo đơn

    /** Tạo đơn từ giỏ trong 1 transaction. Giỏ (Session) do controller xóa sau khi thành công. */
    public BookingDetail create(Long userId, Map<Long, CartService.CartLine> lines, CreateBookingRequest req) {
        if (lines == null || lines.isEmpty()) {
            throw ApiException.badRequest("Phiếu đặt tạm đang trống, vui lòng chọn tour trước khi đặt!");
        }
        BookingDetail detail;
        createLock.lock();
        try {
            detail = new TransactionTemplate(txManager).execute(status -> doCreate(userId, lines, req));
        } finally {
            createLock.unlock();
        }
        mailService.sendBookingCreated(detail.contactEmail(), detail.contactName(), detail.bookingCode(),
                detail.totalAmount());
        return detail;
    }

    private BookingDetail doCreate(Long userId, Map<Long, CartService.CartLine> lines, CreateBookingRequest req) {
        // Khóa ghi các tour theo thứ tự id để tránh deadlock, rồi kiểm tra lại chỗ trống
        List<Long> ids = lines.keySet().stream().sorted().toList();
        Map<Long, Tour> tours = new HashMap<>();
        tourRepository.lockAllByIdIn(ids).forEach(t -> tours.put(t.getId(), t));

        Booking booking = new Booking();
        booking.setUser(userRepository.getReferenceById(userId));
        booking.setContactName(req.contactName().trim());
        booking.setContactPhone(req.contactPhone().trim());
        booking.setContactEmail(req.contactEmail().trim());
        booking.setSpecialRequest(Texts.blankToNull(req.specialRequest()));
        booking.setBookingStatus(BookingStatus.PENDING);
        booking.setPaymentStatus(PaymentStatus.UNPAID);

        BigDecimal total = BigDecimal.ZERO;
        for (Map.Entry<Long, CartService.CartLine> e : lines.entrySet()) {
            Tour tour = tours.get(e.getKey());
            if (tour == null || tour.getStatus() != TourStatus.ACTIVE) {
                throw new ApiException(HttpStatus.CONFLICT, TourService.TOUR_NOT_FOUND
                        + " Vui lòng xóa tour đó khỏi phiếu đặt tạm.");
            }
            CartService.CartLine line = e.getValue();
            int tickets = line.adult() + line.child();
            if (line.adult() < 1 || line.child() < 0 || tickets > tour.getAvailableSeats()) {
                throw new ApiException(HttpStatus.CONFLICT, ERR_SEATS);
            }
            // Giá luôn lấy từ DB tại thời điểm đặt, không tin client
            BigDecimal childPrice = TourMapper.effectiveChildPrice(tour);
            BigDecimal subtotal = tour.getAdultPrice().multiply(BigDecimal.valueOf(line.adult()))
                    .add(childPrice.multiply(BigDecimal.valueOf(line.child())));
            total = total.add(subtotal);

            BookingItem item = new BookingItem();
            item.setTour(tour);
            item.setTourName(tour.getName());
            item.setDepartureDate(tour.getDepartureDate());
            item.setAdultPrice(tour.getAdultPrice());
            item.setChildPrice(childPrice);
            item.setAdultQuantity(line.adult());
            item.setChildQuantity(line.child());
            item.setSubtotal(subtotal);
            booking.addItem(item);

            tour.setAvailableSeats(tour.getAvailableSeats() - tickets);
        }
        booking.setTotalAmount(total);
        booking.setBookingCode(nextBookingCode());
        booking.setPaymentCode(nextPaymentCode());
        bookingRepository.saveAndFlush(booking);
        log.info("Tạo đơn {} cho user {} - tổng {}", booking.getBookingCode(), userId, Money.vnd(total));
        return mapper.toDetail(booking, booking.getItems(), false);
    }

    private String nextBookingCode() {
        String prefix = "BK-" + LocalDate.now(VN).format(DateTimeFormatter.BASIC_ISO_DATE) + "-";
        long n = bookingRepository.countByBookingCodeStartingWith(prefix) + 1;
        String code = prefix + String.format("%03d", n);
        while (bookingRepository.existsByBookingCode(code)) {
            n++;
            code = prefix + String.format("%03d", n);
        }
        return code;
    }

    private String nextPaymentCode() {
        for (int attempt = 0; attempt < 20; attempt++) {
            StringBuilder sb = new StringBuilder("TOUR");
            for (int i = 0; i < 6; i++) {
                sb.append(CODE_CHARS.charAt(RANDOM.nextInt(CODE_CHARS.length())));
            }
            String code = sb.toString();
            if (!bookingRepository.existsByPaymentCode(code)) {
                return code;
            }
        }
        throw new IllegalStateException("Không sinh được mã thanh toán duy nhất");
    }

    // ------------------------------------------------------------------ Đơn của tôi

    @Transactional(readOnly = true)
    public PageResponse<BookingSummary> myBookings(Long userId, int page, int size, BookingStatus status) {
        Page<Booking> result = bookingRepository.findAll(
                BookingSpecs.filter(userId, null, status, null, null, null),
                Pages.of(page, size, Sort.by(Sort.Order.desc("createdAt"), Sort.Order.desc("id"))));
        return PageResponse.of(result, mapper.toSummaries(result.getContent(), false));
    }

    @Transactional(readOnly = true)
    public BookingDetail myBooking(Long userId, Long id) {
        Booking b = bookingRepository.findWithUserByIdAndUserId(id, userId)
                .orElseThrow(() -> ApiException.notFound(ERR_NOT_FOUND));
        return mapper.toDetail(b, false);
    }

    @Transactional
    public BookingDetail cancelMine(Long userId, Long id, String reason) {
        Booking b = bookingRepository.lockById(id)
                .filter(x -> x.getUser().getId().equals(userId))
                .orElseThrow(() -> ApiException.notFound(ERR_NOT_FOUND));
        if (b.getBookingStatus() != BookingStatus.PENDING) {
            throw ApiException.conflict(
                    "Đơn đặt tour đã được xác nhận, không thể tự hủy trực tuyến. Quý khách vui lòng liên hệ bộ phận hỗ trợ!");
        }
        applyCancellation(b, reason);
        BookingDetail detail = mapper.toDetail(b, false);
        mailService.sendBookingCancelled(b.getContactEmail(), b.getContactName(), b.getBookingCode(), reason);
        return detail;
    }

    // ------------------------------------------------------------------ Dùng chung (khách + admin)

    /**
     * Hủy đơn: hoàn chỗ cho các tour (khóa ghi tour trước), đổi trạng thái CANCELLED, đã PAID thì REFUNDED.
     * Phải gọi trong transaction và booking đã được khóa (lockById).
     */
    public void applyCancellation(Booking b, String reason) {
        Map<Long, Integer> seats = new LinkedHashMap<>();
        for (BookingItem item : b.getItems()) {
            seats.merge(item.getTour().getId(), item.getAdultQuantity() + item.getChildQuantity(), Integer::sum);
        }
        if (!seats.isEmpty()) {
            for (Tour t : tourRepository.lockAllByIdIn(seats.keySet())) {
                int restored = t.getAvailableSeats() + seats.getOrDefault(t.getId(), 0);
                t.setAvailableSeats(Math.min(restored, t.getTotalSeats()));
            }
        }
        b.setBookingStatus(BookingStatus.CANCELLED);
        b.setCancelReason(reason == null || reason.isBlank() ? null : reason.trim());
        if (b.getPaymentStatus() == PaymentStatus.PAID) {
            b.setPaymentStatus(PaymentStatus.REFUNDED);
        }
        bookingRepository.save(b);
    }

    /** Ghi nhận đã thanh toán: PAID + thời điểm; đơn PENDING tự chuyển CONFIRMED. */
    public void markPaid(Booking b, com.tourdulich.entity.enums.PaymentMethod method, String note) {
        b.setPaymentStatus(PaymentStatus.PAID);
        b.setPaymentMethod(method);
        b.setPaidAt(LocalDateTime.now(VN));
        b.setPaymentNote(note);
        if (b.getBookingStatus() == BookingStatus.PENDING) {
            b.setBookingStatus(BookingStatus.CONFIRMED);
        }
        bookingRepository.save(b);
    }
}
