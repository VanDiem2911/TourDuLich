package com.tourdulich.security;

import com.tourdulich.entity.User;
import com.tourdulich.entity.enums.Role;

/** Thông tin người dùng đã xác thực, đặt vào SecurityContext. Dùng với @AuthenticationPrincipal. */
public record UserPrincipal(Long id, String email, Role role) {

    public static UserPrincipal from(User user) {
        return new UserPrincipal(user.getId(), user.getEmail(), user.getRole());
    }
}
