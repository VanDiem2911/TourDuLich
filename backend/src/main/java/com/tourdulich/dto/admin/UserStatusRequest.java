package com.tourdulich.dto.admin;

import com.tourdulich.entity.enums.UserStatus;
import jakarta.validation.constraints.NotNull;

public record UserStatusRequest(@NotNull(message = "Vui lòng chọn trạng thái") UserStatus status) {
}
