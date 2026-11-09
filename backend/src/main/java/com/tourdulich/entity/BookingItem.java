package com.tourdulich.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/** Chi tiết tour trong đơn đặt. Lưu snapshot để giữ thông tin lịch sử khi tour đổi giá về sau. */
@Getter
@Setter
@Entity
@Table(name = "booking_items")
public class BookingItem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "booking_id", nullable = false)
    private Booking booking;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "tour_id", nullable = false)
    private Tour tour;

    @Column(name = "tour_name", nullable = false)
    private String tourName;

    @Column(name = "departure_date")
    private LocalDateTime departureDate;

    @Column(name = "adult_price", nullable = false, precision = 15, scale = 2)
    private BigDecimal adultPrice;

    @Column(name = "child_price", precision = 15, scale = 2)
    private BigDecimal childPrice;

    @Column(name = "adult_quantity", nullable = false)
    private Integer adultQuantity;

    @Column(name = "child_quantity", nullable = false)
    private Integer childQuantity = 0;

    @Column(nullable = false, precision = 15, scale = 2)
    private BigDecimal subtotal;
}
