package com.tourdulich.tracking;

import com.tourdulich.security.UserPrincipal;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequiredArgsConstructor
public class TrackingController {

    private final TrackingService trackingService;

    /**
     * Công khai: Guest cũng gửi được. Nếu request kèm JWT hợp lệ thì gắn user_id (principal != null),
     * nếu không thì sự kiện chỉ có định danh ẩn danh.
     */
    @PostMapping("/api/tracking/events")
    public ResponseEntity<Void> events(@AuthenticationPrincipal UserPrincipal principal,
                                       @RequestBody TrackingService.Batch batch) {
        trackingService.record(batch, principal == null ? null : principal.id());
        return ResponseEntity.status(HttpStatus.NO_CONTENT).build();
    }

    /** Thống kê hành vi cho admin (nằm dưới /api/admin/** nên yêu cầu ROLE_ADMIN). */
    @GetMapping("/api/admin/tracking/summary")
    public Map<String, Object> summary(@RequestParam(defaultValue = "7") int days) {
        return trackingService.summary(days);
    }
}
