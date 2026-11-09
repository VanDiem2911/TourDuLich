package com.tourdulich.service;

import com.tourdulich.dto.cart.CartItemResponse;
import com.tourdulich.dto.cart.CartResponse;
import com.tourdulich.entity.Tour;
import com.tourdulich.entity.enums.TourStatus;
import com.tourdulich.exception.ApiException;
import com.tourdulich.repository.TourRepository;
import com.tourdulich.util.Money;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Giỏ tour lưu trong HTTP Session (không lưu DB). Session chỉ giữ tourId + số vé;
 * tên, giá, số chỗ luôn đọc lại từ CSDL nên không tin dữ liệu từ client.
 */
@Service
@RequiredArgsConstructor
public class CartService {

    static final String SESSION_KEY = "TOUR_CART";
    static final String ERR_OVER_SEATS = "Số lượng vé yêu cầu vượt quá số chỗ còn trống của tour!";

    /** Một dòng trong giỏ (Serializable để Session có thể lưu/khôi phục). */
    public record CartLine(int adult, int child) implements Serializable {
        public int total() {
            return adult + child;
        }
    }

    private final TourRepository tourRepository;

    @Transactional(readOnly = true)
    public CartResponse get(HttpSession session) {
        return build(session);
    }

    @Transactional(readOnly = true)
    public CartResponse add(HttpSession session, Long tourId, int adult, int child) {
        Tour tour = requireActiveTour(tourId);
        Map<Long, CartLine> cart = cart(session);
        CartLine old = cart.get(tourId);
        int newAdult = adult + (old == null ? 0 : old.adult());
        int newChild = child + (old == null ? 0 : old.child());
        checkSeats(tour, newAdult, newChild);
        cart.put(tourId, new CartLine(newAdult, newChild));
        save(session, cart);
        return build(session);
    }

    @Transactional(readOnly = true)
    public CartResponse update(HttpSession session, Long tourId, int adult, int child) {
        Tour tour = requireActiveTour(tourId);
        Map<Long, CartLine> cart = cart(session);
        if (!cart.containsKey(tourId)) {
            throw ApiException.notFound("Tour này không có trong phiếu đặt tạm");
        }
        checkSeats(tour, adult, child);
        cart.put(tourId, new CartLine(adult, child));
        save(session, cart);
        return build(session);
    }

    public CartResponse remove(HttpSession session, Long tourId) {
        Map<Long, CartLine> cart = cart(session);
        cart.remove(tourId);
        save(session, cart);
        return build(session);
    }

    public CartResponse clear(HttpSession session) {
        session.removeAttribute(SESSION_KEY);
        return new CartResponse(List.of(), 0, 0);
    }

    /** Bản sao các dòng trong giỏ, dùng khi tạo đơn. */
    public Map<Long, CartLine> lines(HttpSession session) {
        return cart(session);
    }

    // ------------------------------------------------------------------

    private Tour requireActiveTour(Long tourId) {
        return tourRepository.findById(tourId)
                .filter(t -> t.getStatus() == TourStatus.ACTIVE)
                .orElseThrow(() -> ApiException.notFound(TourService.TOUR_NOT_FOUND));
    }

    private static void checkSeats(Tour tour, int adult, int child) {
        if (adult < 1) {
            throw ApiException.badRequest("Số vé người lớn phải từ 1 trở lên");
        }
        if (child < 0) {
            throw ApiException.badRequest("Số vé trẻ em không được âm");
        }
        if ((long) adult + child > tour.getAvailableSeats()) {
            throw ApiException.badRequest(ERR_OVER_SEATS);
        }
    }

    @SuppressWarnings("unchecked")
    private static Map<Long, CartLine> cart(HttpSession session) {
        Object o = session.getAttribute(SESSION_KEY);
        if (o instanceof Map<?, ?> m) {
            return new LinkedHashMap<>((Map<Long, CartLine>) m);
        }
        return new LinkedHashMap<>();
    }

    private static void save(HttpSession session, Map<Long, CartLine> cart) {
        if (cart.isEmpty()) {
            session.removeAttribute(SESSION_KEY);
        } else {
            session.setAttribute(SESSION_KEY, new LinkedHashMap<>(cart));
        }
    }

    /** Dựng giỏ từ DB; tour đã bị xóa/ngừng bán tự bị loại khỏi giỏ. */
    private CartResponse build(HttpSession session) {
        Map<Long, CartLine> cart = cart(session);
        if (cart.isEmpty()) {
            return new CartResponse(List.of(), 0, 0);
        }
        Map<Long, Tour> tours = new LinkedHashMap<>();
        tourRepository.findAllById(cart.keySet()).forEach(t -> tours.put(t.getId(), t));

        List<CartItemResponse> items = new ArrayList<>();
        long total = 0;
        boolean changed = false;
        for (Map.Entry<Long, CartLine> e : new ArrayList<>(cart.entrySet())) {
            Tour t = tours.get(e.getKey());
            if (t == null || t.getStatus() != TourStatus.ACTIVE) {
                cart.remove(e.getKey());
                changed = true;
                continue;
            }
            CartLine line = e.getValue();
            long adultPrice = Money.vnd(t.getAdultPrice());
            long childPrice = Money.vnd(TourMapper.effectiveChildPrice(t));
            long subtotal = adultPrice * line.adult() + childPrice * line.child();
            total += subtotal;
            items.add(new CartItemResponse(t.getId(), t.getTourCode(), t.getName(), t.getImageUrl(),
                    t.getDepartureDate(), t.getDuration(), adultPrice, childPrice,
                    line.adult(), line.child(), subtotal, t.getAvailableSeats()));
        }
        if (changed) {
            save(session, cart);
        }
        return new CartResponse(items, items.size(), total);
    }
}
