# Website Tour Du Lịch - Nhóm 22 (DHKTPM19B)

Đề tài số 49: Website giới thiệu tour du lịch và cho phép đăng ký tour trực tuyến.
Tài liệu gốc nằm trong thư mục `Tài Liệu/`.

| Thành phần | Công nghệ |
|---|---|
| Backend | Java 21, Spring Boot 3.5 (Web, Data JPA, Security, Validation, Mail), JWT, BCrypt, Bucket4j |
| Frontend | React 19, Vite, React Router, Axios |
| CSDL | MariaDB (local) |

## Cấu trúc thư mục

```
TourDuLich/
├── backend/    Spring Boot REST API
├── frontend/   React SPA (Vite)
├── database/   schema.sql (5 bảng nghiệp vụ + contacts + payment_transactions), seed.sql (dữ liệu mẫu)
└── Tài Liệu/   Đặc tả đề tài và use case
```

## Chạy dự án lần đầu

### 1. Cơ sở dữ liệu
```bash
mariadb -u root -p --default-character-set=utf8mb4 < database/schema.sql
mariadb -u root -p --default-character-set=utf8mb4 < database/seed.sql
```

### 2. Backend (cổng 8080)
Cấu hình mật khẩu MariaDB bằng 1 trong 2 cách:
- Sao chép `backend/src/main/resources/application-local.example.yml` thành `application-local.yml`
  (file này đã bị git bỏ qua) rồi điền mật khẩu, chạy với profile `local`; hoặc
- Đặt biến môi trường `DB_USERNAME`, `DB_PASSWORD`.

```bash
cd backend
mvn spring-boot:run -Dspring-boot.run.profiles=local
```
Lần chạy đầu, backend tự tạo tài khoản Admin: `admin@tourdulich.local` / `Admin@123`
(đổi bằng biến môi trường `ADMIN_EMAIL`, `ADMIN_PASSWORD`).

Biến môi trường khác: `JWT_SECRET` (>= 32 ký tự, bắt buộc đổi khi triển khai thật),
`MAIL_ENABLED=true` kèm `MAIL_HOST`, `MAIL_PORT`, `MAIL_USERNAME`, `MAIL_PASSWORD` để gửi email thật
(mặc định chỉ ghi log).

### 3. Frontend (cổng 5173)
```bash
cd frontend
npm install
npm run dev
```
Vite proxy `/api` sang `http://localhost:8080` nên không vướng CORS và cookie Session Cart hoạt động.

## Quy ước kỹ thuật chính

- **Xác thực:** JWT (access 30 phút, refresh 7 ngày), phân quyền `ROLE_CUSTOMER` / `ROLE_ADMIN`.
  `/api/admin/**` bắt buộc ROLE_ADMIN.
- **Giỏ tour:** lưu trong HTTP Session (cookie `JSESSIONID`), không lưu DB. Axios luôn gửi `withCredentials`.
- **CSDL:** do `database/schema.sql` quản lý (`ddl-auto: none`). Theo đề bài không dùng Function,
  Check Constraint, Stored Procedure; ràng buộc kiểm tra ở Frontend và Backend.
- **Rate limit** theo IP (Bucket4j): login 5/phút, register 5/phút, refresh 10/phút, bookings 10/phút, vượt thì HTTP 429.
- **Lỗi API** có định dạng chung: `{ timestamp, status, error, message, path, fieldErrors? }`.
- **Không bao giờ** trả `password` hoặc `passwordHash` trong response.

## Tiến độ

| Giai đoạn | Trạng thái |
|---|---|
| 0. Nền móng (project, CSDL, entity, lỗi chung, CORS) | Xong |
| 1. Auth và bảo mật (register, login, refresh, logout, me, JWT, rate limit) | Xong (backend + giao diện đăng nhập, đăng ký) |
| 2. Tour và danh mục | Chưa làm |
| 3. Giỏ tour và đặt tour | Chưa làm |
| 4-6. Giao diện khách, tài khoản, Admin | Khung layout và route đã có, trang chức năng là trang khung |
| 7. Liên hệ, thanh toán chuyển khoản QR + webhook | Bảng CSDL đã có, chưa có code |
