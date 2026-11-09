package com.tourdulich.controller;

import com.tourdulich.dto.cart.CartItemRequest;
import com.tourdulich.dto.cart.CartQuantityRequest;
import com.tourdulich.dto.cart.CartResponse;
import com.tourdulich.service.CartService;
import jakarta.servlet.http.HttpSession;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

/** Giỏ tour lưu trong HTTP Session. Mọi API trả về toàn bộ giỏ. */
@RestController
@RequestMapping("/api/cart")
@RequiredArgsConstructor
public class CartController {

    private final CartService cartService;

    @GetMapping
    public CartResponse get(HttpSession session) {
        return cartService.get(session);
    }

    @PostMapping("/items")
    public CartResponse add(@Valid @RequestBody CartItemRequest req, HttpSession session) {
        int child = req.childQuantity() == null ? 0 : req.childQuantity();
        return cartService.add(session, req.tourId(), req.adultQuantity(), child);
    }

    @PutMapping("/items/{tourId}")
    public CartResponse update(@PathVariable Long tourId, @Valid @RequestBody CartQuantityRequest req,
                               HttpSession session) {
        int child = req.childQuantity() == null ? 0 : req.childQuantity();
        return cartService.update(session, tourId, req.adultQuantity(), child);
    }

    @DeleteMapping("/items/{tourId}")
    public CartResponse remove(@PathVariable Long tourId, HttpSession session) {
        return cartService.remove(session, tourId);
    }

    @DeleteMapping
    public CartResponse clear(HttpSession session) {
        return cartService.clear(session);
    }
}
