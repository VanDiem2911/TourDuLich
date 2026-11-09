package com.tourdulich.controller.admin;

import com.tourdulich.dto.admin.TourRequest;
import com.tourdulich.dto.admin.TourStatusRequest;
import com.tourdulich.dto.common.PageResponse;
import com.tourdulich.dto.tour.TourDetail;
import com.tourdulich.dto.tour.TourSummary;
import com.tourdulich.entity.enums.TourStatus;
import com.tourdulich.service.AdminTourService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/admin/tours")
@RequiredArgsConstructor
public class AdminTourController {

    private final AdminTourService service;

    @GetMapping
    public PageResponse<TourSummary> list(@RequestParam(defaultValue = "1") int page,
                                          @RequestParam(defaultValue = "10") int size,
                                          @RequestParam(required = false) String keyword,
                                          @RequestParam(required = false) Long categoryId,
                                          @RequestParam(required = false) TourStatus status) {
        return service.list(page, size, keyword, categoryId, status);
    }

    @GetMapping("/{id}")
    public TourDetail get(@PathVariable Long id) {
        return service.get(id);
    }

    @PostMapping
    public ResponseEntity<TourDetail> create(@Valid @RequestBody TourRequest req) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(req));
    }

    @PutMapping("/{id}")
    public TourDetail update(@PathVariable Long id, @Valid @RequestBody TourRequest req) {
        return service.update(id, req);
    }

    @PutMapping("/{id}/status")
    public TourSummary updateStatus(@PathVariable Long id, @Valid @RequestBody TourStatusRequest req) {
        return service.updateStatus(id, req.status());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }
}
