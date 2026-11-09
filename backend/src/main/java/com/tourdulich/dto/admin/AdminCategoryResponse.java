package com.tourdulich.dto.admin;

import com.tourdulich.entity.enums.CategoryStatus;

import java.time.LocalDateTime;

public record AdminCategoryResponse(Long id, String name, String description, CategoryStatus status,
                                    long tourCount, LocalDateTime createdAt) {
}
