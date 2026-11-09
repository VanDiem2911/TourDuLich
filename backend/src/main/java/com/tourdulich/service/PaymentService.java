package com.tourdulich.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.tourdulich.config.AppProperties;
import com.tourdulich.dto.booking.PaymentInfo;
import com.tourdulich.dto.booking.WebhookPayload;
import com.tourdulich.entity.Booking;
import com.tourdulich.entity.PaymentTransaction;
import com.tourdulich.entity.enums.BookingStatus;
import com.tourdulich.entity.enums.MatchStatus;
import com.tourdulich.entity.enums.PaymentMethod;
import com.tourdulich.entity.enums.PaymentStatus;
import com.tourdulich.entity.enums.Role;
import com.tourdulich.exception.ApiException;
import com.tourdulich.repository.BookingRepository;
import com.tourdulich.repository.PaymentTransactionRepository;
import com.tourdulich.security.UserPrincipal;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionTemplate;

import java.math.BigDecimal;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.time.LocalDateTime;
import java.time.OffsetDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.UUID;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/** Thông tin chuyển khoản QR, thanh toán giả lập (demo) và webhook ngân hàng kiểu SePay. */
@Slf4j
@Service
@RequiredArgsConstructor
public class PaymentService {

    private static final ZoneId VN = ZoneId.of("Asia/Ho_Chi_Minh");
    private static final Pattern PAYMENT_CODE = Pattern.compile("TOUR[A-Z0-9]{6}");
    private static final DateTimeFormatter SEPAY_TIME = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    /** Kết quả xử lý webhook: duplicate=true nếu giao dịch đã nhận trước đó. */
    public record WebhookResult(boolean success, String status) {
    }

    private final BookingRepository bookingRepository;
    private final PaymentTransactionRepository transactionRepository;
    private final BookingService bookingService;
    private final MailService mailService;
    private final AppProperties props;
    private final ObjectMapper objectMapper;
    private final PlatformTransactionManager txManager;

    // ------------------------------------------------------------------ Thông tin thanh toán

    @Transactional(readOnly = true)
    public PaymentInfo paymentInfo(Long userId, Long bookingId) {
        Booking b = bookingRepository.findWithUserByIdAndUserId(bookingId, userId)
                .orElseThrow(() -> ApiException.notFound(BookingService.ERR_NOT_FOUND));
        return toInfo(b);
    }

    private PaymentInfo toInfo(Booking b) {
        AppProperties.Payment p = props.payment();
        long amount = com.tourdulich.util.Money.vnd(b.getTotalAmount());
        String content = b.getPaymentCode();
        String qr = "https://img.vietqr.io/image/" + p.bankCode() + "-" + p.accountNumber() + "-compact2.png"
                + "?amount=" + amount
                + "&addInfo=" + encode(content)
                + "&accountName=" + encode(p.accountName());
        return new PaymentInfo(b.getId(), b.getBookingCode(), amount, b.getPaymentCode(),
                p.bankName(), p.accountNumber(), p.accountName(), content, qr,
                b.getPaymentStatus(), b.getBookingStatus(), b.getPaidAt(), p.simulateEnabled());
    }

    private static String encode(String s) {
        return URLEncoder.encode(s == null ? "" : s, StandardCharsets.UTF_8).replace("+", "%20");
    }

    // ------------------------------------------------------------------ Giả lập thanh toán

    @Transactional
    public PaymentInfo simulate(UserPrincipal principal, Long bookingId) {
        if (!props.payment().simulateEnabled()) {
            throw ApiException.forbidden("Chức năng thanh toán giả lập đang bị tắt!");
        }
        Booking b = bookingRepository.lockById(bookingId)
                .filter(x -> principal.role() == Role.ROLE_ADMIN || x.getUser().getId().equals(principal.id()))
                .orElseThrow(() -> ApiException.notFound(BookingService.ERR_NOT_FOUND));
        if (b.getBookingStatus() == BookingStatus.CANCELLED || b.getPaymentStatus() == PaymentStatus.REFUNDED) {
            throw ApiException.conflict("Không thể thanh toán cho đơn đặt tour này!");
        }
        if (b.getPaymentStatus() == PaymentStatus.PAID) {
            throw ApiException.conflict("Đơn đặt tour này đã được thanh toán!");
        }
        PaymentTransaction tx = new PaymentTransaction();
        tx.setTransactionRef("SIM-" + UUID.randomUUID().toString().replace("-", "").substring(0, 16).toUpperCase());
        tx.setGateway("SIMULATOR");
        tx.setBookingId(b.getId());
        tx.setAmount(b.getTotalAmount());
        tx.setContent(b.getPaymentCode());
        tx.setAccountNumber(props.payment().accountNumber());
        tx.setTransactionTime(LocalDateTime.now(VN));
        tx.setMatchStatus(MatchStatus.MATCHED);
        tx.setRawPayload("{\"simulated\":true}");
        transactionRepository.save(tx);

        bookingService.markPaid(b, PaymentMethod.BANK_QR, "Thanh toán giả lập (demo)");
        mailService.sendPaymentSuccess(b.getContactEmail(), b.getContactName(), b.getBookingCode());
        return toInfo(b);
    }

    // ------------------------------------------------------------------ Webhook

    /** Kiểm tra header "Authorization: Apikey <khóa>" (so sánh thời gian hằng định). */
    public void verifyWebhookKey(String authorization) {
        String key = props.payment().webhookKey();
        if (key == null || key.isBlank() || authorization == null) {
            throw ApiException.unauthorized("Khóa xác thực webhook không hợp lệ");
        }
        String prefix = "apikey ";
        if (authorization.length() <= prefix.length()
                || !authorization.regionMatches(true, 0, prefix, 0, prefix.length())) {
            throw ApiException.unauthorized("Khóa xác thực webhook không hợp lệ");
        }
        String given = authorization.substring(prefix.length()).trim();
        if (!MessageDigest.isEqual(given.getBytes(StandardCharsets.UTF_8), key.getBytes(StandardCharsets.UTF_8))) {
            log.warn("Webhook bị từ chối: sai API key");
            throw ApiException.unauthorized("Khóa xác thực webhook không hợp lệ");
        }
    }

    public WebhookResult handleWebhook(WebhookPayload payload) {
        if (payload == null || payload.id() == null || payload.id().isBlank() || payload.transferAmount() == null
                || payload.transferAmount().signum() <= 0) {
            throw ApiException.badRequest("Payload webhook thiếu id hoặc transferAmount");
        }
        if (payload.id().length() > 100) {
            throw ApiException.badRequest("Mã giao dịch quá dài");
        }
        if (transactionRepository.existsByTransactionRef(payload.id())) {
            return new WebhookResult(true, "DUPLICATE");
        }
        try {
            MatchStatus status = new TransactionTemplate(txManager).execute(s -> processWebhook(payload));
            return new WebhookResult(true, status.name());
        } catch (DataIntegrityViolationException dup) {
            // Hai webhook cùng id đến đồng thời: unique key chặn bản thứ hai
            return new WebhookResult(true, "DUPLICATE");
        }
    }

    private MatchStatus processWebhook(WebhookPayload p) {
        String content = p.content() == null ? "" : p.content();
        Booking booking = null;
        Matcher m = PAYMENT_CODE.matcher(content.toUpperCase());
        if (m.find()) {
            booking = bookingRepository.findWithUserByPaymentCode(m.group())
                    .flatMap(b -> bookingRepository.lockById(b.getId()))
                    .orElse(null);
        }

        MatchStatus status;
        if (booking == null) {
            status = MatchStatus.UNMATCHED;
        } else if (booking.getBookingStatus() == BookingStatus.CANCELLED
                || booking.getPaymentStatus() == PaymentStatus.REFUNDED) {
            status = MatchStatus.ORDER_CANCELLED;
        } else if (booking.getPaymentStatus() == PaymentStatus.PAID) {
            status = MatchStatus.OVERPAID; // đã thanh toán rồi mà còn nhận thêm tiền: cần đối soát tay
        } else {
            int cmp = p.transferAmount().compareTo(booking.getTotalAmount());
            status = cmp < 0 ? MatchStatus.UNDERPAID : (cmp > 0 ? MatchStatus.OVERPAID : MatchStatus.MATCHED);
        }

        PaymentTransaction tx = new PaymentTransaction();
        tx.setTransactionRef(p.id());
        tx.setGateway(truncate(p.gateway(), 50));
        tx.setBookingId(booking == null ? null : booking.getId());
        tx.setAmount(p.transferAmount());
        tx.setContent(truncate(content, 500));
        tx.setAccountNumber(truncate(p.accountNumber(), 50));
        tx.setTransactionTime(parseTime(p.transactionDate()));
        tx.setMatchStatus(status);
        tx.setRawPayload(toJson(p));
        transactionRepository.saveAndFlush(tx);

        boolean paysBooking = booking != null && booking.getPaymentStatus() == PaymentStatus.UNPAID
                && booking.getBookingStatus() != BookingStatus.CANCELLED
                && (status == MatchStatus.MATCHED || (status == MatchStatus.OVERPAID));
        if (paysBooking) {
            bookingService.markPaid(booking, PaymentMethod.BANK_QR, "Chuyển khoản QR, mã GD " + p.id());
            mailService.sendPaymentSuccess(booking.getContactEmail(), booking.getContactName(),
                    booking.getBookingCode());
        }
        log.info("Webhook {}: {} (đơn {})", p.id(), status, booking == null ? "-" : booking.getBookingCode());
        return status;
    }

    private static String truncate(String s, int max) {
        return s == null ? null : (s.length() > max ? s.substring(0, max) : s);
    }

    private String toJson(WebhookPayload p) {
        try {
            return objectMapper.writeValueAsString(p);
        } catch (JsonProcessingException e) {
            return null;
        }
    }

    private static LocalDateTime parseTime(String s) {
        if (s == null || s.isBlank()) {
            return LocalDateTime.now(VN);
        }
        try {
            return LocalDateTime.parse(s.trim(), SEPAY_TIME);
        } catch (Exception ignored) {
            // thử ISO-8601
        }
        try {
            return LocalDateTime.parse(s.trim());
        } catch (Exception ignored) {
            // thử có offset
        }
        try {
            return OffsetDateTime.parse(s.trim()).atZoneSameInstant(VN).toLocalDateTime();
        } catch (Exception ignored) {
            return LocalDateTime.now(VN);
        }
    }
}
