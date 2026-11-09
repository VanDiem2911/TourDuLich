package com.tourdulich.repository;

import com.tourdulich.entity.Contact;
import com.tourdulich.entity.enums.ContactStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;

import java.time.LocalDateTime;

public interface ContactRepository extends JpaRepository<Contact, Long>, JpaSpecificationExecutor<Contact> {

    long countByStatus(ContactStatus status);

    long countByEmailIgnoreCaseAndCreatedAtAfter(String email, LocalDateTime after);
}
