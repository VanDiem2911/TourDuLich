package com.tourdulich.ai;

import java.util.HashMap;
import java.util.Map;

/** Kho giả trong bộ nhớ thay cho bảng ai_embedding_cache (để test không cần DB). */
class InMemoryEmbeddingCacheStore implements EmbeddingCacheStore {

    final Map<String, Map<String, float[]>> cache = new HashMap<>();

    @Override
    public Map<String, float[]> loadAll(String namespace) {
        return new HashMap<>(cache.getOrDefault(namespace, Map.of()));
    }

    @Override
    public void saveNew(String namespace, Map<String, float[]> entries) {
        cache.computeIfAbsent(namespace, k -> new HashMap<>()).putAll(entries);
    }
}
