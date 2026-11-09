package com.tourdulich.dto.admin;

import com.tourdulich.entity.enums.TourStatus;
import jakarta.validation.constraints.NotNull;

public record TourStatusRequest(@NotNull(message = "Vui lòng chọn trạng thái") TourStatus status) {
}
