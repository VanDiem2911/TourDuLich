package com.tourdulich.ai;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Cầu nối giữa {@code SimpleVectorStore} (chỉ nạp/lưu được dưới dạng JSON) và các dòng trong DB.
 * Định dạng của nó: {@code {id: {id, text, metadata, embedding[]}}}.
 */
final class VectorStoreJson {

    private VectorStoreJson() {
    }

    /** Dòng DB -> JSON mà SimpleVectorStore.load() đọc được (không gọi API embedding). */
    static byte[] toJson(List<VectorPersistence.Row> rows, ObjectMapper mapper) {
        Map<String, Object> root = new LinkedHashMap<>();
        for (VectorPersistence.Row r : rows) {
            Map<String, Object> one = new LinkedHashMap<>();
            one.put("id", r.id());
            one.put("text", r.text());
            try {
                one.put("metadata", r.metadataJson() == null ? Map.of() : mapper.readValue(r.metadataJson(), Map.class));
            } catch (JsonProcessingException e) {
                one.put("metadata", Map.of());
            }
            one.put("embedding", r.embedding());
            root.put(r.id(), one);
        }
        try {
            return mapper.writeValueAsBytes(root);
        } catch (JsonProcessingException e) {
            throw new IllegalStateException("Không dựng được JSON chỉ mục", e);
        }
    }

    /** JSON do SimpleVectorStore.save() ghi ra (hoặc file chỉ mục cũ) -> các dòng để lưu vào DB. */
    static List<VectorPersistence.Row> fromJson(JsonNode root, ObjectMapper mapper) {
        List<VectorPersistence.Row> rows = new ArrayList<>();
        root.fields().forEachRemaining(e -> {
            JsonNode v = e.getValue();
            String text = v.hasNonNull("text") ? v.get("text").asText() : v.path("content").asText(null);
            JsonNode emb = v.path("embedding");
            if (text == null || !emb.isArray() || emb.isEmpty()) {
                return;
            }
            float[] vec = new float[emb.size()];
            for (int i = 0; i < vec.length; i++) {
                vec[i] = (float) emb.get(i).asDouble();
            }
            String meta = null;
            if (v.hasNonNull("metadata")) {
                try {
                    meta = mapper.writeValueAsString(v.get("metadata"));
                } catch (JsonProcessingException ex) {
                    meta = null;
                }
            }
            rows.add(new VectorPersistence.Row(e.getKey(), text, meta, vec));
        });
        return rows;
    }
}
