package com.tourdulich.service;

import com.tourdulich.dto.common.PageResponse;
import com.tourdulich.dto.tour.CategoryResponse;
import com.tourdulich.dto.tour.DestinationResponse;
import com.tourdulich.dto.tour.TourDetail;
import com.tourdulich.dto.tour.TourSummary;
import com.tourdulich.entity.Category;
import com.tourdulich.entity.Tour;
import com.tourdulich.entity.enums.CategoryStatus;
import com.tourdulich.entity.enums.TourRegion;
import com.tourdulich.entity.enums.TourStatus;
import com.tourdulich.exception.ApiException;
import com.tourdulich.repository.CategoryRepository;
import com.tourdulich.repository.TourRepository;
import com.tourdulich.util.Pages;
import com.tourdulich.util.Texts;
import jakarta.persistence.criteria.Predicate;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;

/** Xem danh sách / chi tiết tour và danh mục phía công khai (chỉ dữ liệu ACTIVE). */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class TourService {

    public static final String TOUR_NOT_FOUND = "Tour du lịch không tồn tại hoặc đã ngừng mở bán!";

    private final TourRepository tourRepository;
    private final CategoryRepository categoryRepository;

    public List<CategoryResponse> listCategories(TourRegion region) {
        Map<Long, Long> counts = new HashMap<>();
        List<Object[]> rows = region == null
                ? tourRepository.countActiveGroupedByCategory()
                : tourRepository.countActiveGroupedByCategoryAndRegion(region);
        for (Object[] row : rows) {
            counts.put((Long) row[0], (Long) row[1]);
        }
        return categoryRepository.findByStatusOrderByNameAsc(CategoryStatus.ACTIVE).stream()
                .map(c -> new CategoryResponse(c.getId(), c.getName(), c.getDescription(),
                        counts.getOrDefault(c.getId(), 0L)))
                .toList();
    }

    public PageResponse<TourSummary> search(int page, int size, String keyword, Long categoryId, String destination,
                                            TourRegion region, BigDecimal minPrice, BigDecimal maxPrice,
                                            LocalDate departureFrom, LocalDate departureTo, String sort) {
        Specification<Tour> spec = (root, query, cb) -> {
            List<Predicate> ps = new ArrayList<>();
            ps.add(cb.equal(root.get("status"), TourStatus.ACTIVE));
            if (categoryId != null) {
                ps.add(cb.equal(root.get("category").get("id"), categoryId));
            }
            if (region != null) {
                ps.add(cb.equal(root.get("region"), region));
            }
            if (destination != null && !destination.isBlank()) {
                ps.add(cb.equal(cb.lower(root.get("destination")), destination.trim().toLowerCase()));
            }
            if (minPrice != null) {
                ps.add(cb.greaterThanOrEqualTo(root.get("adultPrice"), minPrice));
            }
            if (maxPrice != null) {
                ps.add(cb.lessThanOrEqualTo(root.get("adultPrice"), maxPrice));
            }
            if (departureFrom != null) {
                ps.add(cb.greaterThanOrEqualTo(root.get("departureDate"), departureFrom.atStartOfDay()));
            }
            if (departureTo != null) {
                ps.add(cb.lessThan(root.get("departureDate"), departureTo.plusDays(1).atStartOfDay()));
            }
            addKeyword(ps, root, cb, keyword);
            return cb.and(ps.toArray(new Predicate[0]));
        };
        Pageable pageable = Pages.of(page, size, toSort(sort));
        Page<Tour> result = tourRepository.findAll(spec, pageable);
        return PageResponse.of(result, result.getContent().stream().map(TourMapper::toSummary).toList());
    }

    /** Tìm theo tên, điểm đến, mã tour. Ký tự đặc biệt của LIKE được thoát; tham số luôn được bind (không nối chuỗi SQL). */
    static void addKeyword(List<Predicate> ps, jakarta.persistence.criteria.Root<Tour> root,
                           jakarta.persistence.criteria.CriteriaBuilder cb, String keyword) {
        if (keyword == null || keyword.isBlank()) {
            return;
        }
        String pattern = Texts.likePattern(keyword);
        ps.add(cb.or(
                cb.like(cb.lower(root.get("name")), pattern, '\\'),
                cb.like(cb.lower(root.get("destination")), pattern, '\\'),
                cb.like(cb.lower(root.get("tourCode")), pattern, '\\')));
    }

    private static Sort toSort(String sort) {
        String s = sort == null ? "newest" : sort;
        return switch (s) {
            case "priceAsc" -> Sort.by(Sort.Order.asc("adultPrice"), Sort.Order.desc("id"));
            case "priceDesc" -> Sort.by(Sort.Order.desc("adultPrice"), Sort.Order.desc("id"));
            case "departureAsc" -> Sort.by(Sort.Order.asc("departureDate"), Sort.Order.asc("id"));
            default -> Sort.by(Sort.Order.desc("createdAt"), Sort.Order.desc("id"));
        };
    }

    public List<TourSummary> featured(int limit) {
        int n = Math.min(Math.max(limit, 1), 24);
        return tourRepository.findFeatured(LocalDateTime.now(), PageRequest.of(0, n)).stream()
                .map(TourMapper::toSummary).toList();
    }

    public List<DestinationResponse> destinations() {
        Map<String, DestinationAcc> acc = new LinkedHashMap<>();
        for (Tour t : tourRepository.findActiveWithDestination()) {
            DestinationAcc a = acc.computeIfAbsent(t.getDestination().trim(), k -> new DestinationAcc());
            a.count++;
            if (a.imageUrl == null && t.getImageUrl() != null && !t.getImageUrl().isBlank()) {
                a.imageUrl = t.getImageUrl();
            }
        }
        return acc.entrySet().stream()
                .map(e -> new DestinationResponse(e.getKey(), e.getValue().count, e.getValue().imageUrl))
                .sorted(Comparator.comparingLong(DestinationResponse::tourCount).reversed()
                        .thenComparing(DestinationResponse::destination))
                .toList();
    }

    private static final class DestinationAcc {
        long count;
        String imageUrl;
    }

    public TourDetail detail(Long id) {
        Tour tour = tourRepository.findWithCategoryById(id)
                .filter(t -> t.getStatus() == TourStatus.ACTIVE)
                .orElseThrow(() -> ApiException.notFound(TOUR_NOT_FOUND));
        return toDetailWithRelated(tour);
    }

    /** Dùng chung cho cả trang admin (không cần ACTIVE). */
    public TourDetail toDetailWithRelated(Tour tour) {
        Category category = tour.getCategory();
        List<TourSummary> related = tourRepository
                .findRelated(category.getId(), tour.getId(), PageRequest.of(0, 3)).stream()
                .map(TourMapper::toSummary).toList();
        return TourMapper.toDetail(tour, related);
    }
}
