package com.tourdulich.util;

import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;

/** Tạo Pageable từ tham số page (bắt đầu từ 1) và size, có giới hạn size tối đa. */
public final class Pages {

    public static final int MAX_SIZE = 100;

    private Pages() {
    }

    public static Pageable of(int page, int size, Sort sort) {
        int p = Math.max(page, 1) - 1;
        int s = Math.min(Math.max(size, 1), MAX_SIZE);
        return PageRequest.of(p, s, sort);
    }
}
