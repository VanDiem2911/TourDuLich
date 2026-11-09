package com.tourdulich.service;

import com.tourdulich.dto.admin.AdminUserResponse;
import com.tourdulich.dto.common.PageResponse;
import com.tourdulich.entity.User;
import com.tourdulich.entity.enums.Role;
import com.tourdulich.entity.enums.UserStatus;
import com.tourdulich.exception.ApiException;
import com.tourdulich.repository.BookingRepository;
import com.tourdulich.repository.UserRepository;
import com.tourdulich.util.Pages;
import com.tourdulich.util.Texts;
import jakarta.persistence.criteria.Predicate;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/** Quản lý tài khoản người dùng (UC-13). */
@Service
@RequiredArgsConstructor
public class AdminUserService {

    private final UserRepository userRepository;
    private final BookingRepository bookingRepository;

    @Transactional(readOnly = true)
    public PageResponse<AdminUserResponse> list(int page, int size, String keyword, Role role, UserStatus status) {
        Specification<User> spec = (root, q, cb) -> {
            List<Predicate> ps = new ArrayList<>();
            if (role != null) {
                ps.add(cb.equal(root.get("role"), role));
            }
            if (status != null) {
                ps.add(cb.equal(root.get("status"), status));
            }
            if (keyword != null && !keyword.isBlank()) {
                String p = Texts.likePattern(keyword);
                ps.add(cb.or(cb.like(cb.lower(root.get("fullName")), p, '\\'),
                        cb.like(cb.lower(root.get("email")), p, '\\')));
            }
            return cb.and(ps.toArray(new Predicate[0]));
        };
        Page<User> result = userRepository.findAll(spec,
                Pages.of(page, size, Sort.by(Sort.Order.desc("createdAt"), Sort.Order.desc("id"))));
        Map<Long, Long> counts = bookingCounts(result.getContent());
        return PageResponse.of(result, result.getContent().stream()
                .map(u -> toResponse(u, counts.getOrDefault(u.getId(), 0L))).toList());
    }

    @Transactional
    public AdminUserResponse updateStatus(Long currentAdminId, Long id, UserStatus status) {
        User u = userRepository.findById(id).orElseThrow(() -> ApiException.notFound("Không tìm thấy người dùng"));
        if (u.getId().equals(currentAdminId)) {
            throw ApiException.badRequest("Không thể tự khóa hoặc tự xóa tài khoản quản trị đang sử dụng!");
        }
        if (u.getRole() == Role.ROLE_ADMIN) {
            throw ApiException.forbidden("Không thể thay đổi trạng thái của tài khoản quản trị viên khác!");
        }
        u.setStatus(status);
        userRepository.save(u);
        return toResponse(u, bookingCounts(List.of(u)).getOrDefault(u.getId(), 0L));
    }

    private Map<Long, Long> bookingCounts(List<User> users) {
        Map<Long, Long> counts = new HashMap<>();
        if (!users.isEmpty()) {
            for (Object[] row : bookingRepository.countGroupedByUserIds(users.stream().map(User::getId).toList())) {
                counts.put((Long) row[0], (Long) row[1]);
            }
        }
        return counts;
    }

    private static AdminUserResponse toResponse(User u, long bookingCount) {
        return new AdminUserResponse(u.getId(), u.getFullName(), u.getEmail(), u.getPhone(), u.getAddress(),
                u.getRole(), u.getStatus(), u.getCreatedAt(), bookingCount);
    }
}
