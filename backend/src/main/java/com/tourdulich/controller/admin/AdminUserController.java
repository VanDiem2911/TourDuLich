package com.tourdulich.controller.admin;

import com.tourdulich.dto.admin.AdminUserResponse;
import com.tourdulich.dto.admin.UserStatusRequest;
import com.tourdulich.dto.common.PageResponse;
import com.tourdulich.entity.enums.Role;
import com.tourdulich.entity.enums.UserStatus;
import com.tourdulich.security.UserPrincipal;
import com.tourdulich.service.AdminUserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/admin/users")
@RequiredArgsConstructor
public class AdminUserController {

    private final AdminUserService service;

    @GetMapping
    public PageResponse<AdminUserResponse> list(@RequestParam(defaultValue = "1") int page,
                                                @RequestParam(defaultValue = "10") int size,
                                                @RequestParam(required = false) String keyword,
                                                @RequestParam(required = false) Role role,
                                                @RequestParam(required = false) UserStatus status) {
        return service.list(page, size, keyword, role, status);
    }

    @PutMapping("/{id}/status")
    public AdminUserResponse updateStatus(@AuthenticationPrincipal UserPrincipal principal, @PathVariable Long id,
                                          @Valid @RequestBody UserStatusRequest req) {
        return service.updateStatus(principal.id(), id, req.status());
    }
}
