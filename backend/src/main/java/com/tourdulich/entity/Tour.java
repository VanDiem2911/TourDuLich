package com.tourdulich.entity;

import com.tourdulich.entity.enums.TourRegion;
import com.tourdulich.entity.enums.TourStatus;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Getter
@Setter
@Entity
@Table(name = "tours")
public class Tour extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "category_id", nullable = false)
    private Category category;

    @Column(name = "tour_code", nullable = false, unique = true, length = 50)
    private String tourCode;

    @Column(nullable = false)
    private String name;

    @Column(name = "departure_location", length = 150)
    private String departureLocation;

    @Column(length = 150)
    private String destination;

    /** Ví dụ: 3N2Đ, 4N3Đ. */
    @Column(length = 50)
    private String duration;

    /** Phương tiện di chuyển chính (máy bay, xe du lịch, tàu hỏa, du thuyền...). */
    @Column(length = 100)
    private String transport;

    @Column(name = "departure_date")
    private LocalDateTime departureDate;

    @Column(name = "adult_price", nullable = false, precision = 15, scale = 2)
    private BigDecimal adultPrice;

    @Column(name = "child_price", precision = 15, scale = 2)
    private BigDecimal childPrice;

    /** Giá khuyến mãi người lớn (tùy chọn). Chỉ có hiệu lực khi lớn hơn 0 và thấp hơn adultPrice. */
    @Column(name = "promo_price", precision = 15, scale = 2)
    private BigDecimal promoPrice;

    /** Ảnh bổ sung của tour: mỗi dòng một đường dẫn ảnh. */
    @Column(name = "gallery_urls", columnDefinition = "TEXT")
    private String galleryUrls;

    @Column(name = "total_seats", nullable = false)
    private Integer totalSeats;

    @Column(name = "available_seats", nullable = false)
    private Integer availableSeats;

    @Column(name = "image_url", length = 500)
    private String imageUrl;

    @Column(name = "short_description", length = 500)
    private String shortDescription;

    @Column(columnDefinition = "TEXT")
    private String itinerary;

    /** Giá bao gồm / không bao gồm, giấy tờ, quy định hủy... (khối tiêu đề + dòng, cách nhau bằng dòng trống). */
    @Column(columnDefinition = "TEXT")
    private String notes;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private TourStatus status = TourStatus.ACTIVE;

    /** Trong nước / nước ngoài. */
    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private TourRegion region = TourRegion.DOMESTIC;

    /** true nếu đang có giá khuyến mãi hợp lệ. */
    public boolean hasPromo() {
        return promoPrice != null && promoPrice.signum() > 0 && adultPrice != null && promoPrice.compareTo(adultPrice) < 0;
    }

    /** Giá người lớn thực tế đang bán (khuyến mãi nếu có, ngược lại là giá niêm yết) - dùng cho mọi phép tính tiền. */
    public BigDecimal effectiveAdultPrice() {
        return hasPromo() ? promoPrice : adultPrice;
    }
}
