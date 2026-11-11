package com.tourdulich.ai;

import org.springframework.core.env.Environment;

import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

/**
 * Đọc danh sách Gemini API key (theo thứ tự ưu tiên) từ cấu hình/biến môi trường:
 * <ol>
 *   <li>{@code GEMINI_API_KEY}: key chính;</li>
 *   <li>{@code GEMINI_API_KEY_2} ... {@code GEMINI_API_KEY_9}: key dự phòng;</li>
 *   <li>{@code GEMINI_API_KEYS}: danh sách nhiều key cách nhau bằng dấu phẩy hoặc chấm phẩy.</li>
 * </ol>
 * Giá trị rỗng, trùng lặp hoặc giá trị giữ chỗ {@code chua-cau-hinh} bị bỏ qua. Có ít nhất một key thì trợ lý AI được bật.
 */
public final class AiKeys {

    public static final String PLACEHOLDER = "chua-cau-hinh";

    private AiKeys() {
    }

    public static List<String> load(Environment env) {
        Set<String> keys = new LinkedHashSet<>();
        add(keys, env.getProperty("GEMINI_API_KEY"));
        for (int i = 2; i <= 9; i++) {
            add(keys, env.getProperty("GEMINI_API_KEY_" + i));
        }
        String list = env.getProperty("GEMINI_API_KEYS");
        if (list != null) {
            for (String k : list.split("[,;]")) {
                add(keys, k);
            }
        }
        return new ArrayList<>(keys);
    }

    private static void add(Set<String> keys, String raw) {
        if (raw == null) {
            return;
        }
        String k = raw.strip();
        if (!k.isEmpty() && !PLACEHOLDER.equals(k)) {
            keys.add(k);
        }
    }

    /** Che key khi hiển thị/ghi log: chỉ giữ 4 ký tự cuối. */
    public static String mask(String key) {
        if (key == null || key.length() <= 8) {
            return "****";
        }
        return "…" + key.substring(key.length() - 4);
    }
}
