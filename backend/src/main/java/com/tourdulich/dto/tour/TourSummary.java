package com.tourdulich.dto.tour;

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
        TourStatus status) {
}
