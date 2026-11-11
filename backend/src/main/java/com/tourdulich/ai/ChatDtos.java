package com.tourdulich.ai;

import java.util.List;

/** Các DTO của API chat: {@code POST /api/ai/chat}. */
public final class ChatDtos {

    private ChatDtos() {
    }

    /** Một lượt hội thoại trước đó. role: "user" hoặc "assistant". */
    public record Turn(String role, String content) {
    }

    /**
     * message: câu hỏi mới. history: các lượt gần nhất (máy chủ không lưu hội thoại, frontend gửi lại).
     * currentTourId: tour khách đang xem (nếu có). viewedTourIds: các tour khách xem gần đây (từ cơ chế tracking).
     * conversationId: mã ngẫu nhiên của một cuộc trò chuyện (do frontend sinh) để nhóm các lượt trong lịch sử chat.
     */
    public record ChatRequest(String message, List<Turn> history, Long currentTourId, List<Long> viewedTourIds,
                              String conversationId) {
    }

    /** Thẻ tour được trợ lý nhắc đến trong câu trả lời (để frontend hiển thị dạng thẻ bấm được). */
    public record Source(Long tourId, String name, String imageUrl, long price, long originalPrice,
                         String destination, String duration, String url) {
    }

    public record ChatResponse(String answer, List<Source> sources) {
    }

    public record Status(boolean enabled, boolean ready) {
    }
}
