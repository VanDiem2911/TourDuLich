-- =====================================================================
-- Website Tour Du Lịch - Nhóm 22 (DHKTPM19B) - MariaDB
-- Theo đặc tả: KHÔNG dùng Function, Check Constraint, Stored Procedure.
-- Mọi ràng buộc nghiệp vụ được kiểm tra ở Frontend và Backend (Service).
-- Chạy file này một lần:  mariadb -u root -p < database/schema.sql
-- =====================================================================

CREATE DATABASE IF NOT EXISTS tourdulich
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE tourdulich;

-- ---------------------------------------------------------------------
-- 7.1 users
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS users (
    id            BIGINT       NOT NULL AUTO_INCREMENT,
    full_name     VARCHAR(100) NOT NULL,
    email         VARCHAR(150) NOT NULL,
    phone         VARCHAR(20)  NULL,
    address       VARCHAR(255) NULL,
    password_hash VARCHAR(255) NOT NULL,
    role          VARCHAR(20)  NOT NULL DEFAULT 'ROLE_CUSTOMER',  -- ROLE_CUSTOMER / ROLE_ADMIN
    status        VARCHAR(20)  NOT NULL DEFAULT 'ACTIVE',         -- ACTIVE / INACTIVE
    created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uk_users_email (email)
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------
-- 7.2 categories
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS categories (
    id          BIGINT       NOT NULL AUTO_INCREMENT,
    name        VARCHAR(100) NOT NULL,
    description TEXT         NULL,
    status      VARCHAR(20)  NOT NULL DEFAULT 'ACTIVE',           -- ACTIVE / INACTIVE
    created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uk_categories_name (name)
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------
-- 7.3 tours   (thêm cột transport theo mục 2.2 của đặc tả)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tours (
    id                 BIGINT        NOT NULL AUTO_INCREMENT,
    category_id        BIGINT        NOT NULL,
    tour_code          VARCHAR(50)   NOT NULL,
    name               VARCHAR(255)  NOT NULL,
    departure_location VARCHAR(150)  NULL,
    destination        VARCHAR(150)  NULL,
    duration           VARCHAR(50)   NULL,                        -- 3N2Đ, 4N3Đ...
    transport          VARCHAR(100)  NULL,                        -- Máy bay, xe du lịch, tàu hỏa, du thuyền...
    departure_date     DATETIME      NULL,
    adult_price        DECIMAL(15,2) NOT NULL,
    child_price        DECIMAL(15,2) NULL,
    promo_price        DECIMAL(15,2) NULL,                        -- giá khuyến mãi người lớn (nếu có, phải < adult_price)
    total_seats        INT           NOT NULL,
    available_seats    INT           NOT NULL,
    image_url          VARCHAR(500)  NULL,
    short_description  VARCHAR(500)  NULL,
    itinerary          TEXT          NULL,
    gallery_urls       TEXT          NULL,                        -- ảnh bổ sung, mỗi dòng một URL
    notes              TEXT          NULL,                        -- giá bao gồm / không bao gồm, giấy tờ, quy định hủy
    status             VARCHAR(20)   NOT NULL DEFAULT 'ACTIVE',   -- ACTIVE / CLOSED / COMPLETED
    region             VARCHAR(20)   NOT NULL DEFAULT 'DOMESTIC', -- DOMESTIC (trong nước) / INTERNATIONAL (nước ngoài)
    created_at         DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at         DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uk_tours_code (tour_code),
    KEY idx_tours_category (category_id),
    KEY idx_tours_status_departure (status, departure_date),
    KEY idx_tours_region (region),
    CONSTRAINT fk_tours_category FOREIGN KEY (category_id) REFERENCES categories (id)
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------
-- 7.4 bookings (+ các cột thanh toán chuyển khoản QR / lý do hủy)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS bookings (
    id              BIGINT        NOT NULL AUTO_INCREMENT,
    booking_code    VARCHAR(50)   NOT NULL,                       -- BK-20260826-001
    user_id         BIGINT        NOT NULL,
    contact_name    VARCHAR(100)  NULL,
    contact_phone   VARCHAR(20)   NULL,
    contact_email   VARCHAR(150)  NULL,
    special_request TEXT          NULL,
    total_amount    DECIMAL(15,2) NOT NULL,
    payment_status  VARCHAR(30)   NOT NULL DEFAULT 'UNPAID',      -- UNPAID / PAID / REFUNDED
    booking_status  VARCHAR(30)   NOT NULL DEFAULT 'PENDING',     -- PENDING / CONFIRMED / COMPLETED / CANCELLED
    payment_code    VARCHAR(30)   NULL,                           -- mã ngẫu nhiên ghi trong nội dung chuyển khoản
    payment_method  VARCHAR(30)   NULL,                           -- BANK_QR / OFFICE
    paid_at         DATETIME      NULL,
    payment_note    VARCHAR(500)  NULL,
    cancel_reason   VARCHAR(500)  NULL,
    created_at      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uk_bookings_code (booking_code),
    UNIQUE KEY uk_bookings_payment_code (payment_code),
    KEY idx_bookings_user_created (user_id, created_at),
    KEY idx_bookings_status (booking_status),
    CONSTRAINT fk_bookings_user FOREIGN KEY (user_id) REFERENCES users (id)
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------
-- 7.5 booking_items (snapshot giá/tên/ngày tại thời điểm đặt)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS booking_items (
    id             BIGINT        NOT NULL AUTO_INCREMENT,
    booking_id     BIGINT        NOT NULL,
    tour_id        BIGINT        NOT NULL,
    tour_name      VARCHAR(255)  NOT NULL,
    departure_date DATETIME      NULL,
    adult_price    DECIMAL(15,2) NOT NULL,
    child_price    DECIMAL(15,2) NULL,
    adult_quantity INT           NOT NULL,
    child_quantity INT           NOT NULL DEFAULT 0,
    subtotal       DECIMAL(15,2) NOT NULL,
    PRIMARY KEY (id),
    KEY idx_items_booking (booking_id),
    KEY idx_items_tour (tour_id),
    CONSTRAINT fk_items_booking FOREIGN KEY (booking_id) REFERENCES bookings (id),
    CONSTRAINT fk_items_tour FOREIGN KEY (tour_id) REFERENCES tours (id)
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------
-- Bảng mở rộng (UC-16/17 Liên hệ) - chưa có entity, bổ sung ở giai đoạn sau
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS contacts (
    id            BIGINT       NOT NULL AUTO_INCREMENT,
    user_id       BIGINT       NULL,                              -- có giá trị nếu người gửi đã đăng nhập
    full_name     VARCHAR(100) NOT NULL,
    email         VARCHAR(150) NOT NULL,
    phone         VARCHAR(20)  NULL,
    subject       VARCHAR(200) NOT NULL,
    message       TEXT         NOT NULL,
    status        VARCHAR(20)  NOT NULL DEFAULT 'NEW',            -- NEW / IN_PROGRESS / RESOLVED
    reply_content TEXT         NULL,
    admin_note    VARCHAR(500) NULL,
    replied_by    BIGINT       NULL,
    replied_at    DATETIME     NULL,
    created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_contacts_status_created (status, created_at),
    KEY idx_contacts_email_created (email, created_at),
    CONSTRAINT fk_contacts_user FOREIGN KEY (user_id) REFERENCES users (id),
    CONSTRAINT fk_contacts_replied_by FOREIGN KEY (replied_by) REFERENCES users (id)
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------
-- Bảng mở rộng - giao dịch ngân hàng nhận qua webhook (đối soát thanh toán QR)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS payment_transactions (
    id               BIGINT        NOT NULL AUTO_INCREMENT,
    transaction_ref  VARCHAR(100)  NOT NULL,                      -- mã giao dịch do nhà cung cấp gửi, chống xử lý trùng
    gateway          VARCHAR(50)   NULL,                          -- SEPAY / CASSO / ...
    booking_id       BIGINT        NULL,                          -- NULL nếu chưa khớp được đơn
    amount           DECIMAL(15,2) NOT NULL,
    content          VARCHAR(500)  NULL,                          -- nội dung chuyển khoản
    account_number   VARCHAR(50)   NULL,
    transaction_time DATETIME      NULL,
    match_status     VARCHAR(30)   NOT NULL,                      -- MATCHED / UNMATCHED / UNDERPAID / OVERPAID / ORDER_CANCELLED
    raw_payload      TEXT          NULL,
    created_at       DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uk_payment_tx_ref (transaction_ref),
    KEY idx_payment_tx_booking (booking_id),
    KEY idx_payment_tx_match (match_status),
    CONSTRAINT fk_payment_tx_booking FOREIGN KEY (booking_id) REFERENCES bookings (id)
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------
-- Bảng mở rộng - ghi nhận hành vi người dùng trên giao diện (user tracking)
-- ---------------------------------------------------------------------
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

-- ---------------------------------------------------------------------
-- Bảng mở rộng - lịch sử chat giữa khách và trợ lý AI (che email/SĐT, tự xóa sau 90 ngày)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ai_chat_logs (
    id              BIGINT        NOT NULL AUTO_INCREMENT,
    conversation_id VARCHAR(64)   NOT NULL,                       -- mã một cuộc trò chuyện (frontend sinh)
    user_id         BIGINT        NULL,                           -- có giá trị nếu khách đã đăng nhập
    question        TEXT          NOT NULL,
    answer          MEDIUMTEXT    NULL,
    sources         VARCHAR(255)  NULL,                           -- id các tour được nhắc tới, cách nhau bằng dấu phẩy
    ok              TINYINT(1)    NOT NULL DEFAULT 1,
    error           VARCHAR(300)  NULL,
    latency_ms      INT           NULL,
    model           VARCHAR(120)  NULL,                           -- key/mô hình đã trả lời (key đã che)
    on_tour_id      BIGINT        NULL,                           -- tour khách đang xem lúc hỏi
    created_at      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_chat_conv (conversation_id, id),
    KEY idx_chat_time (created_at)
) ENGINE = InnoDB;

-- Vector của trợ lý AI (lưu dạng nhị phân; tìm kiếm chạy trong bộ nhớ) và bộ nhớ đệm embedding
CREATE TABLE IF NOT EXISTS ai_vectors (
    id         VARCHAR(190) NOT NULL,
    kind       VARCHAR(20)  NOT NULL,                             -- tour / overview / doc
    tour_id    BIGINT       NULL,
    content    MEDIUMTEXT   NOT NULL,
    metadata   TEXT         NULL,
    embedding  MEDIUMBLOB   NOT NULL,                             -- float32 big-endian
    dims       INT          NOT NULL,
    model      VARCHAR(100) NOT NULL,
    updated_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_ai_vectors_tour (tour_id),
    KEY idx_ai_vectors_kind (kind)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS ai_embedding_cache (
    hash       CHAR(64)     NOT NULL,                             -- SHA-256(mô hình + nội dung)
    namespace  VARCHAR(100) NOT NULL,
    embedding  MEDIUMBLOB   NOT NULL,
    created_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (hash),
    KEY idx_ai_cache_ns (namespace)
) ENGINE = InnoDB;
