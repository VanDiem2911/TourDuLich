package com.tourdulich.controller;

import com.tourdulich.dto.booking.PaymentInfo;
import com.tourdulich.dto.booking.SimulatePaymentRequest;
import com.tourdulich.dto.booking.WebhookPayload;
import com.tourdulich.security.UserPrincipal;
import com.tourdulich.service.PaymentService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/payments")
@RequiredArgsConstructor
public class PaymentController {

    private final PaymentService paymentService;

    /** Giả lập thanh toán thành công (demo); chỉ chạy khi app.payment.simulate-enabled=true. */
    @PostMapping("/simulate")
    public PaymentInfo simulate(@AuthenticationPrincipal UserPrincipal principal,
                                @Valid @RequestBody SimulatePaymentRequest req) {
        return paymentService.simulate(principal, req.bookingId());
    }

    /** Webhook ngân hàng kiểu SePay: công khai nhưng bắt buộc header "Authorization: Apikey <khóa>". */
    @PostMapping("/webhook")
    public Map<String, Object> webhook(@RequestHeader(value = "Authorization", required = false) String authorization,
                                       @RequestBody WebhookPayload payload) {
        paymentService.verifyWebhookKey(authorization);
        PaymentService.WebhookResult result = paymentService.handleWebhook(payload);
        return Map.of("success", result.success(), "status", result.status());
    }
}
