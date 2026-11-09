package com.tourdulich.dto.cart;

import java.time.LocalDateTime;

public record CartItemResponse(
        Long tourId,
        String tourCode,
        String name,
        String imageUrl,
        LocalDateTime departureDate,
        String duration,
        long adultPrice,
        long childPrice,
        int adultQuantity,
        int childQuantity,
        long subtotal,
        int availableSeats) {
}
