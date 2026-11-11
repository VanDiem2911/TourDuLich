package com.tourdulich.ai;

import com.google.genai.Client;
import com.google.genai.types.HttpOptions;
import com.google.genai.types.HttpRetryOptions;
import org.springframework.ai.chat.model.ChatModel;
import org.springframework.ai.embedding.EmbeddingModel;
import org.springframework.ai.google.genai.GoogleGenAiChatModel;
import org.springframework.ai.google.genai.GoogleGenAiChatOptions;
import org.springframework.ai.google.genai.GoogleGenAiEmbeddingConnectionDetails;
import org.springframework.ai.google.genai.text.GoogleGenAiTextEmbeddingModel;
import org.springframework.ai.google.genai.text.GoogleGenAiTextEmbeddingOptions;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Condition;
import org.springframework.context.annotation.ConditionContext;
import org.springframework.context.annotation.Conditional;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.core.env.Environment;
import org.springframework.core.type.AnnotatedTypeMetadata;
import org.springframework.retry.support.RetryTemplate;

import java.util.ArrayList;
import java.util.List;

/**
 * Tự dựng mô hình chat và embedding của Gemini cho TỪNG API key rồi bọc bằng cơ chế dự phòng key ({@link KeyRotation}).
 * Chỉ bật khi có ít nhất một key (xem {@link AiKeys}); không cần profile hay cờ {@code spring.ai.model.*}.
 *
 * <p>Việc tự thử lại (retry) bên trong thư viện được tắt (1 lần) để lỗi hết hạn mức nổi lên ngay và được chuyển sang key
 * khác, thay vì chờ nhiều phút trong vòng retry mặc định.
 */
@Configuration
@Conditional(AiModelsConfiguration.HasAiKeys.class)
public class AiModelsConfiguration {

    /** Điều kiện bật: có ít nhất một API key trong cấu hình. */
    static class HasAiKeys implements Condition {
        @Override
        public boolean matches(ConditionContext context, AnnotatedTypeMetadata metadata) {
            return !AiKeys.load(context.getEnvironment()).isEmpty();
        }
    }

    /**
     * Danh sách mô hình chat theo thứ tự ưu tiên ({@code GEMINI_CHAT_MODEL}, cách nhau bằng dấu phẩy). Mỗi tổ hợp (mô hình, key) là một
     * "đường đi" dự phòng: hết hạn mức hoặc mô hình không còn dành cho một key thì chuyển sang tổ hợp kế tiếp.
     */
    @Bean
    @Primary
    public ChatModel aiChatModel(Environment env, AiKeyRegistry registry) {
        List<String> keys = AiKeys.load(env);
        List<String> models = chatModels(env);
        double temperature = env.getProperty("app.ai.temperature", Double.class, 0.3);
        List<ChatModel> delegates = new ArrayList<>();
        List<String> labels = new ArrayList<>();
        for (String model : models) {
            for (String key : keys) {
                Client client = Client.builder().apiKey(key).httpOptions(noRetry()).build();
                delegates.add(GoogleGenAiChatModel.builder()
                        .genAiClient(client)
                        .defaultOptions(GoogleGenAiChatOptions.builder().model(model).temperature(temperature).build())
                        .retryTemplate(singleAttempt())
                        .build());
                labels.add(AiKeys.mask(key) + " · " + model);
            }
        }
        KeyRotation rotation = KeyRotation.labeled("chat", labels);
        registry.register(rotation);
        return new FailoverModels.Chat(delegates, rotation);
    }

    static List<String> chatModels(Environment env) {
        String raw = env.getProperty("GEMINI_CHAT_MODEL", "gemini-2.5-flash,gemini-3.5-flash");
        List<String> out = new ArrayList<>();
        for (String m : raw.split("[,;]")) {
            if (!m.isBlank() && !out.contains(m.strip())) {
                out.add(m.strip());
            }
        }
        return out.isEmpty() ? List.of("gemini-2.5-flash") : out;
    }

    @Bean
    @Primary
    public EmbeddingModel aiEmbeddingModel(Environment env, AiKeyRegistry registry, EmbeddingCacheStore cacheStore) {
        List<String> keys = AiKeys.load(env);
        String model = env.getProperty("GEMINI_EMBEDDING_MODEL", "gemini-embedding-001");
        int dims = env.getProperty("app.ai.embedding-dimensions", Integer.class, 768);
        List<EmbeddingModel> delegates = new ArrayList<>();
        for (String key : keys) {
            Client client = Client.builder().apiKey(key).httpOptions(noRetry()).build();
            GoogleGenAiEmbeddingConnectionDetails details = GoogleGenAiEmbeddingConnectionDetails.builder()
                    .genAiClient(client).build();
            delegates.add(new GoogleGenAiTextEmbeddingModel(details,
                    GoogleGenAiTextEmbeddingOptions.builder().model(model).dimensions(dims).build(), singleAttempt()));
        }
        KeyRotation rotation = new KeyRotation("embedding", keys);
        registry.register(rotation);
        EmbeddingModel failover = new FailoverModels.Embedding(delegates, rotation, dims);
        // Bộ nhớ đệm trong DB (bảng ai_embedding_cache): cùng một nội dung chỉ embed (tốn token) một lần
        return new CachingEmbeddingModel(failover, model + "/" + dims, cacheStore);
    }

    private static HttpOptions noRetry() {
        return HttpOptions.builder().retryOptions(HttpRetryOptions.builder().attempts(1).build()).build();
    }

    private static RetryTemplate singleAttempt() {
        return RetryTemplate.builder().maxAttempts(1).build();
    }
}
