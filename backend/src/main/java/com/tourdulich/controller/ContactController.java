package com.tourdulich.controller;

import com.tourdulich.dto.common.MessageResponse;
import com.tourdulich.dto.contact.ContactRequest;
import com.tourdulich.security.UserPrincipal;
import com.tourdulich.service.ContactService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/contacts")
@RequiredArgsConstructor
public class ContactController {

    private final ContactService contactService;

    /** Công khai (Guest hoặc Customer). Nếu có token hợp lệ thì gắn userId vào liên hệ. */
    @PostMapping
    public ResponseEntity<MessageResponse> submit(@Valid @RequestBody ContactRequest req,
                                                  @AuthenticationPrincipal UserPrincipal principal) {
        Long userId = principal == null ? null : principal.id();
        return ResponseEntity.status(HttpStatus.CREATED).body(contactService.submit(req, userId));
    }
}
