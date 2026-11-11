package com.tourdulich.ai;

import com.tourdulich.ai.ChatDtos.ChatRequest;
import com.tourdulich.ai.ChatDtos.ChatResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/** API công khai của trợ lý AI (Guest cũng dùng được; có giới hạn tốc độ theo IP). */
@RestController
@RequestMapping("/api/ai")
@RequiredArgsConstructor
public class AiController {

    private final ChatService chatService;

    /** Frontend gọi khi mở khung chat để biết AI đã bật/sẵn sàng chưa. */
    @GetMapping("/status")
    public ChatDtos.Status status() {
        return chatService.status();
    }

    @PostMapping("/chat")
    public ChatResponse chat(@RequestBody ChatRequest request,
                             @org.springframework.security.core.annotation.AuthenticationPrincipal com.tourdulich.security.UserPrincipal principal) {
        return chatService.chat(request, principal == null ? null : principal.id());
    }
}
