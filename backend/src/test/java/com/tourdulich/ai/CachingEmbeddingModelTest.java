package com.tourdulich.ai;

import org.junit.jupiter.api.Test;
import org.springframework.ai.document.Document;
import org.springframework.ai.embedding.EmbeddingRequest;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

class CachingEmbeddingModelTest {

    /** Embedding giả có đếm số lần gọi API thật (mỗi lần gọi = tốn token). */
    static class CountingModel extends KnowledgeBaseTest.FakeEmbeddingModel {
        final AtomicInteger calls = new AtomicInteger();

        @Override
        public float[] embed(Document document) {
            calls.incrementAndGet();
            return super.embed(document);
        }

        @Override
        public org.springframework.ai.embedding.EmbeddingResponse call(EmbeddingRequest request) {
            calls.incrementAndGet();
            return super.call(request);
        }
    }

    private static Document doc(String id, String text) {
        return new Document(id, text, Map.of());
    }

    @Test
    void sameTextIsEmbeddedOnlyOnce() {
        CountingModel api = new CountingModel();
        try (CachingEmbeddingModel cache = new CachingEmbeddingModel(api, "m/256", null)) {
            float[] v1 = cache.embed(new Document("1", "Tour Singapore 5 ngày", Map.of("tourId", "1")));
            float[] v2 = cache.embed(new Document("2", "Tour Singapore 5 ngày", Map.of("tourId", "9")));
            cache.embed(doc("3", "Tour Phú Quốc 3 ngày"));
            assertEquals(2, api.calls.get(), "hai nội dung khác nhau -> 2 lần gọi API");
            assertTrue(java.util.Arrays.equals(v1, v2));
            assertEquals(1, cache.hits());
            assertEquals(2, cache.misses());
        }
    }

    @Test
    void rebuildingTheSameDocumentsCostsNothingAfterRestart() {
        InMemoryAiStores db = new InMemoryAiStores(); // đại diện cho bảng ai_embedding_cache
        CountingModel api = new CountingModel();
        try (CachingEmbeddingModel first = new CachingEmbeddingModel(api, "m/256", db)) {
            first.embed(doc("a", "Nội dung A"));
            first.embed(doc("b", "Nội dung B"));
        } // đóng = ghi xuống DB
        assertEquals(2, api.calls.get());
        assertEquals(2, db.cache.get("m/256").size(), "đệm được lưu xuống DB khi đóng");

        CountingModel api2 = new CountingModel();
        try (CachingEmbeddingModel second = new CachingEmbeddingModel(api2, "m/256", db)) {
            second.embed(doc("a", "Nội dung A"));
            second.embed(doc("b", "Nội dung B"));
            assertEquals(0, api2.calls.get(), "khởi động lại và dựng lại cùng nội dung: không gọi API");
            second.embed(doc("c", "Nội dung mới"));
            assertEquals(1, api2.calls.get(), "chỉ nội dung MỚI mới tốn một lần gọi");
        }
    }

    @Test
    void savesInBatchesWithoutWaitingForClose() {
        InMemoryAiStores db = new InMemoryAiStores();
        CachingEmbeddingModel cache = new CachingEmbeddingModel(new CountingModel(), "m/256", db);
        for (int i = 0; i < 30; i++) {
            cache.embed(doc("d" + i, "Nội dung số " + i));
        }
        assertTrue(db.cache.getOrDefault("m/256", Map.of()).size() >= 25, "đủ 25 đoạn mới thì tự ghi xuống DB");
    }

    @Test
    void differentModelNamespaceIgnoresOldCache() {
        InMemoryAiStores db = new InMemoryAiStores();
        try (CachingEmbeddingModel a = new CachingEmbeddingModel(new CountingModel(), "model-cu/256", db)) {
            a.embed(doc("a", "Nội dung A"));
        }
        CountingModel api2 = new CountingModel();
        try (CachingEmbeddingModel b = new CachingEmbeddingModel(api2, "model-moi/256", db)) {
            b.embed(doc("a", "Nội dung A"));
        }
        assertEquals(1, api2.calls.get(), "đổi mô hình thì không được dùng lại vector cũ");
    }

    @Test
    void seedFromStoredVectorsMakesFirstReindexFree() {
        // Vector đã lưu trong ai_vectors được nạp sẵn vào đệm
        CountingModel original = new CountingModel();
        float[] v = original.embed(doc("x", "[Tour: Singapore] thông tin tổng quan"));
        float[] wrongDims = new float[]{1f, 2f};
        Map<String, float[]> stored = new LinkedHashMap<>();
        stored.put("[Tour: Singapore] thông tin tổng quan", v);
        stored.put("vector sai số chiều", wrongDims);

        CountingModel api = new CountingModel();
        try (CachingEmbeddingModel cache = new CachingEmbeddingModel(api, "m/256", new InMemoryAiStores())) {
            cache.seed(stored);
            assertEquals(1, cache.cachedDocuments(), "vector sai số chiều bị bỏ qua");
            cache.embed(doc("x", "[Tour: Singapore] thông tin tổng quan"));
            assertEquals(0, api.calls.get(), "lập lại chỉ mục lần đầu dùng lại vector sẵn có, không tốn token");
        }
    }

    @Test
    void worksWhenDatabaseIsUnavailable() {
        EmbeddingCacheStore broken = new EmbeddingCacheStore() {
            @Override
            public Map<String, float[]> loadAll(String namespace) {
                throw new IllegalStateException("DB chưa sẵn sàng");
            }

            @Override
            public void saveNew(String namespace, Map<String, float[]> entries) {
                throw new IllegalStateException("DB chưa sẵn sàng");
            }
        };
        CountingModel api = new CountingModel();
        try (CachingEmbeddingModel cache = new CachingEmbeddingModel(api, "m/256", broken)) {
            cache.embed(doc("a", "Nội dung A"));
            cache.embed(doc("a2", "Nội dung A"));
            assertEquals(1, api.calls.get(), "DB lỗi vẫn đệm trong bộ nhớ, không làm hỏng việc embed");
        }
    }

    @Test
    void repeatedQuestionsAreServedFromMemory() {
        CountingModel api = new CountingModel();
        try (CachingEmbeddingModel cache = new CachingEmbeddingModel(api, "m/256", null)) {
            cache.call(new EmbeddingRequest(List.of("tour đi Nhật giá bao nhiêu"), null));
            cache.call(new EmbeddingRequest(List.of("tour đi Nhật giá bao nhiêu"), null));
            assertEquals(1, api.calls.get());
        }
    }
}
