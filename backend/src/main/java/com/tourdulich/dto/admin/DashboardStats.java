package com.tourdulich.dto.admin;

import com.tourdulich.dto.booking.BookingSummary;
import com.tourdulich.dto.tour.TourSummary;

import java.util.List;
import java.util.Map;

public record DashboardStats(
        long totalActiveTours,
        long totalCategories,
        long totalCustomers,
        long totalBookings,
        long totalRevenue,
        long pendingBookings,
        long newContacts,
        List<MonthRevenue> revenueByMonth,
        Map<String, Long> bookingsByStatus,
        List<TopTour> topTours,
        List<BookingSummary> recentBookings,
        List<TourSummary> lowSeatTours) {
}
