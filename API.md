# Hợp đồng API (backend <-> frontend)

Quy ước chung
- Lỗi: dùng `ErrorResponse` có sẵn `{timestamp,status,error,message,path,fieldErrors?}`. Thông điệp tiếng Việt.
- Phân trang: query `page` (bắt đầu từ 1), `size`. Trả `PageResponse<T>`:
  `{ "content": [...], "page": 1, "size": 9, "totalElements": 36, "totalPages": 4 }`
- Thời gian: ISO-8601 `2026-12-01T07:30:00`. Tiền: số (VND), không có phần thập phân thừa.
- Giỏ tour lưu trong HTTP Session (cookie JSESSIONID). Mọi API giỏ trả về toàn bộ giỏ.
- Không bao giờ trả `passwordHash`.

## Công khai
| Method | Path | Ghi chú |
|---|---|---|
| GET | /api/categories | `[ {id,name,description,tourCount} ]` chỉ ACTIVE, tourCount = số tour ACTIVE |
| GET | /api/tours | query: page,size(mặc định 9),keyword(tên/điểm đến/mã tour),categoryId,destination,minPrice,maxPrice(giá người lớn),departureFrom,departureTo(yyyy-MM-dd),sort=`newest`(mặc định)\|`priceAsc`\|`priceDesc`\|`departureAsc`. Chỉ tour ACTIVE. -> `PageResponse<TourSummary>` |
| GET | /api/tours/featured?limit=6 | `[TourSummary]` ACTIVE, còn chỗ, khởi hành sớm nhất sắp tới |
| GET | /api/tours/destinations | `[ {destination, tourCount, imageUrl} ]` (ảnh = ảnh tour đầu tiên của điểm đến) |
| GET | /api/tours/{id} | `TourDetail` = TourSummary + `itinerary`(string) + `relatedTours:[TourSummary] (<=3, cùng danh mục)`. 404 nếu không có/không ACTIVE |
| GET | /api/cart | Cart |
| POST | /api/cart/items | `{tourId,adultQuantity,childQuantity}` thêm (cộng dồn nếu đã có) |
| PUT | /api/cart/items/{tourId} | `{adultQuantity,childQuantity}` ghi đè |
| DELETE | /api/cart/items/{tourId} | xóa 1 mục |
| DELETE | /api/cart | xóa sạch |
| POST | /api/contacts | `{fullName,email,phone?,subject,message}` -> 201 `{message}` (giới hạn 5 lần/giờ/IP) |

Kiểm tra giỏ: adultQuantity >= 1, childQuantity >= 0, tổng vé <= availableSeats, tour phải ACTIVE.

TourSummary:
`{id,tourCode,name,categoryId,categoryName,departureLocation,destination,duration,transport,departureDate,adultPrice,childPrice,totalSeats,availableSeats,imageUrl,shortDescription,status}`

Cart:
`{items:[{tourId,tourCode,name,imageUrl,departureDate,duration,adultPrice,childPrice,adultQuantity,childQuantity,subtotal,availableSeats}],totalItems,totalAmount}`
(giá luôn tính lại từ DB, không tin client)

`itinerary`: văn bản thuần, mỗi ngày là một khối cách nhau bằng 1 dòng trống, dòng đầu khối dạng
`Ngày 1: Tiêu đề` rồi các dòng mô tả.

## Cần đăng nhập (Customer, Admin)
| Method | Path | Ghi chú |
|---|---|---|
| PUT | /api/auth/me | `{fullName,phone,address}` -> UserResponse |
| PUT | /api/auth/password | `{currentPassword,newPassword}` -> 204 |
| POST | /api/bookings | `{contactName,contactPhone,contactEmail,specialRequest?}` tạo đơn từ giỏ trong Session, trong 1 transaction: khóa dòng tour (PESSIMISTIC_WRITE), trừ `availableSeats`, snapshot giá, sinh `bookingCode` dạng `BK-yyyyMMdd-NNN` và `paymentCode` dạng `TOUR` + 6 ký tự A-Z0-9, xóa giỏ. -> 201 BookingDetail |
| GET | /api/bookings/my-bookings | page,size,status(bookingStatus, tùy chọn) -> `PageResponse<BookingSummary>` mới nhất trước |
| GET | /api/bookings/my-bookings/{id} | BookingDetail (chỉ đơn của mình, nếu không 404) |
| PUT | /api/bookings/{id}/cancel | `{reason}` chỉ khi PENDING và của mình; hoàn lại chỗ; nếu đã PAID thì paymentStatus -> REFUNDED |
| GET | /api/bookings/{id}/payment-info | `{bookingId,bookingCode,amount,paymentCode,bankName,accountNumber,accountName,transferContent,qrUrl,paymentStatus,bookingStatus,paidAt,simulateEnabled}`; `qrUrl` = `https://img.vietqr.io/image/{bank}-{account}-compact2.png?amount=..&addInfo=..&accountName=..`; cấu hình ngân hàng trong `app.payment.*` |
| POST | /api/payments/simulate | `{bookingId}` chỉ chạy khi `app.payment.simulate-enabled=true` (mặc định true ở dev): đánh dấu PAID (+ghi payment_transactions). Dùng để demo |
| POST | /api/payments/webhook | công khai nhưng bắt header `Authorization: Apikey <app.payment.webhook-key>`; payload kiểu SePay `{id,gateway,transferAmount,content,accountNumber,transactionDate}`; khớp `paymentCode` trong content; chống trùng theo `id` |

BookingSummary: `{id,bookingCode,createdAt,totalAmount,paymentStatus,bookingStatus,itemCount,firstTourName,firstTourImage}` (admin có thêm `customerName,customerEmail`)

BookingDetail: BookingSummary + `{contactName,contactPhone,contactEmail,specialRequest,paymentMethod,paidAt,cancelReason,canCancel,items:[{tourId,tourName,imageUrl,departureDate,adultPrice,childPrice,adultQuantity,childQuantity,subtotal}]}`

## Quản trị (ROLE_ADMIN)
| Method | Path | Ghi chú |
|---|---|---|
| GET | /api/admin/dashboard/stats | `{totalActiveTours,totalCategories,totalCustomers,totalBookings,totalRevenue(chỉ đơn PAID),pendingBookings,newContacts,revenueByMonth:[{month:"2026-06",revenue,bookings}] (12 tháng gần nhất, đủ tháng kể cả bằng 0),bookingsByStatus:{PENDING,CONFIRMED,COMPLETED,CANCELLED},topTours:[{tourId,name,bookedSeats,revenue}] (5),recentBookings:[BookingSummary admin] (8)}` |
| GET | /api/admin/categories | page,size,keyword,status -> PageResponse `{id,name,description,status,tourCount,createdAt}` |
| GET | /api/admin/categories/options | `[{id,name,status}]` không phân trang |
| POST/PUT | /api/admin/categories[/{id}] | `{name,description,status}`; tên duy nhất (409) |
| DELETE | /api/admin/categories/{id} | 409 nếu còn tour |
| GET | /api/admin/tours | page,size,keyword,categoryId,status -> PageResponse<TourSummary> |
| GET | /api/admin/tours/{id} | TourDetail (không cần ACTIVE) |
| POST/PUT | /api/admin/tours[/{id}] | `{categoryId,tourCode,name,departureLocation,destination,duration,transport,departureDate,adultPrice,childPrice,totalSeats,imageUrl,shortDescription,itinerary,status}`; mã tour duy nhất (409); khi sửa totalSeats: availableSeats = totalSeats - số chỗ đã đặt, không được < 0 |
| PUT | /api/admin/tours/{id}/status | `{status}` ACTIVE/CLOSED/COMPLETED |
| DELETE | /api/admin/tours/{id} | 409 nếu đã có booking_items |
| POST | /api/admin/uploads | multipart `file` (jpg/png/webp <= 5MB) -> `{url:"/uploads/xxx.jpg"}`; lưu thư mục `./uploads`, phục vụ tại `/uploads/**` công khai |
| GET | /api/admin/bookings | page,size,keyword(mã đơn/tên/email),bookingStatus,paymentStatus,from,to -> PageResponse<BookingSummary admin> |
| GET | /api/admin/bookings/{id} | BookingDetail + `customerName,customerEmail` |
| PUT | /api/admin/bookings/{id}/status | `{status,reason?}` PENDING->CONFIRMED->COMPLETED; hủy được khi chưa COMPLETED (hoàn chỗ, PAID->REFUNDED); không đi lùi |
| PUT | /api/admin/bookings/{id}/payment | `{paymentStatus}` UNPAID/PAID (thu tại văn phòng, method OFFICE) |
| GET | /api/admin/users | page,size,keyword,role,status -> `{id,fullName,email,phone,address,role,status,createdAt,bookingCount}` |
| PUT | /api/admin/users/{id}/status | `{status}` không khóa chính mình / admin khác |
| GET | /api/admin/contacts | page,size,status,keyword -> `{id,fullName,email,phone,subject,message,status,replyContent,adminNote,repliedAt,createdAt}` |
| GET | /api/admin/contacts/{id} | như trên |
| PUT | /api/admin/contacts/{id}/reply | `{replyContent}` lưu, status -> RESOLVED, gửi mail (MailService, mặc định chỉ log) |
| PUT | /api/admin/contacts/{id}/status | `{status,adminNote?}` NEW/IN_PROGRESS/RESOLVED |
| DELETE | /api/admin/contacts/{id} | |
