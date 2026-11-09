package com.tourdulich.repository;

import com.tourdulich.entity.PaymentTransaction;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PaymentTransactionRepository extends JpaRepository<PaymentTransaction, Long> {

    boolean existsByTransactionRef(String transactionRef);
}
