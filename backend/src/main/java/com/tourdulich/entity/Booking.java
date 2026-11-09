package com.tourdulich.entity;

import com.tourdulich.entity.enums.BookingStatus;
import com.tourdulich.entity.enums.PaymentMethod;
import com.tourdulich.entity.enums.PaymentStatus;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Getter
@Setter
@Entity
@Table(name = "bookings")
public class Booking extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /** Ví dụ: BK-20260826-001. */
    @Column(name = "booking_code", nullable = false, unique = true, length = 50)
    private String bookingCode;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    // Snapshot thông tin liên hệ tại thời điểm đặt
    @Column(name = "contact_name", length = 100)
    private String contactName;

    @Column(name = "contact_phone", length = 20)
    private String contactPhone;

    @Column(name = "contact_email", length = 150)
    private String contactEmail;

    @Column(name = "special_request", columnDefinition = "TEXT")
    private String specialRequest;

    @Column(name = "total_amount", nullable = false, precision = 15, scale = 2)
    private BigDecimal totalAmount;

    @Enumerated(EnumType.STRING)
    @Column(name = "payment_status", nullable = false, length = 30)
    private PaymentStatus paymentStatus = PaymentStatus.UNPAID;

    @Enumerated(EnumType.STRING)
    @Column(name = "booking_status", nullable = false, length = 30)
    private BookingStatus bookingStatus = BookingStatus.PENDING;

    // ---- Thanh toán chuyển khoản QR (bổ sung ngoài đặc tả gốc) ----

    /** Mã ngẫu nhiên khách ghi vào nội dung chuyển khoản, ví dụ TOUR7K3QX9. */
    @Column(name = "payment_code", unique = true, length = 30)
    private String paymentCode;

    @Enumerated(EnumType.STRING)
    @Column(name = "payment_method", length = 30)
    private PaymentMethod paymentMethod;

    @Column(name = "paid_at")
    private LocalDateTime paidAt;

    @Column(name = "payment_note", length = 500)
    private String paymentNote;

    @Column(name = "cancel_reason", length = 500)
    private String cancelReason;

    @OneToMany(mappedBy = "booking", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<BookingItem> items = new ArrayList<>();

    public void addItem(BookingItem item) {
        item.setBooking(this);
        items.add(item);
    }
}
