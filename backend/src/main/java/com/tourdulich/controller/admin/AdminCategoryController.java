package com.tourdulich.controller.admin;

import com.tourdulich.dto.admin.AdminCategoryResponse;
import com.tourdulich.dto.admin.CategoryOption;
import com.tourdulich.dto.admin.CategoryRequest;
import com.tourdulich.dto.common.PageResponse;
import com.tourdulich.entity.enums.CategoryStatus;
import com.tourdulich.service.AdminCategoryService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/admin/categories")
@RequiredArgsConstructor
public class AdminCategoryController {

    private final AdminCategoryService service;

    @GetMapping
    public PageResponse<AdminCategoryResponse> list(@RequestParam(defaultValue = "1") int page,
                                                    @RequestParam(defaultValue = "10") int size,
                                                    @RequestParam(required = false) String keyword,
                                                    @RequestParam(required = false) CategoryStatus status) {
        return service.list(page, size, keyword, status);
    }

    @GetMapping("/options")
    public List<CategoryOption> options() {
        return service.options();
    }

    @PostMapping
    public ResponseEntity<AdminCategoryResponse> create(@Valid @RequestBody CategoryRequest req) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(req));
    }

    @PutMapping("/{id}")
    public AdminCategoryResponse update(@PathVariable Long id, @Valid @RequestBody CategoryRequest req) {
        return service.update(id, req);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }
}
