package com.tourdulich.tracking;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.tourdulich.exception.ApiException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.sql.Timestamp;
import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Pattern;

/**
 * Ghi nhận và thống kê hành vi người dùng trên giao diện (user tracking).
 * Frontend gom sự kiện theo lô rồi gửi {@code POST /api/tracking/events}; dữ liệu chỉ gồm định danh ẩn danh
 * (không có nội dung nhập liệu, email, mật khẩu...).
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class TrackingService {

    public static final int MAX_EVENTS_PER_BATCH = 50;
    private static final ZoneId VN = ZoneId.of("Asia/Ho_Chi_Minh");
    private static final Pattern ID = Pattern.compile("^[A-Za-z0-9_-]{8,64}$");
    private static final Pattern TYPE = Pattern.compile("^[a-z][a-z0-9_]{1,39}$");
    private static final int MAX_PROPS_CHARS = 2000;

    public record EventDto(String type, String page, String target, Long tourId, Map<String, Object> props, Long ts) {
    }

    public record Batch(String anonymousId, String sessionId, List<EventDto> events) {
    }

    private final JdbcTemplate jdbc;
    private final ObjectMapper objectMapper;

    /** Lưu một lô sự kiện; sự kiện sai định dạng bị bỏ qua. Trả về số sự kiện đã lưu. */
    public int record(Batch batch, Long userId) {
        if (batch == null || batch.events() == null || batch.events().isEmpty()) {
            return 0;
        }
        if (!valid(batch.anonymousId(), ID) || !valid(batch.sessionId(), ID)) {
            throw ApiException.badRequest("anonymousId/sessionId không hợp lệ");
        }
        if (batch.events().size() > MAX_EVENTS_PER_BATCH) {
            throw ApiException.badRequest("Tối đa " + MAX_EVENTS_PER_BATCH + " sự kiện mỗi lần gửi");
        }
        long now = System.currentTimeMillis();
        List<Object[]> rows = new ArrayList<>();
        for (EventDto e : batch.events()) {
            if (e == null || !valid(e.type(), TYPE)) {
                continue;
            }
            long ts = e.ts() != null && e.ts() > now - 86_400_000L && e.ts() < now + 300_000L ? e.ts() : now;
            Long tourId = e.tourId() != null && e.tourId() > 0 ? e.tourId() : null;
            rows.add(new Object[]{batch.anonymousId(), batch.sessionId(), userId, e.type(), cut(e.page(), 255),
                    cut(e.target(), 255), tourId, json(e.props()),
                    Timestamp.valueOf(LocalDateTime.ofInstant(Instant.ofEpochMilli(ts), VN))});
        }
        if (rows.isEmpty()) {
            return 0;
        }
        jdbc.batchUpdate("INSERT INTO user_events (anonymous_id, session_id, user_id, event_type, page, target, tour_id, "
                + "props, occurred_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)", rows);
        return rows.size();
    }

    /** Thống kê N ngày gần nhất cho admin: lượt truy cập, phễu chuyển đổi, tour được xem nhiều, từ khóa tìm kiếm. */
    public Map<String, Object> summary(int days) {
        int d = Math.min(Math.max(days, 1), 90);
        Timestamp from = Timestamp.valueOf(LocalDateTime.now(VN).minusDays(d));
        Map<String, Object> out = new LinkedHashMap<>();
        out.put("days", d);
        out.put("visitors", jdbc.queryForObject(
                "SELECT COUNT(DISTINCT anonymous_id) FROM user_events WHERE occurred_at >= ?", Long.class, from));
        out.put("sessions", jdbc.queryForObject(
                "SELECT COUNT(DISTINCT session_id) FROM user_events WHERE occurred_at >= ?", Long.class, from));

        Map<String, Long> byType = new LinkedHashMap<>();
        jdbc.query("SELECT event_type, COUNT(*) n FROM user_events WHERE occurred_at >= ? GROUP BY event_type ORDER BY n DESC",
                rs -> {
                    byType.put(rs.getString("event_type"), rs.getLong("n"));
                }, from);
        out.put("byType", byType);

        // Phễu: số phiên (session) đi tới từng bước
        Map<String, Long> funnel = new LinkedHashMap<>();
        for (String step : List.of("view_tour", "add_to_cart", "begin_checkout", "booking_created")) {
            funnel.put(step, jdbc.queryForObject("SELECT COUNT(DISTINCT session_id) FROM user_events "
                    + "WHERE event_type = ? AND occurred_at >= ?", Long.class, step, from));
        }
        out.put("funnel", funnel);

        out.put("topTours", jdbc.queryForList(
                "SELECT e.tour_id AS tourId, t.name AS name, COUNT(*) AS views, COUNT(DISTINCT e.session_id) AS sessions "
                        + "FROM user_events e LEFT JOIN tours t ON t.id = e.tour_id "
                        + "WHERE e.event_type = 'view_tour' AND e.tour_id IS NOT NULL AND e.occurred_at >= ? "
                        + "GROUP BY e.tour_id, t.name ORDER BY views DESC LIMIT 5", from));
        // Theo ngày: số phiên và lượt xem trang (cho biểu đồ)
        out.put("daily", jdbc.queryForList(
                "SELECT DATE_FORMAT(occurred_at, '%Y-%m-%d') AS day, COUNT(DISTINCT session_id) AS sessions, "
                        + "SUM(event_type = 'page_view') AS pageViews, SUM(event_type = 'view_tour') AS tourViews "
                        + "FROM user_events WHERE occurred_at >= ? GROUP BY day ORDER BY day", from));
        // 25 sự kiện mới nhất (chỉ 6 ký tự đầu của mã ẩn danh, không hiện nội dung nhạy cảm)
        out.put("recent", jdbc.queryForList(
                "SELECT DATE_FORMAT(e.occurred_at, '%Y-%m-%d %H:%i:%s') AS at, e.event_type AS type, e.page AS page, "
                        + "e.target AS target, t.name AS tourName, LEFT(e.anonymous_id, 6) AS visitor, "
                        + "(e.user_id IS NOT NULL) AS loggedIn "
                        + "FROM user_events e LEFT JOIN tours t ON t.id = e.tour_id ORDER BY e.id DESC LIMIT 25"));
        out.put("topSearches", jdbc.queryForList(
                "SELECT JSON_VALUE(props, '$.keyword') AS keyword, COUNT(*) AS n FROM user_events "
                        + "WHERE event_type = 'search' AND occurred_at >= ? AND JSON_VALUE(props, '$.keyword') IS NOT NULL "
                        + "GROUP BY keyword ORDER BY n DESC LIMIT 5", from));
        return out;
    }

    private static boolean valid(String s, Pattern p) {
        return s != null && p.matcher(s).matches();
    }

    private static String cut(String s, int max) {
        if (s == null) {
            return null;
        }
        String t = s.strip();
        return t.isEmpty() ? null : (t.length() > max ? t.substring(0, max) : t);
    }

    private String json(Map<String, Object> props) {
        if (props == null || props.isEmpty()) {
            return null;
        }
        try {
            String s = objectMapper.writeValueAsString(props);
            return s.length() > MAX_PROPS_CHARS ? null : s;
        } catch (JsonProcessingException e) {
            return null;
        }
    }
}
