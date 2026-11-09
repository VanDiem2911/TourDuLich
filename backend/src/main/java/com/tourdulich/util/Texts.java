package com.tourdulich.util;

/** Tiện ích xử lý chuỗi dùng chung. */
public final class Texts {

    private Texts() {
    }

    public static String blankToNull(String s) {
        return (s == null || s.isBlank()) ? null : s.trim();
    }

    /** Thoát ký tự đặc biệt của LIKE (%, _, \) để tìm kiếm an toàn, rồi bọc %...%. */
    public static String likePattern(String keyword) {
        String k = keyword.trim().toLowerCase()
                .replace("\\", "\\\\").replace("%", "\\%").replace("_", "\\_");
        return "%" + k + "%";
    }
}
