package com.tourdulich.ai;

import org.springframework.stereotype.Component;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/** Nơi các {@link KeyRotation} (chat, embedding) đăng ký để admin xem trạng thái các API key (đã che). */
@Component
public class AiKeyRegistry {

    private final Map<String, KeyRotation> rotations = new ConcurrentHashMap<>();

    public void register(KeyRotation rotation) {
        rotations.put(rotation.name(), rotation);
    }

    /** Nhãn tổ hợp key/mô hình đang dùng của một nhóm (null nếu chưa có). */
    public String activeLabel(String name) {
        KeyRotation r = rotations.get(name);
        return r == null ? null : r.activeLabel();
    }

    /** {tên nhóm -> {keys: danh sách trạng thái, failovers: số lần đã chuyển key}}. Rỗng nếu AI chưa bật. */
    public Map<String, Object> snapshot() {
        Map<String, Object> out = new LinkedHashMap<>();
        for (String name : List.of("chat", "embedding")) {
            KeyRotation r = rotations.get(name);
            if (r != null) {
                Map<String, Object> one = new LinkedHashMap<>();
                one.put("keyCount", r.keyCount());
                one.put("failovers", r.failovers());
                one.put("keys", r.snapshot());
                out.put(name, one);
            }
        }
        return out;
    }
}
