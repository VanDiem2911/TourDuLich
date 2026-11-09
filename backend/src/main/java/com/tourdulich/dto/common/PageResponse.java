package com.tourdulich.dto.common;

import org.springframework.data.domain.Page;

import java.util.List;

/** Kết quả phân trang. page bắt đầu từ 1. */
public record PageResponse<T>(List<T> content, int page, int size, long totalElements, int totalPages) {

    public static <S, T> PageResponse<T> of(Page<S> source, List<T> mapped) {
        return new PageResponse<>(mapped, source.getNumber() + 1, source.getSize(),
                source.getTotalElements(), source.getTotalPages());
    }
}
