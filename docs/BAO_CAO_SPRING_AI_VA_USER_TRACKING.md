# Báo cáo: Spring AI Vector Database và User Tracking

**Đề tài áp dụng:** website đặt tour du lịch TourDuLich (Spring Boot 3.5, Java 21, MariaDB, React 19)

**Nội dung:**
1. Tìm hiểu Spring AI và Vector Database (phía Backend).
2. Tìm hiểu cơ chế User Tracking trên giao diện (phía Frontend).
3. Áp dụng vào đề tài: khung chat "Trợ lý TourDuLich" và hệ thống theo dõi hành vi người dùng.

---

## Phần 1. Spring AI và Vector Database (Backend)

### 1.1 Vì sao cần vector database

Chatbot dùng mô hình ngôn ngữ lớn (LLM) có hai điểm yếu khi áp dụng vào một website cụ thể:
- Mô hình **không biết dữ liệu của website** (giá tour, ngày khởi hành, chính sách riêng).
- Mô hình **có thể bịa** khi không biết.

Cách giải quyết phổ biến là **RAG (Retrieval-Augmented Generation)**: trước khi hỏi mô hình, hệ thống tìm trong kho dữ liệu của mình các đoạn liên quan nhất rồi đưa kèm vào câu hỏi. Mô hình chỉ việc đọc và trả lời dựa trên đó. Công việc "tìm đoạn liên quan" chính là việc của vector database.

So với việc huấn luyện lại (fine-tune) mô hình, RAG có ba ưu điểm: dữ liệu đổi thì chỉ cập nhật kho tìm kiếm, không phải huấn luyện lại; câu trả lời bám dữ liệu thật nên ít bịa hơn; chi phí thấp.

### 1.2 Các khái niệm chính

| Khái niệm | Giải thích |
|---|---|
| **Embedding** | Chuyển một đoạn văn thành một dãy số (vector), ví dụ 768 số, biểu diễn *ý nghĩa* của đoạn đó. Hai đoạn gần nghĩa thì hai vector nằm gần nhau |
| **Cosine similarity** | Phép đo độ gần nhau giữa hai vector (từ 0 đến 1). Dùng để xếp hạng đoạn nào giống câu hỏi nhất |
| **Vector database** | Nơi lưu vector cùng đoạn văn gốc và metadata, trả về *k đoạn gần nhất* với một câu hỏi (top-k) |
| **Chunking** | Cắt tài liệu dài thành các đoạn ngắn trước khi embed, vì mỗi đoạn cần đủ nhỏ để tập trung một ý |
| **Metadata filter** | Lọc kết quả theo thuộc tính (ví dụ chỉ lấy đoạn thuộc tour số 51) |
| **Prompt** | Câu lệnh gửi cho mô hình, gồm quy tắc, ngữ cảnh tìm được và câu hỏi của khách |

Ví dụ: khách hỏi "đi biển yên tĩnh cùng gia đình". Tìm theo từ khóa sẽ không ra gì vì không tour nào chứa đúng cụm đó. Tìm theo vector vẫn ra tour Phú Quốc vì ý nghĩa gần nhau.

### 1.3 Luồng RAG

```
 Giai đoạn 1 - Lập chỉ mục (làm trước, một lần rồi cập nhật khi dữ liệu đổi)
   Tour, tài liệu --> cắt đoạn --> embed --> lưu vào Vector Store

 Giai đoạn 2 - Hỏi đáp (mỗi câu hỏi)
   Câu hỏi --> embed --> tìm k đoạn gần nhất --> ghép vào prompt
            --> gửi LLM --> câu trả lời
```

### 1.4 Spring AI cung cấp gì

Spring AI là thư viện của hệ sinh thái Spring giúp tích hợp AI theo cách quen thuộc với lập trình viên Spring. Điểm mạnh là các **interface dùng chung** nên đổi nhà cung cấp không phải viết lại mã:

| Interface | Vai trò |
|---|---|
| `ChatModel` / `ChatClient` | Gọi mô hình chat (Gemini, OpenAI, Anthropic, Ollama...) |
| `EmbeddingModel` | Biến văn bản thành vector |
| `VectorStore` | Lưu và tìm kiếm vector: `add`, `similaritySearch`, `delete` |
| `Document` | Một đoạn văn kèm metadata |
| `TokenTextSplitter` | Cắt văn bản thành đoạn theo số token |
| `FilterExpressionBuilder` | Viết điều kiện lọc metadata độc lập với từng loại database |

### 1.5 Các vector database mà Spring AI hỗ trợ

| Lựa chọn | Đặc điểm | Khi nào dùng |
|---|---|---|
| `SimpleVectorStore` | Nằm trong bộ nhớ, không cần cài gì | Dữ liệu nhỏ (vài trăm đến vài nghìn đoạn), học tập, thử nghiệm |
| PGvector (PostgreSQL) | Thêm kiểu vector vào PostgreSQL | Đã dùng PostgreSQL |
| MariaDB Vector | Kiểu `VECTOR` có từ MariaDB 11.7 | Đã dùng MariaDB bản mới |
| Qdrant, Chroma, Milvus, Weaviate | Database chuyên cho vector | Dữ liệu lớn, cần hiệu năng cao |
| Redis, Elasticsearch, Pinecone... | Dịch vụ có sẵn hoặc trên đám mây | Đã có hạ tầng tương ứng |

### 1.6 Chọn gì cho đề tài

Hệ thống đang chạy **MariaDB 11.6.2, chưa có kiểu `VECTOR`**. Vì vậy nhóm chọn: tìm kiếm trong bộ nhớ bằng `SimpleVectorStore`, còn **vector được lưu bền trong chính MariaDB** (bảng `ai_vectors`, dạng nhị phân). Cách này không cần cài thêm dịch vụ nào, dữ liệu vẫn nằm trong DB của đề tài, và khởi động lại không phải embed lại. Mã của project chỉ phụ thuộc interface `VectorStore` nên sau này nâng MariaDB lên 11.7 hoặc đổi sang Qdrant chỉ phải sửa chỗ dựng store.

---

## Phần 2. User Tracking trên giao diện (Frontend)

### 2.1 User tracking là gì

Là việc **ghi nhận người dùng làm gì trên giao diện**: xem trang nào, bấm vào đâu, tìm gì, bỏ ngang ở bước nào. Mục đích:
- Hiểu hành vi: tour nào được quan tâm, khách rớt ở bước nào của quy trình đặt tour (phễu chuyển đổi).
- Cải thiện giao diện và nội dung dựa trên số liệu thật.
- Cá nhân hóa: gợi ý theo những gì khách vừa xem.

### 2.2 Các cơ chế kỹ thuật cốt lõi

| Cơ chế | Giải thích |
|---|---|
| **Định danh ẩn danh** | Sinh một mã ngẫu nhiên lưu ở `localStorage` để nhận ra cùng một trình duyệt qua nhiều lần truy cập, không cần biết đó là ai |
| **Phiên (session)** | Nhóm các hành động liên tiếp; coi là phiên mới sau một khoảng không hoạt động (ở đây 30 phút) |
| **Sự kiện (event)** | Một bản ghi hành động: loại, thời điểm, trang, dữ liệu kèm theo |
| **Event delegation** | Một listener duy nhất ở `document` bắt mọi lượt click thay vì gắn listener cho từng nút |
| **Page view trong SPA** | Ứng dụng một trang (React) không tải lại trang khi chuyển route, nên phải tự bắt sự kiện đổi route để ghi page view |
| **Gom lô (batching)** | Dồn nhiều sự kiện rồi gửi một lần để đỡ tốn request |
| **`navigator.sendBeacon`** | Gửi dữ liệu lúc đóng hoặc ẩn tab. Đáng tin hơn `fetch`/axios vì trình duyệt đảm bảo gửi ngay cả khi trang đang đóng |
| **Consent (đồng ý)** | Chỉ theo dõi khi người dùng cho phép |

### 2.3 Các giải pháp có sẵn

| Giải pháp | Nhận xét |
|---|---|
| Google Analytics 4, Mixpanel | Dùng nhanh, mạnh, nhưng dữ liệu nằm ở bên thứ ba |
| Hotjar, Microsoft Clarity | Ghi lại bản đồ nhiệt và bản ghi phiên |
| PostHog, Matomo | Mã nguồn mở, có thể tự đặt máy chủ |
| **Tự xây (first-party)** | Dữ liệu nằm hoàn toàn trong DB của mình, hiểu rõ từng cơ chế. Nhóm chọn cách này vì phù hợp mục tiêu học tập và dữ liệu cần liên kết với tour trong hệ thống |

### 2.4 Quyền riêng tư

Theo dõi hành vi liên quan dữ liệu cá nhân nên cần tuân thủ nguyên tắc (tương tự GDPR): minh bạch, có sự đồng ý, thu thập ở mức tối thiểu. Đề tài làm theo hướng "**mặc định không theo dõi**", chi tiết ở mục 3.6.

---

## Phần 3. Áp dụng vào đề tài TourDuLich

### 3.1 Tổng quan hệ thống đã làm

| Thành phần | Mô tả |
|---|---|
| Khung chat "Trợ lý TourDuLich" | Nút nổi trên mọi trang khách; hỏi đáp về tour, đặt tour, thanh toán, hủy đơn bằng RAG với Gemini |
| Kho tri thức | Tour tự lập chỉ mục từ DB, kèm các tài liệu `.md` về quy trình và chính sách |
| User tracking | Ghi nhận hành vi trên giao diện, gửi về backend, lưu bảng `user_events` |
| Trang quản trị | Hai trang mới: **Hành vi người dùng** và **Trợ lý AI** (trạng thái, API key, thử hỏi, lịch sử chat) |

### 3.2 Backend: các thành phần chính (package `com.tourdulich.ai`)

| Lớp | Vai trò |
|---|---|
| `KnowledgeBase` | **Lập chỉ mục:** dựng tài liệu từ tour và file tri thức, cắt đoạn, embed, lưu vector. Tự cập nhật khi admin sửa tour |
| `ChatService` | **Truy xuất và sinh câu trả lời:** tìm đoạn liên quan, dựng prompt, gọi Gemini, tách tour được nhắc để trả về thẻ tour |
| `AiModelsConfiguration`, `FailoverModels`, `KeyRotation` | Dựng mô hình theo từng API key và mô hình, tự chuyển khi lỗi |
| `CachingEmbeddingModel` | Bộ nhớ đệm embedding lưu trong DB |
| `VectorPersistence`, `AiVectorRepository` | Lưu và nạp vector từ MariaDB |
| `ChatLogRepository`, `ChatRedactor` | Lưu lịch sử chat, che thông tin cá nhân, tự xóa dữ liệu cũ |
| `AiController`, `AiAdminController` | API cho khách và cho quản trị |

### 3.3 Lập chỉ mục (Indexing)

- **Từ mỗi tour** đang mở bán tạo các đoạn: thẻ tổng quan (tên, mã, trong nước hay nước ngoài, điểm đến, thời lượng, giá, mô tả), lịch trình, và điều kiện (giá bao gồm, không bao gồm, hủy, phụ thu). Mỗi đoạn bắt đầu bằng `[Tour: <tên>]` để đứng riêng vẫn rõ thuộc tour nào.
- **Tài liệu tổng quan tự sinh từ DB** (ví dụ danh sách tour theo khu vực, theo khoảng giá) để trả lời được câu hỏi mang tính so sánh toàn cục.
- **Từ file tri thức** `.md`: cắt theo tiêu đề rồi theo độ dài (`TokenTextSplitter`, khoảng 500 token mỗi đoạn).
- **Metadata** gồm `type`, `tourId`, `title`; dùng để lọc đúng tour khách đang xem.
- **Luôn mới:** khi admin thêm, sửa, xóa tour, hệ thống phát `TourChangedEvent`; sau khi giao dịch commit, đoạn cũ của tour đó bị xóa và lập lại.
- **Dữ liệu "sống":** giá hiện tại, số chỗ, ngày khởi hành **không lấy từ chỉ mục** (có thể đã cũ) mà đọc lại từ DB lúc trả lời.

### 3.4 Hỏi đáp (`POST /api/ai/chat`)

```
1. Làm sạch đầu vào: tối đa 1000 ký tự, giữ 8 lượt hội thoại gần nhất
2. Truy vấn = câu hỏi + câu hỏi trước đó (hiểu câu nối tiếp)
3. similaritySearch: topK = 10, ngưỡng giống nhau tối thiểu 0.4
4. Nếu khách đang xem một tour: luôn thêm các đoạn của tour đó
5. Dựng prompt = quy tắc + ngữ cảnh tìm được + dữ liệu hiện tại từ DB
6. Gọi Gemini, tách liên kết /tours/<id> trong câu trả lời thành thẻ tour
7. Ghi lịch sử (đã che email, số điện thoại) và trả kết quả
```

Máy chủ không giữ hội thoại; frontend gửi lại các lượt gần nhất (stateless, dễ mở rộng).

### 3.5 An toàn và độ tin cậy

- **Chỉ dùng ngữ cảnh, không bịa:** thiếu thông tin thì nói thẳng và mời gọi hotline.
- **Chống prompt injection:** prompt nêu rõ nội dung ngữ cảnh và câu hỏi chỉ là dữ liệu, bỏ qua mọi yêu cầu đổi quy tắc hoặc tiết lộ prompt. Đã thử thực tế: AI từ chối yêu cầu lộ system prompt và câu hỏi ngoài chủ đề.
- **Giới hạn tốc độ:** 15 câu hỏi mỗi phút mỗi IP (Bucket4j).
- **Không chèn HTML:** câu trả lời dựng bằng phần tử React, chỉ nhận liên kết `/...` hoặc `https://`; thử chèn `<script>` thì hiện thành chữ.
- **API key:** chỉ nằm trong `backend/.env` (đã `.gitignore`); giao diện admin luôn che, chỉ hiện 4 ký tự cuối.
- **Dự phòng nhiều key và nhiều mô hình:** gặp lỗi do chính key (hết hạn mức, key sai) hoặc mô hình ngừng hỗ trợ thì tự chuyển sang key hoặc mô hình kế tiếp ngay trong cùng yêu cầu, khách không thấy lỗi. Lỗi khác (mạng, 5xx) thì không đổi.

| Lỗi | Hành động |
|---|---|
| 429, hết hạn mức | Key nghỉ 90 giây, đổi key |
| Hết hạn mức theo ngày | Key nghỉ 1 giờ |
| Key không hợp lệ, 401, 403 | Key nghỉ 6 giờ |
| Mô hình không còn (404) | Chuyển mô hình khác |
| Lỗi khác | Không đổi, báo lỗi bình thường |

### 3.6 Frontend: User tracking trong đề tài (`frontend/src/tracking/tracker.js`)

**Định danh:** `anonymousId` (lưu lâu dài), `sessionId` (đổi sau 30 phút không hoạt động). `user_id` **không do client khai báo**: khách đã đăng nhập thì request mang JWT và backend tự gắn.

**Sự kiện tự động:** `page_view`, `page_leave` (thời gian ở trang, độ cuộn), `click` (event delegation, lấy nhãn từ `data-track`).

**Sự kiện nghiệp vụ:** `view_tour`, `search`, `add_to_cart`, `remove_from_cart`, `begin_checkout`, `booking_created`, `login`, `register`, `chat_open`, `chat_message`, `chat_error`.

**Gửi dữ liệu:** gom lô, gửi mỗi 5 giây hoặc khi đủ 20 sự kiện; dùng `sendBeacon` khi đóng tab; mất mạng thì giữ lại gửi sau.

**Quyền riêng tư (mặc định không theo dõi):**
- Banner đồng ý: chưa bấm **Đồng ý** thì không ghi gì. Đã kiểm thử: bấm Từ chối thì có 0 request tracking.
- Tôn trọng **Do Not Track** và **Global Privacy Control** của trình duyệt.
- Không bao giờ ghi nội dung ô nhập liệu; nhãn giống email hoặc số điện thoại bị che.
- Link ra ngoài chỉ ghi tên miền.

**Phía backend:** `POST /api/tracking/events` nhận lô tối đa 50 sự kiện (90 request mỗi phút mỗi IP), lưu bảng `user_events`. `GET /api/admin/tracking/summary` trả khách truy cập, phiên, phễu chuyển đổi, tour xem nhiều, từ khóa tìm nhiều, biểu đồ theo ngày, hoạt động gần đây.

### 3.7 Cơ sở dữ liệu

| Bảng | Nội dung |
|---|---|
| `user_events` | Sự kiện hành vi (không có khóa ngoại tới `tours`, tour bị xóa vẫn giữ lịch sử) |
| `ai_vectors` | Vector của từng đoạn, dạng nhị phân, kèm nội dung và metadata |
| `ai_embedding_cache` | Bộ nhớ đệm embedding, khóa theo SHA-256 của nội dung và mô hình |
| `ai_chat_logs` | Lịch sử chat theo cuộc trò chuyện |

### 3.8 Trang quản trị

| Trang | Chức năng |
|---|---|
| **Hành vi người dùng** | Khách truy cập, phiên, phễu chuyển đổi, tour và từ khóa nổi bật, biểu đồ theo ngày, hoạt động gần đây; chọn khoảng thời gian |
| **Trợ lý AI** | Trạng thái chỉ mục và tiến độ, bảng API key (đã che), xem trước tài liệu AI đọc, thử hỏi, lập lại chỉ mục, **lịch sử chat với khách** (tìm kiếm, mở từng cuộc, xóa) |

Lịch sử chat: nhóm theo cuộc trò chuyện, mặc định che email và số điện thoại trước khi lưu, tự xóa sau 90 ngày, có thể xóa từng cuộc. Việc che có thể tắt bằng biến `AI_CHAT_REDACT=false`. Khung chat có dòng thông báo cho khách biết nội dung được lưu.

### 3.9 Tiết kiệm chi phí token

| Biện pháp | Hiệu quả |
|---|---|
| Lưu vector vào DB | Khởi động lại chỉ nạp, không gọi API embed |
| Bộ nhớ đệm embedding | Cùng nội dung chỉ embed một lần; lập lại toàn bộ chỉ mục trong thử nghiệm không phát sinh lần gọi API nào |
| Cập nhật theo từng tour | Admin sửa một tour chỉ embed lại tour đó |
| Điều tiết tốc độ | Tuân thủ hạn mức gói miễn phí, tự chờ và thử lại khi gặp 429 |

Chi phí thường xuyên lớn nhất là mỗi câu hỏi của khách (vài nghìn token đầu vào do phải đính kèm ngữ cảnh).

---

## Phần 4. Kiểm thử và kết quả

| Kiểm thử | Kết quả |
|---|---|
| Unit test (34 test): lập chỉ mục, tìm kiếm, lọc theo tour, bộ nhớ đệm, lưu và nạp vector, chuyển key và mô hình, che thông tin cá nhân, mốc thời gian dashboard | 34/34 đạt |
| Chạy Gemini thật: tư vấn tour Nhật, tour biển dưới 8 triệu, hủy đơn; hỏi thời tiết và giá vàng; đòi lộ system prompt | Trả lời đúng dữ liệu kèm liên kết và giá; từ chối đúng câu ngoài chủ đề và câu dò prompt |
| Chuyển key và mô hình thật: key 1 hết hạn mức ngày, key 2 mô hình không còn, chuyển sang mô hình khác | Vẫn trả lời thành công |
| Trình duyệt thật (Chrome headless): banner đồng ý, từ chối thì 0 request, đồng ý thì có đủ sự kiện, khung chat desktop và mobile, markdown, thẻ tour, chống chèn `<script>`, không lỗi console | Đạt |
| Lịch sử chat: số điện thoại và email nhập vào chat được che trong trang admin | Đạt |

Hạn chế của phần kiểm thử: chất lượng ngữ nghĩa mới thử trên một số câu hỏi mẫu, chưa có bộ câu hỏi đánh giá lớn. Unit test dùng embedding giả nên chỉ chứng minh mã của project.

---

## Phần 5. Hạn chế và hướng phát triển

- **Chưa streaming:** câu trả lời hiện ra một lần sau vài giây; có thể chuyển sang SSE.
- **Câu hỏi về con số** ("tour dưới 10 triệu") embedding làm chưa tốt khi có nhiều tour. Hướng cải thiện: function calling để AI gọi API lọc tour, hoặc lọc theo metadata giá.
- **Tìm kiếm trong bộ nhớ:** phù hợp quy mô vài nghìn đoạn; lớn hơn cần chuyển sang PGvector, MariaDB Vector (11.7 trở lên) hoặc Qdrant.
- **Hạn mức Gemini:** gói miễn phí có giới hạn; hạn mức tính theo project nên key dự phòng cần ở project khác.
- **Tracking:** chưa có chính sách tự xóa `user_events` cũ và trang chính sách quyền riêng tư đầy đủ.
- **Cá nhân hóa:** có thể dùng `user_events` để gợi ý tour tương tự các tour khách hay xem.

---

## Phần 6. Kết luận

Đề tài đã áp dụng đầy đủ hai nội dung tìm hiểu vào một hệ thống chạy được. Ở backend, kiến trúc RAG với Spring AI, vector lưu trong MariaDB, Gemini làm mô hình chat và embedding. Ở frontend, cơ chế user tracking tự xây theo hướng tôn trọng quyền riêng tư, dữ liệu hiển thị cho quản trị viên để theo dõi hành vi khách và chất lượng trợ lý.

### Phụ lục: các API chính

| API | Quyền | Mục đích |
|---|---|---|
| `POST /api/ai/chat` | Công khai, 15/phút/IP | Hỏi đáp với trợ lý |
| `GET /api/ai/status` | Công khai | AI đã sẵn sàng chưa |
| `POST /api/tracking/events` | Công khai, 90/phút/IP | Gửi lô sự kiện hành vi |
| `GET /api/admin/tracking/summary` | Admin | Thống kê hành vi |
| `GET /api/admin/ai/status`, `/keys`, `/preview` | Admin | Trạng thái, key (đã che), xem trước tài liệu |
| `POST /api/admin/ai/reindex` | Admin | Lập lại chỉ mục |
| `GET /api/admin/ai/chats`, `/chats/{id}` | Admin | Xem lịch sử chat |
| `DELETE /api/admin/ai/chats/{id}` | Admin | Xóa một cuộc trò chuyện |
