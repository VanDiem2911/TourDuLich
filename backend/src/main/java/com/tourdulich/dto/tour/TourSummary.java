package com.tourdulich.dto.tour;

import com.tourdulich.entity.enums.TourRegion;
import com.tourdulich.entity.enums.TourStatus;

import java.time.LocalDateTime;

public record TourSummary(
        Long id,
        String tourCode,
        String name,
        Long categoryId,
        String categoryName,
        String departureLocation,
        String destination,
        String duration,
        String transport,
        LocalDateTime departureDate,
        long adultPrice,
        long childPrice,
        Integer totalSeats,
        Integer availableSeats,
        String imageUrl,
        String shortDescription,
        TourStatus status,
        TourRegion region,
        /** Giá niêm yết người lớn khi đang khuyến mãi (adultPrice lúc đó là giá khuyến mãi); 0 nếu không khuyến mãi. */
        long originalPrice) {
}
