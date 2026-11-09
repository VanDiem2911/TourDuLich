package com.tourdulich.dto.cart;

import java.util.List;

/** totalItems = số tour trong giỏ; totalAmount tính lại từ giá trong CSDL. */
public record CartResponse(List<CartItemResponse> items, int totalItems, long totalAmount) {
}
