package com.tourdulich.service;

import com.tourdulich.entity.Booking;
import com.tourdulich.entity.enums.BookingStatus;
import com.tourdulich.entity.enums.PaymentStatus;
import com.tourdulich.util.Texts;
import jakarta.persistence.criteria.Join;
import jakarta.persistence.criteria.JoinType;
import jakarta.persistence.criteria.Predicate;
import org.springframework.data.jpa.domain.Specification;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

/** Bộ lọc động cho danh sách đơn đặt tour (khách và admin). */
public final class BookingSpecs {

    private BookingSpecs() {
    }

    public static Specification<Booking> filter(Long userId, String keyword, BookingStatus bookingStatus,
                                                PaymentStatus paymentStatus, LocalDate from, LocalDate to) {
        return (root, query, cb) -> {
            List<Predicate> ps = new ArrayList<>();
            if (userId != null) {
                ps.add(cb.equal(root.get("user").get("id"), userId));
            }
            if (bookingStatus != null) {
                ps.add(cb.equal(root.get("bookingStatus"), bookingStatus));
            }
            if (paymentStatus != null) {
                ps.add(cb.equal(root.get("paymentStatus"), paymentStatus));
            }
            if (from != null) {
                ps.add(cb.greaterThanOrEqualTo(root.get("createdAt"), from.atStartOfDay()));
            }
            if (to != null) {
                ps.add(cb.lessThan(root.get("createdAt"), to.plusDays(1).atStartOfDay()));
            }
            if (keyword != null && !keyword.isBlank()) {
                String p = Texts.likePattern(keyword);
                Join<Object, Object> user = root.join("user", JoinType.LEFT);
                ps.add(cb.or(
                        cb.like(cb.lower(root.get("bookingCode")), p, '\\'),
                        cb.like(cb.lower(root.get("contactName")), p, '\\'),
                        cb.like(cb.lower(root.get("contactEmail")), p, '\\'),
                        cb.like(cb.lower(user.get("fullName")), p, '\\'),
                        cb.like(cb.lower(user.get("email")), p, '\\')));
            }
            return cb.and(ps.toArray(new Predicate[0]));
        };
    }
}
