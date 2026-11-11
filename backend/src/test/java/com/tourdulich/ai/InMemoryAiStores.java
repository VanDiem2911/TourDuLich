package com.tourdulich.ai;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/** Kho lưu giả trong bộ nhớ thay cho bảng ai_vectors / ai_embedding_cache (để test không cần DB). */
class InMemoryAiStores implements VectorPersistence, EmbeddingCacheStore {

    List<Row> rows = new ArrayList<>();
    String model;
    int replaceCalls;
    final Map<String, Map<String, float[]>> cache = new HashMap<>();

    @Override
    public List<Row> loadAll() {
        return new ArrayList<>(rows);
    }

    @Override
    public void replaceAll(List<Row> newRows, String model) {
        this.rows = new ArrayList<>(newRows);
        this.model = model;
        replaceCalls++;
    }

    @Override
    public Map<String, float[]> loadAll(String namespace) {
        return new HashMap<>(cache.getOrDefault(namespace, Map.of()));
    }

    @Override
    public void saveNew(String namespace, Map<String, float[]> entries) {
        cache.computeIfAbsent(namespace, k -> new HashMap<>()).putAll(entries);
    }
}
