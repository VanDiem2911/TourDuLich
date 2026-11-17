package com.tourdulich.dto.booking;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import java.math.BigDecimal;

/**
 * Payload kiểu SePay: id, gateway, transferAmount, content, accountNumber, transactionDate.
 * transferType là "in" (tiền vào) hoặc "out" (tiền ra); thiếu trường này thì coi như tiền vào.
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public record WebhookPayload(
        String id,
        String gateway,
        BigDecimal transferAmount,
        String content,
        String accountNumber,
        String transactionDate,
        String transferType) {
}
