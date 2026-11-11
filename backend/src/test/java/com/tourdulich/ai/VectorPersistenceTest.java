package com.tourdulich.ai;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.ai.document.Document;
import org.springframework.ai.vectorstore.SearchRequest;
import org.springframework.ai.vectorstore.SimpleVectorStore;

import java.io.File;
import java.nio.file.Path;
import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;

import static org.junit.jupiter.api.Assertions.assertArrayEquals;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

/** Kiểm tra đường đi lưu/nạp chỉ mục qua DB: vector -> byte[] -> dòng DB -> JSON -> SimpleVectorStore, và tìm kiếm không cần gọi API. */
class VectorPersistenceTest {

    private final ObjectMapper mapper = new ObjectMapper();

    @TempDir
    Path tmp;

    @Test
    void floatVectorsSurviveByteRoundTrip() {
        float[] v = {0.5f, -1.25f, 3.1415927f, 0f, Float.MIN_VALUE, 123456.78f};
        assertArrayEquals(v, AiVectorRepository.fromBytes(AiVectorRepository.toBytes(v)));
        assertEquals(768 * 4, AiVectorRepository.toBytes(new float[768]).length, "768 chiều = 3072 byte");
    }

    @Test
    void storeSavedAsRowsCanBeLoadedBackAndSearchedWithoutEmbeddingCalls() throws Exception {
        // 1) Lập chỉ mục bằng embedding giả rồi "lưu vào DB" (qua file JSON tạm giống KnowledgeBase.persist)
        AtomicInteger calls = new AtomicInteger();
        KnowledgeBaseTest.FakeEmbeddingModel model = new KnowledgeBaseTest.FakeEmbeddingModel() {
            @Override
            public float[] embed(Document d) {
                calls.incrementAndGet();
                return super.embed(d);
            }
        };
        SimpleVectorStore original = SimpleVectorStore.builder(model).build();
        original.add(List.of(
                new Document("tour:1:head", "[Tour: Singapore] tham quan Merlion và Gardens by the Bay", Map.of("type", "tour", "tourId", "1")),
                new Document("tour:2:head", "[Tour: Phú Quốc] tắm biển Bãi Sao ăn hải sản", Map.of("type", "tour", "tourId", "2")),
                new Document("kb:faq:0", "[Tài liệu: FAQ] cách thanh toán chuyển khoản", Map.of("type", "doc"))));
        File tmpJson = tmp.resolve("snapshot.json").toFile();
        original.save(tmpJson);
        List<VectorPersistence.Row> rows = VectorStoreJson.fromJson(mapper.readTree(tmpJson), mapper);
        assertEquals(3, rows.size());
        InMemoryAiStores db = new InMemoryAiStores();
        db.replaceAll(rows, "m/256");

        // 2) "Khởi động lại": nạp từ các dòng DB, KHÔNG gọi embedding cho tài liệu
        int before = calls.get();
        SimpleVectorStore reloaded = SimpleVectorStore.builder(model).build();
        reloaded.load(new ByteArrayResource(VectorStoreJson.toJson(db.loadAll(), mapper)));
        assertEquals(before, calls.get(), "nạp từ DB không tốn lần embed nào");

        // 3) Tìm kiếm vẫn đúng, kể cả lọc theo metadata
        List<Document> hits = reloaded.similaritySearch(SearchRequest.builder().query("ngắm Merlion Singapore").topK(2).similarityThreshold(0.0).build());
        assertEquals("tour:1:head", hits.get(0).getId());
        assertEquals("1", hits.get(0).getMetadata().get("tourId"), "metadata được giữ nguyên qua DB");
        List<Document> only2 = reloaded.similaritySearch(SearchRequest.builder().query("Singapore").topK(5).similarityThreshold(0.0)
                .filterExpression("tourId == '2'").build());
        assertTrue(only2.stream().allMatch(d -> "2".equals(d.getMetadata().get("tourId"))));
    }

    @Test
    void legacyJsonFileFormatIsReadable() throws Exception {
        String legacy = "{\"tour:5:head\":{\"id\":\"tour:5:head\",\"text\":\"nội dung\",\"metadata\":{\"type\":\"tour\",\"tourId\":\"5\"},\"embedding\":[0.1,0.2,0.3]},"
                + "\"bad\":{\"id\":\"bad\",\"text\":\"thiếu vector\",\"metadata\":{}}}";
        List<VectorPersistence.Row> rows = VectorStoreJson.fromJson(mapper.readTree(legacy), mapper);
        assertEquals(1, rows.size(), "dòng thiếu vector bị bỏ qua");
        assertEquals("tour:5:head", rows.get(0).id());
        assertEquals(3, rows.get(0).embedding().length);
        assertTrue(rows.get(0).metadataJson().contains("\"tourId\":\"5\""));
    }
}
