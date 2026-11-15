package com.tourdulich.ai;

import com.tourdulich.config.AppProperties;
import com.tourdulich.entity.Tour;
import com.tourdulich.repository.TourRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;
import org.springframework.ai.document.Document;
import org.springframework.ai.embedding.Embedding;
import org.springframework.ai.embedding.EmbeddingModel;
import org.springframework.ai.embedding.EmbeddingRequest;
import org.springframework.ai.embedding.EmbeddingResponse;
import org.springframework.ai.vectorstore.SimpleVectorStore;
import org.springframework.ai.vectorstore.VectorStore;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.transaction.support.TransactionOperations;

import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

/**
 * Kiểm tra luồng RAG (lập chỉ mục -> tìm kiếm -> lọc theo tour -> cập nhật/xóa) bằng mô hình embedding GIẢ
 * (băm từ thành vector) và {@link SimpleVectorStore} đóng vai {@link VectorStore} (production dùng MariaDBVectorStore),
 * nên không cần API key Gemini lẫn database. Chất lượng ngữ nghĩa thật phụ thuộc Gemini, nhưng toàn bộ phần mã của
 * project (cắt đoạn, metadata, filter, thay thế/xóa/cập nhật chỉ mục) được kiểm tra ở đây.
 */
class KnowledgeBaseTest {

    /** Embedding "túi từ": mỗi từ băm vào một trong 256 chiều, rồi chuẩn hóa. Giống nhau về từ thì gần nhau. */
    public static class FakeEmbeddingModel implements EmbeddingModel {
        @Override
        public EmbeddingResponse call(EmbeddingRequest request) {
            List<Embedding> out = new ArrayList<>();
            int i = 0;
            for (String text : request.getInstructions()) {
                out.add(new Embedding(vec(text), i++));
            }
            return new EmbeddingResponse(out);
        }

        @Override
        public float[] embed(Document document) {
            return vec(document.getText());
        }

        @Override
        public int dimensions() {
            return 256;
        }

        static float[] vec(String text) {
            float[] v = new float[256];
            for (String w : text.toLowerCase().split("[^\\p{L}\\p{N}]+")) {
                if (w.length() > 1) {
                    v[Math.floorMod(w.hashCode(), 256)] += 1f;
                }
            }
            double norm = 0;
            for (float x : v) {
                norm += x * x;
            }
            norm = Math.sqrt(Math.max(norm, 1e-9));
            for (int k = 0; k < v.length; k++) {
                v[k] /= (float) norm;
            }
            return v;
        }
    }

    @TempDir
    Path tmp;

    private TourRepository tours;
    private KnowledgeBase kb;
    private Tour singapore;
    private Tour phuQuoc;

    @SuppressWarnings("unchecked")
    @BeforeEach
    void setUp() {
        tours = mock(TourRepository.class);
        singapore = TourFixtures.singapore();
        phuQuoc = TourFixtures.phuQuoc();
        when(tours.findAllActiveWithCategory()).thenReturn(List.of(singapore, phuQuoc));
        when(tours.findWithCategoryById(anyLong())).thenAnswer(inv -> {
            Long id = inv.getArgument(0);
            return id == 1L ? Optional.of(singapore) : id == 2L ? Optional.of(phuQuoc) : Optional.empty();
        });

        EmbeddingModel model = new FakeEmbeddingModel();
        ObjectProvider<EmbeddingModel> embeddings = mock(ObjectProvider.class);
        when(embeddings.getIfAvailable()).thenReturn(model);
        ObjectProvider<VectorStore> stores = mock(ObjectProvider.class);
        when(stores.getIfAvailable()).thenReturn(SimpleVectorStore.builder(model).build());
        KnowledgeDocuments documents = new KnowledgeDocuments(new AppProperties(null, null, null, null, null, null,
                new AppProperties.Ai(tmp.resolve("no-such-dir").toString(), 6, 0.0, 8, 1000)));
        kb = new KnowledgeBase(embeddings, stores, tours, documents, TransactionOperations.withoutTransaction());
        kb.throttle = false;
    }

    /** Đoạn của một tour (tourId) hoặc tài liệu tổng quan có nhắc tour đó (tourIds). */
    private static boolean refersToTour(Document d, String id) {
        if (id.equals(d.getMetadata().get(KnowledgeDocuments.META_TOUR_ID))) {
            return true;
        }
        Object many = d.getMetadata().get(KnowledgeDocuments.META_TOUR_IDS);
        return many != null && List.of(String.valueOf(many).split(",")).contains(id);
    }

    @Test
    void reindexAllReplacesThePreviousChunks() {
        kb.reindexAll();
        when(tours.findAllActiveWithCategory()).thenReturn(List.of(phuQuoc)); // tour 1 ngừng bán
        kb.reindexAll();
        List<Document> hits = kb.search("Singapore Merlion Phú Quốc", 100, 0.0, null);
        assertTrue(hits.stream().noneMatch(d -> "1".equals(d.getMetadata().get(KnowledgeDocuments.META_TOUR_ID))),
                "đoạn của tour đã ngừng bán phải bị xóa khỏi chỉ mục");
        assertTrue(hits.stream().anyMatch(d -> "2".equals(d.getMetadata().get(KnowledgeDocuments.META_TOUR_ID))));
    }

    @Test
    void reindexSearchFilterAndUpdate() {
        assertFalse(kb.isReady());
        KnowledgeBase.Stats stats = kb.reindexAll();
        assertTrue(kb.isReady());
        assertTrue(stats.tourChunks() >= 2);
        assertTrue(stats.docChunks() > 0, "phải đọc được các tài liệu mẫu trong classpath:ai/knowledge");
        assertEquals(stats.chunks(), kb.search("tour", 10_000, 0.0, null).size(), "mọi đoạn đều nằm trong chỉ mục");

        // Tìm theo ngữ nghĩa (ở đây là theo từ): hỏi về Singapore -> đoạn của tour Singapore
        List<Document> hits = kb.search("Tour đi Singapore ngắm Merlion", 3, 0.0, null);
        assertFalse(hits.isEmpty());
        assertTrue(hits.stream().limit(3).anyMatch(d -> refersToTour(d, "1")), "top 3 phải liên quan tour Singapore");
        assertFalse(refersToTour(hits.get(0), "2"), "kết quả đầu không được là tour Phú Quốc");
        List<Document> beach = kb.search("tắm biển ăn hải sản Phú Quốc", 3, 0.0, null);
        assertTrue(beach.stream().limit(3).anyMatch(d -> refersToTour(d, "2")), "top 3 phải liên quan tour Phú Quốc");

        // Lọc theo một tour cụ thể
        List<Document> only2 = kb.search("Singapore", 5, 0.0, 2L);
        assertFalse(only2.isEmpty());
        assertTrue(only2.stream().allMatch(d -> "2".equals(d.getMetadata().get(KnowledgeDocuments.META_TOUR_ID))));

        // Tour bị xóa -> chỉ mục không còn đoạn của tour đó
        when(tours.findWithCategoryById(1L)).thenReturn(Optional.empty());
        when(tours.findAllActiveWithCategory()).thenReturn(List.of(phuQuoc)); // tour 1 không còn đang mở bán
        kb.reindexTour(1L);
        List<Document> afterDelete = kb.search("Singapore Merlion", 10, 0.0, null);
        assertTrue(afterDelete.stream().noneMatch(d -> "1".equals(d.getMetadata().get(KnowledgeDocuments.META_TOUR_ID))));
        // Tài liệu tổng quan cũng được dựng lại: không còn nhắc tour đã gỡ
        assertTrue(afterDelete.stream().noneMatch(d -> d.getText().contains("(/tours/1)")));
        assertTrue(kb.search("Tổng quan tour đến Phú Quốc", 5, 0.0, null).stream()
                .anyMatch(d -> d.getText().contains("(/tours/2)")));
        assertNotNull(kb.stats().lastIndexedAt());
    }
}
