package com.tourdulich.ai;

import com.tourdulich.entity.Category;
import com.tourdulich.entity.Tour;
import com.tourdulich.entity.enums.TourRegion;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/** Tour mẫu dùng chung cho các test của trợ lý AI. */
final class TourFixtures {

    private TourFixtures() {
    }

    static Tour singapore() {
        return tour(1L, "Singapore - Malaysia 5N4Đ", "Singapore", TourRegion.INTERNATIONAL,
                "Ngày 1: Hà Nội - Singapore\nĂn tối trên máy bay, đến Singapore ngắm Merlion và Gardens by the Bay.\n\n"
                        + "Ngày 2: Singapore - Malacca\nThăm phố cổ Malacca.",
                "Giá tour bao gồm\nVé máy bay khứ hồi, khách sạn 4 sao.\n\nGiấy tờ mang theo\nHộ chiếu còn hạn 6 tháng.\n\n"
                        + "Điều kiện hoãn hủy\nHủy trước 30 ngày chi trả 10% giá tour.");
    }

    static Tour phuQuoc() {
        return tour(2L, "Phú Quốc 3N2Đ", "Phú Quốc", TourRegion.DOMESTIC,
                "Ngày 1: TP.HCM - Phú Quốc\nTắm biển Bãi Sao, ăn hải sản.", "Giá tour bao gồm\nKhách sạn 3 sao.");
    }

    static Tour tour(Long id, String name, String dest, TourRegion region, String itinerary, String notes) {
        Category c = new Category();
        c.setName(region == TourRegion.INTERNATIONAL ? "Tour quốc tế" : "Nghỉ dưỡng biển đảo");
        Tour t = new Tour();
        t.setId(id);
        t.setCategory(c);
        t.setTourCode("FDT-" + id);
        t.setName(name);
        t.setDestination(dest);
        t.setDepartureLocation("TP.HCM");
        t.setDuration("5N4Đ");
        t.setTransport("Máy bay");
        t.setDepartureDate(LocalDateTime.of(2026, 12, 1, 7, 0));
        t.setAdultPrice(new BigDecimal("11691000"));
        t.setChildPrice(new BigDecimal("8000000"));
        t.setTotalSeats(30);
        t.setAvailableSeats(20);
        t.setShortDescription("Tour " + dest);
        t.setItinerary(itinerary);
        t.setNotes(notes);
        t.setRegion(region);
        return t;
    }
}
