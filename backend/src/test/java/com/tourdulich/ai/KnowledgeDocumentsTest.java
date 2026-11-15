package com.tourdulich.ai;

import com.tourdulich.config.AppProperties;
import com.tourdulich.entity.Tour;
import org.junit.jupiter.api.Test;
import org.springframework.ai.document.Document;

import java.util.List;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

/** Kiểm tra phần dựng "đoạn" cho AI đọc (cắt đoạn, metadata, bỏ mục không cần): không cần API key lẫn database. */
class KnowledgeDocumentsTest {

    private final KnowledgeDocuments documents = new KnowledgeDocuments(new AppProperties(null, null, null, null, null, null,
            new AppProperties.Ai("no-such-dir", 6, 0.0, 8, 1000)));
    private final Tour singapore = TourFixtures.singapore();
    private final Tour phuQuoc = TourFixtures.phuQuoc();

    @Test
    void tourDocumentsHaveHeadlineItineraryAndOnlyUsefulNotes() {
        List<Document> docs = documents.tourDocuments(singapore);
        String headId = KnowledgeDocuments.docId("tour:1:head");
        assertTrue(docs.stream().anyMatch(d -> d.getId().equals(headId)));
        Document head = docs.stream().filter(d -> d.getId().equals(headId)).findFirst().orElseThrow();
        assertTrue(head.getText().contains("Điểm đến: Singapore"));
        assertTrue(head.getText().contains("11.691.000 đ"));
        assertTrue(head.getText().contains("/tours/1"));
        assertEquals("1", head.getMetadata().get(KnowledgeDocuments.META_TOUR_ID));
        assertTrue(docs.stream().anyMatch(d -> d.getText().contains("Merlion")));
        String all = String.join("\n", docs.stream().map(Document::getText).toList());
        assertTrue(all.contains("Hủy trước 30 ngày"), "giữ mục hủy tour");
        assertFalse(all.contains("Hộ chiếu còn hạn"), "bỏ mục giấy tờ mang theo");
    }

    @Test
    void markdownIsSplitBySectionWithLabels() {
        List<Document> docs = documents.documentsOf("faq.md", "# Hướng dẫn thanh toán\n## Chuyển khoản\nQuét mã QR và ghi đúng nội dung.\n"
                + "## Hủy đơn\nChỉ hủy được khi đơn còn chờ xác nhận.");
        assertEquals(2, docs.size());
        assertTrue(docs.get(0).getText().startsWith("[Tài liệu: Hướng dẫn thanh toán > Chuyển khoản]"));
        assertTrue(docs.get(1).getText().contains("chờ xác nhận"));
        assertEquals(KnowledgeDocuments.TYPE_DOC, docs.get(0).getMetadata().get(KnowledgeDocuments.META_TYPE));
    }

    @Test
    void usefulNotesKeepsOnlyIncludedCancelAndSurcharge() {
        String n = KnowledgeDocuments.usefulNotes("Giá tour bao gồm\nA\n\nGiấy tờ mang theo\nB\n\nQuy định phụ thu\nC");
        assertTrue(n.contains("A") && n.contains("C"));
        assertFalse(n.contains("B"));
    }

    @Test
    void docIdIsAStableUuid() {
        String id = KnowledgeDocuments.docId("tour:1:head");
        assertEquals(id, UUID.fromString(id).toString(), "đúng định dạng UUID (cột id của vector_store)");
        assertEquals(id, KnowledgeDocuments.docId("tour:1:head"), "cùng khóa thì cùng id");
        assertFalse(id.equals(KnowledgeDocuments.docId("tour:2:head")));
    }

    @Test
    void overviewDocumentsCoverDestinationCategoryAndRegion() {
        List<Document> docs = documents.overviewDocuments(List.of(singapore, phuQuoc));
        String all = String.join("\n", docs.stream().map(Document::getText).toList());
        assertTrue(all.contains("[Tổng quan tour đến Singapore]"));
        assertTrue(all.contains("(/tours/1)") && all.contains("(/tours/2)"), "có liên kết tới từng tour");
        assertTrue(all.contains("[Tổng quan tour nước ngoài]") && all.contains("[Tổng quan tour trong nước]"));
        assertTrue(all.contains("[Tổng quan loại hành trình: Nghỉ dưỡng biển đảo]"));
        assertTrue(all.contains("Hành trình: Hà Nội - Singapore → Singapore - Malacca"), "tóm tắt hành trình từ tiêu đề ngày");
        Document dest = docs.stream()
                .filter(d -> String.valueOf(d.getMetadata().get(KnowledgeDocuments.META_TITLE)).startsWith("overview:dest:singapore"))
                .findFirst().orElseThrow();
        assertEquals("1", dest.getMetadata().get(KnowledgeDocuments.META_TOUR_IDS));
        assertEquals(KnowledgeDocuments.TYPE_OVERVIEW, dest.getMetadata().get(KnowledgeDocuments.META_TYPE));
    }
}
