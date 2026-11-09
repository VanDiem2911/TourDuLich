package com.tourdulich.entity.enums;

/** Kết quả đối soát một giao dịch ngân hàng nhận qua webhook. */
public enum MatchStatus {
    MATCHED,
    UNMATCHED,
    UNDERPAID,
    OVERPAID,
    ORDER_CANCELLED
}
