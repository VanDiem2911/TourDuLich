package com.tourdulich.ai;

import org.junit.jupiter.api.Test;
import org.springframework.ai.chat.messages.AssistantMessage;
import org.springframework.ai.chat.model.ChatModel;
import org.springframework.ai.chat.model.ChatResponse;
import org.springframework.ai.chat.model.Generation;
import org.springframework.ai.chat.prompt.Prompt;
import org.springframework.ai.document.Document;
import org.springframework.ai.embedding.Embedding;
import org.springframework.ai.embedding.EmbeddingModel;
import org.springframework.ai.embedding.EmbeddingRequest;
import org.springframework.ai.embedding.EmbeddingResponse;
import org.springframework.mock.env.MockEnvironment;

import java.util.List;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.atomic.AtomicLong;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertInstanceOf;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

class KeyFailoverTest {

    private static final RuntimeException QUOTA = new RuntimeException("429 . You exceeded your current quota");
    private static final RuntimeException INVALID = new RuntimeException("400 . API key not valid. Please pass a valid API key.");

    // ------------------------------------------------------------------ Phân loại lỗi

    @Test
    void classifiesErrors() {
        assertEquals(KeyRotation.Kind.QUOTA, KeyRotation.classify(QUOTA));
        assertEquals(KeyRotation.Kind.INVALID, KeyRotation.classify(INVALID));
        assertEquals(KeyRotation.Kind.QUOTA_DAILY,
                KeyRotation.classify(new RuntimeException("429 RESOURCE_EXHAUSTED: Quota exceeded for metric ... PerDay")));
        assertEquals(KeyRotation.Kind.INVALID, KeyRotation.classify(new RuntimeException("403 PERMISSION_DENIED")));
        assertEquals(KeyRotation.Kind.OTHER, KeyRotation.classify(new RuntimeException("503 Service Unavailable")));
        assertEquals(KeyRotation.Kind.OTHER, KeyRotation.classify(new IllegalArgumentException("prompt rỗng")));
        // Mô hình không còn dành cho key/project (đã gặp thật: gemini-2.5-flash với key của project mới)
        assertEquals(KeyRotation.Kind.UNAVAILABLE, KeyRotation.classify(new RuntimeException(
                "404 NOT_FOUND. This model models/gemini-2.5-flash is no longer available to new users.")));
        // Chữ "rate" trong "generate" KHÔNG được hiểu là giới hạn tốc độ (lỗi cũ)
        assertEquals(KeyRotation.Kind.OTHER, KeyRotation.classify(new RuntimeException("Failed to generate content")));
        // lỗi nằm trong nguyên nhân (cause)
        assertEquals(KeyRotation.Kind.QUOTA, KeyRotation.classify(new RuntimeException("Gọi thất bại", QUOTA)));
    }

    // ------------------------------------------------------------------ Xoay key

    @Test
    void switchesToNextKeyOnQuotaAndStaysThere() {
        KeyRotation r = new KeyRotation("t", List.of("key-aaaa1111", "key-bbbb2222", "key-cccc3333"));
        AtomicInteger calls = new AtomicInteger();
        String out = r.execute(i -> {
            calls.incrementAndGet();
            if (i == 0) {
                throw QUOTA;
            }
            return "ok-" + i;
        });
        assertEquals("ok-1", out);
        assertEquals(2, calls.get(), "thử key 1 lỗi rồi key 2 thành công");
        assertEquals(1, r.current());
        assertEquals(1, r.failovers());
        // lần sau dùng luôn key đang hoạt động, không thử lại key đã hỏng
        assertEquals("ok-1", r.execute(i -> "ok-" + i));
        assertTrue(r.snapshot().get(0).cooling());
        assertTrue(r.snapshot().get(1).active());
    }

    @Test
    void skipsModelThatIsUnavailableForAKeyAndTriesTheNextCombination() {
        // Thứ tự tổ hợp: [2.5-flash/key1, 2.5-flash/key2, 3.5-flash/key1, 3.5-flash/key2]
        KeyRotation r = KeyRotation.labeled("chat", List.of("…aaaa · 2.5", "…bbbb · 2.5", "…aaaa · 3.5", "…bbbb · 3.5"));
        // key1 hết hạn mức ngày; key2 không có mô hình 2.5 (404) -> rơi xuống 3.5 với key1
        String out = r.execute(i -> {
            if (i == 0) {
                throw new RuntimeException("429 RESOURCE_EXHAUSTED PerDay");
            }
            if (i == 1) {
                throw new RuntimeException("404 NOT_FOUND no longer available to new users");
            }
            return "ok-" + i;
        });
        assertEquals("ok-2", out);
        assertEquals(2, r.current());
        assertEquals("UNAVAILABLE", r.snapshot().get(1).lastError());
        assertEquals("QUOTA_DAILY", r.snapshot().get(0).lastError());
        assertEquals("…aaaa · 3.5", r.snapshot().get(2).key().strip());
    }

    @Test
    void cooledKeyIsUsedAgainAfterCooldown() {
        AtomicLong now = new AtomicLong(1_000_000L);
        KeyRotation r = new KeyRotation("t", List.of("key-aaaa1111", "key-bbbb2222"), now::get);
        r.execute(i -> {
            if (i == 0) {
                throw QUOTA; // key 1 nghỉ 90 giây
            }
            return "ok";
        });
        assertEquals(1, r.current());
        now.addAndGet(91_000L); // hết thời gian nghỉ
        // key 2 giờ lỗi -> quay lại key 1 (đã hồi phục)
        String out = r.execute(i -> {
            if (i == 1) {
                throw QUOTA;
            }
            return "back-" + i;
        });
        assertEquals("back-0", out);
    }

    @Test
    void invalidKeyIsParkedForLong() {
        AtomicLong now = new AtomicLong(0L);
        KeyRotation r = new KeyRotation("t", List.of("key-aaaa1111", "key-bbbb2222"), now::get);
        r.execute(i -> {
            if (i == 0) {
                throw INVALID;
            }
            return "ok";
        });
        now.addAndGet(60 * 60_000L); // sau 1 giờ vẫn còn nghỉ (key sai không tự hồi phục nhanh)
        assertTrue(r.snapshot().get(0).cooling());
        assertEquals("INVALID", r.snapshot().get(0).lastError());
    }

    @Test
    void throwsWhenAllKeysFail() {
        KeyRotation r = new KeyRotation("t", List.of("key-aaaa1111", "key-bbbb2222"));
        AtomicInteger calls = new AtomicInteger();
        RuntimeException e = assertThrows(RuntimeException.class, () -> r.execute(i -> {
            calls.incrementAndGet();
            throw QUOTA;
        }));
        assertEquals(QUOTA, e);
        assertEquals(2, calls.get(), "mỗi key thử đúng một lần");
    }

    @Test
    void nonKeyErrorsDoNotSwitchKeys() {
        KeyRotation r = new KeyRotation("t", List.of("key-aaaa1111", "key-bbbb2222"));
        AtomicInteger calls = new AtomicInteger();
        assertThrows(IllegalStateException.class, () -> r.execute(i -> {
            calls.incrementAndGet();
            throw new IllegalStateException("503 Service Unavailable");
        }));
        assertEquals(1, calls.get());
        assertEquals(0, r.failovers());
        assertEquals(0, r.current());
    }

    @Test
    void singleKeyStillWorksAndReportsFailure() {
        KeyRotation r = new KeyRotation("t", List.of("key-aaaa1111"));
        assertThrows(RuntimeException.class, () -> r.execute(i -> {
            throw QUOTA;
        }));
        assertEquals(0, r.failovers(), "không có key dự phòng thì không tính là chuyển key");
        assertEquals("ok", r.execute(i -> "ok"), "lần sau vẫn thử lại key duy nhất");
    }

    @Test
    void snapshotMasksKeys() {
        KeyRotation r = new KeyRotation("t", List.of("AQ.secret-key-value-1234"));
        String shown = r.snapshot().get(0).key();
        assertEquals("…1234", shown);
        assertFalse(shown.contains("secret"));
    }

    // ------------------------------------------------------------------ Mô hình bọc

    private static EmbeddingModel embeddingStub(RuntimeException failWith, float v) {
        return new EmbeddingModel() {
            @Override
            public EmbeddingResponse call(EmbeddingRequest request) {
                if (failWith != null) {
                    throw failWith;
                }
                return new EmbeddingResponse(List.of(new Embedding(new float[]{v}, 0)));
            }

            @Override
            public float[] embed(Document document) {
                if (failWith != null) {
                    throw failWith;
                }
                return new float[]{v};
            }
        };
    }

    @Test
    void embeddingModelFailsOverToBackupKey() {
        KeyRotation r = new KeyRotation("embedding", List.of("key-aaaa1111", "key-bbbb2222"));
        FailoverModels.Embedding model = new FailoverModels.Embedding(
                List.of(embeddingStub(QUOTA, 1f), embeddingStub(null, 2f)), r, 768);
        EmbeddingResponse resp = model.call(new EmbeddingRequest(List.of("tour Singapore"), null));
        assertEquals(2f, resp.getResults().get(0).getOutput()[0]);
        assertEquals(1, r.current());
        assertEquals(768, model.dimensions(), "không gọi API chỉ để đo số chiều");
        assertEquals(2f, model.embed(new Document("x"))[0]);
    }

    @Test
    void chatModelFailsOverToBackupKey() {
        ChatModel bad = new ChatModel() {
            @Override
            public ChatResponse call(Prompt prompt) {
                throw QUOTA;
            }
        };
        ChatModel good = new ChatModel() {
            @Override
            public ChatResponse call(Prompt prompt) {
                return new ChatResponse(List.of(new Generation(new AssistantMessage("xin chào từ key dự phòng"))));
            }
        };
        KeyRotation r = new KeyRotation("chat", List.of("key-aaaa1111", "key-bbbb2222"));
        FailoverModels.Chat model = new FailoverModels.Chat(List.of(bad, good), r);
        assertEquals("xin chào từ key dự phòng", model.call(new Prompt("hi")).getResult().getOutput().getText());
        assertEquals(1, r.failovers());
    }

    // ------------------------------------------------------------------ Đọc key từ cấu hình và dựng mô hình

    @Test
    void loadsKeysFromAllSourcesWithoutDuplicatesOrPlaceholders() {
        MockEnvironment env = new MockEnvironment()
                .withProperty("GEMINI_API_KEY", "key-primary-0001")
                .withProperty("GEMINI_API_KEY_2", "key-backup-0002")
                .withProperty("GEMINI_API_KEY_3", "")
                .withProperty("GEMINI_API_KEY_4", "chua-cau-hinh")
                .withProperty("GEMINI_API_KEYS", "key-backup-0002, key-list-0003;key-list-0004");
        assertEquals(List.of("key-primary-0001", "key-backup-0002", "key-list-0003", "key-list-0004"), AiKeys.load(env));
        assertTrue(AiKeys.load(new MockEnvironment().withProperty("GEMINI_API_KEY", "")).isEmpty());
        assertTrue(AiKeys.load(new MockEnvironment().withProperty("GEMINI_API_KEY", "chua-cau-hinh")).isEmpty());
    }

    @Test
    void configurationBuildsOneModelPerKeyWithoutCallingTheNetwork() {
        MockEnvironment env = new MockEnvironment()
                .withProperty("GEMINI_API_KEY", "key-primary-0001")
                .withProperty("GEMINI_API_KEY_2", "key-backup-0002");
        AiKeyRegistry registry = new AiKeyRegistry();
        AiModelsConfiguration cfg = new AiModelsConfiguration();
        ChatModel chat = cfg.aiChatModel(env, registry);
        EmbeddingModel embedding = cfg.aiEmbeddingModel(env, registry, new InMemoryAiStores());
        assertInstanceOf(FailoverModels.Chat.class, chat);
        assertInstanceOf(CachingEmbeddingModel.class, embedding); // bọc ngoài mô hình có dự phòng key để đệm vector
        assertEquals(768, embedding.dimensions());
        @SuppressWarnings("unchecked")
        java.util.Map<String, Object> chatInfo = (java.util.Map<String, Object>) registry.snapshot().get("chat");
        assertEquals(4, chatInfo.get("keyCount"), "2 key x 2 mô hình chat mặc định = 4 đường dự phòng");
        assertTrue(registry.snapshot().containsKey("embedding"));
    }
}
