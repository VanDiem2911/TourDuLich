-- =====================================================================
-- Dữ liệu mẫu cho website đặt tour du lịch (Nhóm 22 - DHKTPM19B)
-- Gồm 5 danh mục. Tour mẫu nằm ở seed_fiditour.sql.
-- Tài khoản Admin do backend tự tạo ở lần chạy đầu. File được backend nạp tự động khi bảng categories còn trống.
-- Chạy tay sau schema.sql:  mariadb -u root -p tourdulich < database/seed.sql
-- =====================================================================
USE tourdulich;

INSERT INTO categories (name, description, status) VALUES
    ('Tour trong nước', 'Khám phá các điểm đến đẹp khắp ba miền Bắc - Trung - Nam với lịch trình trọn gói.', 'ACTIVE'),
    ('Tour quốc tế', 'Hành trình đến Đông Nam Á, Đông Á và nhiều quốc gia khác, có hướng dẫn viên tiếng Việt.', 'ACTIVE'),
    ('Nghỉ dưỡng biển đảo', 'Nghỉ dưỡng thư giãn tại các bãi biển và hòn đảo nổi tiếng trong nước.', 'ACTIVE'),
    ('Khám phá & Trekking', 'Hành trình vùng cao, đi bộ đường dài và trải nghiệm thiên nhiên nguyên sơ.', 'ACTIVE'),
    ('Văn hóa - Lịch sử', 'Tìm hiểu di sản, di tích lịch sử, làng nghề và văn hóa địa phương.', 'ACTIVE');

-- Tour không nằm ở file này nữa: backend nạp tiếp database/seed_fiditour.sql (tour lấy từ fiditour.com
-- bằng tools/scrape_fiditour.py, đã chia trong nước / nước ngoài).
