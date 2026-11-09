package com.tourdulich.util;

import java.math.BigDecimal;
import java.math.RoundingMode;

/** Tiền VND trả ra API dạng số nguyên (không có phần thập phân thừa). */
public final class Money {

    private Money() {
    }

    public static long vnd(BigDecimal value) {
        return value == null ? 0L : value.setScale(0, RoundingMode.HALF_UP).longValue();
    }
}
