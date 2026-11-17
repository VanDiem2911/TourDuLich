# Hướng dẫn cấu hình thanh toán QR + SePay (chạy demo trên máy)

Tài liệu ghi lại **toàn bộ các bước đã làm** để thanh toán chuyển khoản QR tự xác nhận qua SePay, từ backend, frontend,
đường hầm Cloudflare đến cấu hình SePay. Dùng để làm tiếp hoặc dựng lại về sau.

> Tài liệu **không chứa bí mật**. Các giá trị thật (khóa webhook, `JWT_SECRET`, số tài khoản) chỉ nằm trong `backend/.env`
> (file này đã `.gitignore`, không commit).

## 1. Luồng hoạt động

```
Khách đặt tour ─► Backend sinh mã TOURxxxxxx ─► Khách quét QR, chuyển khoản kèm mã
                                                          │
 Trang thanh toán hỏi lại mỗi 5s ◄─ Backend đánh dấu PAID ◄─ SePay gọi webhook ◄─ TPBank báo biến động số dư
```

| Bước | Việc xảy ra | Vị trí code |
|---|---|---|
| 1 | Tạo đơn, sinh mã `TOUR` + 6 ký tự ngẫu nhiên (không trùng) | `BookingService.nextPaymentCode()` |
| 2 | Tạo URL ảnh QR VietQR có sẵn số tiền và nội dung chuyển khoản | `PaymentService.toInfo()`, `Payment.jsx` |
| 3 | SePay gọi `POST /api/payments/webhook` kèm header `Authorization: Apikey <khóa>` | `PaymentController`, `PaymentService.verifyWebhookKey()` |
| 4 | Đối soát: tìm mã trong nội dung, so số tiền, ghi `payment_transactions`, đánh dấu đã thanh toán | `PaymentService.handleWebhook()`, `processWebhook()` |
| 5 | Trang thanh toán hỏi `payment-info` mỗi 5 giây tới khi hết `UNPAID` | `frontend/src/pages/Payment.jsx` |

Kết quả đối soát (`MatchStatus`):

| Trạng thái | Khi nào | Đơn có được xác nhận? |
|---|---|---|
| `MATCHED` | Đúng số tiền | Có |
| `OVERPAID` | Chuyển thừa (hoặc đơn đã `PAID` mà còn tiền vào) | Có nếu đơn đang `UNPAID`; phần dư cần đối soát tay |
| `UNDERPAID` | Chuyển thiếu | **Không**, chỉ ghi lịch sử |
| `UNMATCHED` | Không thấy mã `TOUR…` hoặc không có đơn tương ứng | Không |
| `ORDER_CANCELLED` | Đơn đã hủy hoặc hoàn tiền | Không |

Các lớp bảo vệ: xác thực bằng API Key (so sánh thời gian hằng định), chống trùng theo `id` giao dịch (có ràng buộc duy nhất
trong DB), khóa dòng đơn khi xử lý, bỏ qua giao dịch `transferType = out`.

## 2. Chuẩn bị một lần

| Cần có | Ghi chú |
|---|---|
| Tài khoản SePay | Đăng ký tại `my.sepay.vn`; chọn nhu cầu **"Chỉ cần chia sẻ biến động số dư"** |
| Tài khoản TPBank | Số tài khoản nhận tiền; liên kết với SePay ở mục 5 |
| MariaDB cục bộ | Cần bản 11.7 trở lên (chatbot dùng kiểu `VECTOR`). Máy đang dùng 12.3.3 |
| `cloudflared` | Cài bằng `winget install Cloudflare.cloudflared`, kiểm tra `cloudflared --version` |
| Java 21, Maven, Node | Để chạy backend và frontend |

## 3. Backend

### 3.1. Biến môi trường trong `backend/.env`

Mẫu đầy đủ ở `backend/.env.example`. Phần liên quan thanh toán và bảo mật:

| Biến | Ý nghĩa | Giá trị |
|---|---|---|
| `PAYMENT_BANK_NAME` | Tên ngân hàng hiển thị cho khách | `TPBank` |
| `PAYMENT_BANK_CODE` | Mã ngân hàng cho ảnh QR VietQR | `TPB` (BIN `970423`; tên `TPBank` cũng chạy) |
| `PAYMENT_ACCOUNT_NUMBER` | Số tài khoản nhận tiền | số tài khoản của bạn |
| `PAYMENT_ACCOUNT_NAME` | Tên chủ tài khoản | **chữ in hoa, không dấu**, đúng như ngân hàng |
| `PAYMENT_WEBHOOK_KEY` | Khóa xác thực webhook | chuỗi ngẫu nhiên dài, **không dùng giá trị mặc định** |
| `PAYMENT_SIMULATE_ENABLED` | Hiện nút "thanh toán giả lập" | `true` khi demo, **`false` khi chạy thật** |
| `JWT_SECRET` | Khóa ký token đăng nhập | 64 ký tự hex ngẫu nhiên |
| `ADMIN_EMAIL`, `ADMIN_PASSWORD` | Tài khoản admin tạo ở lần chạy đầu | xem lưu ý bên dưới |

Tạo chuỗi ngẫu nhiên (PowerShell):

```powershell
$b = New-Object byte[] 32; [Security.Cryptography.RNGCryptoServiceProvider]::new().GetBytes($b); ($b | % { $_.ToString('x2') }) -join ''
```

Lưu ý:
- File `.env` đang dùng xuống dòng CRLF. Sửa bằng công cụ thay chuỗi chính xác để không làm hỏng ký tự xuống dòng.
- Sửa `ADMIN_PASSWORD` trong `.env` **không đổi** mật khẩu admin đã có trong DB (chỉ tác dụng lần tạo đầu). Muốn đổi, đăng
  nhập admin rồi vào trang **Tài khoản**.
- Đổi `JWT_SECRET` làm mọi người đang đăng nhập bị đăng xuất.
- Đổi `.env` xong phải **restart backend**.

### 3.2. Chạy và kiểm tra

```powershell
cd backend
mvn spring-boot:run          # hoặc chạy từ IDE
```

Mở `http://localhost:8080/api/health`, phải ra `{"status":"UP"}`.

Mở `/` của backend sẽ ra `401 Vui lòng đăng nhập`. Đó là **bình thường**: mọi đường dẫn không nằm trong danh sách công khai
của `SecurityConfig` đều cần đăng nhập.

### 3.3. Yêu cầu định dạng của SePay (đã xử lý trong code)

- Phản hồi phải là HTTP **200 hoặc 201**, body **đúng** `{"success": true}` (không thêm trường khác), trong 30 giây.
  `PaymentController.webhook()` đã trả đúng như vậy.
- Header xác thực: `Authorization: Apikey <khóa>`.
- Payload gồm: `id`, `gateway`, `transactionDate`, `accountNumber`, `subAccount`, `code`, `content`, `transferType`
  (`in` hoặc `out`), `description`, `transferAmount`, `accumulated`, `referenceCode`. Backend chỉ dùng `id`, `gateway`,
  `transferAmount`, `content`, `accountNumber`, `transactionDate`, `transferType`.

## 4. Frontend

Chạy dev:

```powershell
cd frontend
npm install        # lần đầu
npm run dev        # http://localhost:5173
```

- Frontend gọi API bằng đường dẫn tương đối `/api` và `/uploads` (`frontend/src/api/client.js`). Vite proxy chuyển hai
  đường dẫn này tới `http://localhost:8080` (`frontend/vite.config.js`), đổi bằng biến `API_PROXY`.
- Làm vậy để **cùng origin**, nên cookie `JSESSIONID` của giỏ tour hoạt động mà không vướng CORS.
- Đăng nhập dùng JWT lưu ở `localStorage`; chỉ giỏ tour cần cookie phiên.
- Trang thanh toán (`Payment.jsx`): hiển thị QR từ `info.qrUrl`, nút chép nội dung chuyển khoản, và tự hỏi lại mỗi 5 giây.

> Nếu frontend triển khai ở Vercel: phải có rewrite `/api/*` và `/uploads/*` sang backend (xem mục 9), vì cookie phiên
> `same-site: lax` không đi được giữa hai tên miền khác nhau.

## 5. SePay

### 5.1. Liên kết tài khoản TPBank

1. Trong SePay, thêm tài khoản ngân hàng (**Bank accounts → Add**), chọn **TPBank**, nhập số tài khoản.
2. SePay chuyển sang `tpconnect.tpb.vn` (cổng TPBank Connect). Trước khi đăng nhập hãy kiểm tra thanh địa chỉ đúng tên
   miền `tpb.vn` (chứng chỉ SSL cấp cho TPBank). Nhập tài khoản và mật khẩu **trên trang của TPBank**, rồi nhập OTP nếu
   được hỏi. Đừng đọc OTP cho ai.
3. Chờ khoảng 1 phút để TPBank đồng bộ giao dịch. Tài khoản hiện nhãn **API Banking**.
4. Bỏ qua phần "Tài khoản ảo (VA)". Luồng này dùng chính số tài khoản và mã `TOUR…` trong nội dung chuyển khoản.

### 5.2. Tạo webhook

Menu **Webhooks** (`my.sepay.vn/webhooks`) → **Thêm webhook**:

| Mục | Giá trị |
|---|---|
| Tên | tùy ý (đang dùng "Xác Thực Thanh Toán") |
| URL | `https://<địa-chỉ-đường-hầm>/api/payments/webhook` |
| Event type | **Có tiền vào** (Money in) |
| Content-Type | `application/json` |
| Tài khoản | chọn đúng tài khoản TPBank (bỏ trống bộ lọc prefix, tắt "Skip transactions without code") |
| Bảo mật | **API Key**, dán đúng giá trị `PAYMENT_WEBHOOK_KEY` trong `.env` |
| Tự gửi lại khi lỗi | Bật |

- SePay chỉ hiện khóa đầy đủ **một lần**, sau đó chỉ thấy 4 ký tự cuối. Nếu mất, sửa webhook và dán lại.
- Backend tự tìm mã `TOUR[A-Z0-9]{6}` trong nội dung, nên không cần cấu hình "cấu trúc mã thanh toán" của SePay.
- SePay khuyên HMAC-SHA256 cho bảo mật, nhưng backend hiện chỉ hỗ trợ API Key.

### 5.3. Gửi thử

Ở dòng webhook, bấm **⋮ → Gửi thử**. Đúng là **HTTP 200** (đã thử: 405 ms). Giao dịch mẫu không có mã `TOUR…` nên backend
ghi một dòng `UNMATCHED` vào `payment_transactions`. Đó là bình thường. Test send dùng `id` mẫu cố định nên các lần thử
sau trả `DUPLICATE`.

Xem lại các lần gửi ở tab **Lịch sử gửi**.

### 5.4. Cơ chế gửi lại của SePay

- Luôn gửi lại khi không kết nối được (lỗi DNS, từ chối kết nối, hết thời gian, lỗi SSL).
- Gửi lại với mã HTTP ngoài 200-299 nếu bật "Tự gửi lại khi lỗi".
- Khoảng cách tăng dần theo dãy Fibonacci, tối đa 8 lần gửi trong khoảng 33 phút, sau đó đánh dấu thất bại.
- `id` giao dịch không đổi giữa các lần gửi lại, backend dùng nó để chống xử lý trùng.

## 6. Đường hầm Cloudflare (để SePay gọi vào máy)

SePay gọi từ máy chủ của họ nên không tới được `localhost`. Dùng đường hầm nhanh của Cloudflare, không cần tài khoản:

```powershell
cloudflared tunnel --url http://localhost:8080
```

Sau vài giây in ra địa chỉ dạng `https://xxx-yyy-zzz.trycloudflare.com`. Giữ cửa sổ này mở.

**Đặc điểm quan trọng**
- Mỗi lần chạy lại, địa chỉ **đổi**. Phải cập nhật URL webhook trên SePay (**⋮ → Sửa**).
- Đường hầm nhanh không có cam kết thời gian hoạt động. Dùng cho demo, không dùng cho chạy thật.
- Đường hầm mở **toàn bộ backend** ra internet, không chỉ webhook. Vì vậy phải làm xong mục 8 trước.
- Máy ngủ hoặc tắt đường hầm: SePay không gọi tới được, sẽ tự gửi lại theo mục 5.4.

**Thử webhook qua đường hầm (chưa cần SePay).** Gọi bằng khóa đọc từ `.env`, loại `out` để không ghi vào DB:

```powershell
cd d:\WWW_JAVA\TourDuLich
$key = (Select-String -Path backend\.env -Pattern '^PAYMENT_WEBHOOK_KEY=(.*)$').Matches[0].Groups[1].Value
$url = "https://xxx-yyy-zzz.trycloudflare.com"
Invoke-RestMethod -Method Post -Uri "$url/api/payments/webhook" `
  -Headers @{ Authorization = "Apikey $key" } -ContentType "application/json" `
  -Body '{"id":"test-1","transferType":"out","transferAmount":1000,"content":"test"}'
```

Kết quả đúng: `success : True`. Sai khóa trả 401.

## 7. Kiểm tra từ đầu đến cuối

1. Bật backend (mục 3), đường hầm (mục 6), frontend (mục 4); URL webhook trên SePay khớp địa chỉ đường hầm hiện tại.
2. Đăng nhập tài khoản khách, đặt tour có giá thấp nhất.
3. Ở trang thanh toán, quét QR bằng app **của ngân hàng khác** (không tự chuyển cho chính tài khoản nhận).
4. Kiểm tra app điền sẵn số tiền và nội dung `TOURxxxxxx`. Chuyển **đúng số tiền**, không sửa nội dung.
5. Vài giây sau đơn phải chuyển sang đã thanh toán; SePay hiện giao dịch ở **Lịch sử gửi**.

## 8. Bảo mật (làm trước khi mở đường hầm)

- [ ] `JWT_SECRET` là chuỗi ngẫu nhiên riêng, không phải giá trị mặc định (giá trị mặc định nằm công khai trong repo).
- [ ] Đã đổi mật khẩu admin (trang **Tài khoản**), không còn `Admin@123`.
- [ ] `PAYMENT_WEBHOOK_KEY` là chuỗi ngẫu nhiên riêng và khớp với khóa khai trên SePay.
- [ ] `backend/.env` không bị commit (đã `.gitignore`).
- [ ] Chạy thật thì `PAYMENT_SIMULATE_ENABLED=false` (nút giả lập cho phép đánh dấu đã thanh toán mà không cần tiền).
- [ ] Xong demo thì đóng đường hầm (`Ctrl+C`), và nên tạo lại khóa webhook cho lần sau.

## 9. Muốn đưa lên chạy thật (làm tiếp)

Trong repo đã có sẵn (chưa kiểm chứng bằng deploy thật, image Docker chưa build thử):

- `backend/Dockerfile`, `.dockerignore`, `render.yaml`: cấu hình triển khai backend lên Render (Docker, Java 21).
  Các biến bí mật đặt `sync: false`, điền trên dashboard Render.
- `application.yml` đọc `PORT`, `DB_URL`, `CORS_ALLOWED_ORIGINS` từ môi trường.

Còn thiếu để chạy thật:

1. **Database MariaDB 11.7+ có `VECTOR`.** Render không có MariaDB. Đã cân nhắc:
   - MariaDB Cloud gói free: giới hạn 10 MCU-giờ/tháng, chưa xác nhận bản mặc định có `VECTOR`; phải thử
     `SELECT VERSION();` và tạo thử cột `VECTOR(3)`.
   - Railway (template MariaDB): khoảng 5 USD/tháng, phải kiểm tra phiên bản.
   - Sửa backend để vector của chatbot lưu trong bộ nhớ (khi đó dùng được DB không có `VECTOR`).
   Sau khi có DB: nhập `database/data.sql` (đủ cấu trúc 10 bảng và dữ liệu); `DB_URL` thêm `?sslMode=trust` nếu cần TLS.
2. **Vercel**: thêm `frontend/vercel.json` (hiện chưa commit) với rewrite `/api/:path*` và `/uploads/:path*` sang backend,
   và đường dẫn dự phòng về `index.html` cho React Router. Cần đặt Root Directory của dự án Vercel là `frontend`.
3. **Webhook SePay** đổi sang `https://<tên-service>.onrender.com/api/payments/webhook`, không cần Cloudflare nữa.
4. Lưu ý Render gói free: ngủ sau khoảng 15 phút không truy cập, request đầu mất khoảng 1 phút; theo mình biết còn chặn
   cổng SMTP gửi ra nên `MAIL_ENABLED` để `false`.
5. Muốn URL cố định khi vẫn chạy trên máy: dùng named tunnel của Cloudflare (cần tài khoản Cloudflare và một tên miền).

## 10. Xử lý sự cố

| Hiện tượng | Nguyên nhân thường gặp | Cách xử lý |
|---|---|---|
| Mở địa chỉ gốc `/` ra `401 Vui lòng đăng nhập` | Bình thường, backend không có trang ở `/` | Thử `/api/health` |
| Webhook trả **401** "Khóa xác thực webhook không hợp lệ" | Khóa trên SePay khác `PAYMENT_WEBHOOK_KEY` | Sửa webhook, dán lại khóa; nhớ restart backend sau khi đổi `.env` |
| Webhook trả **404** hoặc lỗi kết nối | URL sai (thiếu `/api/payments/webhook`) hoặc đường hầm đã tắt hoặc đổi địa chỉ | Xem lại URL đầy đủ; chạy lại đường hầm và cập nhật URL |
| Gửi thử OK nhưng đơn không đổi trạng thái | Số tiền khác, hoặc nội dung chuyển khoản bị sửa | Xem `match_status` trong `payment_transactions` (`UNDERPAID`, `OVERPAID`, `UNMATCHED`) |
| Trạng thái webhook "Chưa gửi" | Chưa có giao dịch nào | Bấm **Gửi thử** hoặc chuyển khoản thật |
| Khách chuyển thiếu hoặc đơn đã hủy mà tiền đã vào | Backend chỉ ghi lịch sử, không tự xử lý | Admin đối soát tay theo `payment_transactions` |
| Backend không khởi động, lỗi DB | MariaDB chưa chạy hoặc sai `DB_URL`, `DB_USERNAME`, `DB_PASSWORD` | Kiểm tra DB và `.env` |
| QR không ra hoặc lỗi 404 ảnh QR | `PAYMENT_BANK_CODE` sai | Dùng `TPB` (hoặc `970423`); `TienPhongBank` không dùng được |
| Phản hồi webhook bị SePay báo thất bại dù HTTP 200 | Body khác `{"success": true}` | Giữ nguyên `PaymentController.webhook()` chỉ trả `success` |

## 11. Tài liệu tham khảo

- SePay: [Tích hợp webhook](https://developer.sepay.vn/en/sepay-webhooks/tich-hop-webhook),
  [Tạo webhook](https://developer.sepay.vn/en/sepay-webhooks/tao-webhook),
  [Xác thực](https://developer.sepay.vn/en/sepay-webhooks/xac-thuc),
  [Xử lý lỗi](https://developer.sepay.vn/en/sepay-webhooks/xu-ly-loi)
- Cloudflare Tunnel: https://developers.cloudflare.com/cloudflare-one/connections/connect-apps
- Commit liên quan: `11f8d12` (sửa phản hồi webhook, bỏ qua tiền ra), `d4b2ea7` (cấu hình deploy)
