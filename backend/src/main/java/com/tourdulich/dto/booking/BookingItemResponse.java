package com.tourdulich.dto.booking;

import java.time.LocalDateTime;

public record BookingItemResponse(
        Long tourId,
        String tourName,
        String imageUrl,
        LocalDateTime departureDate,
        long adultPrice,
        long childPrice,
        int adultQuantity,
        int childQuantity,
        long subtotal) {
}
