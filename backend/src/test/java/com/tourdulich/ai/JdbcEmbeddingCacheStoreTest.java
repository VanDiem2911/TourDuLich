package com.tourdulich.ai;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertArrayEquals;
import static org.junit.jupiter.api.Assertions.assertEquals;

class JdbcEmbeddingCacheStoreTest {

    @Test
    void floatVectorsSurviveByteRoundTrip() {
        float[] v = {0.5f, -1.25f, 3.1415927f, 0f, Float.MIN_VALUE, 123456.78f};
        assertArrayEquals(v, JdbcEmbeddingCacheStore.fromBytes(JdbcEmbeddingCacheStore.toBytes(v)));
        assertEquals(768 * 4, JdbcEmbeddingCacheStore.toBytes(new float[768]).length, "768 chiều = 3072 byte");
    }
}
