package com.tourdulich.service;

import com.tourdulich.dto.admin.AdminContactResponse;
import com.tourdulich.dto.common.PageResponse;
import com.tourdulich.entity.Contact;
import com.tourdulich.entity.enums.ContactStatus;
import com.tourdulich.exception.ApiException;
import com.tourdulich.repository.ContactRepository;
import com.tourdulich.util.Pages;
import com.tourdulich.util.Texts;
import jakarta.persistence.criteria.Predicate;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/** Quản lý và phản hồi liên hệ khách hàng (UC-17). */
@Service
@RequiredArgsConstructor
public class AdminContactService {

    private final ContactRepository contactRepository;
    private final MailService mailService;

    @Transactional(readOnly = true)
    public PageResponse<AdminContactResponse> list(int page, int size, ContactStatus status, String keyword) {
        Specification<Contact> spec = (root, q, cb) -> {
            List<Predicate> ps = new ArrayList<>();
            if (status != null) {
                ps.add(cb.equal(root.get("status"), status));
            }
            if (keyword != null && !keyword.isBlank()) {
                String p = Texts.likePattern(keyword);
                ps.add(cb.or(cb.like(cb.lower(root.get("fullName")), p, '\\'),
                        cb.like(cb.lower(root.get("email")), p, '\\'),
                        cb.like(cb.lower(root.get("subject")), p, '\\')));
            }
            return cb.and(ps.toArray(new Predicate[0]));
        };
        Page<Contact> result = contactRepository.findAll(spec,
                Pages.of(page, size, Sort.by(Sort.Order.desc("createdAt"), Sort.Order.desc("id"))));
        return PageResponse.of(result, result.getContent().stream().map(AdminContactService::toResponse).toList());
    }

    /** Xem chi tiết: liên hệ NEW tự chuyển sang IN_PROGRESS (theo UC-17 bước 6). */
    @Transactional
    public AdminContactResponse get(Long id) {
        Contact c = find(id);
        if (c.getStatus() == ContactStatus.NEW) {
            c.setStatus(ContactStatus.IN_PROGRESS);
            contactRepository.save(c);
        }
        return toResponse(c);
    }

    @Transactional
    public AdminContactResponse reply(Long adminId, Long id, String replyContent) {
        Contact c = find(id);
        c.setReplyContent(replyContent.trim());
        c.setRepliedBy(adminId);
        c.setRepliedAt(LocalDateTime.now());
        c.setStatus(ContactStatus.RESOLVED);
        contactRepository.save(c);
        mailService.sendContactReply(c.getEmail(), c.getFullName(), c.getSubject(), c.getReplyContent());
        return toResponse(c);
    }

    @Transactional
    public AdminContactResponse updateStatus(Long id, ContactStatus status, String adminNote) {
        Contact c = find(id);
        c.setStatus(status);
        if (adminNote != null) {
            c.setAdminNote(Texts.blankToNull(adminNote));
        }
        contactRepository.save(c);
        return toResponse(c);
    }

    @Transactional
    public void delete(Long id) {
        contactRepository.delete(find(id));
    }

    private Contact find(Long id) {
        return contactRepository.findById(id).orElseThrow(() -> ApiException.notFound("Không tìm thấy liên hệ"));
    }

    private static AdminContactResponse toResponse(Contact c) {
        return new AdminContactResponse(c.getId(), c.getFullName(), c.getEmail(), c.getPhone(), c.getSubject(),
                c.getMessage(), c.getStatus(), c.getReplyContent(), c.getAdminNote(), c.getRepliedAt(),
                c.getCreatedAt());
    }
}
