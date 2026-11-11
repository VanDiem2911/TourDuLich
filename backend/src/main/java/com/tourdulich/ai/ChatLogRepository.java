package com.tourdulich.ai;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Lịch sử hội thoại giữa khách và trợ lý AI (bảng {@code ai_chat_logs}) để admin xem lại chất lượng câu trả lời.
 * Nội dung được che email/số điện thoại trước khi lưu ({@link ChatRedactor}) và tự xóa sau {@code AI_CHAT_LOG_DAYS} ngày (mặc định 90).
 * Bảng tự được tạo nếu chưa có.
 */
@Slf4j
@Repository
public class ChatLogRepository {

    static final String DDL = """
            CREATE TABLE IF NOT EXISTS ai_chat_logs (
                id              BIGINT        NOT NULL AUTO_INCREMENT,
                conversation_id VARCHAR(64)   NOT NULL,
                user_id         BIGINT        NULL,
                question        TEXT          NOT NULL,
                answer          MEDIUMTEXT    NULL,
                sources         VARCHAR(255)  NULL,
                ok              TINYINT(1)    NOT NULL DEFAULT 1,
                error           VARCHAR(300)  NULL,
                latency_ms      INT           NULL,
                model           VARCHAR(120)  NULL,
                on_tour_id      BIGINT        NULL,
                created_at      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
                PRIMARY KEY (id),
                KEY idx_chat_conv (conversation_id, id),
                KEY idx_chat_time (created_at)
            ) ENGINE = InnoDB
            """;

    /** Một lượt hỏi đáp cần lưu. */
    public record Entry(String conversationId, Long userId, String question, String answer, String sources, boolean ok,
                        String error, int latencyMs, String model, Long onTourId) {
    }

    private final JdbcTemplate jdbc;
    private final int retentionDays;
    private final boolean redact;
    private volatile boolean schemaReady;

    public ChatLogRepository(JdbcTemplate jdbc, @Value("${AI_CHAT_LOG_DAYS:90}") int retentionDays,
                             @Value("${AI_CHAT_REDACT:true}") boolean redact) {
        this.jdbc = jdbc;
        this.redact = redact;
        this.retentionDays = retentionDays;
    }

    private void ensureSchema() {
        if (!schemaReady) {
            synchronized (this) {
                if (!schemaReady) {
                    jdbc.execute(DDL);
                    schemaReady = true;
                }
            }
        }
    }

    private String mask(String s) {
        return redact ? ChatRedactor.redact(s) : s;
    }

    public void insert(Entry e) {
        ensureSchema();
        jdbc.update("INSERT INTO ai_chat_logs (conversation_id, user_id, question, answer, sources, ok, error, latency_ms, model, on_tour_id) "
                        + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
                e.conversationId(), e.userId(), ChatRedactor.cut(mask(e.question()), 2000),
                ChatRedactor.cut(mask(e.answer()), 20000), e.sources(), e.ok() ? 1 : 0,
                ChatRedactor.cut(e.error(), 300), e.latencyMs(), ChatRedactor.cut(e.model(), 120), e.onTourId());
    }

    /** Danh sách hội thoại (mới nhất trước), có thể lọc theo từ khóa trong câu hỏi/câu trả lời. */
    public Map<String, Object> conversations(String keyword, int page, int size) {
        ensureSchema();
        int p = Math.max(1, page);
        int s = Math.min(Math.max(size, 1), 50);
        String like = keyword == null || keyword.isBlank() ? null : "%" + keyword.strip().replace("%", "").replace("_", "") + "%";
        String where = like == null ? "" : "WHERE c.question LIKE ? OR c.answer LIKE ? ";
        Object[] filter = like == null ? new Object[0] : new Object[]{like, like};

        Long total = jdbc.queryForObject("SELECT COUNT(*) FROM (SELECT c.conversation_id FROM ai_chat_logs c " + where
                + "GROUP BY c.conversation_id) x", Long.class, filter);

        Object[] args = new Object[filter.length + 2];
        System.arraycopy(filter, 0, args, 0, filter.length);
        args[filter.length] = s;
        args[filter.length + 1] = (p - 1) * s;
        List<Map<String, Object>> items = jdbc.queryForList(
                "SELECT c.conversation_id AS id, DATE_FORMAT(MIN(c.created_at), '%Y-%m-%d %H:%i') AS startedAt, "
                        + "DATE_FORMAT(MAX(c.created_at), '%Y-%m-%d %H:%i') AS lastAt, COUNT(*) AS turns, SUM(c.ok = 0) AS errors, "
                        + "MAX(u.full_name) AS userName, MAX(c.user_id) AS userId, "
                        + "(SELECT f.question FROM ai_chat_logs f WHERE f.conversation_id = c.conversation_id ORDER BY f.id LIMIT 1) AS firstQuestion "
                        + "FROM ai_chat_logs c LEFT JOIN users u ON u.id = c.user_id " + where
                        + "GROUP BY c.conversation_id ORDER BY MAX(c.id) DESC LIMIT ? OFFSET ?", args);
        Map<String, Object> out = new LinkedHashMap<>();
        out.put("items", items);
        out.put("total", total == null ? 0 : total);
        out.put("page", p);
        out.put("size", s);
        return out;
    }

    public List<Map<String, Object>> conversation(String conversationId) {
        ensureSchema();
        return jdbc.queryForList("SELECT c.id, DATE_FORMAT(c.created_at, '%Y-%m-%d %H:%i:%s') AS at, c.question, c.answer, c.sources, "
                + "c.ok AS ok, c.error, c.latency_ms AS latencyMs, c.model, c.on_tour_id AS onTourId, u.full_name AS userName "
                + "FROM ai_chat_logs c LEFT JOIN users u ON u.id = c.user_id WHERE c.conversation_id = ? ORDER BY c.id", conversationId);
    }

    public int delete(String conversationId) {
        ensureSchema();
        return jdbc.update("DELETE FROM ai_chat_logs WHERE conversation_id = ?", conversationId);
    }

    /** Thống kê nhanh cho trang admin: số hội thoại, số câu hỏi, số lỗi trong N ngày. */
    public Map<String, Object> stats(int days) {
        ensureSchema();
        Map<String, Object> m = jdbc.queryForMap("SELECT COUNT(DISTINCT conversation_id) AS conversations, COUNT(*) AS questions, "
                + "COALESCE(SUM(ok = 0), 0) AS errors, COALESCE(ROUND(AVG(latency_ms)), 0) AS avgLatencyMs "
                + "FROM ai_chat_logs WHERE created_at >= DATE_SUB(NOW(), INTERVAL ? DAY)", Math.min(Math.max(days, 1), 365));
        return new LinkedHashMap<>(m);
    }

    @EventListener(ApplicationReadyEvent.class)
    public void purgeOld() {
        try {
            ensureSchema();
            int n = jdbc.update("DELETE FROM ai_chat_logs WHERE created_at < DATE_SUB(NOW(), INTERVAL ? DAY)", retentionDays);
            if (n > 0) {
                log.info("Đã xóa {} lượt chat cũ hơn {} ngày.", n, retentionDays);
            }
        } catch (Exception e) {
            log.warn("Không dọn được lịch sử chat cũ: {}", e.getMessage());
        }
    }
}
