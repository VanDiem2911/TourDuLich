package com.tourdulich.ai;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.tourdulich.config.AppProperties;
import com.tourdulich.entity.Tour;
import com.tourdulich.entity.enums.TourRegion;
import com.tourdulich.entity.enums.TourStatus;
import com.tourdulich.repository.TourRepository;
import com.tourdulich.service.TourMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.document.Document;
import org.springframework.ai.embedding.EmbeddingModel;
import org.springframework.ai.transformer.splitter.TokenTextSplitter;
import org.springframework.ai.vectorstore.SearchRequest;
import org.springframework.ai.vectorstore.SimpleVectorStore;
import org.springframework.ai.vectorstore.filter.FilterExpressionBuilder;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.core.io.Resource;
import org.springframework.core.io.support.PathMatchingResourcePatternResolver;
import org.springframework.stereotype.Service;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;

import java.io.File;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.time.Instant;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.stream.Stream;

/**
 * "Kho tri thức" của trợ lý AI (phần Indexing của RAG).
 *
 * <p>Nguồn dữ liệu: (1) các tour đang mở bán trong MariaDB, (2) tài liệu .md/.txt trong
 * {@code classpath:ai/knowledge/} và thư mục {@code app.ai.knowledge-dir}. Mỗi nguồn được cắt thành các đoạn ngắn
 * (chunk), chuyển thành vector bằng {@link EmbeddingModel} (Gemini) rồi lưu vào {@link SimpleVectorStore}
 * (lưu ra file JSON để khởi động lại không phải embed lại).
 *
 * <p>Khi chưa bật AI (không có EmbeddingModel) mọi thao tác đều bị bỏ qua, ứng dụng vẫn chạy bình thường.
 */
@Slf4j
@Service
public class KnowledgeBase {

    public static final String META_TYPE = "type";
    public static final String META_TOUR_ID = "tourId";
    public static final String META_TITLE = "title";
    public static final String TYPE_TOUR = "tour";
    public static final String TYPE_DOC = "doc";
    /** Tài liệu tổng quan tự sinh từ DB (theo điểm đến, phạm vi, loại hành trình). */
    public static final String TYPE_OVERVIEW = "overview";
    /** Danh sách id tour (cách nhau bằng dấu phẩy) mà một tài liệu tổng quan nhắc tới. */
    public static final String META_TOUR_IDS = "tourIds";

    /** Trạng thái chỉ mục để hiển thị cho admin. */
    public record Stats(boolean enabled, boolean ready, boolean indexing, int chunks, int tourChunks, int docChunks,
                        Instant lastIndexedAt, String lastError, int doneChunks, int totalChunks,
                        long cacheHits, long cacheMisses, int cachedVectors) {
    }

    private static final DateTimeFormatter DATE = DateTimeFormatter.ofPattern("dd/MM/yyyy");

    private final ObjectProvider<EmbeddingModel> embeddingProvider;
    private final TourRepository tourRepository;
    private final AppProperties props;
    private final ObjectMapper objectMapper;
    private final VectorPersistence persistence;

    private final ExecutorService worker = Executors.newSingleThreadExecutor(r -> {
        Thread t = new Thread(r, "ai-indexer");
        t.setDaemon(true);
        return t;
    });
    private final TokenTextSplitter splitter = TokenTextSplitter.builder()
            .withChunkSize(500)
            .withMinChunkSizeChars(100)
            .withMinChunkLengthToEmbed(10)
            .withMaxNumChunks(5)
            .withKeepSeparator(true)
            .build();

    private volatile SimpleVectorStore store;
    private volatile boolean indexing;
    private volatile Instant lastIndexedAt;
    private volatile String lastError;
    private volatile int doneChunks;
    private volatile int totalChunks;
    private volatile int tourChunks;
    private volatile int docChunks;

    public KnowledgeBase(ObjectProvider<EmbeddingModel> embeddingProvider, TourRepository tourRepository,
                         AppProperties props, ObjectMapper objectMapper, VectorPersistence persistence) {
        this.embeddingProvider = embeddingProvider;
        this.tourRepository = tourRepository;
        this.props = props;
        this.objectMapper = objectMapper;
        this.persistence = persistence;
    }

    // ------------------------------------------------------------------ Trạng thái

    /** Có cấu hình mô hình embedding (có ít nhất một GEMINI_API_KEY) hay không. */
    public boolean isEnabled() {
        return embeddingProvider.getIfAvailable() != null;
    }

    /** Đã có chỉ mục để tìm kiếm. */
    public boolean isReady() {
        return isEnabled() && store != null;
    }

    public Stats stats() {
        return new Stats(isEnabled(), store != null, indexing, tourChunks + docChunks, tourChunks, docChunks,
                lastIndexedAt, lastError, doneChunks, totalChunks, cacheHits(), cacheMisses(), cachedVectors());
    }

    private long cacheHits() {
        return embeddingProvider.getIfAvailable() instanceof CachingEmbeddingModel c ? c.hits() : 0L;
    }

    private long cacheMisses() {
        return embeddingProvider.getIfAvailable() instanceof CachingEmbeddingModel c ? c.misses() : 0L;
    }

    private int cachedVectors() {
        return embeddingProvider.getIfAvailable() instanceof CachingEmbeddingModel c ? c.cachedDocuments() : 0;
    }

    // ------------------------------------------------------------------ Khởi động

    /** Nạp vector đã lưu; nếu chưa có thì lập chỉ mục nền (không chặn việc khởi động ứng dụng). */
    @EventListener(ApplicationReadyEvent.class)
    public void warmUp() {
        if (!isEnabled()) {
            log.info("Trợ lý AI đang TẮT (chưa có GEMINI_API_KEY trong .env). Chatbot sẽ báo chưa sẵn sàng.");
            return;
        }
        try {
            List<VectorPersistence.Row> rows = persistence.loadAll();
            if (rows.isEmpty()) {
                rows = importLegacyFile(); // chuyển file JSON của phiên bản cũ vào DB (một lần)
            }
            if (!rows.isEmpty()) {
                SimpleVectorStore loaded = newStore();
                loaded.load(new ByteArrayResource(VectorStoreJson.toJson(rows, objectMapper)));
                countRows(rows);
                store = loaded;
                lastIndexedAt = Instant.now();
                seedCache(rows);
                log.info("Đã nạp chỉ mục AI từ bảng ai_vectors ({} đoạn tour/tổng quan, {} đoạn tài liệu).", tourChunks, docChunks);
                return;
            }
        } catch (Exception e) {
            log.warn("Không nạp được chỉ mục AI đã lưu trong DB, sẽ lập lại: {}", e.getMessage());
        }
        worker.submit(() -> {
            try {
                reindexAll();
            } catch (Exception e) {
                log.error("Lập chỉ mục AI thất bại: {}", e.getMessage());
            }
        });
    }

    // ------------------------------------------------------------------ Lập chỉ mục

    /** Lập lại toàn bộ chỉ mục từ DB + tài liệu. Dựng chỉ mục mới rồi mới thay thế nên chat không bị gián đoạn. */
    public synchronized Stats reindexAll() {
        EmbeddingModel model = requireModel();
        indexing = true;
        lastError = null;
        try {
            List<Document> tourDocs = new ArrayList<>();
            List<Tour> activeTours = tourRepository.findAllActiveWithCategory();
            for (Tour t : activeTours) {
                tourDocs.addAll(tourDocuments(t));
            }
            tourDocs.addAll(overviewDocuments(activeTours));
            List<Document> kbDocs = knowledgeDocuments();
            totalChunks = tourDocs.size() + kbDocs.size();
            doneChunks = 0;
            log.info("Bắt đầu lập chỉ mục AI: {} đoạn (có điều tiết tốc độ theo hạn mức Gemini, có thể mất vài phút).", totalChunks);

            SimpleVectorStore fresh = SimpleVectorStore.builder(model).build();
            addInBatches(fresh, tourDocs);
            addInBatches(fresh, kbDocs);
            persist(fresh);

            store = fresh;
            tourChunks = tourDocs.size();
            docChunks = kbDocs.size();
            lastIndexedAt = Instant.now();
            log.info("Đã lập chỉ mục AI: {} đoạn tour + {} đoạn tài liệu.", tourChunks, docChunks);
            return stats();
        } catch (RuntimeException e) {
            lastError = e.getMessage();
            throw e;
        } finally {
            indexing = false;
        }
    }

    /** Cập nhật chỉ mục cho một tour (thêm/sửa/xóa/đóng bán). Chạy nền sau khi giao dịch DB đã commit. */
    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT, fallbackExecution = true)
    public void onTourChanged(TourChangedEvent event) {
        if (!isEnabled()) {
            return;
        }
        worker.submit(() -> {
            try {
                reindexTour(event.tourId());
            } catch (Exception e) {
                log.warn("Không cập nhật được chỉ mục AI cho tour {}: {}", event.tourId(), e.getMessage());
            }
        });
    }

    synchronized void reindexTour(Long tourId) {
        SimpleVectorStore s = store;
        if (s == null) {
            return; // chưa có chỉ mục: lần lập chỉ mục đầu sẽ bao gồm tour này
        }
        s.delete(new FilterExpressionBuilder().eq(META_TOUR_ID, String.valueOf(tourId)).build());
        tourRepository.findWithCategoryById(tourId)
                .filter(t -> t.getStatus() == TourStatus.ACTIVE)
                .ifPresent(t -> s.add(tourDocuments(t)));
        // Tài liệu tổng quan (theo điểm đến...) phụ thuộc cả danh sách tour nên dựng lại toàn bộ (rẻ: vài chục đoạn)
        s.delete(new FilterExpressionBuilder().eq(META_TYPE, TYPE_OVERVIEW).build());
        List<Document> overview = overviewDocuments(tourRepository.findAllActiveWithCategory());
        if (!overview.isEmpty()) {
            s.add(overview);
        }
        try {
            persist(s);
        } catch (RuntimeException e) {
            log.warn("Không lưu được file chỉ mục AI: {}", e.getMessage());
        }
        log.info("Đã cập nhật chỉ mục AI cho tour {}.", tourId);
    }

    /** Xem trước các tài liệu tổng quan sẽ được lập chỉ mục (không cần API key): để admin kiểm tra AI "đọc" gì về tour. */
    public List<Map<String, String>> previewOverview() {
        List<Map<String, String>> out = new ArrayList<>();
        for (Document d : overviewDocuments(tourRepository.findAllActiveWithCategory())) {
            Map<String, String> m = new LinkedHashMap<>();
            m.put("id", d.getId());
            m.put("text", d.getText());
            out.add(m);
        }
        return out;
    }

    // ------------------------------------------------------------------ Tìm kiếm (Retrieval)

    /** Tìm các đoạn gần nghĩa nhất với câu hỏi; tourId != null thì chỉ lấy trong các đoạn của tour đó. */
    public List<Document> search(String query, int topK, double threshold, Long tourId) {
        SimpleVectorStore s = store;
        if (s == null) {
            return List.of();
        }
        SearchRequest.Builder b = SearchRequest.builder().query(query).topK(topK).similarityThreshold(threshold);
        if (tourId != null) {
            b.filterExpression(new FilterExpressionBuilder().eq(META_TOUR_ID, String.valueOf(tourId)).build());
        }
        return s.similaritySearch(b.build());
    }

    // ------------------------------------------------------------------ Dựng tài liệu từ tour

    List<Document> tourDocuments(Tour t) {
        String id = String.valueOf(t.getId());
        String prefix = "[Tour: " + t.getName() + "] ";
        Map<String, Object> meta = new LinkedHashMap<>();
        meta.put(META_TYPE, TYPE_TOUR);
        meta.put(META_TOUR_ID, id);
        meta.put(META_TITLE, t.getName());

        List<Document> out = new ArrayList<>();
        // 1) Thẻ thông tin tổng quan (đoạn quan trọng nhất để tìm theo điểm đến, giá, thời lượng...)
        out.add(Document.builder().id("tour:" + id + ":head")
                .text(prefix + headline(t)).metadata(meta).build());
        // 2) Lịch trình chi tiết
        addSplit(out, "tour:" + id + ":itin", prefix + "Lịch trình chi tiết:\n" + nz(t.getItinerary()), meta);
        // 3) Giá bao gồm / không bao gồm / hủy / phụ thu (bỏ phần "giấy tờ" dài và giống nhau giữa các tour)
        addSplit(out, "tour:" + id + ":note", prefix + "Giá, dịch vụ và quy định:\n" + usefulNotes(t.getNotes()), meta);
        return out;
    }

    // ------------------------------------------------------------------ Tài liệu tổng quan về tour

    /**
     * Các tài liệu "danh mục tour" tự sinh từ DB để trả lời câu hỏi tổng quát ("có tour nào đi Nhật?", "tour biển nào hợp
     * gia đình?"): một tài liệu cho mỗi điểm đến, mỗi loại hành trình (danh mục) và mỗi phạm vi (trong nước / nước ngoài).
     * Luôn khớp với dữ liệu hiện có và có sẵn liên kết /tours/id. Giá chỉ để tham khảo, giá hiện tại do ChatService bổ sung.
     */
    List<Document> overviewDocuments(List<Tour> tours) {
        List<Document> out = new ArrayList<>();
        if (tours == null || tours.isEmpty()) {
            return out;
        }
        Map<String, List<Tour>> byDestination = new java.util.TreeMap<>();
        Map<String, List<Tour>> byCategory = new java.util.TreeMap<>();
        for (Tour t : tours) {
            byDestination.computeIfAbsent(nz(t.getDestination()).isBlank() ? "Khác" : t.getDestination().strip(),
                    k -> new ArrayList<>()).add(t);
            byCategory.computeIfAbsent(t.getCategory().getName(), k -> new ArrayList<>()).add(t);
        }
        byDestination.forEach((dest, list) -> addOverviewChunks(out, "overview:dest:" + slug(dest),
                "[Tổng quan tour đến " + dest + "] Các tour đi " + dest + " hiện có (" + list.size() + " tour):", list, true));
        byCategory.forEach((cat, list) -> addOverviewChunks(out, "overview:cat:" + slug(cat),
                "[Tổng quan loại hành trình: " + cat + "] Các tour thuộc loại \"" + cat + "\" (" + list.size() + " tour):", list, false));
        for (TourRegion region : TourRegion.values()) {
            List<Tour> list = tours.stream().filter(t -> t.getRegion() == region).toList();
            if (list.isEmpty()) {
                continue;
            }
            Map<String, Long> counts = new java.util.TreeMap<>();
            list.forEach(t -> counts.merge(nz(t.getDestination()).isBlank() ? "Khác" : t.getDestination().strip(), 1L, Long::sum));
            boolean intl = region == TourRegion.INTERNATIONAL;
            String header = (intl ? "[Tổng quan tour nước ngoài] Website có " : "[Tổng quan tour trong nước] Website có ")
                    + list.size() + (intl ? " tour nước ngoài" : " tour trong nước") + ". Các điểm đến: "
                    + String.join(", ", counts.entrySet().stream().map(e -> e.getKey() + " (" + e.getValue() + " tour)").toList()) + ".";
            addOverviewChunks(out, "overview:region:" + region.name().toLowerCase(), header, list, false);
        }
        return out;
    }

    /**
     * Gom các dòng tour thành các đoạn tối đa khoảng 1500 ký tự mà KHÔNG cắt giữa một dòng (tránh cắt đôi số tiền hay tên tour),
     * mỗi đoạn lặp lại tiêu đề và chỉ gắn id của các tour có trong đoạn đó.
     */
    private void addOverviewChunks(List<Document> out, String idPrefix, String header, List<Tour> list, boolean withRoute) {
        final int max = 1500;
        StringBuilder sb = new StringBuilder(header).append('\n');
        List<Tour> in = new ArrayList<>();
        int part = 0;
        for (Tour t : list) {
            String line = tourLine(t, withRoute);
            if (!in.isEmpty() && sb.length() + line.length() > max) {
                emitOverview(out, idPrefix + ":" + part++, sb.toString(), in);
                sb = new StringBuilder(header).append(" (tiếp)\n");
                in = new ArrayList<>();
            }
            sb.append(line);
            in.add(t);
        }
        if (!in.isEmpty()) {
            emitOverview(out, idPrefix + ":" + part, sb.toString(), in);
        }
    }

    private void emitOverview(List<Document> out, String id, String text, List<Tour> tours) {
        Map<String, Object> meta = new LinkedHashMap<>();
        meta.put(META_TYPE, TYPE_OVERVIEW);
        meta.put(META_TITLE, id);
        meta.put(META_TOUR_IDS, String.join(",", tours.stream().map(t -> String.valueOf(t.getId())).toList()));
        out.add(Document.builder().id(id).text(text.strip()).metadata(meta).build());
    }

    private static String tourLine(Tour t, boolean withRoute) {
        StringBuilder sb = new StringBuilder();
        sb.append("- ").append(t.getName()).append(" (/tours/").append(t.getId()).append("), ")
                .append(nz(t.getDuration())).append(", ").append(nz(t.getTransport()))
                .append(", khởi hành từ ").append(nz(t.getDepartureLocation()))
                .append(", giá người lớn khoảng ").append(vnd(t.effectiveAdultPrice().longValue()));
        if (withRoute) {
            String route = routeOf(t.getItinerary());
            if (!route.isEmpty()) {
                sb.append(". Hành trình: ").append(route);
            }
        }
        return sb.append('\n').toString();
    }

    /** Tóm tắt hành trình từ tiêu đề các ngày ("Ngày 1: Hà Nội - Singapore" -> "Hà Nội - Singapore → ..."). */
    static String routeOf(String itinerary) {
        if (itinerary == null || itinerary.isBlank()) {
            return "";
        }
        List<String> titles = new ArrayList<>();
        for (String line : itinerary.replace("\r", "").split("\n")) {
            java.util.regex.Matcher m = java.util.regex.Pattern.compile("^Ngày\\s*\\d+\\s*:\\s*(.+)$").matcher(line.strip());
            if (m.matches()) {
                String title = m.group(1).strip();
                // Bỏ tiêu đề "rác" do nguồn dữ liệu (đó là câu mô tả buổi sáng/trưa, không phải tên chặng); rút gọn tiêu đề dài
                if (title.matches("(?i)^(sáng|trưa|chiều|tối)\\s*:.*")) {
                    continue;
                }
                titles.add(title.length() > 70 ? title.substring(0, 70).strip() + "…" : title);
            }
        }
        String joined = String.join(" → ", titles);
        return joined.length() > 320 ? joined.substring(0, 320).strip() + "…" : joined;
    }

    private static String slug(String s) {
        String n = java.text.Normalizer.normalize(s.replace('đ', 'd').replace('Đ', 'D'), java.text.Normalizer.Form.NFD)
                .replaceAll("\\p{M}+", "");
        return n.toLowerCase().replaceAll("[^a-z0-9]+", "-").replaceAll("(^-|-$)", "");
    }

    private void addSplit(List<Document> out, String idPrefix, String text, Map<String, Object> meta) {
        if (text == null || text.isBlank() || text.endsWith(":\n")) {
            return;
        }
        List<Document> parts = splitter.apply(List.of(Document.builder().text(text).metadata(meta).build()));
        for (int i = 0; i < parts.size(); i++) {
            out.add(parts.get(i).mutate().id(idPrefix + ":" + i).build());
        }
    }

    private static String headline(Tour t) {
        StringBuilder sb = new StringBuilder();
        sb.append(t.getName()).append(" (mã ").append(t.getTourCode()).append("). ");
        sb.append(t.getRegion() == TourRegion.INTERNATIONAL ? "Tour nước ngoài" : "Tour trong nước");
        sb.append(", danh mục ").append(t.getCategory().getName()).append(". ");
        sb.append("Điểm đến: ").append(nz(t.getDestination())).append(". ");
        sb.append("Khởi hành từ: ").append(nz(t.getDepartureLocation())).append(". ");
        sb.append("Thời lượng: ").append(nz(t.getDuration())).append(". ");
        sb.append("Phương tiện: ").append(nz(t.getTransport())).append(". ");
        if (t.getDepartureDate() != null) {
            sb.append("Khởi hành dự kiến: ").append(t.getDepartureDate().format(DATE)).append(". ");
        }
        sb.append("Giá người lớn: ").append(vnd(t.effectiveAdultPrice().longValue()));
        if (t.hasPromo()) {
            sb.append(" (đang khuyến mãi, giá gốc ").append(vnd(t.getAdultPrice().longValue())).append(")");
        }
        sb.append(". Giá trẻ em: ").append(vnd(TourMapper.effectiveChildPrice(t).longValue())).append(". ");
        if (t.getShortDescription() != null) {
            sb.append("Mô tả: ").append(t.getShortDescription());
        }
        sb.append(" Xem chi tiết tại /tours/").append(t.getId());
        return sb.toString();
    }

    /** Giữ các mục "bao gồm", "hủy", "phụ thu"; bỏ "giấy tờ mang theo" và các mục dài khác. */
    static String usefulNotes(String notes) {
        if (notes == null || notes.isBlank()) {
            return "";
        }
        StringBuilder sb = new StringBuilder();
        for (String block : notes.replace("\r", "").split("\n\\s*\n")) {
            String first = block.lines().findFirst().orElse("").toLowerCase();
            if (first.contains("bao gồm") || first.contains("hủy") || first.contains("phụ thu")) {
                sb.append(block.strip()).append("\n\n");
            }
        }
        return sb.toString().strip();
    }

    // ------------------------------------------------------------------ Dựng tài liệu từ file tri thức

    List<Document> knowledgeDocuments() {
        List<Document> out = new ArrayList<>();
        Map<String, String> files = new LinkedHashMap<>();
        try {
            PathMatchingResourcePatternResolver resolver = new PathMatchingResourcePatternResolver();
            for (String pattern : List.of("classpath*:ai/knowledge/*.md", "classpath*:ai/knowledge/*.txt")) {
                for (Resource r : resolver.getResources(pattern)) {
                    if (r.getFilename() != null) {
                        files.put(r.getFilename(), new String(r.getInputStream().readAllBytes(), StandardCharsets.UTF_8));
                    }
                }
            }
        } catch (IOException e) {
            log.warn("Không đọc được tài liệu trong classpath: {}", e.getMessage());
        }
        // Thư mục ngoài (ghi đè file cùng tên trong classpath): thêm/sửa tài liệu mà không cần build lại
        String dir = props.ai() == null ? null : props.ai().knowledgeDir();
        if (dir != null && !dir.isBlank() && Files.isDirectory(Path.of(dir))) {
            try (Stream<Path> list = Files.list(Path.of(dir))) {
                for (Path p : list.filter(x -> x.toString().endsWith(".md") || x.toString().endsWith(".txt")).toList()) {
                    files.put(p.getFileName().toString(), Files.readString(p, StandardCharsets.UTF_8));
                }
            } catch (IOException e) {
                log.warn("Không đọc được thư mục tài liệu {}: {}", dir, e.getMessage());
            }
        }
        files.forEach((name, text) -> out.addAll(documentsOf(name, text)));
        return out;
    }

    /** Cắt một file markdown theo tiêu đề (#, ##) rồi cắt tiếp theo độ dài; mỗi đoạn kèm tên tài liệu + mục. */
    List<Document> documentsOf(String filename, String text) {
        String title = filename;
        List<String[]> sections = new ArrayList<>(); // {heading, body}
        String heading = "";
        StringBuilder body = new StringBuilder();
        for (String line : text.replace("\r", "").split("\n")) {
            if (line.startsWith("# ") && title.equals(filename)) {
                title = line.substring(2).strip();
                continue;
            }
            if (line.startsWith("## ") || line.startsWith("# ")) {
                if (body.toString().isBlank() && sections.isEmpty() && heading.isEmpty()) {
                    // chưa có nội dung trước tiêu đề đầu tiên
                } else {
                    sections.add(new String[]{heading, body.toString()});
                }
                heading = line.replaceFirst("^#+\\s*", "").strip();
                body = new StringBuilder();
                continue;
            }
            body.append(line).append('\n');
        }
        sections.add(new String[]{heading, body.toString()});

        List<Document> out = new ArrayList<>();
        for (int i = 0; i < sections.size(); i++) {
            String h = sections.get(i)[0];
            String b = sections.get(i)[1].strip();
            if (b.isBlank()) {
                continue;
            }
            Map<String, Object> meta = new LinkedHashMap<>();
            meta.put(META_TYPE, TYPE_DOC);
            meta.put(META_TITLE, title);
            String label = "[Tài liệu: " + title + (h.isEmpty() ? "" : " > " + h) + "] ";
            addSplit(out, "kb:" + filename + ":" + i, label + b, meta);
        }
        return out;
    }

    // ------------------------------------------------------------------ Lưu trữ

    /** Giới hạn gói miễn phí của embedding Gemini (xấp xỉ): ~100 văn bản và ~30.000 token mỗi phút. Dùng mức thấp hơn cho an toàn. */
    private static final int MAX_TEXTS_PER_MINUTE = 70;
    private static final int MAX_TOKENS_PER_MINUTE = 20_000;
    private static final int MAX_BATCH_TEXTS = 20;
    private static final int RATE_LIMIT_RETRIES = 4;

    /**
     * Embed theo từng lô nhỏ và tự điều tiết tốc độ để không vượt hạn mức API: sau mỗi lô chờ đủ lâu để số văn bản và số token
     * trung bình mỗi phút nằm dưới ngưỡng. Gặp lỗi 429 thì chờ hơn một phút rồi thử lại lô đó. Cập nhật tiến độ cho admin.
     */
    private void addInBatches(SimpleVectorStore target, List<Document> docs) {
        int i = 0;
        while (i < docs.size()) {
            int end = i;
            int tokens = 0;
            while (end < docs.size() && end - i < MAX_BATCH_TEXTS) {
                int t = estimateTokens(docs.get(end).getText());
                if (end > i && tokens + t > MAX_TOKENS_PER_MINUTE / 2) {
                    break;
                }
                tokens += t;
                end++;
            }
            List<Document> batch = docs.subList(i, end);
            long missesBefore = apiCalls();
            addWithRetry(target, batch);
            // Số đoạn THỰC SỰ gọi API (phần còn lại lấy từ bộ nhớ đệm, không tốn token). Không có bộ nhớ đệm thì coi như gọi hết.
            long apiUsed = embeddingProvider.getIfAvailable() instanceof CachingEmbeddingModel ? apiCalls() - missesBefore : batch.size();
            doneChunks += batch.size();
            log.info("Đã embed {}/{} đoạn (gọi API {}, lấy từ bộ nhớ đệm {})...", doneChunks, totalChunks, apiUsed, batch.size() - apiUsed);
            i = end;
            if (i < docs.size() && apiUsed > 0) { // chỉ điều tiết khi có gọi API
                long waitMs = Math.max(1200L, Math.max(apiUsed * 60_000L / MAX_TEXTS_PER_MINUTE,
                        tokens * apiUsed / batch.size() * 60_000L / MAX_TOKENS_PER_MINUTE));
                sleep(waitMs);
            }
        }
    }

    /** Số lần đã gọi API embedding thật (0 nếu không có bộ nhớ đệm hoặc AI tắt). */
    private long apiCalls() {
        return embeddingProvider.getIfAvailable() instanceof CachingEmbeddingModel c ? c.misses() : 0L;
    }

    private void addWithRetry(SimpleVectorStore target, List<Document> batch) {
        for (int attempt = 0; ; attempt++) {
            try {
                target.add(batch);
                return;
            } catch (RuntimeException e) {
                String m = String.valueOf(e.getMessage()).toLowerCase();
                boolean rateLimited = m.contains("429") || m.contains("quota") || m.contains("exhausted");
                if (!rateLimited || attempt >= RATE_LIMIT_RETRIES) {
                    throw e;
                }
                log.warn("Gemini giới hạn tốc độ (lần {}), chờ 65 giây rồi thử lại lô {} đoạn...", attempt + 1, batch.size());
                sleep(65_000L);
            }
        }
    }

    /** Ước lượng thô số token của văn bản tiếng Việt (~2,5 ký tự mỗi token) để điều tiết tốc độ. */
    private static int estimateTokens(String text) {
        return text == null ? 0 : (int) Math.ceil(text.length() / 2.5);
    }

    private static void sleep(long ms) {
        try {
            Thread.sleep(ms);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new IllegalStateException("Bị ngắt khi lập chỉ mục", e);
        }
    }

    private SimpleVectorStore newStore() {
        return SimpleVectorStore.builder(requireModel()).build();
    }

    private EmbeddingModel requireModel() {
        EmbeddingModel m = embeddingProvider.getIfAvailable();
        if (m == null) {
            throw new IllegalStateException("Trợ lý AI chưa được bật (thiếu GEMINI_API_KEY)..");
        }
        return m;
    }

    /** Đường dẫn file JSON của phiên bản cũ (chỉ dùng để chuyển dữ liệu cũ vào DB một lần). */
    private File legacyFile() {
        String p = props.ai() == null ? null : props.ai().storePath();
        return new File(p == null || p.isBlank() ? "./data/ai/vector-store.json" : p);
    }

    /** Có file chỉ mục JSON cũ thì đọc, lưu vào DB và trả về các dòng đó; không thì trả rỗng. */
    private List<VectorPersistence.Row> importLegacyFile() {
        File file = legacyFile();
        if (!file.isFile()) {
            return List.of();
        }
        try {
            List<VectorPersistence.Row> rows = VectorStoreJson.fromJson(objectMapper.readTree(file), objectMapper);
            if (!rows.isEmpty()) {
                persistence.replaceAll(rows, modelName());
                log.info("Đã chuyển {} vector từ file {} vào bảng ai_vectors. Có thể xóa file cũ.", rows.size(), file);
            }
            return rows;
        } catch (IOException e) {
            log.warn("Không đọc được file chỉ mục cũ {}: {}", file, e.getMessage());
            return List.of();
        }
    }

    /** Ghi toàn bộ chỉ mục xuống DB (một giao dịch): SimpleVectorStore chỉ xuất được JSON nên đi qua file tạm. */
    private void persist(SimpleVectorStore s) {
        File tmp = null;
        try {
            tmp = File.createTempFile("ai-vectors-", ".json");
            s.save(tmp);
            persistence.replaceAll(VectorStoreJson.fromJson(objectMapper.readTree(tmp), objectMapper), modelName());
        } catch (IOException e) {
            throw new IllegalStateException("Không lưu được chỉ mục AI vào DB: " + e.getMessage(), e);
        } finally {
            if (tmp != null) {
                tmp.delete();
            }
        }
    }

    private String modelName() {
        return embeddingProvider.getIfAvailable() instanceof CachingEmbeddingModel c ? c.namespace() : "unknown";
    }

    /** Nạp sẵn vector đã có vào bộ nhớ đệm embedding để lần lập lại chỉ mục tiếp theo không tốn token. */
    private void seedCache(List<VectorPersistence.Row> rows) {
        if (embeddingProvider.getIfAvailable() instanceof CachingEmbeddingModel c) {
            Map<String, float[]> m = new LinkedHashMap<>();
            rows.forEach(r -> m.put(r.text(), r.embedding()));
            c.seed(m);
        }
    }

    private void countRows(List<VectorPersistence.Row> rows) {
        int t = 0;
        int d = 0;
        for (VectorPersistence.Row r : rows) {
            if (r.id().startsWith("tour:") || r.id().startsWith("overview:")) {
                t++;
            } else {
                d++;
            }
        }
        tourChunks = t;
        docChunks = d;
    }

    // ------------------------------------------------------------------ Tiện ích

    private static String nz(String s) {
        return s == null ? "" : s;
    }

    static String vnd(long n) {
        return String.format("%,d", n).replace(',', '.') + " đ";
    }
}
