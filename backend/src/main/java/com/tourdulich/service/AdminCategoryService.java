package com.tourdulich.service;

import com.tourdulich.dto.admin.AdminCategoryResponse;
import com.tourdulich.dto.admin.CategoryOption;
import com.tourdulich.dto.admin.CategoryRequest;
import com.tourdulich.dto.common.PageResponse;
import com.tourdulich.entity.Category;
import com.tourdulich.entity.enums.CategoryStatus;
import com.tourdulich.exception.ApiException;
import com.tourdulich.repository.CategoryRepository;
import com.tourdulich.repository.TourRepository;
import com.tourdulich.util.Pages;
import com.tourdulich.util.Texts;
import jakarta.persistence.criteria.Predicate;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;

/** Quản lý danh mục tour (UC-11). */
@Service
@RequiredArgsConstructor
public class AdminCategoryService {

    static final String ERR_DUPLICATE = "Tên danh mục đã tồn tại, vui lòng nhập tên khác!";

    private final CategoryRepository categoryRepository;
    private final TourRepository tourRepository;

    @Transactional(readOnly = true)
    public PageResponse<AdminCategoryResponse> list(int page, int size, String keyword, CategoryStatus status) {
        Specification<Category> spec = (root, q, cb) -> {
            List<Predicate> ps = new ArrayList<>();
            if (status != null) {
                ps.add(cb.equal(root.get("status"), status));
            }
            if (keyword != null && !keyword.isBlank()) {
                ps.add(cb.like(cb.lower(root.get("name")), Texts.likePattern(keyword), '\\'));
            }
            return cb.and(ps.toArray(new Predicate[0]));
        };
        Page<Category> result = categoryRepository.findAll(spec,
                Pages.of(page, size, Sort.by(Sort.Order.desc("createdAt"), Sort.Order.desc("id"))));
        Map<Long, Long> counts = new HashMap<>();
        if (!result.isEmpty()) {
            for (Object[] row : tourRepository.countGroupedByCategoryIds(
                    result.getContent().stream().map(Category::getId).toList())) {
                counts.put((Long) row[0], (Long) row[1]);
            }
        }
        return PageResponse.of(result, result.getContent().stream()
                .map(c -> toResponse(c, counts.getOrDefault(c.getId(), 0L))).toList());
    }

    @Transactional(readOnly = true)
    public List<CategoryOption> options() {
        return categoryRepository.findAllByOrderByNameAsc().stream()
                .map(c -> new CategoryOption(c.getId(), c.getName(), c.getStatus())).toList();
    }

    @Transactional
    public AdminCategoryResponse create(CategoryRequest req) {
        String name = req.name().trim();
        if (categoryRepository.existsByNameIgnoreCase(name)) {
            throw duplicate();
        }
        Category c = new Category();
        apply(c, req, name);
        c.setStatus(req.status() == null ? CategoryStatus.ACTIVE : req.status());
        return toResponse(categoryRepository.save(c), 0);
    }

    @Transactional
    public AdminCategoryResponse update(Long id, CategoryRequest req) {
        Category c = find(id);
        String name = req.name().trim();
        if (categoryRepository.existsByNameIgnoreCaseAndIdNot(name, id)) {
            throw duplicate();
        }
        apply(c, req, name);
        if (req.status() != null) {
            c.setStatus(req.status());
        }
        categoryRepository.save(c);
        long count = 0;
        for (Object[] row : tourRepository.countGroupedByCategoryIds(List.of(id))) {
            count = (Long) row[1];
        }
        return toResponse(c, count);
    }

    @Transactional
    public void delete(Long id) {
        Category c = find(id);
        if (tourRepository.existsByCategoryId(id)) {
            throw ApiException.conflict("Không thể xóa danh mục đang có tour du lịch trực thuộc!");
        }
        categoryRepository.delete(c);
    }

    private Category find(Long id) {
        return categoryRepository.findById(id)
                .orElseThrow(() -> ApiException.notFound("Không tìm thấy danh mục"));
    }

    private static void apply(Category c, CategoryRequest req, String name) {
        c.setName(name);
        c.setDescription(Texts.blankToNull(req.description()));
    }

    private static ApiException duplicate() {
        return new ApiException(HttpStatus.CONFLICT, ERR_DUPLICATE, Map.of("name", ERR_DUPLICATE));
    }

    private static AdminCategoryResponse toResponse(Category c, long tourCount) {
        return new AdminCategoryResponse(c.getId(), c.getName(), c.getDescription(), c.getStatus(),
                tourCount, c.getCreatedAt());
    }
}
