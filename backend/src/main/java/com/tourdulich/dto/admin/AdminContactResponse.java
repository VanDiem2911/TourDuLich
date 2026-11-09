package com.tourdulich.dto.admin;

import com.tourdulich.entity.enums.ContactStatus;

import java.time.LocalDateTime;

public record AdminContactResponse(Long id, String fullName, String email, String phone, String subject,
                                   String message, ContactStatus status, String replyContent, String adminNote,
                                   LocalDateTime repliedAt, LocalDateTime createdAt) {
}
