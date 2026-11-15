package com.tourdulich.ai;

import org.junit.jupiter.api.Test;
import org.springframework.ai.document.Document;
import org.springframework.ai.embedding.EmbeddingOptions;
import org.springframework.ai.embedding.EmbeddingRequest;

import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;

import static org.junit.jupiter.api.Assertions.assertArrayEquals;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

class CachingEmbeddingModelTest {

    /** Embedding giả có đếm số lần gọi API thật (mỗi lần gọi = tốn token). */
    static class CountingModel extends KnowledgeBaseTest.FakeEmbeddingModel {
        final AtomicInteger calls = new AtomicInteger();

        @Override
        public org.springframework.ai.embedding.EmbeddingResponse call(EmbeddingRequest request) {
            calls.incrementAndGet();
            return super.call(request);
        }
    }

    private static Document doc(String id, String text) {
        return new Document(id, text, Map.of());
    }

    /** Embed một đoạn qua đường "tài liệu" (đường mà VectorStore.add(...) gọi). */
    private static float[] embedDoc(CachingEmbeddingModel model, Document document) {
        return model.embed(List.of(document), EmbeddingOptions.builder().build(), documents -> List.of(documents)).get(0);
    }

    @Test
    void sameTextIsEmbeddedOnlyOnce() {
        CountingModel api = new CountingModel();
        try (CachingEmbeddingModel cache = new CachingEmbeddingModel(api, "m/256", null)) {
            float[] v1 = embedDoc(cache, new Document("1", "Tour Singapore 5 ngày", Map.of("tourId", "1")));
            float[] v2 = embedDoc(cache, new Document("2", "Tour Singapore 5 ngày", Map.of("tourId", "9")));
            embedDoc(cache, doc("3", "Tour Phú Quốc 3 ngày"));
            assertEquals(2, api.calls.get(), "hai nội dung khác nhau -> 2 lần gọi API");
            assertTrue(java.util.Arrays.equals(v1, v2));
            assertEquals(1, cache.hits());
            assertEquals(2, cache.misses());
        }
    }

    @Test
    void rebuildingTheSameDocumentsCostsNothingAfterRestart() {
        InMemoryEmbeddingCacheStore db = new InMemoryEmbeddingCacheStore(); // đại diện cho bảng ai_embedding_cache
        CountingModel api = new CountingModel();
        try (CachingEmbeddingModel first = new CachingEmbeddingModel(api, "m/256", db)) {
            embedDoc(first, doc("a", "Nội dung A"));
            embedDoc(first, doc("b", "Nội dung B"));
        } // đóng = ghi xuống DB
        assertEquals(2, api.calls.get());
        assertEquals(2, db.cache.get("m/256").size(), "đệm được lưu xuống DB khi đóng");

        CountingModel api2 = new CountingModel();
        try (CachingEmbeddingModel second = new CachingEmbeddingModel(api2, "m/256", db)) {
            embedDoc(second, doc("a", "Nội dung A"));
            embedDoc(second, doc("b", "Nội dung B"));
            assertEquals(0, api2.calls.get(), "khởi động lại và dựng lại cùng nội dung: không gọi API");
            embedDoc(second, doc("c", "Nội dung mới"));
            assertEquals(1, api2.calls.get(), "chỉ nội dung MỚI mới tốn một lần gọi");
        }
    }

    @Test
    void savesInBatchesWithoutWaitingForClose() {
        InMemoryEmbeddingCacheStore db = new InMemoryEmbeddingCacheStore();
        CachingEmbeddingModel cache = new CachingEmbeddingModel(new CountingModel(), "m/256", db);
        for (int i = 0; i < 30; i++) {
            embedDoc(cache, doc("d" + i, "Nội dung số " + i));
        }
        assertTrue(db.cache.getOrDefault("m/256", Map.of()).size() >= 25, "đủ 25 đoạn mới thì tự ghi xuống DB");
    }

    @Test
    void differentModelNamespaceIgnoresOldCache() {
        InMemoryEmbeddingCacheStore db = new InMemoryEmbeddingCacheStore();
        try (CachingEmbeddingModel a = new CachingEmbeddingModel(new CountingModel(), "model-cu/256", db)) {
            embedDoc(a, doc("a", "Nội dung A"));
        }
        CountingModel api2 = new CountingModel();
        try (CachingEmbeddingModel b = new CachingEmbeddingModel(api2, "model-moi/256", db)) {
            embedDoc(b, doc("a", "Nội dung A"));
        }
        assertEquals(1, api2.calls.get(), "đổi mô hình thì không được dùng lại vector cũ");
    }

    /** Đây là đường mà VectorStore.add(...) gọi: nhiều đoạn cùng lúc, chỉ đoạn chưa có mới tốn API (gộp một lượt). */
    @Test
    void documentBatchCallsApiOnlyOnceForTheMissingOnes() {
        CountingModel api = new CountingModel();
        try (CachingEmbeddingModel cache = new CachingEmbeddingModel(api, "m/256", null)) {
            embedDoc(cache, doc("a", "Nội dung A"));
            assertEquals(1, api.calls.get());

            List<float[]> out = cache.embed(List.of(doc("a", "Nội dung A"), doc("b", "Nội dung B"), doc("c", "Nội dung C")),
                    EmbeddingOptions.builder().build(), documents -> List.of(documents));

            assertEquals(2, api.calls.get(), "hai đoạn mới gộp thành MỘT lượt gọi API");
            assertEquals(1, cache.hits());
            assertEquals(3, cache.misses(), "A (lần đầu) + B + C");
            assertArrayEquals(KnowledgeBaseTest.FakeEmbeddingModel.vec("Nội dung A"), out.get(0));
            assertArrayEquals(KnowledgeBaseTest.FakeEmbeddingModel.vec("Nội dung B"), out.get(1), "đúng thứ tự đầu vào");
            assertArrayEquals(KnowledgeBaseTest.FakeEmbeddingModel.vec("Nội dung C"), out.get(2));
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
            embedDoc(cache, doc("a", "Nội dung A"));
            embedDoc(cache, doc("a2", "Nội dung A"));
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
