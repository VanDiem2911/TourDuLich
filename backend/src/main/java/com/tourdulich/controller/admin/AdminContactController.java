package com.tourdulich.controller.admin;

import com.tourdulich.dto.admin.AdminContactResponse;
import com.tourdulich.dto.admin.ContactReplyRequest;
import com.tourdulich.dto.admin.ContactStatusRequest;
import com.tourdulich.dto.common.PageResponse;
import com.tourdulich.entity.enums.ContactStatus;
import com.tourdulich.security.UserPrincipal;
import com.tourdulich.service.AdminContactService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/admin/contacts")
@RequiredArgsConstructor
public class AdminContactController {

    private final AdminContactService service;

    @GetMapping
    public PageResponse<AdminContactResponse> list(@RequestParam(defaultValue = "1") int page,
                                                   @RequestParam(defaultValue = "10") int size,
                                                   @RequestParam(required = false) ContactStatus status,
                                                   @RequestParam(required = false) String keyword) {
        return service.list(page, size, status, keyword);
    }

    @GetMapping("/{id}")
    public AdminContactResponse get(@PathVariable Long id) {
        return service.get(id);
    }

    @PutMapping("/{id}/reply")
    public AdminContactResponse reply(@AuthenticationPrincipal UserPrincipal principal, @PathVariable Long id,
                                      @Valid @RequestBody ContactReplyRequest req) {
        return service.reply(principal.id(), id, req.replyContent());
    }

    @PutMapping("/{id}/status")
    public AdminContactResponse updateStatus(@PathVariable Long id, @Valid @RequestBody ContactStatusRequest req) {
        return service.updateStatus(id, req.status(), req.adminNote());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }
}
