package com.tourdulich.ai;

import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.document.Document;
import org.springframework.ai.embedding.BatchingStrategy;
import org.springframework.ai.embedding.Embedding;
import org.springframework.ai.embedding.EmbeddingModel;
import org.springframework.ai.embedding.EmbeddingOptions;
import org.springframework.ai.embedding.EmbeddingRequest;
import org.springframework.ai.embedding.EmbeddingResponse;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicLong;

/**
 * Bộ nhớ đệm embedding lưu trong DB (bảng {@code ai_embedding_cache}): cùng một nội dung (và cùng mô hình/số chiều) chỉ gọi API
 * <b>một lần</b>.
 *
 * <p>Tiết kiệm token khi lập lại chỉ mục, khi dựng lại các tài liệu không đổi (ví dụ tài liệu tổng quan mỗi lần sửa tour),
 * hoặc khi xóa chỉ mục rồi dựng lại. Câu hỏi của khách cũng được nhớ ngắn hạn (200 câu gần nhất, chỉ trong bộ nhớ).
 * Việc nạp từ DB làm lười (lần dùng đầu tiên) và chịu được DB chưa sẵn sàng: khi đó chỉ đệm trong bộ nhớ.
 */
@Slf4j
public class CachingEmbeddingModel implements EmbeddingModel, AutoCloseable {

    private static final int SAVE_EVERY = 25;
    private static final int MAX_QUERIES = 200;
    /** Không chia nhỏ thêm: người gọi đã tự chia lô. */
    private static final BatchingStrategy ONE_BATCH = documents -> List.of(documents);

    private final EmbeddingModel delegate;
    private final String namespace;
    private final EmbeddingCacheStore store; // có thể null: chỉ đệm trong bộ nhớ
    private final Map<String, float[]> docs = new ConcurrentHashMap<>();
    private final Map<String, float[]> pending = new ConcurrentHashMap<>(); // mới thêm, chưa ghi xuống DB
    private final Map<String, float[]> queries = Collections.synchronizedMap(new LinkedHashMap<>(16, 0.75f, true) {
        @Override
        protected boolean removeEldestEntry(Map.Entry<String, float[]> eldest) {
            return size() > MAX_QUERIES;
        }
    });
    private final AtomicLong hits = new AtomicLong();
    private final AtomicLong misses = new AtomicLong();
    private volatile boolean loaded;

    /**
     * @param namespace định danh mô hình + số chiều (ví dụ "gemini-embedding-001/768"); đổi mô hình thì đệm cũ không bị dùng lại
     * @param store     nơi lưu bền (DB); null thì chỉ đệm trong bộ nhớ
     */
    public CachingEmbeddingModel(EmbeddingModel delegate, String namespace, EmbeddingCacheStore store) {
        this.delegate = delegate;
        this.namespace = namespace;
        this.store = store;
    }

    public String namespace() {
        return namespace;
    }

    public long hits() {
        return hits.get();
    }

    /** Số lần phải gọi API thật (không có trong đệm). */
    public long misses() {
        return misses.get();
    }

    public int cachedDocuments() {
        ensureLoaded();
        return docs.size();
    }

    // ------------------------------------------------------------------ EmbeddingModel

    /**
     * Đường "tài liệu" (lập chỉ mục), cũng là hàm mà {@code VectorStore.add(...)} gọi: đệm bền xuống DB, chỉ những nội dung
     * CHƯA có mới gọi API (gộp thành một lượt), phần còn lại lấy từ đệm.
     */
    @Override
    public List<float[]> embed(List<Document> documents, EmbeddingOptions options, BatchingStrategy strategy) {
        ensureLoaded();
        List<float[]> result = new ArrayList<>(Collections.nCopies(documents.size(), null));
        List<Document> missing = new ArrayList<>();
        List<Integer> missingAt = new ArrayList<>();
        for (int i = 0; i < documents.size(); i++) {
            float[] cached = docs.get(key(documents.get(i).getText())); // nội dung đã mang tên tour/tài liệu ở đầu nên đủ để phân biệt
            if (cached != null) {
                hits.incrementAndGet();
                result.set(i, cached);
            } else {
                missing.add(documents.get(i));
                missingAt.add(i);
            }
        }
        if (!missing.isEmpty()) {
            List<float[]> fresh = delegate.embed(missing, options, strategy);
            for (int j = 0; j < missing.size(); j++) {
                String key = key(missing.get(j).getText());
                docs.put(key, fresh.get(j));
                pending.put(key, fresh.get(j));
                result.set(missingAt.get(j), fresh.get(j));
            }
            misses.addAndGet(missing.size());
            if (pending.size() >= SAVE_EVERY) {
                save();
            }
        }
        return result;
    }

    /** Interface bắt buộc có hàm này; đi cùng đường "tài liệu" ở trên. */
    @Override
    public float[] embed(Document document) {
        return embed(List.of(document), EmbeddingOptions.builder().build(), ONE_BATCH).get(0);
    }

    @Override
    public EmbeddingResponse call(EmbeddingRequest request) {
        ensureLoaded();
        List<String> in = request.getInstructions();
        if (in.size() != 1) {
            return delegate.call(request);
        }
        String key = key(in.get(0));
        float[] cached = queries.get(key);
        if (cached == null) {
            cached = docs.get(key);
        }
        if (cached != null) {
            hits.incrementAndGet();
            return new EmbeddingResponse(List.of(new Embedding(cached, 0)));
        }
        EmbeddingResponse response = delegate.call(request);
        misses.incrementAndGet();
        queries.put(key, response.getResults().get(0).getOutput());
        return response;
    }

    @Override
    public int dimensions() {
        return delegate.dimensions();
    }

    // ------------------------------------------------------------------ Lưu / nạp

    private String key(String text) {
        try {
            byte[] d = MessageDigest.getInstance("SHA-256").digest((namespace + "|" + text).getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder();
            for (byte b : d) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (Exception e) {
            throw new IllegalStateException(e);
        }
    }

    private void ensureLoaded() {
        if (loaded) {
            return;
        }
        synchronized (this) {
            if (loaded) {
                return;
            }
            if (store != null) {
                try {
                    Map<String, float[]> all = store.loadAll(namespace);
                    docs.putAll(all);
                    log.info("Đã nạp bộ nhớ đệm embedding từ DB: {} đoạn.", all.size());
                } catch (Exception e) {
                    log.warn("Không nạp được bộ nhớ đệm embedding từ DB (sẽ chỉ đệm trong bộ nhớ): {}", e.getMessage());
                }
            }
            loaded = true;
        }
    }

    /** Ghi các vector mới xuống DB. Lỗi DB chỉ ghi log (không làm hỏng việc embed). */
    public synchronized void save() {
        if (store == null || pending.isEmpty()) {
            return;
        }
        Map<String, float[]> batch = new HashMap<>(pending);
        try {
            store.saveNew(namespace, batch);
            batch.keySet().forEach(pending::remove);
        } catch (Exception e) {
            log.warn("Không lưu được bộ nhớ đệm embedding xuống DB: {}", e.getMessage());
        }
    }

    @Override
    public void close() {
        save();
    }
}
