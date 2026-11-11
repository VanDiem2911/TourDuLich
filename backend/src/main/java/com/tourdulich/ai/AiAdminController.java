package com.tourdulich.ai;

import com.tourdulich.exception.ApiException;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/** Quản trị chỉ mục AI (chỉ ROLE_ADMIN, nằm dưới /api/admin/**). */
@RestController
@RequestMapping("/api/admin/ai")
@RequiredArgsConstructor
public class AiAdminController {

    private final KnowledgeBase knowledgeBase;
    private final AiKeyRegistry keyRegistry;
    private final ChatLogRepository chatLogs;

    @GetMapping("/status")
    public KnowledgeBase.Stats status() {
        return knowledgeBase.stats();
    }

    /** Trạng thái các API key (đã che, chỉ 4 ký tự cuối): key nào đang dùng, đang nghỉ do hết hạn mức, số lần đã chuyển key. */
    @GetMapping("/keys")
    public java.util.Map<String, Object> keys() {
        return keyRegistry.snapshot();
    }

    /** Lịch sử hội thoại giữa khách và trợ lý (nhóm theo cuộc trò chuyện), có thể tìm theo từ khóa. */
    @GetMapping("/chats")
    public java.util.Map<String, Object> chats(@org.springframework.web.bind.annotation.RequestParam(required = false) String keyword,
                                               @org.springframework.web.bind.annotation.RequestParam(defaultValue = "1") int page,
                                               @org.springframework.web.bind.annotation.RequestParam(defaultValue = "15") int size) {
        return chatLogs.conversations(keyword, page, size);
    }

    @GetMapping("/chats/stats")
    public java.util.Map<String, Object> chatStats(@org.springframework.web.bind.annotation.RequestParam(defaultValue = "7") int days) {
        return chatLogs.stats(days);
    }

    @GetMapping("/chats/{conversationId}")
    public java.util.List<java.util.Map<String, Object>> chat(@org.springframework.web.bind.annotation.PathVariable String conversationId) {
        return chatLogs.conversation(conversationId);
    }

    /** Xóa một hội thoại (ví dụ nội dung nhạy cảm hoặc spam). */
    @org.springframework.web.bind.annotation.DeleteMapping("/chats/{conversationId}")
    public java.util.Map<String, Object> deleteChat(@org.springframework.web.bind.annotation.PathVariable String conversationId) {
        return java.util.Map.of("deleted", chatLogs.delete(conversationId));
    }

    /** Xem trước các tài liệu tổng quan về tour (theo điểm đến, loại hành trình, phạm vi) mà AI sẽ đọc. */
    @GetMapping("/preview")
    public java.util.List<java.util.Map<String, String>> preview() {
        return knowledgeBase.previewOverview();
    }

    /** Lập lại chỉ mục (đọc lại tour trong DB + tài liệu). Gọi sau khi thêm/sửa file trong ai-knowledge. */
    @PostMapping("/reindex")
    public KnowledgeBase.Stats reindex() {
        if (!knowledgeBase.isEnabled()) {
            throw new ApiException(HttpStatus.SERVICE_UNAVAILABLE,
                    "Trợ lý AI chưa được bật: chưa có GEMINI_API_KEY trong backend/.env (xem docs/AI_CHATBOT_VA_USER_TRACKING.md).");
        }
        try {
            return knowledgeBase.reindexAll();
        } catch (RuntimeException e) {
            throw new ApiException(HttpStatus.BAD_GATEWAY, "Lập chỉ mục thất bại: " + e.getMessage());
        }
    }
}
