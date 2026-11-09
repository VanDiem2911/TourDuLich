package com.tourdulich.entity;

import com.tourdulich.entity.enums.ContactStatus;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

/** Liên hệ / yêu cầu tư vấn do khách gửi (UC-16, UC-17). */
@Getter
@Setter
@Entity
@Table(name = "contacts")
public class Contact extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /** Có giá trị nếu người gửi đã đăng nhập. */
    @Column(name = "user_id")
    private Long userId;

    @Column(name = "full_name", nullable = false, length = 100)
    private String fullName;

    @Column(nullable = false, length = 150)
    private String email;

    @Column(length = 20)
    private String phone;

    @Column(nullable = false, length = 200)
    private String subject;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String message;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private ContactStatus status = ContactStatus.NEW;

    @Column(name = "reply_content", columnDefinition = "TEXT")
    private String replyContent;

    @Column(name = "admin_note", length = 500)
    private String adminNote;

    @Column(name = "replied_by")
    private Long repliedBy;

    @Column(name = "replied_at")
    private LocalDateTime repliedAt;
}
