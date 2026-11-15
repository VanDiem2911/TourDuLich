package com.tourdulich.ai;

import com.tourdulich.entity.Tour;
import com.tourdulich.entity.enums.TourStatus;
import com.tourdulich.repository.TourRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.document.Document;
import org.springframework.ai.embedding.BatchingStrategy;
import org.springframework.ai.embedding.EmbeddingModel;
import org.springframework.ai.embedding.EmbeddingOptions;
import org.springframework.ai.vectorstore.SearchRequest;
import org.springframework.ai.vectorstore.VectorStore;
import org.springframework.ai.vectorstore.filter.Filter;
import org.springframework.ai.vectorstore.filter.FilterExpressionBuilder;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Service;
import org.springframework.transaction.support.TransactionOperations;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;

import java.time.Instant;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import static com.tourdulich.ai.KnowledgeDocuments.META_TITLE;
import static com.tourdulich.ai.KnowledgeDocuments.META_TOUR_ID;
import static com.tourdulich.ai.KnowledgeDocuments.META_TYPE;
import static com.tourdulich.ai.KnowledgeDocuments.TYPE_DOC;
import static com.tourdulich.ai.KnowledgeDocuments.TYPE_OVERVIEW;
import static com.tourdulich.ai.KnowledgeDocuments.TYPE_TOUR;

/**
 * "Kho tri thức" của trợ lý AI: đưa các đoạn do {@link KnowledgeDocuments} dựng ra vào {@link VectorStore} của Spring AI
 * (Indexing) và tìm các đoạn gần nghĩa với câu hỏi (Retrieval). Store (xem {@link VectorStoreConfiguration}) tự chuyển đoạn
 * thành vector bằng {@link EmbeddingModel} (Gemini), lưu trong MariaDB và tìm kiếm ngay trong database.
 *
 * <p>Khi chưa bật AI (không có EmbeddingModel) mọi thao tác đều bị bỏ qua, ứng dụng vẫn chạy bình thường.
 */
@Slf4j
@Service
public class KnowledgeBase {

    /** Trạng thái chỉ mục để hiển thị cho admin. */
    public record Stats(boolean enabled, boolean ready, boolean indexing, int chunks, int tourChunks, int docChunks,
                        Instant lastIndexedAt, String lastError, int doneChunks, int totalChunks,
                        long cacheHits, long cacheMisses, int cachedVectors) {
    }

    /** Chọn mọi đoạn do {@link KnowledgeDocuments} tạo ra (dùng để xóa trước khi lập lại chỉ mục). */
    private static final Filter.Expression ALL_CHUNKS =
            new FilterExpressionBuilder().in(META_TYPE, TYPE_TOUR, TYPE_OVERVIEW, TYPE_DOC).build();
    /** Không chia nhỏ thêm khi embed: {@link #embedInBatches} đã tự chia lô theo hạn mức API. */
    private static final BatchingStrategy ONE_BATCH = documents -> List.of(documents);

    private final ObjectProvider<EmbeddingModel> embeddingProvider;
    private final ObjectProvider<VectorStore> storeProvider;
    private final TourRepository tourRepository;
    private final KnowledgeDocuments documents;
    private final TransactionOperations tx;

    private final ExecutorService worker = Executors.newSingleThreadExecutor(r -> {
        Thread t = new Thread(r, "ai-indexer");
        t.setDaemon(true);
        return t;
    });

    /** Chờ giữa các lô để không vượt hạn mức API. Chỉ test mới tắt (embedding giả không có hạn mức). */
    volatile boolean throttle = true;
    private volatile boolean ready;
    private volatile boolean indexing;
    private volatile Instant lastIndexedAt;
    private volatile String lastError;
    private volatile int doneChunks;
    private volatile int totalChunks;
    private volatile int tourChunks;
    private volatile int docChunks;

    public KnowledgeBase(ObjectProvider<EmbeddingModel> embeddingProvider, ObjectProvider<VectorStore> storeProvider,
                         TourRepository tourRepository, KnowledgeDocuments documents, TransactionOperations tx) {
        this.embeddingProvider = embeddingProvider;
        this.storeProvider = storeProvider;
        this.tourRepository = tourRepository;
        this.documents = documents;
        this.tx = tx;
    }

    // ------------------------------------------------------------------ Trạng thái

    /** Có cấu hình mô hình embedding (có ít nhất một GEMINI_API_KEY) hay không. */
    public boolean isEnabled() {
        return embeddingProvider.getIfAvailable() != null;
    }

    /** Đã lập chỉ mục ít nhất một lần (từ lúc khởi động) nên có thể tìm kiếm. */
    public boolean isReady() {
        return isEnabled() && ready;
    }

    public Stats stats() {
        return new Stats(isEnabled(), ready, indexing, tourChunks + docChunks, tourChunks, docChunks,
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

    /**
     * Đồng bộ chỉ mục ở nền mỗi lần khởi động (không chặn việc khởi động ứng dụng). Đoạn nào đã embed rồi lấy từ bộ nhớ đệm
     * nên gần như miễn phí, và tour sửa lúc ứng dụng tắt cũng được cập nhật.
     */
    @EventListener(ApplicationReadyEvent.class)
    public void warmUp() {
        if (!isEnabled()) {
            log.info("Trợ lý AI đang TẮT (chưa có GEMINI_API_KEY trong .env). Chatbot sẽ báo chưa sẵn sàng.");
            return;
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

    /** Lập lại toàn bộ chỉ mục từ DB + tài liệu; chỉ mục cũ được giữ nguyên cho tới khi chỉ mục mới sẵn sàng. */
    public synchronized Stats reindexAll() {
        indexing = true;
        lastError = null;
        try {
            List<Document> tourDocs = new ArrayList<>();
            List<Tour> activeTours = tourRepository.findAllActiveWithCategory();
            for (Tour t : activeTours) {
                tourDocs.addAll(documents.tourDocuments(t));
            }
            tourDocs.addAll(documents.overviewDocuments(activeTours));
            List<Document> kbDocs = documents.knowledgeDocuments();
            List<Document> all = new ArrayList<>(tourDocs);
            all.addAll(kbDocs);
            totalChunks = all.size();
            doneChunks = 0;
            log.info("Bắt đầu lập chỉ mục AI: {} đoạn (có điều tiết tốc độ theo hạn mức Gemini, có thể mất vài phút).", totalChunks);

            replace(all, ALL_CHUNKS);

            ready = true;
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

    /**
     * Thay các đoạn khớp {@code stale} bằng {@code docs}. Phần chậm (gọi API embedding, có điều tiết) làm TRƯỚC và ngoài giao dịch,
     * nên lỗi giữa chừng không làm mất bộ nhớ đệm. Sau đó xóa cũ + thêm mới trong một giao dịch ngắn (embed lúc này lấy từ bộ
     * nhớ đệm): lỗi thì giữ nguyên chỉ mục cũ, chat đang chạy không thấy trạng thái dở dang.
     */
    private void replace(List<Document> docs, Filter.Expression... stale) {
        VectorStore store = requireStore();
        embedInBatches(docs);
        tx.executeWithoutResult(status -> {
            for (Filter.Expression old : stale) {
                store.delete(old);
            }
            if (!docs.isEmpty()) {
                store.add(docs);
            }
        });
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
        if (!ready) {
            return; // chưa có chỉ mục: lần lập chỉ mục đầu sẽ bao gồm tour này
        }
        FilterExpressionBuilder f = new FilterExpressionBuilder();
        List<Document> docs = new ArrayList<>();
        tourRepository.findWithCategoryById(tourId)
                .filter(t -> t.getStatus() == TourStatus.ACTIVE)
                .ifPresent(t -> docs.addAll(documents.tourDocuments(t)));
        // Tài liệu tổng quan (theo điểm đến...) phụ thuộc cả danh sách tour nên dựng lại toàn bộ (rẻ: vài chục đoạn)
        docs.addAll(documents.overviewDocuments(tourRepository.findAllActiveWithCategory()));
        replace(docs, f.eq(META_TOUR_ID, String.valueOf(tourId)).build(), f.eq(META_TYPE, TYPE_OVERVIEW).build());
        log.info("Đã cập nhật chỉ mục AI cho tour {}.", tourId);
    }

    /** Xem trước các tài liệu tổng quan sẽ được lập chỉ mục (không cần API key): để admin kiểm tra AI "đọc" gì về tour. */
    public List<Map<String, String>> previewOverview() {
        List<Map<String, String>> out = new ArrayList<>();
        for (Document d : documents.overviewDocuments(tourRepository.findAllActiveWithCategory())) {
            Map<String, String> m = new LinkedHashMap<>();
            m.put("id", String.valueOf(d.getMetadata().get(META_TITLE)));
            m.put("text", d.getText());
            out.add(m);
        }
        return out;
    }

    // ------------------------------------------------------------------ Tìm kiếm (Retrieval)

    /** Tìm các đoạn gần nghĩa nhất với câu hỏi; tourId != null thì chỉ lấy trong các đoạn của tour đó. */
    public List<Document> search(String query, int topK, double threshold, Long tourId) {
        VectorStore store = storeProvider.getIfAvailable();
        if (store == null || !ready) {
            return List.of();
        }
        SearchRequest.Builder b = SearchRequest.builder().query(query).topK(topK).similarityThreshold(threshold);
        if (tourId != null) {
            b.filterExpression(new FilterExpressionBuilder().eq(META_TOUR_ID, String.valueOf(tourId)).build());
        }
        return store.similaritySearch(b.build());
    }

    // ------------------------------------------------------------------ Embed theo hạn mức API

    /** Giới hạn gói miễn phí của embedding Gemini (xấp xỉ): ~100 văn bản và ~30.000 token mỗi phút. Dùng mức thấp hơn cho an toàn. */
    private static final int MAX_TEXTS_PER_MINUTE = 70;
    private static final int MAX_TOKENS_PER_MINUTE = 20_000;
    private static final int MAX_BATCH_TEXTS = 20;
    private static final int RATE_LIMIT_RETRIES = 4;

    /**
     * Embed trước các đoạn theo từng lô nhỏ (kết quả vào bộ nhớ đệm, sau đó {@code VectorStore.add} lấy lại từ đó) và tự điều tiết
     * tốc độ để không vượt hạn mức API: sau mỗi lô chờ đủ lâu để số văn bản và số token trung bình mỗi phút nằm dưới ngưỡng.
     * Gặp lỗi 429 thì chờ hơn một phút rồi thử lại lô đó. Cập nhật tiến độ cho admin khi đang lập lại toàn bộ chỉ mục.
     */
    private void embedInBatches(List<Document> docs) {
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
            embedWithRetry(batch);
            // Số đoạn THỰC SỰ gọi API (phần còn lại lấy từ bộ nhớ đệm, không tốn token). Không có bộ nhớ đệm thì coi như gọi hết.
            long apiUsed = embeddingProvider.getIfAvailable() instanceof CachingEmbeddingModel ? apiCalls() - missesBefore : batch.size();
            if (indexing) {
                doneChunks += batch.size();
                log.info("Đã embed {}/{} đoạn (gọi API {}, lấy từ bộ nhớ đệm {})...", doneChunks, totalChunks, apiUsed, batch.size() - apiUsed);
            }
            i = end;
            if (throttle && i < docs.size() && apiUsed > 0) { // chỉ điều tiết khi có gọi API
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

    private void embedWithRetry(List<Document> batch) {
        EmbeddingModel model = requireModel();
        for (int attempt = 0; ; attempt++) {
            try {
                model.embed(batch, EmbeddingOptions.builder().build(), ONE_BATCH);
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

    private EmbeddingModel requireModel() {
        EmbeddingModel m = embeddingProvider.getIfAvailable();
        if (m == null) {
            throw new IllegalStateException("Trợ lý AI chưa được bật (thiếu GEMINI_API_KEY)..");
        }
        return m;
    }

    private VectorStore requireStore() {
        VectorStore s = storeProvider.getIfAvailable();
        if (s == null) {
            throw new IllegalStateException("Trợ lý AI chưa được bật (thiếu GEMINI_API_KEY)..");
        }
        return s;
    }
}
