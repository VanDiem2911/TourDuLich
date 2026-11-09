package com.tourdulich.dto.admin;

import com.tourdulich.entity.enums.Role;
import com.tourdulich.entity.enums.UserStatus;

import java.time.LocalDateTime;

public record AdminUserResponse(Long id, String fullName, String email, String phone, String address,
                                Role role, UserStatus status, LocalDateTime createdAt, long bookingCount) {
}
