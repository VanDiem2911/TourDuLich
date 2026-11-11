-- Nâng cấp CSDL đã tạo từ trước: thêm phân loại tour trong nước / nước ngoài (region) và ghi chú tour (notes).
-- Backend (SchemaMigrator) tự chạy việc này khi khởi động; file này dùng nếu muốn chạy tay:
--   mariadb -u root -p tourdulich < database/migration_region.sql
USE tourdulich;

ALTER TABLE tours ADD COLUMN region VARCHAR(20) NOT NULL DEFAULT 'DOMESTIC' AFTER status;  -- DOMESTIC / INTERNATIONAL
CREATE INDEX idx_tours_region ON tours (region);
ALTER TABLE tours ADD COLUMN notes TEXT NULL AFTER itinerary;  -- giá bao gồm / không bao gồm, quy định hủy
ALTER TABLE tours ADD COLUMN promo_price DECIMAL(15,2) NULL AFTER child_price;  -- giá khuyến mãi người lớn
ALTER TABLE tours ADD COLUMN gallery_urls TEXT NULL AFTER notes;  -- ảnh bổ sung, mỗi dòng một URL

UPDATE tours t JOIN categories c ON c.id = t.category_id
   SET t.region = 'INTERNATIONAL'
 WHERE c.name = 'Tour quốc tế' OR t.tour_code = 'TOUR-KH-001';

-- Bảng ghi nhận hành vi người dùng (user tracking)
CREATE TABLE IF NOT EXISTS user_events (
    id           BIGINT       NOT NULL AUTO_INCREMENT,
    anonymous_id VARCHAR(64)  NOT NULL,                           -- mã ẩn danh lưu ở trình duyệt khách
    session_id   VARCHAR(64)  NOT NULL,                           -- phiên truy cập (hết sau 30 phút không hoạt động)
    user_id      BIGINT       NULL,                               -- có giá trị nếu khách đã đăng nhập lúc gửi sự kiện
    event_type   VARCHAR(40)  NOT NULL,                           -- page_view, click, view_tour, search, add_to_cart...
    page         VARCHAR(255) NULL,
    target       VARCHAR(255) NULL,
    tour_id      BIGINT       NULL,                               -- không đặt khóa ngoại: tour bị xóa vẫn giữ lịch sử
    props        TEXT         NULL,                               -- JSON thuộc tính bổ sung
    occurred_at  DATETIME     NOT NULL,
    created_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_events_type_time (event_type, occurred_at),
    KEY idx_events_tour (tour_id, event_type),
    KEY idx_events_anon (anonymous_id),
    KEY idx_events_session (session_id)
) ENGINE = InnoDB;
