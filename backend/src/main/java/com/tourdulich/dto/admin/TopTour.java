package com.tourdulich.dto.admin;

import com.tourdulich.util.Money;

import java.math.BigDecimal;

public record TopTour(Long tourId, String name, long bookedSeats, long revenue) {

    /** Constructor cho truy vấn JPQL (tổng số nguyên trả về Long, tổng tiền trả về BigDecimal). */
    public TopTour(Long tourId, String name, Long bookedSeats, BigDecimal revenue) {
        this(tourId, name, bookedSeats == null ? 0 : bookedSeats, Money.vnd(revenue));
    }
}
