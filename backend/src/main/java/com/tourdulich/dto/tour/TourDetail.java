package com.tourdulich.dto.tour;

import com.tourdulich.entity.enums.TourRegion;
import com.tourdulich.entity.enums.TourStatus;

import java.time.LocalDateTime;
import java.util.List;

/** TourSummary + lịch trình + tour liên quan. */
public record TourDetail(
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
        long originalPrice,
        String itinerary,
        String notes,
        List<String> gallery,
        List<TourSummary> relatedTours) {

    public static TourDetail of(TourSummary s, String itinerary, String notes, List<String> gallery,
                                List<TourSummary> related) {
        return new TourDetail(s.id(), s.tourCode(), s.name(), s.categoryId(), s.categoryName(),
                s.departureLocation(), s.destination(), s.duration(), s.transport(), s.departureDate(),
                s.adultPrice(), s.childPrice(), s.totalSeats(), s.availableSeats(), s.imageUrl(),
                s.shortDescription(), s.status(), s.region(), s.originalPrice(), itinerary, notes, gallery, related);
    }
}
