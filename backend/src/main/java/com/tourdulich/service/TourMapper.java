package com.tourdulich.service;

import com.tourdulich.dto.tour.TourDetail;
import com.tourdulich.dto.tour.TourSummary;
import com.tourdulich.entity.Tour;
import com.tourdulich.util.Money;

import java.math.BigDecimal;
import java.util.List;

/** Chuyển Tour (entity) sang DTO. Gọi trong transaction vì đọc quan hệ category (lazy). */
public final class TourMapper {

    private TourMapper() {
    }

    /** Giá trẻ em chưa nhập thì tính theo giá người lớn. */
    public static BigDecimal effectiveChildPrice(Tour t) {
        return t.getChildPrice() != null ? t.getChildPrice() : t.getAdultPrice();
    }

    public static TourSummary toSummary(Tour t) {
        return new TourSummary(
                t.getId(), t.getTourCode(), t.getName(),
                t.getCategory().getId(), t.getCategory().getName(),
                t.getDepartureLocation(), t.getDestination(), t.getDuration(), t.getTransport(),
                t.getDepartureDate(),
                Money.vnd(t.getAdultPrice()), Money.vnd(effectiveChildPrice(t)),
                t.getTotalSeats(), t.getAvailableSeats(),
                t.getImageUrl(), t.getShortDescription(), t.getStatus());
    }

    public static TourDetail toDetail(Tour t, List<TourSummary> related) {
        return TourDetail.of(toSummary(t), t.getItinerary(), related);
    }
}
