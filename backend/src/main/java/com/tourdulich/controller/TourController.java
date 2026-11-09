package com.tourdulich.controller;

import com.tourdulich.dto.common.PageResponse;
import com.tourdulich.dto.tour.CategoryResponse;
import com.tourdulich.dto.tour.DestinationResponse;
import com.tourdulich.dto.tour.TourDetail;
import com.tourdulich.dto.tour.TourSummary;
import com.tourdulich.service.TourService;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

/** API công khai: tour và danh mục. */
@RestController
@RequiredArgsConstructor
public class TourController {

    private final TourService tourService;

    @GetMapping("/api/categories")
    public List<CategoryResponse> categories() {
        return tourService.listCategories();
    }

    @GetMapping("/api/tours")
    public PageResponse<TourSummary> search(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "9") int size,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) Long categoryId,
            @RequestParam(required = false) String destination,
            @RequestParam(required = false) BigDecimal minPrice,
            @RequestParam(required = false) BigDecimal maxPrice,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate departureFrom,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate departureTo,
            @RequestParam(defaultValue = "newest") String sort) {
        return tourService.search(page, size, keyword, categoryId, destination, minPrice, maxPrice,
                departureFrom, departureTo, sort);
    }

    @GetMapping("/api/tours/featured")
    public List<TourSummary> featured(@RequestParam(defaultValue = "6") int limit) {
        return tourService.featured(limit);
    }

    @GetMapping("/api/tours/destinations")
    public List<DestinationResponse> destinations() {
        return tourService.destinations();
    }

    @GetMapping("/api/tours/{id}")
    public TourDetail detail(@PathVariable Long id) {
        return tourService.detail(id);
    }
}
