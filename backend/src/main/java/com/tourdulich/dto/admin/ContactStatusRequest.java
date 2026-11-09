package com.tourdulich.dto.admin;

import com.tourdulich.entity.enums.ContactStatus;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record ContactStatusRequest(
        @NotNull(message = "Vui lòng chọn trạng thái") ContactStatus status,
        @Size(max = 500, message = "Ghi chú tối đa 500 ký tự") String adminNote) {
}
