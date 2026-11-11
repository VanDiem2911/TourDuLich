package com.tourdulich.ai;

/** Phát ra khi admin thêm/sửa/xóa/đổi trạng thái một tour, để chỉ mục AI được cập nhật theo. */
public record TourChangedEvent(Long tourId) {
}
