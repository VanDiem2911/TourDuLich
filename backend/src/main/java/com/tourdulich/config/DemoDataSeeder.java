package com.tourdulich.config;

import com.tourdulich.entity.*;
import com.tourdulich.entity.enums.*;
import com.tourdulich.repository.*;
import com.tourdulich.service.TourMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.core.annotation.Order;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.support.TransactionTemplate;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.*;

/**
 * Dev/demo: tạo khách hàng, đơn đặt tour (rải 12 tháng gần nhất) và liên hệ mẫu để Dashboard có số liệu.
 * Chỉ chạy khi chưa có đơn nào và có dưới 3 khách hàng; tắt bằng app.seed.demo-data=false.
 * Mật khẩu khách demo: Demo@123. Dữ liệu nhất quán với nghiệp vụ (PAID chỉ với CONFIRMED/COMPLETED...).
 */
@Slf4j
@Order(3)
@Component
@RequiredArgsConstructor
public class DemoDataSeeder implements CommandLineRunner {

    private static final ZoneId VN = ZoneId.of("Asia/Ho_Chi_Minh");
    private static final String PASSWORD = "Demo@123";
    private static final String CODE_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    private static final int CUSTOMER_COUNT = 8;
    private static final int BOOKING_COUNT = 40;

    private static final String[] NAMES = {
            "Nguyễn Văn An", "Trần Thị Bích", "Lê Hoàng Cường", "Phạm Thu Dung",
            "Hoàng Minh Đức", "Vũ Thị Hà", "Đặng Quốc Huy", "Bùi Ngọc Lan"};
    private static final String[] ADDRESSES = {
            "12 Nguyễn Huệ, Quận 1, TP.HCM", "45 Lê Lợi, Hải Châu, Đà Nẵng", "88 Trần Phú, Ba Đình, Hà Nội",
            "7 Hùng Vương, Ninh Kiều, Cần Thơ", "23 Pasteur, Quận 3, TP.HCM", "101 Hai Bà Trưng, Hoàn Kiếm, Hà Nội",
            "56 Nguyễn Trãi, Thanh Xuân, Hà Nội", "9 Lý Thường Kiệt, Nha Trang, Khánh Hòa"};
    private static final String[] REQUESTS = {
            null, null, null, "Cần ghế gần cửa sổ", "Gia đình có người ăn chay", "Có trẻ nhỏ, cần ghế trẻ em",
            "Xuất hóa đơn VAT cho công ty", null};
    private static final String[] CANCEL_REASONS = {
            "Thay đổi lịch trình cá nhân", "Đặt nhầm ngày khởi hành", "Có việc đột xuất của gia đình",
            "Tìm được tour phù hợp hơn"};

    private final UserRepository userRepository;
    private final TourRepository tourRepository;
    private final BookingRepository bookingRepository;
    private final ContactRepository contactRepository;
    private final PaymentTransactionRepository transactionRepository;
    private final PasswordEncoder passwordEncoder;
    private final JdbcTemplate jdbc;
    private final PlatformTransactionManager txManager;
    private final AppProperties props;

    @Override
    public void run(String... args) {
        if (!props.seed().demoData()) {
            return;
        }
        if (bookingRepository.count() > 0 || userRepository.countByRole(Role.ROLE_CUSTOMER) >= 3) {
            return;
        }
        if (tourRepository.count() == 0) {
            log.info("Chưa có tour nào nên bỏ qua việc tạo đơn đặt tour mẫu.");
            return;
        }
        try {
            new TransactionTemplate(txManager).executeWithoutResult(s -> seed());
        } catch (Exception ex) {
            log.error("Tạo dữ liệu demo thất bại (đã rollback): {}", ex.getMessage(), ex);
        }
    }

    private void seed() {
        Random rnd = new Random(20260626L);
        LocalDateTime now = LocalDateTime.now(VN);

        List<User> customers = createCustomers(rnd, now);
        List<Tour> tours = tourRepository.findAll();
        // Mỗi tour chỉ dùng tối đa một nửa số chỗ còn lại cho đơn demo (không bao giờ trừ quá 0)
        Map<Long, Integer> budget = new HashMap<>();
        tours.forEach(t -> budget.put(t.getId(), Math.max(0, t.getAvailableSeats() / 2)));

        Map<String, Integer> codeCounter = new HashMap<>();
        Set<String> usedPaymentCodes = new HashSet<>();
        int created = 0;
        for (int i = 0; i < BOOKING_COUNT; i++) {
            int ageDays = Math.min(359, (i % 12) * 30 + rnd.nextInt(30));
            LocalDateTime createdAt = now.minusDays(ageDays).minusHours(rnd.nextInt(10)).minusMinutes(rnd.nextInt(60));
            User customer = customers.get(rnd.nextInt(customers.size()));
            createBooking(rnd, now, createdAt, ageDays, customer, tours, budget, codeCounter, usedPaymentCodes);
            created++;
        }
        tourRepository.saveAll(tours);
        int contacts = createContacts(now, customers);
        log.info("Đã tạo dữ liệu demo: {} khách hàng (mật khẩu {}), {} đơn đặt tour, {} liên hệ.",
                customers.size(), PASSWORD, created, contacts);
    }

    // ------------------------------------------------------------------ Khách hàng

    private List<User> createCustomers(Random rnd, LocalDateTime now) {
        List<User> list = new ArrayList<>();
        String hash = passwordEncoder.encode(PASSWORD);
        for (int i = 1; i <= CUSTOMER_COUNT; i++) {
            String email = "khachhang" + i + "@example.com";
            User u = userRepository.findByEmail(email).orElse(null);
            if (u == null) {
                u = new User();
                u.setFullName(NAMES[i - 1]);
                u.setEmail(email);
                u.setPhone(String.format("09%08d", 12345678 + i * 1111111));
                u.setAddress(ADDRESSES[i - 1]);
                u.setPasswordHash(hash);
                u.setRole(Role.ROLE_CUSTOMER);
                u.setStatus(UserStatus.ACTIVE);
                u = userRepository.saveAndFlush(u);
                LocalDateTime registered = now.minusDays(365L + rnd.nextInt(20));
                jdbc.update("update users set created_at = ?, updated_at = ? where id = ?",
                        Timestamp.valueOf(registered), Timestamp.valueOf(registered), u.getId());
            }
            list.add(u);
        }
        return list;
    }

    // ------------------------------------------------------------------ Đơn đặt tour

    private void createBooking(Random rnd, LocalDateTime now, LocalDateTime createdAt, int ageDays, User customer,
                               List<Tour> tours, Map<Long, Integer> budget, Map<String, Integer> codeCounter,
                               Set<String> usedPaymentCodes) {
        BookingStatus status = pickStatus(rnd, ageDays);

        Booking b = new Booking();
        b.setUser(customer);
        b.setContactName(customer.getFullName());
        b.setContactPhone(customer.getPhone());
        b.setContactEmail(customer.getEmail());
        b.setSpecialRequest(REQUESTS[rnd.nextInt(REQUESTS.length)]);

        // Chọn 1-2 tour khác nhau
        int wanted = rnd.nextInt(100) < 25 ? 2 : 1;
        Set<Long> picked = new LinkedHashSet<>();
        BigDecimal total = BigDecimal.ZERO;
        for (int attempt = 0; attempt < 30 && picked.size() < wanted; attempt++) {
            Tour t = tours.get(rnd.nextInt(tours.size()));
            if (picked.contains(t.getId())) {
                continue;
            }
            int adult = 1 + rnd.nextInt(4);
            int child = rnd.nextInt(100) < 40 ? 1 + rnd.nextInt(2) : 0;
            if (status != BookingStatus.CANCELLED) {
                int left = budget.getOrDefault(t.getId(), 0);
                if (left < 1) {
                    continue;
                }
                if (adult + child > left) {
                    child = 0;
                    adult = Math.min(adult, left);
                }
                budget.put(t.getId(), left - adult - child);
                t.setAvailableSeats(Math.max(0, t.getAvailableSeats() - adult - child));
            }
            total = total.add(addItem(b, t, adult, child));
            picked.add(t.getId());
        }
        if (b.getItems().isEmpty()) {
            // Không tour nào còn "ngân sách" chỗ: chuyển thành đơn đã hủy (không chiếm chỗ)
            status = BookingStatus.CANCELLED;
            Tour t = tours.get(rnd.nextInt(tours.size()));
            total = addItem(b, t, 1 + rnd.nextInt(3), 0);
        }
        b.setTotalAmount(total);
        b.setBookingStatus(status);

        // Trạng thái thanh toán nhất quán với trạng thái đơn
        LocalDateTime paidAt = null;
        switch (status) {
            case COMPLETED -> b.setPaymentStatus(PaymentStatus.PAID);
            case CONFIRMED -> b.setPaymentStatus(rnd.nextInt(100) < 70 ? PaymentStatus.PAID : PaymentStatus.UNPAID);
            case PENDING -> b.setPaymentStatus(PaymentStatus.UNPAID);
            case CANCELLED -> {
                boolean wasPaid = rnd.nextInt(100) < 30;
                b.setPaymentStatus(wasPaid ? PaymentStatus.REFUNDED : PaymentStatus.UNPAID);
                b.setCancelReason(CANCEL_REASONS[rnd.nextInt(CANCEL_REASONS.length)]);
                if (wasPaid) {
                    paidAt = createdAt.plusMinutes(10 + rnd.nextInt(120));
                }
            }
        }
        boolean viaQr = rnd.nextInt(100) < 70;
        if (b.getPaymentStatus() == PaymentStatus.PAID) {
            paidAt = createdAt.plusMinutes(5 + rnd.nextInt(180));
        }
        if (paidAt != null) {
            if (paidAt.isAfter(now)) {
                paidAt = now;
            }
            b.setPaidAt(paidAt);
            b.setPaymentMethod(viaQr ? PaymentMethod.BANK_QR : PaymentMethod.OFFICE);
            b.setPaymentNote(viaQr ? "Chuyển khoản QR (dữ liệu demo)" : "Thu tại văn phòng (dữ liệu demo)");
        }

        b.setBookingCode(nextCode(createdAt, codeCounter));
        b.setPaymentCode(nextPaymentCode(rnd, usedPaymentCodes));
        bookingRepository.saveAndFlush(b);

        LocalDateTime updatedAt = paidAt != null ? paidAt : createdAt.plusHours(1 + rnd.nextInt(48));
        if (updatedAt.isAfter(now)) {
            updatedAt = now;
        }
        jdbc.update("update bookings set created_at = ?, updated_at = ? where id = ?",
                Timestamp.valueOf(createdAt), Timestamp.valueOf(updatedAt), b.getId());

        // Giao dịch ngân hàng khớp đơn cho các đơn đã thu qua QR
        if (paidAt != null && b.getPaymentMethod() == PaymentMethod.BANK_QR) {
            PaymentTransaction tx = new PaymentTransaction();
            tx.setTransactionRef("DEMO-" + b.getPaymentCode());
            tx.setGateway("SEPAY");
            tx.setBookingId(b.getId());
            tx.setAmount(b.getTotalAmount());
            tx.setContent(b.getPaymentCode());
            tx.setAccountNumber(props.payment().accountNumber());
            tx.setTransactionTime(paidAt);
            tx.setMatchStatus(MatchStatus.MATCHED);
            tx.setRawPayload("{\"demo\":true}");
            tx = transactionRepository.saveAndFlush(tx);
            jdbc.update("update payment_transactions set created_at = ? where id = ?",
                    Timestamp.valueOf(paidAt), tx.getId());
        }
    }

    private BigDecimal addItem(Booking b, Tour t, int adult, int child) {
        BigDecimal childPrice = TourMapper.effectiveChildPrice(t);
        BigDecimal subtotal = t.effectiveAdultPrice().multiply(BigDecimal.valueOf(adult))
                .add(childPrice.multiply(BigDecimal.valueOf(child)));
        BookingItem item = new BookingItem();
        item.setTour(t);
        item.setTourName(t.getName());
        item.setDepartureDate(t.getDepartureDate());
        item.setAdultPrice(t.effectiveAdultPrice());
        item.setChildPrice(childPrice);
        item.setAdultQuantity(adult);
        item.setChildQuantity(child);
        item.setSubtotal(subtotal);
        b.addItem(item);
        return subtotal;
    }

    /** Đơn càng cũ càng nhiều đơn đã hoàn tất; đơn mới thì chủ yếu chờ xác nhận/đã xác nhận. */
    private static BookingStatus pickStatus(Random rnd, int ageDays) {
        int r = rnd.nextInt(100);
        if (ageDays > 60) {
            return r < 70 ? BookingStatus.COMPLETED : r < 85 ? BookingStatus.CANCELLED
                    : r < 95 ? BookingStatus.CONFIRMED : BookingStatus.PENDING;
        }
        if (ageDays > 15) {
            return r < 40 ? BookingStatus.COMPLETED : r < 70 ? BookingStatus.CONFIRMED
                    : r < 85 ? BookingStatus.CANCELLED : BookingStatus.PENDING;
        }
        return r < 50 ? BookingStatus.PENDING : r < 85 ? BookingStatus.CONFIRMED : BookingStatus.CANCELLED;
    }

    private String nextCode(LocalDateTime createdAt, Map<String, Integer> counter) {
        String day = createdAt.toLocalDate().format(DateTimeFormatter.BASIC_ISO_DATE);
        int n = counter.merge(day, 1, Integer::sum);
        return "BK-" + day + "-" + String.format("%03d", n);
    }

    private static String nextPaymentCode(Random rnd, Set<String> used) {
        while (true) {
            StringBuilder sb = new StringBuilder("TOUR");
            for (int i = 0; i < 6; i++) {
                sb.append(CODE_CHARS.charAt(rnd.nextInt(CODE_CHARS.length())));
            }
            if (used.add(sb.toString())) {
                return sb.toString();
            }
        }
    }

    // ------------------------------------------------------------------ Liên hệ

    private int createContacts(LocalDateTime now, List<User> customers) {
        if (contactRepository.count() > 0) {
            return 0;
        }
        Long adminId = userRepository.findByEmail(props.seed().adminEmail().trim().toLowerCase())
                .map(User::getId).orElse(null);
        Object[][] data = {
                // fullName, email, phone, subject, message, status, daysAgo, reply
                {"Nguyễn Thị Mai", "mai.nguyen@example.com", "0912345678", "Tư vấn tour Phú Quốc cho gia đình 6 người",
                        "Chào bạn, gia đình mình có 6 người (2 trẻ em) muốn đi Phú Quốc 4 ngày 3 đêm vào dịp hè. Bạn tư vấn giúp lịch trình và giá nhé.",
                        ContactStatus.NEW, 1, null},
                {"Trần Quang Vinh", "vinh.tran@example.com", null, "Hỏi về chính sách hoàn hủy tour",
                        "Nếu mình đã thanh toán rồi nhưng cần hủy trước ngày khởi hành 10 ngày thì được hoàn bao nhiêu phần trăm?",
                        ContactStatus.NEW, 2, null},
                {"Lê Thanh Hằng", "hang.le@example.com", "0987654321", "Đoàn công ty 25 người đi Đà Nẵng",
                        "Công ty mình dự kiến tổ chức team building cho 25 người tại Đà Nẵng. Mong nhận báo giá ưu đãi cho đoàn.",
                        ContactStatus.NEW, 5, null},
                {"Phạm Đức Long", "long.pham@example.com", "0933221100", "Tour Sapa có phù hợp với người lớn tuổi?",
                        "Bố mẹ mình ngoài 60 tuổi, sức khỏe bình thường. Tour trekking Sapa có quá sức không, có phương án nhẹ nhàng hơn không?",
                        ContactStatus.IN_PROGRESS, 8, null},
                {"Võ Thị Ngọc", "ngoc.vo@example.com", "0977112233", "Xác nhận thông tin xuất hóa đơn",
                        "Mình cần xuất hóa đơn VAT cho đơn đặt tour vừa rồi, cần gửi thông tin công ty ở đâu?",
                        ContactStatus.RESOLVED, 20,
                        "Chào bạn, bạn vui lòng gửi mã số thuế và tên công ty qua email này, chúng tôi sẽ xuất hóa đơn trong 24 giờ làm việc. Cảm ơn bạn!"},
                {"Đỗ Minh Khôi", "khoi.do@example.com", null, "Góp ý về trang web",
                        "Trang web dễ dùng, đặt tour nhanh. Mong bổ sung thêm bộ lọc theo ngày khởi hành. Cảm ơn đội ngũ.",
                        ContactStatus.RESOLVED, 45,
                        "Cảm ơn bạn đã góp ý! Bộ lọc theo ngày khởi hành đã có trong trang Tour du lịch, bạn thử nhé."}
        };
        int idx = 0;
        for (Object[] d : data) {
            Contact c = new Contact();
            c.setFullName((String) d[0]);
            c.setEmail((String) d[1]);
            c.setPhone((String) d[2]);
            c.setSubject((String) d[3]);
            c.setMessage((String) d[4]);
            c.setStatus((ContactStatus) d[5]);
            if (idx == 1 && !customers.isEmpty()) {
                c.setUserId(customers.get(0).getId());
            }
            LocalDateTime createdAt = now.minusDays((Integer) d[6]).minusHours(2 + idx);
            LocalDateTime repliedAt = null;
            if (d[7] != null) {
                c.setReplyContent((String) d[7]);
                c.setRepliedBy(adminId);
                repliedAt = createdAt.plusHours(5);
                c.setRepliedAt(repliedAt);
            }
            if (c.getStatus() == ContactStatus.IN_PROGRESS) {
                c.setAdminNote("Đã gọi điện tư vấn, chờ khách xác nhận lịch trình.");
            }
            c = contactRepository.saveAndFlush(c);
            LocalDateTime updatedAt = repliedAt != null ? repliedAt : createdAt;
            jdbc.update("update contacts set created_at = ?, updated_at = ? where id = ?",
                    Timestamp.valueOf(createdAt), Timestamp.valueOf(updatedAt), c.getId());
            idx++;
        }
        return data.length;
    }
}
