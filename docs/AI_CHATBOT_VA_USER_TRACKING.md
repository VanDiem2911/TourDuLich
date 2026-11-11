# Trợ lý AI (Spring AI + Vector Database) và User Tracking cho TourDuLich

Tài liệu này giải thích **đã làm gì, vì sao làm vậy, và dùng thế nào**. Gồm hai phần ghép với nhau:

1. **Backend:** Spring AI + vector database, dùng để làm khung chat "Trợ lý TourDuLich" (RAG với Gemini).
2. **Frontend:** cơ chế user tracking (ghi nhận hành vi người dùng trên giao diện) và khung chat.

---

## 0. Tóm tắt nhanh

| Hạng mục | Trạng thái |
|---|---|
| Khung chat nổi trên mọi trang khách (gợi ý câu hỏi, thẻ tour, markdown, mobile) | Xong, đã chạy thử trên trình duyệt |
| Backend RAG: lập chỉ mục tour + tài liệu, tìm kiếm, ghép ngữ cảnh, gọi Gemini | Xong, test bằng embedding giả (7 test đạt) |
| Gọi Gemini thật | **Đã chạy với key thật**: lập chỉ mục 447 đoạn, hỏi đáp đúng dữ liệu tour, từ chối câu ngoài chủ đề |
| Dự phòng nhiều API key | Xong: tự chuyển key khi hết hạn mức hoặc key lỗi (đã thử thật với key giả + key thật) |
| Tài liệu cho AI học | 7 file mẫu trong `backend/src/main/resources/ai/knowledge/`, viết theo hành vi thật của hệ thống |
| User tracking (FE + BE + bảng DB + thống kê admin) | Xong, đã chạy thử |
| Thống kê hành vi trên Dashboard admin | Xong |

**Việc cần bạn làm:** thêm key dự phòng (mục 4) và đưa dữ liệu riêng của công ty để AI học (mục 5).

---

## 1. Spring AI và Vector Database: kiến thức nền

**Embedding** là một dãy số (ở đây 768 số) biểu diễn *ý nghĩa* của đoạn văn. Hai đoạn gần nghĩa thì hai vector gần nhau (đo bằng cosine). Nhờ vậy câu hỏi "đi biển yên tĩnh cùng gia đình" tìm được tour Phú Quốc dù không trùng từ khóa.

**Vector database** là nơi lưu các vector kèm đoạn văn và metadata, và trả về *k đoạn gần nhất* với một câu hỏi.

**RAG (Retrieval-Augmented Generation)** là cách dùng hai thứ trên để chatbot trả lời theo dữ liệu của mình mà không cần huấn luyện lại mô hình:

```
 Câu hỏi khách ──► embed ──► VectorStore.similaritySearch ──► k đoạn liên quan
                                                                   │
        Câu trả lời ◄── Gemini ◄── prompt = quy tắc + NGỮ CẢNH + câu hỏi
```

Vì sao RAG chứ không "dạy" (fine-tune) AI: dữ liệu tour đổi liên tục (giá, chỗ, ngày đi). Với RAG chỉ cần cập nhật chỉ mục, không phải huấn luyện lại, và câu trả lời bám sát dữ liệu thật nên ít bịa hơn.

**Spring AI** cung cấp các interface chung (`EmbeddingModel`, `ChatModel`/`ChatClient`, `VectorStore`, `Document`, `TokenTextSplitter`), nên đổi nhà cung cấp (Gemini sang OpenAI, SimpleVectorStore sang PGvector...) chủ yếu là đổi dependency và cấu hình.

---

## 2. Backend: đã áp dụng như thế nào

### 2.1 Phiên bản và dependency (`backend/pom.xml`)

- **Spring AI 1.1.8.** Đây là bản 1.x mới nhất. Bản 2.x yêu cầu Spring Boot 4 trong khi project dùng Boot 3.5.7.
- `spring-ai-starter-model-google-genai`: chat (Gemini).
- `spring-ai-starter-model-google-genai-embedding`: embedding (Gemini).
- `spring-ai-vector-store`: `SimpleVectorStore`.

### 2.2 Chọn vector store: `SimpleVectorStore`

MariaDB của bạn là 11.6.2, **chưa có kiểu `VECTOR`** (từ 11.7) và Spring AI chưa có starter cho MariaDB. `SimpleVectorStore` lưu trong bộ nhớ và ghi ra file JSON (`backend/data/ai/vector-store.json`), không cần cài thêm dịch vụ nào. Với khoảng vài trăm đoạn như hiện tại là đủ nhanh.

Khi dữ liệu lớn hơn (hàng chục nghìn đoạn) hoặc chạy nhiều máy chủ, đổi sang PGvector, Qdrant hoặc Chroma. Mã của project chỉ phụ thuộc interface `VectorStore` nên chỉ cần sửa chỗ dựng store trong `KnowledgeBase`.

### 2.3 Các thành phần (package `com.tourdulich.ai`)

| Lớp | Vai trò |
|---|---|
| `KnowledgeBase` | **Indexing.** Dựng tài liệu từ tour và file tri thức, cắt đoạn, embed, lưu vector. Tự cập nhật khi admin sửa tour |
| `ChatService` | **Retrieval + Generation.** Tìm đoạn liên quan, dựng prompt, gọi Gemini, tách tour được nhắc để trả về thẻ tour |
| `AiController` | `GET /api/ai/status`, `POST /api/ai/chat` (công khai) |
| `AiAdminController` | `GET /api/admin/ai/status`, `POST /api/admin/ai/reindex` (chỉ admin) |
| `TourChangedEvent` | Sự kiện phát ra khi thêm, sửa, xóa hoặc đổi trạng thái tour |
| `ChatDtos` | Các DTO của API chat |

### 2.4 Luồng lập chỉ mục (Indexing)

Khởi động ứng dụng thì `KnowledgeBase` nạp file vector đã lưu. Nếu chưa có file thì lập chỉ mục ở một luồng nền, không chặn việc khởi động.

**Từ mỗi tour** (đang mở bán) tạo 3 loại đoạn, mỗi đoạn đều bắt đầu bằng `[Tour: <tên>]` để đứng riêng vẫn rõ là của tour nào:
1. **Thẻ tổng quan:** tên, mã, trong nước hay nước ngoài, danh mục, điểm đến, nơi đi, thời lượng, phương tiện, giá, mô tả, đường dẫn `/tours/<id>`.
2. **Lịch trình:** cắt theo độ dài.
3. **Giá bao gồm, không bao gồm, hủy, phụ thu:** bỏ mục "giấy tờ mang theo" vì dài và giống nhau giữa các tour.

**Từ tài liệu tri thức** (`.md`/`.txt`): cắt theo tiêu đề `#`/`##`, rồi cắt tiếp theo độ dài. Mỗi đoạn mang nhãn `[Tài liệu: <tên> > <mục>]`.

Cắt đoạn bằng `TokenTextSplitter`, mỗi đoạn tối đa khoảng 400 token. Metadata gồm `type` (`tour`/`doc`), `tourId`, `title`. `tourId` lưu dạng chuỗi để lọc chính xác sau khi nạp lại từ file JSON.

**Giữ chỉ mục luôn mới:** `AdminTourService` phát `TourChangedEvent`, `KnowledgeBase` lắng nghe sau khi giao dịch commit (`@TransactionalEventListener`), xóa các đoạn cũ của tour đó (lọc theo `tourId`) rồi thêm lại. Tour bị đóng hoặc xóa thì chỉ xóa.

**Dữ liệu "sống":** số chỗ, giá hiện tại và ngày khởi hành **không dựa vào chỉ mục** (có thể đã cũ). Khi trả lời, `ChatService` đọc lại tour từ DB và gắn dòng "Dữ liệu hiện tại" vào ngữ cảnh, và prompt yêu cầu ưu tiên dòng này.

### 2.5 Luồng hỏi đáp (`POST /api/ai/chat`)

```
1. Kiểm tra AI đã bật / chỉ mục đã sẵn sàng (nếu chưa: HTTP 503 + thông báo thân thiện)
2. Làm sạch đầu vào: cắt tối đa 1000 ký tự, giữ 8 lượt hội thoại gần nhất
3. Tạo câu truy vấn: câu hỏi + câu hỏi trước đó của khách (để hiểu câu nối tiếp như "còn tour rẻ hơn không?")
4. similaritySearch: topK = 10, ngưỡng giống nhau tối thiểu = 0.4
5. Nếu khách đang xem một tour: luôn thêm các đoạn của tour đó (lọc theo tourId)
6. Dựng prompt hệ thống = quy tắc + (tour đang xem, tour xem gần đây) + NGỮ CẢNH + dữ liệu hiện tại từ DB
7. Gọi Gemini bằng ChatClient (temperature 0.3)
8. Tách các liên kết /tours/<id> trong câu trả lời -> trả về "thẻ tour" (tối đa 3) cho frontend
```

Máy chủ **không lưu hội thoại**. Frontend gửi lại các lượt gần nhất (stateless, dễ mở rộng, không cần lưu dữ liệu cuộc trò chuyện).

### 2.6 Các lớp an toàn trong prompt và API

- **Chỉ dùng NGỮ CẢNH, không bịa:** thiếu thông tin thì nói thẳng và mời gọi hotline 1900 1234.
- **Chống prompt injection:** prompt nêu rõ nội dung ngữ cảnh và câu hỏi chỉ là dữ liệu, bỏ qua mọi yêu cầu đổi quy tắc, tiết lộ prompt hay đóng vai khác.
- Chỉ trả lời chủ đề du lịch và website; không hỏi hay lưu thông tin nhạy cảm.
- **Giới hạn tốc độ:** 15 câu hỏi mỗi phút mỗi IP (mỗi câu hỏi tốn một lần gọi Gemini). Dùng `RateLimitInterceptor` sẵn có (Bucket4j).
- **Frontend không chèn HTML:** câu trả lời được dựng bằng phần tử React (`ChatMarkdown`), chỉ nhận liên kết `/...` hoặc `https://`. Đã thử chèn `<script>`, kết quả hiện thành chữ.
- Lỗi từ Gemini được đổi thành thông báo thân thiện (429 thành "đang quá tải", lỗi khác thành 502).

### 2.7 Bật tắt tự động theo API key, và dự phòng nhiều key

Spring AI mặc định tạo mô hình từ cấu hình `spring.ai.*` và **không khởi động được nếu thiếu key**. Vì vậy project tự dựng mô hình:
- `AiModelsConfiguration` đọc danh sách key (`AiKeys`) và dựng **một mô hình chat + một mô hình embedding cho mỗi key**, rồi bọc bằng `FailoverModels`. Có ít nhất một key thì trợ lý tự bật, **không cần profile hay cờ nào**; không có key thì ứng dụng vẫn chạy và chat báo "chưa bật".
- Auto-config của Spring AI được giữ ở `none` để không tạo thêm bộ mô hình thứ hai.
- Việc tự thử lại bên trong thư viện được tắt (1 lần). Mặc định nó chờ hàng phút khi gặp lỗi hạn mức, làm lập chỉ mục treo rất lâu.

**Cơ chế dự phòng (`KeyRotation`):**
- Dùng key đang hoạt động cho tới khi gặp lỗi do chính key đó, rồi tự chuyển key kế tiếp **ngay trong cùng yêu cầu** (khách không thấy lỗi).
- Phân loại lỗi:

| Lỗi | Hành động |
|---|---|
| 429, quota, `RESOURCE_EXHAUSTED` | Key nghỉ 90 giây, đổi key |
| Hết hạn mức theo ngày (`PerDay`) | Key nghỉ 1 giờ, đổi key |
| `API key not valid`, 401, 403, `PERMISSION_DENIED` | Key coi như hỏng (nghỉ 6 giờ), đổi key |
| Lỗi khác (mạng, 5xx, câu lệnh sai) | **Không đổi key**, báo lỗi bình thường |

- Hết thời gian nghỉ thì key được dùng lại. Mọi key đều lỗi thì trả lỗi thân thiện ("AI đang quá tải"). Chat và embedding xoay key **độc lập** nhau.
- Admin xem trạng thái ở Dashboard, hoặc `GET /api/admin/ai/keys` (key luôn bị che, chỉ lộ 4 ký tự cuối).
- **Lưu ý:** hạn mức của Google tính theo **project**, không theo key. Hai key tạo trong cùng một project dùng chung hạn mức nên dự phòng không có tác dụng với lỗi 429. Hãy tạo key ở các project Google khác nhau.

**Điều tiết tốc độ khi lập chỉ mục:** gói miễn phí giới hạn embedding khoảng 100 văn bản và 30.000 token mỗi phút. `KnowledgeBase` gửi từng lô nhỏ và tự chờ giữa các lô (tối đa 70 văn bản và 20.000 token mỗi phút), gặp 429 thì chờ 65 giây rồi thử lại. Lập chỉ mục 447 đoạn mất khoảng 12 phút với một key miễn phí; Dashboard hiển thị tiến độ. Chỉ mục được lưu ra file nên **chỉ phải làm một lần**, các lần khởi động sau nạp lại trong vài giây.

### 2.8 Chi phí token và cách tiết kiệm

Số liệu đo trên dữ liệu hiện tại (46 tour, 7 tài liệu):

| Nguồn | Token ước tính | Khi nào xảy ra |
|---|---|---|
| Embed toàn bộ chỉ mục (447 đoạn: 371 đoạn tour, 40 tổng quan, 36 tài liệu) | ≈ 170.000 | **Một lần** (đã lưu ra đĩa) |
| Sửa một tour | ≈ 2.500 với bộ nhớ đệm (trước đó ≈ 15.000) | Mỗi lần admin sửa tour |
| Mỗi câu hỏi của khách | ≈ 5.000–7.000 token đầu vào | Mỗi lượt chat (đây là chi phí chạy thường xuyên lớn nhất) |

Đã làm để tiết kiệm:
- **Lưu chỉ mục ra đĩa** (`data/ai/vector-store.json`): khởi động lại chỉ nạp file, không gọi API.
- **Bộ nhớ đệm embedding** (`CachingEmbeddingModel`, file `data/ai/embedding-cache.json`): cùng một nội dung chỉ embed một lần, khóa theo nội dung và mô hình. Lập lại toàn bộ chỉ mục thử thật mất 0,6 giây và 0 lần gọi API. Lần đầu tự nạp sẵn vector từ chỉ mục cũ. Câu hỏi giống hệt nhau cũng được nhớ trong bộ nhớ (200 câu gần nhất).
- **Cập nhật theo từng tour** khi admin sửa, không dựng lại toàn bộ.
- **Điều tiết tốc độ** chỉ áp dụng khi có gọi API thật.

Các cách giảm tiếp (chưa làm, đánh đổi với chất lượng): giảm `app.ai.top-k` từ 10 xuống 6–8 (rẻ hơn nhưng dễ bỏ sót tour); cắt ngắn mỗi đoạn ngữ cảnh gửi cho mô hình; bỏ lịch trình chi tiết của từng tour khỏi chỉ mục nếu chỉ cần tư vấn tổng quan; nhớ lại câu trả lời cho câu hỏi giống hệt.

---

## 3. Frontend: user tracking

### 3.1 Tracking là gì và để làm gì

Ghi nhận **khách làm gì trên giao diện** (xem trang nào, bấm gì, tìm gì, bỏ ngang ở bước nào) để:
- thấy tour nào được quan tâm và phễu đặt tour rớt ở đâu (Dashboard admin);
- làm ngữ cảnh gợi ý cho trợ lý AI (tour khách vừa xem).

### 3.2 Cơ chế (`frontend/src/tracking/tracker.js`)

1. **Định danh ẩn danh:**
   - `anonymousId` lưu trong `localStorage`, sống lâu.
   - `sessionId` đổi sau 30 phút không hoạt động.
   - `user_id` **không do client khai báo**: khi khách đã đăng nhập, request kèm JWT và backend tự gắn.
2. **Sự kiện tự động:**
   - `page_view` và `page_leave` (thời gian ở trang, độ cuộn). SPA không tải lại trang nên phải tự bắt khi router đổi trang (hook `usePageTracking`).
   - `click`: một listener duy nhất ở `document` (event delegation), lấy nhãn từ `data-track` hoặc `aria-label` hoặc chữ của nút.
3. **Sự kiện nghiệp vụ** gọi tường minh tại điểm xảy ra:
   - `view_tour` (kèm tourId)
   - `search` (từ khóa, số kết quả)
   - `add_to_cart`, `remove_from_cart`
   - `begin_checkout`, `booking_created`
   - `login`, `register`
   - `chat_open`, `chat_message`, `chat_error`
4. **Gom lô và gửi:** đưa vào hàng đợi, gửi mỗi 5 giây hoặc khi đủ 20 sự kiện. Khi đóng hoặc ẩn tab dùng `navigator.sendBeacon` (đáng tin hơn `fetch`/axios lúc trang đang đóng). Mất mạng thì giữ lại gửi sau.
5. **Thẻ tour** có `data-track="tour-card" data-tour-id=...`, nên một click vào thẻ tour được ghi là "click tour 51" thay vì một đoạn chữ dài.

### 3.3 Quyền riêng tư (làm theo hướng "mặc định không theo dõi")

- **Banner đồng ý** (`TrackingConsent`): chưa bấm **Đồng ý** thì không ghi gì. Đã kiểm thử: bấm Từ chối thì có **0** request tracking.
- Tôn trọng **Do Not Track** và **Global Privacy Control** của trình duyệt (coi như từ chối, không hỏi lại).
- **Không bao giờ ghi nội dung ô nhập liệu.** Nhãn nút giống email hoặc số điện thoại bị che.
- Link ra ngoài chỉ ghi tên miền, không ghi query. Danh sách tour vừa xem chỉ lưu cục bộ khi khách đồng ý.
- Từ chối thì xóa hàng đợi và danh sách đã lưu.

### 3.4 Backend nhận dữ liệu (package `com.tourdulich.tracking`)

- `POST /api/tracking/events` (công khai, 90 request mỗi phút mỗi IP): nhận một lô tối đa 50 sự kiện. Sự kiện sai định dạng bị bỏ qua; id hoặc số lượng không hợp lệ thì trả HTTP 400.
- Bảng **`user_events`** (không có khóa ngoại tới `tours`: tour bị xóa vẫn giữ lịch sử). Có trong `database/schema.sql`, và `SchemaMigrator` tự tạo khi DB đã có sẵn.
- `GET /api/admin/tracking/summary?days=7` (admin): khách truy cập, phiên, phễu chuyển đổi (xem tour, thêm giỏ, vào trang đặt, đặt xong), tour xem nhiều, từ khóa tìm nhiều. Hiển thị ở panel **"Hành vi người dùng"** trên Dashboard admin, kèm trạng thái AI và nút "Lập lại chỉ mục".

### 3.5 Khung chat (`ChatWidget`)

Nút tròn góc phải dưới, mở khung chat:
- Gợi ý câu hỏi khi mới mở. Nếu đang ở trang một tour, các gợi ý đổi thành "Tour này gồm những gì?"...
- Trả lời hiển thị markdown (đậm, gạch đầu dòng, liên kết) và **thẻ tour bấm được**.
- Gửi kèm `currentTourId` (từ đường dẫn) và `viewedTourIds` (từ tracking) để trợ lý hiểu ngữ cảnh.
- Trạng thái lỗi có nút "Thử lại". Nếu AI chưa bật thì hiển thị thông báo kèm link Liên hệ.
- Hỗ trợ bàn phím (Enter gửi, Shift+Enter xuống dòng, Esc đóng), `aria-live` cho tin mới, giảm chuyển động khi người dùng bật `prefers-reduced-motion`. Trên mobile mở toàn màn hình.

---

## 4. Cách bật trợ lý AI và thêm key dự phòng

1. Lấy key tại <https://aistudio.google.com/apikey>. **Không commit key lên git.**
2. Mở `backend/.env` (đã `.gitignore`, mẫu ở `backend/.env.example`) và điền:
   ```
   GEMINI_API_KEY=key_chinh
   GEMINI_API_KEY_2=key_du_phong_1
   GEMINI_API_KEY_3=key_du_phong_2
   ```
   hoặc một dòng `GEMINI_API_KEYS=key1,key2,key3`. Key trùng hoặc để trống sẽ được bỏ qua. Thứ tự = thứ tự ưu tiên.
3. Khởi động lại backend. Có ít nhất một key thì trợ lý tự bật. Lần đầu tự lập chỉ mục ở luồng nền (theo dõi tiến độ ở Dashboard admin hoặc log `Đã embed x/y đoạn`).
4. Mở website, bấm nút chat và hỏi thử.

Backend tự đọc `.env` (cấu hình `spring.config.import` trong `application.yml`), không cần plugin IDE.

Tên mô hình mặc định (đổi bằng biến môi trường nếu Google đổi tên hoặc ngừng hỗ trợ):
- `GEMINI_CHAT_MODEL` mặc định `gemini-2.5-flash`.
- `GEMINI_EMBEDDING_MODEL` mặc định `gemini-embedding-001` (768 chiều).

---

## 5. Tài liệu cho AI học

### 5.1 Đã có sẵn
7 file ở `backend/src/main/resources/ai/knowledge/`: giới thiệu và liên hệ, hướng dẫn đặt tour, thanh toán, hủy đơn và hoàn tiền, tài khoản và bảo mật, câu hỏi thường gặp, tư vấn chọn tour và giấy tờ chung.

Nội dung dựa trên **hành vi thật của hệ thống** (quy tắc mật khẩu, cách tính tiền, chỉ hủy được đơn Chờ xác nhận, thanh toán QR...). Những chỗ liên quan chính sách riêng của công ty (mức phí hủy, hoàn tiền) mình **cố ý không bịa số**: tài liệu chỉ hướng khách tới mục "Điều kiện hủy" của từng tour (lấy từ dữ liệu Fiditour đã nạp) hoặc hotline.

### 5.2 Thêm hoặc sửa tài liệu
- **Cách 1 (đi kèm mã nguồn):** thêm file `.md` vào `backend/src/main/resources/ai/knowledge/`, build lại, rồi bấm "Lập lại chỉ mục".
- **Cách 2 (không cần build):** bỏ file vào thư mục `backend/ai-knowledge/` (đổi bằng `AI_KNOWLEDGE_DIR`), bấm "Lập lại chỉ mục". File trùng tên sẽ ghi đè bản trong classpath.

Cách viết để AI trả lời tốt:
- Mỗi file một chủ đề, bắt đầu bằng `# Tiêu đề`; mỗi ý một mục `## ...`. Phần mục sẽ là nhãn của đoạn khi tìm kiếm.
- Viết câu đầy đủ, nêu rõ đối tượng ("Khách muốn hủy đơn đã xác nhận thì...").
- Đưa số liệu ổn định (quy định, giờ làm việc). **Đừng ghi giá, số chỗ**: những thứ này AI lấy từ DB.
- Tour được lập chỉ mục tự động từ DB, không cần viết tay.

### 5.3 Cần bạn đưa
- **Gemini API key**, đưa mình hoặc tự dán theo mục 4.
- **Dữ liệu riêng của công ty:** chính sách hủy và hoàn tiền thật, khuyến mãi, quy định trẻ em và phụ thu, hướng dẫn visa từng nước, câu hỏi khách hay hỏi, thông tin công ty (giới thiệu, chứng nhận lữ hành...). Gửi dạng văn bản bất kỳ, mình sẽ chuẩn hóa thành file `.md` đúng định dạng.

---

## 6. Bảng API

| API | Quyền | Mục đích |
|---|---|---|
| `GET /api/ai/status` | Công khai | AI đã bật và sẵn sàng chưa |
| `POST /api/ai/chat` | Công khai, 15/phút/IP | `{message, history[], currentTourId, viewedTourIds[]}` trả `{answer, sources[]}` |
| `POST /api/tracking/events` | Công khai, 90/phút/IP | Gửi lô sự kiện hành vi |
| `GET /api/admin/tracking/summary?days=7` | Admin | Thống kê hành vi |
| `GET /api/admin/ai/status` | Admin | Trạng thái chỉ mục (số đoạn, tiến độ, đang lập hay không) |
| `GET /api/admin/ai/keys` | Admin | Trạng thái các API key (đã che): key đang dùng, key đang nghỉ, số lần đã chuyển key |
| `GET /api/admin/ai/preview` | Admin | Xem trước các tài liệu tổng quan về tour mà AI đọc |
| `POST /api/admin/ai/reindex` | Admin | Lập lại toàn bộ chỉ mục |

---

## 7. Đã kiểm thử gì

| Kiểm thử | Kết quả |
|---|---|
| Unit test `KnowledgeBaseTest` (embedding giả): dựng đoạn tour, tài liệu tổng quan, cắt tài liệu, lập chỉ mục, tìm kiếm, lọc theo tour, xóa khi tour bị gỡ, lưu file | 5/5 đạt |
| Unit test mốc thời gian Dashboard | 3/3 đạt |
| App khởi động khi chưa có key; chat trả 503 thân thiện; tracking trả 204/400 đúng; admin summary; reindex khi AI tắt trả 503 | Đạt |
| **Gemini thật** (key của bạn): lập chỉ mục 447 đoạn, hỏi 5 câu (tour Nhật, đi biển dưới 8 triệu, hủy đơn, thời tiết/giá vàng, đòi lộ system prompt) | Đạt: đúng dữ liệu, kèm link và giá; từ chối đúng câu ngoài chủ đề và câu dò prompt |
| Dự phòng key thật: key đầu là key giả, key thứ hai là key thật | Đạt: chat và embedding tự chuyển sang key thật và trả lời bình thường |
| `KeyFailoverTest` (12 test): phân loại lỗi, đổi key, hết thời gian nghỉ, mọi key lỗi, lỗi không do key, che key, đọc key từ cấu hình | 12/12 đạt |
| Trình duyệt thật (Chrome headless): banner đồng ý, từ chối thì 0 request, đồng ý thì có đủ sự kiện, khung chat desktop và mobile, markdown, thẻ tour, chống chèn `<script>`, không lỗi console | Đạt |
| Chất lượng trên tập câu hỏi lớn hơn (chỉ thử 5 câu) | Chưa: nên tự thử thêm và chỉnh `top-k`/ngưỡng nếu cần |

Các unit test dùng embedding giả nên chỉ chứng minh mã của project; chất lượng ngữ nghĩa được kiểm bằng lần chạy Gemini thật ở trên.

---

## 8. Hạn chế và hướng phát triển

- **Ngưỡng tìm kiếm** (`top-k=10`, `similarity-threshold=0.4`) là giá trị khởi đầu. Lúc đầu `top-k=6` làm AI bỏ sót các tour biển dưới 8 triệu; tăng lên 10 đã khắc phục. Hãy thử thêm câu hỏi thật và chỉnh trong `application.yml`.
- **Chưa streaming:** câu trả lời hiện ra một lần sau vài giây. Có thể chuyển sang `stream()` và SSE.
- **Câu hỏi về con số** ("tour dưới 10 triệu") embedding làm chưa tốt (vẫn có thể sót khi có nhiều tour). Hướng cải thiện: dùng tool/function calling để AI gọi API lọc tour, hoặc lọc theo metadata giá.
- **Chi phí và hạn mức:** mỗi câu hỏi tốn một lần gọi Gemini; gói miễn phí có giới hạn tốc độ. Đã chặn 15 câu/phút/IP.
- **Cá nhân hóa sâu hơn:** có thể dùng dữ liệu `user_events` để gợi ý tour tương tự các tour khách hay xem.
- **Tracking:** chưa có chính sách xóa dữ liệu theo thời gian (nên tự xóa sự kiện cũ hơn 90 ngày) và chưa có trang chính sách quyền riêng tư đầy đủ.

---

## 9. Danh sách file mới và thay đổi

**Backend**
- `ai/` gồm `KnowledgeBase`, `ChatService`, `AiController`, `AiAdminController`, `ChatDtos`, `TourChangedEvent`, và phần key dự phòng: `AiKeys`, `KeyRotation`, `FailoverModels`, `AiModelsConfiguration`, `AiKeyRegistry`, và `CachingEmbeddingModel` (bộ nhớ đệm embedding).
- `tracking/` gồm `TrackingService`, `TrackingController`.
- `resources/ai/knowledge/*.md`, `config/BlankGeminiKeyEnvironmentPostProcessor` (biến key rỗng không làm app sập), `backend/.env.example`.
- Sửa: `pom.xml`, `application.yml`, `AppProperties`, `SecurityConfig`, `RateLimitInterceptor`, `AdminTourService`, `SchemaMigrator`, `TourRepository`.
- Test: `KnowledgeBaseTest`, `KeyFailoverTest`, `DashboardPeriodTest`.

**Frontend**
- `tracking/tracker.js`, `components/ChatWidget.jsx`, `ChatMarkdown.jsx`, `TrackingConsent.jsx`, `styles/chat.css`.
- Sửa: `MainLayout` (gắn tracking, chat, banner), `api/index.js`, các trang gắn sự kiện (`TourDetail`, `Tours`, `Cart`, `Checkout`, `BookingSuccess`, `Login`, `Register`), `TourCard` (`data-track`), `admin/Dashboard.jsx` (panel hành vi).

**Database:** bảng `user_events` trong `database/schema.sql` và `database/migration_region.sql`.
