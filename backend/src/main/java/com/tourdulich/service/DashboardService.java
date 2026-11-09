package com.tourdulich.service;

import com.tourdulich.dto.admin.BookingStat;
import com.tourdulich.dto.admin.DashboardStats;
import com.tourdulich.dto.admin.MonthRevenue;
import com.tourdulich.entity.enums.BookingStatus;
import com.tourdulich.entity.enums.ContactStatus;
import com.tourdulich.entity.enums.PaymentStatus;
import com.tourdulich.entity.enums.Role;
import com.tourdulich.entity.enums.TourStatus;
import com.tourdulich.repository.*;
import com.tourdulich.util.Money;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.YearMonth;
import java.time.ZoneId;
import java.util.*;

/** Số liệu tổng quan cho trang Dashboard quản trị (UC-15). */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class DashboardService {

    private static final ZoneId VN = ZoneId.of("Asia/Ho_Chi_Minh");

    private final TourRepository tourRepository;
    private final CategoryRepository categoryRepository;
    private final UserRepository userRepository;
    private final BookingRepository bookingRepository;
    private final BookingItemRepository bookingItemRepository;
    private final ContactRepository contactRepository;
    private final BookingMapper bookingMapper;

    public DashboardStats stats() {
        BigDecimal revenue = bookingRepository.sumTotalAmountByPaymentStatus(PaymentStatus.PAID);

        Map<String, Long> byStatus = new LinkedHashMap<>();
        for (BookingStatus s : BookingStatus.values()) {
            byStatus.put(s.name(), 0L);
        }
        long totalBookings = 0;
        for (Object[] row : bookingRepository.countGroupedByStatus()) {
            long n = (Long) row[1];
            byStatus.put(((BookingStatus) row[0]).name(), n);
            totalBookings += n;
        }

        return new DashboardStats(
                tourRepository.countByStatus(TourStatus.ACTIVE),
                categoryRepository.count(),
                userRepository.countByRole(Role.ROLE_CUSTOMER),
                totalBookings,
                Money.vnd(revenue),
                byStatus.get(BookingStatus.PENDING.name()),
                contactRepository.countByStatus(ContactStatus.NEW),
                revenueByMonth(),
                byStatus,
                bookingItemRepository.findTopTours(PageRequest.of(0, 5)),
                bookingMapper.toSummaries(bookingRepository.findTop8ByOrderByCreatedAtDescIdDesc(), true),
                tourRepository.findLowSeats(5, PageRequest.of(0, 5)).stream().map(TourMapper::toSummary).toList());
    }

    /** 12 tháng gần nhất (đủ tháng kể cả bằng 0): doanh thu = đơn PAID; bookings = số đơn không bị hủy. */
    private List<MonthRevenue> revenueByMonth() {
        YearMonth now = YearMonth.now(VN);
        YearMonth start = now.minusMonths(11);
        Map<YearMonth, long[]> acc = new LinkedHashMap<>();
        for (int i = 0; i < 12; i++) {
            acc.put(start.plusMonths(i), new long[2]);
        }
        LocalDateTime from = start.atDay(1).atStartOfDay();
        for (BookingStat s : bookingRepository.findStatsSince(from)) {
            long[] a = acc.get(YearMonth.from(s.createdAt()));
            if (a == null) {
                continue;
            }
            if (s.paymentStatus() == PaymentStatus.PAID) {
                a[0] += Money.vnd(s.totalAmount());
            }
            if (s.bookingStatus() != BookingStatus.CANCELLED) {
                a[1]++;
            }
        }
        List<MonthRevenue> out = new ArrayList<>();
        acc.forEach((ym, a) -> out.add(new MonthRevenue(ym.toString(), a[0], a[1])));
        return out;
    }
}
