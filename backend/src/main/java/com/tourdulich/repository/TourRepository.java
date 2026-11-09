package com.tourdulich.repository;

import com.tourdulich.entity.Tour;
import com.tourdulich.entity.enums.TourStatus;
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

import java.time.LocalDateTime;
import java.util.Collection;
import java.util.List;
import java.util.Optional;

public interface TourRepository extends JpaRepository<Tour, Long>, JpaSpecificationExecutor<Tour> {

    boolean existsByTourCodeIgnoreCase(String tourCode);

    boolean existsByTourCodeIgnoreCaseAndIdNot(String tourCode, Long id);

    boolean existsByCategoryId(Long categoryId);

    long countByStatus(TourStatus status);

    /** Nạp sẵn danh mục để tránh N+1 khi map sang DTO. */
    @Override
    @EntityGraph(attributePaths = "category")
    Page<Tour> findAll(Specification<Tour> spec, Pageable pageable);

    @Query("select t from Tour t join fetch t.category where t.id = :id")
    Optional<Tour> findWithCategoryById(@Param("id") Long id);

    /** Khóa ghi các dòng tour (theo thứ tự id để tránh deadlock) khi đặt/hủy tour. */
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select t from Tour t where t.id in :ids order by t.id")
    List<Tour> lockAllByIdIn(@Param("ids") Collection<Long> ids);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select t from Tour t where t.id = :id")
    Optional<Tour> lockById(@Param("id") Long id);

    @Query("select t from Tour t join fetch t.category "
            + "where t.status = com.tourdulich.entity.enums.TourStatus.ACTIVE and t.availableSeats > 0 "
            + "and t.departureDate >= :now order by t.departureDate asc, t.id asc")
    List<Tour> findFeatured(@Param("now") LocalDateTime now, Pageable pageable);

    @Query("select t from Tour t join fetch t.category "
            + "where t.status = com.tourdulich.entity.enums.TourStatus.ACTIVE "
            + "and t.category.id = :categoryId and t.id <> :excludeId "
            + "order by t.departureDate asc, t.id asc")
    List<Tour> findRelated(@Param("categoryId") Long categoryId, @Param("excludeId") Long excludeId, Pageable pageable);

    @Query("select t from Tour t where t.status = com.tourdulich.entity.enums.TourStatus.ACTIVE "
            + "and t.destination is not null and t.destination <> '' order by t.id")
    List<Tour> findActiveWithDestination();

    @Query("select t from Tour t join fetch t.category "
            + "where t.status = com.tourdulich.entity.enums.TourStatus.ACTIVE and t.availableSeats <= :max "
            + "order by t.availableSeats asc, t.departureDate asc")
    List<Tour> findLowSeats(@Param("max") int max, Pageable pageable);

    /** Số tour ACTIVE theo danh mục: [categoryId, count]. */
    @Query("select t.category.id, count(t) from Tour t "
            + "where t.status = com.tourdulich.entity.enums.TourStatus.ACTIVE group by t.category.id")
    List<Object[]> countActiveGroupedByCategory();

    /** Tổng số tour (mọi trạng thái) theo danh mục: [categoryId, count]. */
    @Query("select t.category.id, count(t) from Tour t where t.category.id in :ids group by t.category.id")
    List<Object[]> countGroupedByCategoryIds(@Param("ids") Collection<Long> ids);
}
