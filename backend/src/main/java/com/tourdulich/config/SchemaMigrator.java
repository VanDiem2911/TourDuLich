package com.tourdulich.config;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.core.annotation.Order;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

/**
 * Nâng cấp CSDL đã có sẵn (Hibernate để ddl-auto=none nên không tự thêm cột): bổ sung cột tours.region
 * (DOMESTIC / INTERNATIONAL), tours.notes (giá bao gồm, quy định...), tours.promo_price và tours.gallery_urls, cùng bảng user_events nếu còn thiếu. Chạy trước các seeder;
 * an toàn khi chạy lại. Bảng chưa tồn tại thì bỏ qua (dùng database/schema.sql, đã có sẵn các cột này).
 */
@Slf4j
@Order(0)
@Component
@RequiredArgsConstructor
public class SchemaMigrator implements CommandLineRunner {

    private final JdbcTemplate jdbc;

    @Override
    public void run(String... args) {
        try {
            if (!tableExists("tours")) {
                return;
            }
            if (!columnExists("tours", "region")) {
                jdbc.execute("ALTER TABLE tours ADD COLUMN region VARCHAR(20) NOT NULL DEFAULT 'DOMESTIC' AFTER status");
                jdbc.execute("CREATE INDEX idx_tours_region ON tours (region)");
                // Tour của danh mục "Tour quốc tế" và các tour có điểm đến ở nước ngoài thuộc nhóm nước ngoài
                int n = jdbc.update("UPDATE tours t JOIN categories c ON c.id = t.category_id "
                        + "SET t.region = 'INTERNATIONAL' WHERE c.name = 'Tour quốc tế' OR t.tour_code = 'TOUR-KH-001'");
                log.info("Đã thêm cột tours.region và gán 'nước ngoài' cho {} tour.", n);
            }
            if (!columnExists("tours", "notes")) {
                jdbc.execute("ALTER TABLE tours ADD COLUMN notes TEXT NULL AFTER itinerary");
                log.info("Đã thêm cột tours.notes.");
            }
            if (!columnExists("tours", "promo_price")) {
                jdbc.execute("ALTER TABLE tours ADD COLUMN promo_price DECIMAL(15,2) NULL AFTER child_price");
                log.info("Đã thêm cột tours.promo_price.");
            }
            if (!columnExists("tours", "gallery_urls")) {
                jdbc.execute("ALTER TABLE tours ADD COLUMN gallery_urls TEXT NULL AFTER notes");
                log.info("Đã thêm cột tours.gallery_urls.");
            }
            if (!tableExists("user_events")) {
                jdbc.execute("""
                        CREATE TABLE user_events (
                            id           BIGINT       NOT NULL AUTO_INCREMENT,
                            anonymous_id VARCHAR(64)  NOT NULL,
                            session_id   VARCHAR(64)  NOT NULL,
                            user_id      BIGINT       NULL,
                            event_type   VARCHAR(40)  NOT NULL,
                            page         VARCHAR(255) NULL,
                            target       VARCHAR(255) NULL,
                            tour_id      BIGINT       NULL,
                            props        TEXT         NULL,
                            occurred_at  DATETIME     NOT NULL,
                            created_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
                            PRIMARY KEY (id),
                            KEY idx_events_type_time (event_type, occurred_at),
                            KEY idx_events_tour (tour_id, event_type),
                            KEY idx_events_anon (anonymous_id),
                            KEY idx_events_session (session_id)
                        ) ENGINE = InnoDB
                        """);
                log.info("Đã tạo bảng user_events (ghi nhận hành vi người dùng).");
            }
        } catch (Exception ex) {
            log.error("Nâng cấp CSDL thất bại: {}. Hãy chạy database/migration_region.sql thủ công.", ex.getMessage());
        }
    }

    private boolean tableExists(String table) {
        Integer n = jdbc.queryForObject("SELECT COUNT(*) FROM information_schema.TABLES "
                + "WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ?", Integer.class, table);
        return n != null && n > 0;
    }

    private boolean columnExists(String table, String column) {
        Integer n = jdbc.queryForObject("SELECT COUNT(*) FROM information_schema.COLUMNS "
                + "WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ? AND COLUMN_NAME = ?", Integer.class, table, column);
        return n != null && n > 0;
    }
}
