package com.tourdulich.dto.admin;

import com.tourdulich.entity.enums.TourRegion;
import com.tourdulich.entity.enums.TourStatus;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public record TourRequest(
        @NotNull(message = "Vui lòng chọn danh mục") Long categoryId,

        @NotBlank(message = "Mã tour không được để trống")
        @Size(max = 50, message = "Mã tour tối đa 50 ký tự")
        String tourCode,

        @NotBlank(message = "Tên tour không được để trống")
        @Size(max = 255, message = "Tên tour tối đa 255 ký tự")
        String name,

        @Size(max = 150, message = "Điểm khởi hành tối đa 150 ký tự")
        String departureLocation,

        @Size(max = 150, message = "Điểm đến tối đa 150 ký tự")
        String destination,

        @Size(max = 50, message = "Thời lượng tối đa 50 ký tự")
        String duration,

        @Size(max = 100, message = "Phương tiện tối đa 100 ký tự")
        String transport,

        LocalDateTime departureDate,

        @NotNull(message = "Vui lòng nhập giá vé người lớn")
        @DecimalMin(value = "0", inclusive = false, message = "Giá vé người lớn phải lớn hơn 0")
        BigDecimal adultPrice,

        @DecimalMin(value = "0", message = "Giá vé trẻ em không được âm")
        BigDecimal childPrice,

        /** Giá khuyến mãi người lớn (tùy chọn): phải lớn hơn 0 và thấp hơn giá vé người lớn. */
        @DecimalMin(value = "0", inclusive = false, message = "Giá khuyến mãi phải lớn hơn 0")
        BigDecimal promoPrice,

        @NotNull(message = "Vui lòng nhập tổng số chỗ")
        @Min(value = 1, message = "Tổng số chỗ phải từ 1 trở lên")
        Integer totalSeats,

        @Size(max = 500, message = "Link ảnh tối đa 500 ký tự")
        String imageUrl,

        @Size(max = 500, message = "Mô tả ngắn tối đa 500 ký tự")
        String shortDescription,

        @Size(max = 20000, message = "Lịch trình quá dài")
        String itinerary,

        @Size(max = 20000, message = "Ghi chú quá dài")
        String notes,

        /** Ảnh bổ sung: mỗi dòng một đường dẫn. */
        @Size(max = 6000, message = "Danh sách ảnh quá dài")
        String gallery,

        TourStatus status,

        /** Trong nước / nước ngoài; bỏ trống thì giữ nguyên (tour mới mặc định trong nước). */
        TourRegion region) {
}
