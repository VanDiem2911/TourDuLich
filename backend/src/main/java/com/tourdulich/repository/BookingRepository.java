package com.tourdulich.repository;

import com.tourdulich.dto.admin.BookingStat;
import com.tourdulich.entity.Booking;
import com.tourdulich.entity.enums.BookingStatus;
import com.tourdulich.entity.enums.PaymentStatus;
import jakarta.persistence.LockModeType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Collection;
import java.util.List;
import java.util.Optional;

public interface BookingRepository extends JpaRepository<Booking, Long>, JpaSpecificationExecutor<Booking> {

    boolean existsByUserId(Long userId);

    boolean existsByBookingCode(String bookingCode);

    boolean existsByPaymentCode(String paymentCode);

    long countByBookingCodeStartingWith(String prefix);

    long countByBookingStatus(BookingStatus status);

    @EntityGraph(attributePaths = "user")
    Optional<Booking> findWithUserByPaymentCode(String paymentCode);

    @EntityGraph(attributePaths = "user")
    Optional<Booking> findWithUserById(Long id);

    @EntityGraph(attributePaths = "user")
    Optional<Booking> findWithUserByIdAndUserId(Long id, Long userId);

    @Override
    @EntityGraph(attributePaths = "user")
    Page<Booking> findAll(Specification<Booking> spec, Pageable pageable);

    @EntityGraph(attributePaths = "user")
    List<Booking> findTop8ByOrderByCreatedAtDescIdDesc();

    /** Khóa ghi dòng booking khi hủy / đổi trạng thái / ghi nhận thanh toán. */
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select b from Booking b join fetch b.user where b.id = :id")
    Optional<Booking> lockById(@Param("id") Long id);

    /** Doanh thu / số đơn trong khoảng thời gian (theo ngày đặt) cho bộ lọc Dashboard. */
    @Query("select sum(b.totalAmount) from Booking b where b.paymentStatus = :status and b.createdAt >= :from")
    BigDecimal sumTotalAmountByPaymentStatusSince(@Param("status") PaymentStatus status, @Param("from") LocalDateTime from);

    @Query("select b.bookingStatus, count(b) from Booking b where b.createdAt >= :from group by b.bookingStatus")
    List<Object[]> countGroupedByStatusSince(@Param("from") LocalDateTime from);

    @EntityGraph(attributePaths = "user")
    List<Booking> findTop8ByCreatedAtGreaterThanEqualOrderByCreatedAtDescIdDesc(LocalDateTime from);

    @Query("select sum(b.totalAmount) from Booking b where b.paymentStatus = :status")
    BigDecimal sumTotalAmountByPaymentStatus(@Param("status") PaymentStatus status);

    /** [bookingStatus, count]. */
    @Query("select b.bookingStatus, count(b) from Booking b group by b.bookingStatus")
    List<Object[]> countGroupedByStatus();

    @Query("select new com.tourdulich.dto.admin.BookingStat(b.createdAt, b.totalAmount, b.paymentStatus, b.bookingStatus) "
            + "from Booking b where b.createdAt >= :from")
    List<BookingStat> findStatsSince(@Param("from") LocalDateTime from);

    /** [userId, count]. */
    @Query("select b.user.id, count(b) from Booking b where b.user.id in :ids group by b.user.id")
    List<Object[]> countGroupedByUserIds(@Param("ids") Collection<Long> ids);
}
