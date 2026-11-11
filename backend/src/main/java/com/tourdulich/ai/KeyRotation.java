package com.tourdulich.ai;

import lombok.extern.slf4j.Slf4j;

import java.util.ArrayList;
import java.util.List;
import java.util.function.IntFunction;
import java.util.function.LongSupplier;

/**
 * Xoay vòng nhiều API key với cơ chế dự phòng (failover).
 *
 * <p>Dùng một key cho tới khi nó lỗi do hết hạn mức (429/quota) hoặc key không hợp lệ; lúc đó key bị "nghỉ" một thời gian và
 * yêu cầu được thử lại ngay bằng key kế tiếp. Lỗi không liên quan tới key (mạng, 5xx, câu lệnh sai...) được ném ra bình thường,
 * không đổi key. Hết thời gian nghỉ thì key được dùng lại.
 */
@Slf4j
public class KeyRotation {

    /** Phân loại lỗi để quyết định có đổi key không và nghỉ bao lâu. */
    public enum Kind {
        /** Vượt hạn mức theo phút/lượt gọi: nghỉ ngắn. */
        QUOTA(90_000L),
        /** Hết hạn mức theo ngày: nghỉ lâu. */
        QUOTA_DAILY(3_600_000L),
        /** Key sai, hết hạn hoặc bị khóa: coi như hỏng (tới khi khởi động lại). */
        INVALID(6 * 3_600_000L),
        /** Mô hình không còn dành cho key/project này (404 NOT_FOUND, "no longer available"): bỏ qua tổ hợp đó. */
        UNAVAILABLE(6 * 3_600_000L),
        /** Lỗi khác: không đổi key. */
        OTHER(0L);

        final long cooldownMs;

        Kind(long cooldownMs) {
            this.cooldownMs = cooldownMs;
        }
    }

    /** Trạng thái một key để hiển thị cho admin (đã che key). */
    public record KeyState(int index, String key, boolean active, boolean cooling, long coolingSeconds,
                           int failures, String lastError) {
    }

    private final String name;
    private final List<String> keys;   // nhãn hiển thị đã che (ví dụ "…7Dgg" hoặc "…7Dgg · gemini-2.5-flash")
    private final long[] blockedUntil;
    private final int[] failures;
    private final String[] lastError;
    private final LongSupplier clock;
    private int current;
    private int totalFailovers;

    /** Mỗi phần tử là một API key thô; nhãn hiển thị tự được che (chỉ 4 ký tự cuối). */
    public KeyRotation(String name, List<String> keys) {
        this(name, keys.stream().map(AiKeys::mask).toList(), System::currentTimeMillis, true);
    }

    KeyRotation(String name, List<String> keys, LongSupplier clock) {
        this(name, keys.stream().map(AiKeys::mask).toList(), clock, true);
    }

    /** Mỗi phần tử là MỘT TỔ HỢP (key, mô hình) với nhãn hiển thị đã che sẵn, ví dụ "…7Dgg · gemini-2.5-flash". */
    public static KeyRotation labeled(String name, List<String> labels) {
        return new KeyRotation(name, labels, System::currentTimeMillis, true);
    }

    private KeyRotation(String name, List<String> labels, LongSupplier clock, boolean ready) {
        if (labels == null || labels.isEmpty()) {
            throw new IllegalArgumentException("Cần ít nhất một API key");
        }
        this.name = name;
        this.keys = List.copyOf(labels);
        this.blockedUntil = new long[labels.size()];
        this.failures = new int[labels.size()];
        this.lastError = new String[labels.size()];
        this.clock = clock;
    }

    public int keyCount() {
        return keys.size();
    }

    public String name() {
        return name;
    }

    public synchronized int current() {
        return current;
    }

    public synchronized int failovers() {
        return totalFailovers;
    }

    /**
     * Gọi {@code call} với chỉ số key hiện tại; nếu lỗi do key thì chuyển sang key kế tiếp và thử lại (tối đa mỗi key một lần).
     */
    public <T> T execute(IntFunction<T> call) {
        RuntimeException last = null;
        for (int attempt = 0; attempt < keys.size(); attempt++) {
            int idx = pick();
            try {
                T result = call.apply(idx);
                markOk(idx);
                return result;
            } catch (RuntimeException e) {
                Kind kind = classify(e);
                if (kind == Kind.OTHER) {
                    throw e;
                }
                markFailed(idx, kind, e);
                last = e;
            }
        }
        throw last;
    }

    /** Chọn key dùng được (không đang nghỉ), ưu tiên key hiện tại; nếu tất cả đang nghỉ thì chọn key sắp hết nghỉ nhất. */
    private synchronized int pick() {
        long now = clock.getAsLong();
        for (int i = 0; i < keys.size(); i++) {
            int idx = (current + i) % keys.size();
            if (blockedUntil[idx] <= now) {
                current = idx;
                return idx;
            }
        }
        int best = 0;
        for (int i = 1; i < keys.size(); i++) {
            if (blockedUntil[i] < blockedUntil[best]) {
                best = i;
            }
        }
        current = best;
        return best;
    }

    private synchronized void markOk(int idx) {
        lastError[idx] = null;
    }

    private synchronized void markFailed(int idx, Kind kind, RuntimeException e) {
        failures[idx]++;
        lastError[idx] = kind.name();
        blockedUntil[idx] = clock.getAsLong() + kind.cooldownMs;
        if (keys.size() > 1) {
            totalFailovers++;
            current = (idx + 1) % keys.size();
        }
        log.warn("[{}] {} lỗi ({}), {}", name, keys.get(idx), kind,
                keys.size() > 1 ? "chuyển sang " + keys.get((idx + 1) % keys.size()) : "không còn dự phòng");
    }

    /** Nhãn của tổ hợp (key, mô hình) đang hoạt động, ví dụ "…7Dgg · gemini-3.5-flash". */
    public synchronized String activeLabel() {
        return keys.get(current);
    }

    public synchronized List<KeyState> snapshot() {
        long now = clock.getAsLong();
        List<KeyState> out = new ArrayList<>();
        for (int i = 0; i < keys.size(); i++) {
            boolean cooling = blockedUntil[i] > now;
            out.add(new KeyState(i + 1, keys.get(i), i == current, cooling,
                    cooling ? (blockedUntil[i] - now) / 1000 : 0, failures[i], lastError[i]));
        }
        return out;
    }

    // ------------------------------------------------------------------ Phân loại lỗi

    public static Kind classify(Throwable t) {
        String text = messages(t).toLowerCase();
        if (text.contains("no longer available") || text.contains("is not found for api version")
                || text.contains("not_found") || text.matches("(?s).*\\b404\\b.*")) {
            return Kind.UNAVAILABLE;
        }
        if (text.contains("api key not valid") || text.contains("api_key_invalid") || text.contains("api key expired")
                || text.contains("invalid api key") || text.contains("permission_denied") || text.contains("unauthenticated")
                || text.contains("reported as leaked") || text.matches("(?s).*\\b(401|403)\\b.*")) {
            return Kind.INVALID;
        }
        if (text.contains("429") || text.contains("quota") || text.contains("resource_exhausted")
                || text.contains("rate limit") || text.contains("too many requests") || text.contains("exhausted")) {
            return (text.contains("perday") || text.contains("per day") || text.contains("daily")) ? Kind.QUOTA_DAILY : Kind.QUOTA;
        }
        return Kind.OTHER;
    }

    private static String messages(Throwable t) {
        StringBuilder sb = new StringBuilder();
        int depth = 0;
        for (Throwable c = t; c != null && depth < 6; c = c.getCause(), depth++) {
            sb.append(c.getClass().getSimpleName()).append(' ').append(c.getMessage()).append(' ');
        }
        return sb.toString();
    }
}
