package com.tourdulich.service;

import com.tourdulich.dto.admin.TourRequest;
import com.tourdulich.dto.common.PageResponse;
import com.tourdulich.dto.tour.TourDetail;
import com.tourdulich.dto.tour.TourSummary;
import com.tourdulich.entity.Category;
import com.tourdulich.entity.Tour;
import com.tourdulich.entity.enums.TourStatus;
import com.tourdulich.exception.ApiException;
import com.tourdulich.repository.BookingItemRepository;
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

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/** Quản lý tour du lịch (UC-12). */
@Service
@RequiredArgsConstructor
public class AdminTourService {

    static final String ERR_DUP_CODE = "Mã tour đã tồn tại trong hệ thống, vui lòng nhập mã tour khác!";

    private final TourRepository tourRepository;
    private final CategoryRepository categoryRepository;
    private final BookingItemRepository bookingItemRepository;
    private final TourService tourService;

    @Transactional(readOnly = true)
    public PageResponse<TourSummary> list(int page, int size, String keyword, Long categoryId, TourStatus status) {
        Specification<Tour> spec = (root, q, cb) -> {
            List<Predicate> ps = new ArrayList<>();
            if (categoryId != null) {
                ps.add(cb.equal(root.get("category").get("id"), categoryId));
            }
            if (status != null) {
                ps.add(cb.equal(root.get("status"), status));
            }
            TourService.addKeyword(ps, root, cb, keyword);
            return cb.and(ps.toArray(new Predicate[0]));
        };
        Page<Tour> result = tourRepository.findAll(spec,
                Pages.of(page, size, Sort.by(Sort.Order.desc("createdAt"), Sort.Order.desc("id"))));
        return PageResponse.of(result, result.getContent().stream().map(TourMapper::toSummary).toList());
    }

    @Transactional(readOnly = true)
    public TourDetail get(Long id) {
        Tour t = tourRepository.findWithCategoryById(id)
                .orElseThrow(() -> ApiException.notFound("Không tìm thấy tour du lịch"));
        return tourService.toDetailWithRelated(t);
    }

    @Transactional
    public TourDetail create(TourRequest req) {
        String code = req.tourCode().trim();
        if (tourRepository.existsByTourCodeIgnoreCase(code)) {
            throw duplicateCode();
        }
        Tour t = new Tour();
        apply(t, req, code);
        t.setAvailableSeats(req.totalSeats());
        t.setStatus(req.status() == null ? TourStatus.ACTIVE : req.status());
        tourRepository.saveAndFlush(t);
        return tourService.toDetailWithRelated(t);
    }

    @Transactional
    public TourDetail update(Long id, TourRequest req) {
        // Khóa dòng tour để tính lại chỗ trống không bị đè bởi đơn đặt đồng thời
        Tour t = tourRepository.lockById(id)
                .orElseThrow(() -> ApiException.notFound("Không tìm thấy tour du lịch"));
        String code = req.tourCode().trim();
        if (tourRepository.existsByTourCodeIgnoreCaseAndIdNot(code, id)) {
            throw duplicateCode();
        }
        int booked = t.getTotalSeats() - t.getAvailableSeats();
        int available = req.totalSeats() - booked;
        if (available < 0) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "Dữ liệu không hợp lệ", Map.of("totalSeats",
                    "Tổng số chỗ không được nhỏ hơn số chỗ đã đặt (" + booked + ")"));
        }
        apply(t, req, code);
        t.setAvailableSeats(available);
        if (req.status() != null) {
            t.setStatus(req.status());
        }
        tourRepository.saveAndFlush(t);
        return tourService.toDetailWithRelated(t);
    }

    @Transactional
    public TourSummary updateStatus(Long id, TourStatus status) {
        Tour t = tourRepository.findWithCategoryById(id)
                .orElseThrow(() -> ApiException.notFound("Không tìm thấy tour du lịch"));
        t.setStatus(status);
        tourRepository.save(t);
        return TourMapper.toSummary(t);
    }

    @Transactional
    public void delete(Long id) {
        Tour t = tourRepository.findById(id)
                .orElseThrow(() -> ApiException.notFound("Không tìm thấy tour du lịch"));
        if (bookingItemRepository.existsByTourId(id)) {
            throw ApiException.conflict(
                    "Tour này đã có khách đặt chỗ, không được phép xóa để đảm bảo toàn vẹn dữ liệu đơn hàng!");
        }
        tourRepository.delete(t);
    }

    private void apply(Tour t, TourRequest req, String code) {
        Category category = categoryRepository.findById(req.categoryId())
                .orElseThrow(() -> new ApiException(HttpStatus.BAD_REQUEST, "Dữ liệu không hợp lệ",
                        Map.of("categoryId", "Danh mục không tồn tại")));
        t.setCategory(category);
        t.setTourCode(code);
        t.setName(req.name().trim());
        t.setDepartureLocation(Texts.blankToNull(req.departureLocation()));
        t.setDestination(Texts.blankToNull(req.destination()));
        t.setDuration(Texts.blankToNull(req.duration()));
        t.setTransport(Texts.blankToNull(req.transport()));
        t.setDepartureDate(req.departureDate());
        t.setAdultPrice(req.adultPrice());
        t.setChildPrice(req.childPrice());
        t.setTotalSeats(req.totalSeats());
        t.setImageUrl(Texts.blankToNull(req.imageUrl()));
        t.setShortDescription(Texts.blankToNull(req.shortDescription()));
        t.setItinerary(Texts.blankToNull(req.itinerary()));
    }

    private static ApiException duplicateCode() {
        return new ApiException(HttpStatus.CONFLICT, ERR_DUP_CODE, Map.of("tourCode", ERR_DUP_CODE));
    }
}
