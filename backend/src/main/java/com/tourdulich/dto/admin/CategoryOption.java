package com.tourdulich.dto.admin;

import com.tourdulich.entity.enums.CategoryStatus;

public record CategoryOption(Long id, String name, CategoryStatus status) {
}
