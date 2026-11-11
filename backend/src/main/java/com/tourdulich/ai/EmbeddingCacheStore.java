package com.tourdulich.ai;

import java.util.Map;

/** Nơi lưu bền bộ nhớ đệm embedding (bảng {@code ai_embedding_cache}): khóa là mã băm của (mô hình + nội dung). */
public interface EmbeddingCacheStore {

    /** Các vector đã đệm của một mô hình (namespace = tên mô hình + số chiều). */
    Map<String, float[]> loadAll(String namespace);

    /** Lưu thêm các vector mới (bỏ qua khóa đã tồn tại). */
    void saveNew(String namespace, Map<String, float[]> entries);
}
