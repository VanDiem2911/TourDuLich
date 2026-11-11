package com.tourdulich.ai;

import java.util.regex.Pattern;

/** Che thông tin cá nhân (email, số điện thoại, dãy số dài như số thẻ/CCCD) trước khi lưu lịch sử chat. */
public final class ChatRedactor {

    private static final Pattern EMAIL = Pattern.compile("[\\w.+-]+@[\\w-]+(\\.[\\w-]+)+");
    // 9-14 chữ số, có thể xen dấu cách, chấm hoặc gạch: số điện thoại, CCCD, số thẻ...
    private static final Pattern NUMBER = Pattern.compile("(?<!\\d)(?:\\+?\\d[\\s.-]?){9,14}\\d(?!\\d)");

    private ChatRedactor() {
    }

    public static String redact(String text) {
        if (text == null) {
            return null;
        }
        String t = EMAIL.matcher(text).replaceAll("[email]");
        return NUMBER.matcher(t).replaceAll("[số]");
    }

    public static String cut(String text, int max) {
        if (text == null) {
            return null;
        }
        return text.length() > max ? text.substring(0, max) : text;
    }
}
