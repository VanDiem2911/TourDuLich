package com.tourdulich.service;

import org.junit.jupiter.api.Test;

import java.time.LocalDate;
import java.time.LocalDateTime;

import static org.junit.jupiter.api.Assertions.assertEquals;

class DashboardPeriodTest {

    // Thứ Ba 10/11/2026
    private static final LocalDate TODAY = LocalDate.of(2026, 11, 10);

    @Test
    void periodStartsAtExpectedBoundary() {
        assertEquals(LocalDateTime.of(2026, 11, 10, 0, 0), DashboardService.periodStart("today", TODAY));
        assertEquals(LocalDateTime.of(2026, 11, 9, 0, 0), DashboardService.periodStart("week", TODAY)); // thứ Hai
        assertEquals(LocalDateTime.of(2026, 11, 1, 0, 0), DashboardService.periodStart("month", TODAY));
        assertEquals(LocalDateTime.of(2026, 1, 1, 0, 0), DashboardService.periodStart("year", TODAY));
    }

    @Test
    void unknownOrMissingPeriodMeansAll() {
        LocalDateTime all = LocalDateTime.of(2000, 1, 1, 0, 0);
        assertEquals(all, DashboardService.periodStart("all", TODAY));
        assertEquals(all, DashboardService.periodStart(null, TODAY));
        assertEquals(all, DashboardService.periodStart("bogus", TODAY));
        assertEquals(LocalDateTime.of(2026, 11, 10, 0, 0), DashboardService.periodStart(" TODAY ", TODAY));
    }

    @Test
    void weekStartOnMondayIsTheSameDay() {
        assertEquals(LocalDateTime.of(2026, 11, 9, 0, 0), DashboardService.periodStart("week", LocalDate.of(2026, 11, 9)));
        assertEquals(LocalDateTime.of(2026, 11, 9, 0, 0), DashboardService.periodStart("week", LocalDate.of(2026, 11, 15))); // Chủ nhật
    }
}
