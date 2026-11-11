package com.tourdulich.controller.admin;

import com.tourdulich.dto.admin.DashboardStats;
import com.tourdulich.service.DashboardService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/admin/dashboard")
@RequiredArgsConstructor
public class AdminDashboardController {

    private final DashboardService dashboardService;

    @GetMapping("/stats")
    public DashboardStats stats(@RequestParam(defaultValue = "all") String period) {
        return dashboardService.stats(period);
    }
}
