package com.tourdulich.repository;

import com.tourdulich.dto.admin.TopTour;
import com.tourdulich.entity.BookingItem;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Collection;
import java.util.List;

public interface BookingItemRepository extends JpaRepository<BookingItem, Long> {

    boolean existsByTourId(Long tourId);

    @Query("select i from BookingItem i join fetch i.tour where i.booking.id in :ids order by i.id")
    List<BookingItem> findByBookingIds(@Param("ids") Collection<Long> ids);

    /** Top tour theo số chỗ đã đặt (bỏ qua đơn đã hủy). */
    @Query("select new com.tourdulich.dto.admin.TopTour(i.tour.id, i.tour.name, "
            + "sum(i.adultQuantity + i.childQuantity), sum(i.subtotal)) "
            + "from BookingItem i where i.booking.bookingStatus <> com.tourdulich.entity.enums.BookingStatus.CANCELLED "
            + "group by i.tour.id, i.tour.name "
            + "order by sum(i.adultQuantity + i.childQuantity) desc, sum(i.subtotal) desc")
    List<TopTour> findTopTours(Pageable pageable);
}
