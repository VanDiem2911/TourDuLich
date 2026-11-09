package com.tourdulich.dto.auth;

import com.tourdulich.entity.User;
import com.tourdulich.entity.enums.Role;
import com.tourdulich.entity.enums.UserStatus;

import java.time.LocalDateTime;

/** Thông tin người dùng trả về client. Tuyệt đối không có password / passwordHash. */
public record UserResponse(
        Long id,
        String fullName,
        String email,
        String phone,
        String address,
        Role role,
        UserStatus status,
        LocalDateTime createdAt) {

    public static UserResponse from(User u) {
        return new UserResponse(u.getId(), u.getFullName(), u.getEmail(), u.getPhone(), u.getAddress(),
                u.getRole(), u.getStatus(), u.getCreatedAt());
    }
}
