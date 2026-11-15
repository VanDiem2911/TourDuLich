package com.tourdulich.ai;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Lưu bộ nhớ đệm embedding vào MariaDB (bảng {@code ai_embedding_cache}): vector được ghi dạng nhị phân (float32) trong
 * cột MEDIUMBLOB. Đây chỉ là bộ đệm để khỏi gọi API lại; chỉ mục vector dùng để tìm kiếm do
 * {@link VectorStoreConfiguration} (MariaDBVectorStore của Spring AI) quản lý.
 *
 * <p>Bảng tự được tạo nếu chưa có ({@code CREATE TABLE IF NOT EXISTS}), nên chạy với DB cũ không cần migrate tay.
 */
@Repository
public class JdbcEmbeddingCacheStore implements EmbeddingCacheStore {

    static final String DDL_CACHE = """
            CREATE TABLE IF NOT EXISTS ai_embedding_cache (
                hash       CHAR(64)     NOT NULL,
                namespace  VARCHAR(100) NOT NULL,
                embedding  MEDIUMBLOB   NOT NULL,
                created_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
                PRIMARY KEY (hash),
                KEY idx_ai_cache_ns (namespace)
            ) ENGINE = InnoDB
            """;

    private final JdbcTemplate jdbc;
    private volatile boolean schemaReady;

    public JdbcEmbeddingCacheStore(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    /** Tạo bảng nếu chưa có (gọi lười, lần đầu cần dùng). */
    private void ensureSchema() {
        if (!schemaReady) {
            synchronized (this) {
                if (!schemaReady) {
                    jdbc.execute(DDL_CACHE);
                    schemaReady = true;
                }
            }
        }
    }

    @Override
    public Map<String, float[]> loadAll(String namespace) {
        ensureSchema();
        Map<String, float[]> out = new HashMap<>();
        jdbc.query("SELECT hash, embedding FROM ai_embedding_cache WHERE namespace = ?",
                rs -> {
                    out.put(rs.getString("hash"), fromBytes(rs.getBytes("embedding")));
                }, namespace);
        return out;
    }

    @Override
    public void saveNew(String namespace, Map<String, float[]> entries) {
        if (entries.isEmpty()) {
            return;
        }
        ensureSchema();
        List<Object[]> batch = new ArrayList<>();
        entries.forEach((hash, v) -> batch.add(new Object[]{hash, namespace, toBytes(v)}));
        jdbc.batchUpdate("INSERT IGNORE INTO ai_embedding_cache (hash, namespace, embedding) VALUES (?, ?, ?)", batch);
    }

    // ------------------------------------------------------------------ Vector <-> byte[]

    static byte[] toBytes(float[] v) {
        ByteBuffer b = ByteBuffer.allocate(v.length * 4);
        for (float f : v) {
            b.putFloat(f);
        }
        return b.array();
    }

    static float[] fromBytes(byte[] bytes) {
        ByteBuffer b = ByteBuffer.wrap(bytes);
        float[] v = new float[bytes.length / 4];
        for (int i = 0; i < v.length; i++) {
            v[i] = b.getFloat();
        }
        return v;
    }
}
