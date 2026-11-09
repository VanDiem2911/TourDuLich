package com.tourdulich.entity;

import com.tourdulich.entity.enums.MatchStatus;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.annotations.CreationTimestamp;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/** Giao dịch ngân hàng (webhook hoặc giả lập) dùng đối soát thanh toán QR. */
@Getter
@Setter
@Entity
@Table(name = "payment_transactions")
public class PaymentTransaction {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /** Mã giao dịch do nhà cung cấp gửi, duy nhất để chống xử lý trùng. */
    @Column(name = "transaction_ref", nullable = false, unique = true, length = 100)
    private String transactionRef;

    @Column(length = 50)
    private String gateway;

    /** NULL nếu chưa khớp được đơn. */
    @Column(name = "booking_id")
    private Long bookingId;

    @Column(nullable = false, precision = 15, scale = 2)
    private BigDecimal amount;

    @Column(length = 500)
    private String content;

    @Column(name = "account_number", length = 50)
    private String accountNumber;

    @Column(name = "transaction_time")
    private LocalDateTime transactionTime;

    @Enumerated(EnumType.STRING)
    @Column(name = "match_status", nullable = false, length = 30)
    private MatchStatus matchStatus;

    @Column(name = "raw_payload", columnDefinition = "TEXT")
    private String rawPayload;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;
}
