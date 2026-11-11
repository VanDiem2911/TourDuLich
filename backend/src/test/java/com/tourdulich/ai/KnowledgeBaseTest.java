package com.tourdulich.ai;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.tourdulich.config.AppProperties;
import com.tourdulich.entity.Category;
import com.tourdulich.entity.Tour;
import com.tourdulich.entity.enums.TourRegion;
import com.tourdulich.repository.TourRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;
import org.springframework.ai.document.Document;
import org.springframework.ai.embedding.Embedding;
import org.springframework.ai.embedding.EmbeddingModel;
import org.springframework.ai.embedding.EmbeddingRequest;
import org.springframework.ai.embedding.EmbeddingResponse;
import org.springframework.beans.factory.ObjectProvider;

import java.math.BigDecimal;
import java.nio.file.Path;
import java.time.LocalDateTime;
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
 * (băm từ thành vector), nên không cần API key Gemini. Chất lượng ngữ nghĩa thật phụ thuộc Gemini, nhưng toàn bộ
 * phần mã của project (cắt đoạn, metadata, lưu file, filter, xóa/cập nhật) được kiểm tra ở đây.
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
    private InMemoryAiStores db;
    private Tour singapore;
    private Tour phuQuoc;

    @SuppressWarnings("unchecked")
    @BeforeEach
    void setUp() {
        tours = mock(TourRepository.class);
        singapore = tour(1L, "Singapore - Malaysia 5N4Đ", "Singapore", TourRegion.INTERNATIONAL,
                "Ngày 1: Hà Nội - Singapore\nĂn tối trên máy bay, đến Singapore ngắm Merlion và Gardens by the Bay.\n\n"
                        + "Ngày 2: Singapore - Malacca\nThăm phố cổ Malacca.",
                "Giá tour bao gồm\nVé máy bay khứ hồi, khách sạn 4 sao.\n\nGiấy tờ mang theo\nHộ chiếu còn hạn 6 tháng.\n\n"
                        + "Điều kiện hoãn hủy\nHủy trước 30 ngày chi trả 10% giá tour.");
        phuQuoc = tour(2L, "Phú Quốc 3N2Đ", "Phú Quốc", TourRegion.DOMESTIC,
                "Ngày 1: TP.HCM - Phú Quốc\nTắm biển Bãi Sao, ăn hải sản.", "Giá tour bao gồm\nKhách sạn 3 sao.");
        when(tours.findAllActiveWithCategory()).thenReturn(List.of(singapore, phuQuoc));
        when(tours.findWithCategoryById(anyLong())).thenAnswer(inv -> {
            Long id = inv.getArgument(0);
            return id == 1L ? Optional.of(singapore) : id == 2L ? Optional.of(phuQuoc) : Optional.empty();
        });

        ObjectProvider<EmbeddingModel> provider = mock(ObjectProvider.class);
        when(provider.getIfAvailable()).thenReturn(new FakeEmbeddingModel());
        AppProperties props = new AppProperties(null, null, null, null, null, null,
                new AppProperties.Ai(tmp.resolve("no-such-dir").toString(), tmp.resolve("store.json").toString(), 6, 0.0, 8, 1000));
        db = new InMemoryAiStores();
        kb = new KnowledgeBase(provider, tours, props, new ObjectMapper(), db);
    }

    private static Tour tour(Long id, String name, String dest, TourRegion region, String itinerary, String notes) {
        Category c = new Category();
        c.setName(region == TourRegion.INTERNATIONAL ? "Tour quốc tế" : "Nghỉ dưỡng biển đảo");
        Tour t = new Tour();
        t.setId(id);
        t.setCategory(c);
        t.setTourCode("FDT-" + id);
        t.setName(name);
        t.setDestination(dest);
        t.setDepartureLocation("TP.HCM");
        t.setDuration("5N4Đ");
        t.setTransport("Máy bay");
        t.setDepartureDate(LocalDateTime.of(2026, 12, 1, 7, 0));
        t.setAdultPrice(new BigDecimal("11691000"));
        t.setChildPrice(new BigDecimal("8000000"));
        t.setTotalSeats(30);
        t.setAvailableSeats(20);
        t.setShortDescription("Tour " + dest);
        t.setItinerary(itinerary);
        t.setNotes(notes);
        t.setRegion(region);
        return t;
    }

    /** Đoạn của một tour (tourId) hoặc tài liệu tổng quan có nhắc tour đó (tourIds). */
    private static boolean refersToTour(Document d, String id) {
        if (id.equals(d.getMetadata().get(KnowledgeBase.META_TOUR_ID))) {
            return true;
        }
        Object many = d.getMetadata().get(KnowledgeBase.META_TOUR_IDS);
        return many != null && List.of(String.valueOf(many).split(",")).contains(id);
    }

    @Test
    void tourDocumentsHaveHeadlineItineraryAndOnlyUsefulNotes() {
        List<Document> docs = kb.tourDocuments(singapore);
        assertTrue(docs.stream().anyMatch(d -> d.getId().equals("tour:1:head")));
        Document head = docs.stream().filter(d -> d.getId().equals("tour:1:head")).findFirst().orElseThrow();
        assertTrue(head.getText().contains("Điểm đến: Singapore"));
        assertTrue(head.getText().contains("11.691.000 đ"));
        assertTrue(head.getText().contains("/tours/1"));
        assertEquals("1", head.getMetadata().get(KnowledgeBase.META_TOUR_ID));
        assertTrue(docs.stream().anyMatch(d -> d.getText().contains("Merlion")));
        String all = String.join("\n", docs.stream().map(Document::getText).toList());
        assertTrue(all.contains("Hủy trước 30 ngày"), "giữ mục hủy tour");
        assertFalse(all.contains("Hộ chiếu còn hạn"), "bỏ mục giấy tờ mang theo");
    }

    @Test
    void markdownIsSplitBySectionWithLabels() {
        List<Document> docs = kb.documentsOf("faq.md", "# Hướng dẫn thanh toán\n## Chuyển khoản\nQuét mã QR và ghi đúng nội dung.\n"
                + "## Hủy đơn\nChỉ hủy được khi đơn còn chờ xác nhận.");
        assertEquals(2, docs.size());
        assertTrue(docs.get(0).getText().startsWith("[Tài liệu: Hướng dẫn thanh toán > Chuyển khoản]"));
        assertTrue(docs.get(1).getText().contains("chờ xác nhận"));
        assertEquals(KnowledgeBase.TYPE_DOC, docs.get(0).getMetadata().get(KnowledgeBase.META_TYPE));
    }

    @Test
    void usefulNotesKeepsOnlyIncludedCancelAndSurcharge() {
        String n = KnowledgeBase.usefulNotes("Giá tour bao gồm\nA\n\nGiấy tờ mang theo\nB\n\nQuy định phụ thu\nC");
        assertTrue(n.contains("A") && n.contains("C"));
        assertFalse(n.contains("B"));
    }

    @Test
    void reindexSearchFilterUpdateAndPersist() {
        assertFalse(kb.isReady());
        KnowledgeBase.Stats stats = kb.reindexAll();
        assertTrue(kb.isReady());
        assertTrue(stats.tourChunks() >= 2);
        assertTrue(stats.docChunks() > 0, "phải đọc được các tài liệu mẫu trong classpath:ai/knowledge");
        assertFalse(db.rows.isEmpty(), "chỉ mục được lưu vào DB (bảng ai_vectors)");
        assertEquals(stats.chunks(), db.rows.size(), "mọi đoạn đều được lưu");

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
        assertTrue(only2.stream().allMatch(d -> "2".equals(d.getMetadata().get(KnowledgeBase.META_TOUR_ID))));

        // Tour bị xóa -> chỉ mục không còn đoạn của tour đó
        when(tours.findWithCategoryById(1L)).thenReturn(Optional.empty());
        when(tours.findAllActiveWithCategory()).thenReturn(List.of(phuQuoc)); // tour 1 không còn đang mở bán
        kb.reindexTour(1L);
        List<Document> afterDelete = kb.search("Singapore Merlion", 10, 0.0, null);
        assertTrue(afterDelete.stream().noneMatch(d -> "1".equals(d.getMetadata().get(KnowledgeBase.META_TOUR_ID))));
        // Tài liệu tổng quan cũng được dựng lại: không còn nhắc tour đã gỡ
        assertTrue(afterDelete.stream().noneMatch(d -> d.getText().contains("(/tours/1)")));
        assertTrue(kb.search("Tổng quan tour đến Phú Quốc", 5, 0.0, null).stream()
                .anyMatch(d -> d.getText().contains("(/tours/2)")));
        assertNotNull(kb.stats().lastIndexedAt());
    }

    @Test
    void overviewDocumentsCoverDestinationCategoryAndRegion() {
        List<Document> docs = kb.overviewDocuments(List.of(singapore, phuQuoc));
        String all = String.join("\n", docs.stream().map(Document::getText).toList());
        assertTrue(all.contains("[Tổng quan tour đến Singapore]"));
        assertTrue(all.contains("(/tours/1)") && all.contains("(/tours/2)"), "có liên kết tới từng tour");
        assertTrue(all.contains("[Tổng quan tour nước ngoài]") && all.contains("[Tổng quan tour trong nước]"));
        assertTrue(all.contains("[Tổng quan loại hành trình: Nghỉ dưỡng biển đảo]"));
        assertTrue(all.contains("Hành trình: Hà Nội - Singapore → Singapore - Malacca"), "tóm tắt hành trình từ tiêu đề ngày");
        Document dest = docs.stream().filter(d -> d.getId().startsWith("overview:dest:singapore")).findFirst().orElseThrow();
        assertEquals("1", dest.getMetadata().get(KnowledgeBase.META_TOUR_IDS));
        assertEquals(KnowledgeBase.TYPE_OVERVIEW, dest.getMetadata().get(KnowledgeBase.META_TYPE));
    }
}
