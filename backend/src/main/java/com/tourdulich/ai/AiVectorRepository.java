package com.tourdulich.ai;

import lombok.extern.slf4j.Slf4j;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.support.TransactionTemplate;

import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Lưu chỉ mục vector và bộ nhớ đệm embedding vào MariaDB (bảng {@code ai_vectors}, {@code ai_embedding_cache}).
 *
 * <p>MariaDB 11.6 chưa có kiểu VECTOR nên mỗi vector được lưu dạng nhị phân (float32, big-endian) trong cột MEDIUMBLOB và việc
 * tìm kiếm vẫn do {@code SimpleVectorStore} làm trong bộ nhớ. Hai bảng tự được tạo nếu chưa có ({@code CREATE TABLE IF NOT EXISTS}),
 * nên chạy với DB cũ không cần migrate tay.
 */
@Slf4j
@Repository
public class AiVectorRepository implements VectorPersistence, EmbeddingCacheStore {

    static final String DDL_VECTORS = """
            CREATE TABLE IF NOT EXISTS ai_vectors (
                id         VARCHAR(190) NOT NULL,
                kind       VARCHAR(20)  NOT NULL,
                tour_id    BIGINT       NULL,
                content    MEDIUMTEXT   NOT NULL,
                metadata   TEXT         NULL,
                embedding  MEDIUMBLOB   NOT NULL,
                dims       INT          NOT NULL,
                model      VARCHAR(100) NOT NULL,
                updated_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                PRIMARY KEY (id),
                KEY idx_ai_vectors_tour (tour_id),
                KEY idx_ai_vectors_kind (kind)
            ) ENGINE = InnoDB
            """;

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
    private final TransactionTemplate tx;
    private volatile boolean schemaReady;

    public AiVectorRepository(JdbcTemplate jdbc, PlatformTransactionManager txManager) {
        this.jdbc = jdbc;
        this.tx = new TransactionTemplate(txManager);
    }

    /** Tạo hai bảng nếu chưa có (gọi lười, lần đầu cần dùng). */
    private void ensureSchema() {
        if (!schemaReady) {
            synchronized (this) {
                if (!schemaReady) {
                    jdbc.execute(DDL_VECTORS);
                    jdbc.execute(DDL_CACHE);
                    schemaReady = true;
                }
            }
        }
    }

    // ------------------------------------------------------------------ Chỉ mục vector

    @Override
    public List<Row> loadAll() {
        ensureSchema();
        return jdbc.query("SELECT id, content, metadata, embedding FROM ai_vectors ORDER BY id",
                (rs, n) -> new Row(rs.getString("id"), rs.getString("content"), rs.getString("metadata"),
                        fromBytes(rs.getBytes("embedding"))));
    }

    @Override
    public void replaceAll(List<Row> rows, String model) {
        ensureSchema();
        tx.executeWithoutResult(status -> {
            jdbc.update("DELETE FROM ai_vectors");
            jdbc.batchUpdate("INSERT INTO ai_vectors (id, kind, tour_id, content, metadata, embedding, dims, model) "
                    + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)", rows.stream().map(r -> new Object[]{
                    r.id(), kindOf(r.id()), tourIdOf(r), r.text(), r.metadataJson(), toBytes(r.embedding()),
                    r.embedding().length, model}).toList());
        });
    }

    private static String kindOf(String id) {
        int i = id.indexOf(':');
        return i < 0 ? "doc" : id.substring(0, i).replace("kb", "doc");
    }

    /** tour_id lấy từ id dạng "tour:23:head"; các loại khác để NULL. */
    private static Long tourIdOf(Row r) {
        if (!r.id().startsWith("tour:")) {
            return null;
        }
        String[] p = r.id().split(":");
        try {
            return p.length > 1 ? Long.valueOf(p[1]) : null;
        } catch (NumberFormatException e) {
            return null;
        }
    }

    // ------------------------------------------------------------------ Bộ nhớ đệm embedding

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
