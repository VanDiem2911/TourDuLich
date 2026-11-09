package com.tourdulich.service;

import com.tourdulich.dto.booking.BookingDetail;
import com.tourdulich.dto.booking.BookingItemResponse;
import com.tourdulich.dto.booking.BookingSummary;
import com.tourdulich.entity.Booking;
import com.tourdulich.entity.BookingItem;
import com.tourdulich.entity.enums.BookingStatus;
import com.tourdulich.repository.BookingItemRepository;
import com.tourdulich.util.Money;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/** Chuyển Booking sang DTO. Gọi trong transaction (đọc user/tour lazy). */
@Component
@RequiredArgsConstructor
public class BookingMapper {

    private final BookingItemRepository itemRepository;

    /** Danh sách tóm tắt; nạp item của cả trang bằng 1 truy vấn. admin=true thì kèm tên/email khách. */
    public List<BookingSummary> toSummaries(Collection<Booking> bookings, boolean admin) {
        if (bookings.isEmpty()) {
            return List.of();
        }
        Map<Long, List<BookingItem>> byBooking = new HashMap<>();
        itemRepository.findByBookingIds(bookings.stream().map(Booking::getId).toList())
                .forEach(i -> byBooking.computeIfAbsent(i.getBooking().getId(), k -> new java.util.ArrayList<>()).add(i));
        return bookings.stream()
                .map(b -> toSummary(b, byBooking.getOrDefault(b.getId(), List.of()), admin))
                .toList();
    }

    public BookingSummary toSummary(Booking b, List<BookingItem> items, boolean admin) {
        BookingItem first = items.isEmpty() ? null : items.get(0);
        return new BookingSummary(
                b.getId(), b.getBookingCode(), b.getCreatedAt(), Money.vnd(b.getTotalAmount()),
                b.getPaymentStatus(), b.getBookingStatus(), items.size(),
                first == null ? null : first.getTourName(),
                first == null ? null : first.getTour().getImageUrl(),
                admin ? b.getUser().getFullName() : null,
                admin ? b.getUser().getEmail() : null);
    }

    public BookingDetail toDetail(Booking b, boolean admin) {
        List<BookingItem> items = itemRepository.findByBookingIds(List.of(b.getId()));
        return toDetail(b, items, admin);
    }

    public BookingDetail toDetail(Booking b, List<BookingItem> items, boolean admin) {
        BookingItem first = items.isEmpty() ? null : items.get(0);
        List<BookingItemResponse> itemDtos = items.stream().map(i -> new BookingItemResponse(
                i.getTour().getId(), i.getTourName(), i.getTour().getImageUrl(), i.getDepartureDate(),
                Money.vnd(i.getAdultPrice()),
                Money.vnd(i.getChildPrice() != null ? i.getChildPrice() : i.getAdultPrice()),
                i.getAdultQuantity(), i.getChildQuantity(), Money.vnd(i.getSubtotal()))).toList();
        // Khách chỉ tự hủy khi PENDING; admin hủy được cho tới khi COMPLETED
        boolean canCancel = b.getBookingStatus() == BookingStatus.PENDING
                || (admin && b.getBookingStatus() == BookingStatus.CONFIRMED);
        return new BookingDetail(
                b.getId(), b.getBookingCode(), b.getCreatedAt(), Money.vnd(b.getTotalAmount()),
                b.getPaymentStatus(), b.getBookingStatus(), items.size(),
                first == null ? null : first.getTourName(),
                first == null ? null : first.getTour().getImageUrl(),
                admin ? b.getUser().getFullName() : null,
                admin ? b.getUser().getEmail() : null,
                b.getContactName(), b.getContactPhone(), b.getContactEmail(), b.getSpecialRequest(),
                b.getPaymentMethod(), b.getPaidAt(), b.getCancelReason(), canCancel, itemDtos);
    }
}
