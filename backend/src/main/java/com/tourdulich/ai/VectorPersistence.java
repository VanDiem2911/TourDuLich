package com.tourdulich.ai;

import java.util.List;

/**
 * Nơi LƯU BỀN chỉ mục vector (hiện là bảng {@code ai_vectors} trong MariaDB).
 * Việc tìm kiếm vẫn chạy trong bộ nhớ ({@code SimpleVectorStore}) nên rất nhanh; lớp này chỉ để không phải embed lại khi khởi động.
 */
public interface VectorPersistence {

    /** Một đoạn đã được embed: id, nội dung, metadata (JSON) và vector. */
    record Row(String id, String text, String metadataJson, float[] embedding) {
    }

    /** Toàn bộ các đoạn đã lưu (rỗng nếu chưa có). */
    List<Row> loadAll();

    /** Thay toàn bộ nội dung đã lưu bằng {@code rows} (trong một giao dịch: lỗi thì giữ nguyên bản cũ). */
    void replaceAll(List<Row> rows, String model);
}
