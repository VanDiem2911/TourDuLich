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
    total_seats        INT           NOT NULL,
    available_seats    INT           NOT NULL,
    image_url          VARCHAR(500)  NULL,
    short_description  VARCHAR(500)  NULL,
    itinerary          TEXT          NULL,
    status             VARCHAR(20)   NOT NULL DEFAULT 'ACTIVE',   -- ACTIVE / CLOSED / COMPLETED
    created_at         DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at         DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uk_tours_code (tour_code),
    KEY idx_tours_category (category_id),
    KEY idx_tours_status_departure (status, departure_date),
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
