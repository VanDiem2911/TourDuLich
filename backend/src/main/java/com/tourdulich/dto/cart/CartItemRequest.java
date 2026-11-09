package com.tourdulich.dto.cart;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

public record CartItemRequest(
        @NotNull(message = "Vui lòng chọn tour") Long tourId,

        @NotNull(message = "Vui lòng nhập số vé người lớn")
        @Min(value = 1, message = "Số vé người lớn phải từ 1 trở lên")
        @Max(value = 500, message = "Số vé người lớn quá lớn")
        Integer adultQuantity,

        @Min(value = 0, message = "Số vé trẻ em không được âm")
        @Max(value = 500, message = "Số vé trẻ em quá lớn")
        Integer childQuantity) {
}
