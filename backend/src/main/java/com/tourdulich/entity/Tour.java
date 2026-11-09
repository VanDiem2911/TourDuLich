package com.tourdulich.entity;

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

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private TourStatus status = TourStatus.ACTIVE;
}
