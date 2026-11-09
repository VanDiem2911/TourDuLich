package com.tourdulich.entity.enums;

public enum PaymentMethod {
    /** Chuyển khoản qua mã QR kèm mã thanh toán ngẫu nhiên (đối soát tự động qua webhook). */
    BANK_QR,
    /** Thanh toán trực tiếp tại văn phòng. */
    OFFICE
}
