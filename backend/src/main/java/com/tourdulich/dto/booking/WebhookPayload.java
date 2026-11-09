package com.tourdulich.dto.booking;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import java.math.BigDecimal;

/** Payload kiểu SePay: id, gateway, transferAmount, content, accountNumber, transactionDate. */
@JsonIgnoreProperties(ignoreUnknown = true)
public record WebhookPayload(
        String id,
        String gateway,
        BigDecimal transferAmount,
        String content,
        String accountNumber,
        String transactionDate) {
}
