package com.tourdulich.ai;

import org.springframework.ai.chat.model.ChatModel;
import org.springframework.ai.chat.model.ChatResponse;
import org.springframework.ai.chat.prompt.Prompt;
import org.springframework.ai.document.Document;
import org.springframework.ai.embedding.EmbeddingModel;
import org.springframework.ai.embedding.EmbeddingRequest;
import org.springframework.ai.embedding.EmbeddingResponse;
import reactor.core.publisher.Flux;

import java.util.List;

/** Các mô hình "bọc" nhiều key: mỗi lời gọi đi qua {@link KeyRotation} nên tự đổi key khi key hiện tại hết hạn mức hoặc lỗi. */
public final class FailoverModels {

    private FailoverModels() {
    }

    public static final class Chat implements ChatModel {
        private final List<ChatModel> delegates;
        private final KeyRotation rotation;

        public Chat(List<ChatModel> delegates, KeyRotation rotation) {
            this.delegates = delegates;
            this.rotation = rotation;
        }

        @Override
        public ChatResponse call(Prompt prompt) {
            return rotation.execute(i -> delegates.get(i).call(prompt));
        }

        /** Streaming dùng key đang hoạt động (không tự đổi key giữa chừng một luồng). */
        @Override
        public Flux<ChatResponse> stream(Prompt prompt) {
            return delegates.get(rotation.current()).stream(prompt);
        }

        public KeyRotation rotation() {
            return rotation;
        }
    }

    public static final class Embedding implements EmbeddingModel {
        private final List<EmbeddingModel> delegates;
        private final KeyRotation rotation;
        private final int dimensions;

        public Embedding(List<EmbeddingModel> delegates, KeyRotation rotation, int dimensions) {
            this.delegates = delegates;
            this.rotation = rotation;
            this.dimensions = dimensions;
        }

        @Override
        public EmbeddingResponse call(EmbeddingRequest request) {
            return rotation.execute(i -> delegates.get(i).call(request));
        }

        @Override
        public float[] embed(Document document) {
            return rotation.execute(i -> delegates.get(i).embed(document));
        }

        /** Trả số chiều đã cấu hình, không gọi API chỉ để đo (mặc định của interface sẽ embed thử một chuỗi). */
        @Override
        public int dimensions() {
            return dimensions;
        }

        public KeyRotation rotation() {
            return rotation;
        }
    }
}
