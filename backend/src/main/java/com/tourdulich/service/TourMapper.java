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

    /** Giá trẻ em chưa nhập thì tính theo giá người lớn; không bao giờ cao hơn giá người lớn đang bán. */
    public static BigDecimal effectiveChildPrice(Tour t) {
        BigDecimal adult = t.effectiveAdultPrice();
        return t.getChildPrice() != null ? t.getChildPrice().min(adult) : adult;
    }

    /** Danh sách ảnh bổ sung (mỗi dòng một URL, tối đa 12). */
    public static List<String> gallery(Tour t) {
        if (t.getGalleryUrls() == null) {
            return List.of();
        }
        return java.util.Arrays.stream(t.getGalleryUrls().split("\\R")).map(String::trim)
                .filter(s -> !s.isEmpty()).limit(12).toList();
    }

    public static TourSummary toSummary(Tour t) {
        return new TourSummary(
                t.getId(), t.getTourCode(), t.getName(),
                t.getCategory().getId(), t.getCategory().getName(),
                t.getDepartureLocation(), t.getDestination(), t.getDuration(), t.getTransport(),
                t.getDepartureDate(),
                Money.vnd(t.effectiveAdultPrice()), Money.vnd(effectiveChildPrice(t)),
                t.getTotalSeats(), t.getAvailableSeats(),
                t.getImageUrl(), t.getShortDescription(), t.getStatus(), t.getRegion(),
                t.hasPromo() ? Money.vnd(t.getAdultPrice()) : 0L);
    }

    public static TourDetail toDetail(Tour t, List<TourSummary> related) {
        return TourDetail.of(toSummary(t), t.getItinerary(), t.getNotes(), gallery(t), related);
    }
}
