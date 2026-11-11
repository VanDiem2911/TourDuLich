package com.tourdulich.ai;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

class ChatRedactorTest {

    @Test
    void masksEmailsAndPhoneNumbers() {
        assertEquals("Liên hệ mình qua [email] nhé", ChatRedactor.redact("Liên hệ mình qua nguyen.van+a@gmail.com nhé"));
        assertEquals("SĐT của mình là [số]", ChatRedactor.redact("SĐT của mình là 0912 345 678"));
        assertEquals("gọi [số] hoặc [số]", ChatRedactor.redact("gọi 0912.345.678 hoặc +84 912-345-678"));
        assertEquals("CCCD [số]", ChatRedactor.redact("CCCD 079201001234"));
        assertFalse(ChatRedactor.redact("thẻ 4111 1111 1111 1111").contains("4111"));
    }

    @Test
    void keepsPricesAndShortNumbersReadable() {
        // Giá tiền và số nhỏ không phải thông tin cá nhân: phải giữ nguyên để lịch sử còn đọc được
        String s = "Tour 5N4Đ giá 11.691.000 đ cho 2 người lớn, khởi hành 23/11/2026";
        assertEquals(s, ChatRedactor.redact(s));
        assertEquals("Hotline 1900 1234", ChatRedactor.redact("Hotline 1900 1234"));
    }

    @Test
    void nullSafeAndCut() {
        assertNull(ChatRedactor.redact(null));
        assertEquals("abc", ChatRedactor.cut("abcdef", 3));
        assertTrue(ChatRedactor.cut("ab", 5).length() == 2);
    }
}
