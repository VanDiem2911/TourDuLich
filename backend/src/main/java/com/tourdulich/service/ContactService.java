package com.tourdulich.service;

import com.tourdulich.config.AppProperties;
import com.tourdulich.dto.common.MessageResponse;
import com.tourdulich.dto.contact.ContactRequest;
import com.tourdulich.entity.Contact;
import com.tourdulich.exception.ApiException;
import com.tourdulich.repository.ContactRepository;
import com.tourdulich.util.Texts;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Locale;

/** Khách gửi liên hệ / yêu cầu tư vấn (UC-16). */
@Service
@RequiredArgsConstructor
public class ContactService {

    private static final int MAX_PER_EMAIL = 3;
    private static final int WINDOW_MINUTES = 10;

    private final ContactRepository contactRepository;
    private final MailService mailService;
    private final AppProperties props;

    @Transactional
    public MessageResponse submit(ContactRequest req, Long userId) {
        String email = req.email().trim().toLowerCase(Locale.ROOT);
        // Chống spam: cùng 1 email quá 3 liên hệ trong 10 phút
        long recent = contactRepository.countByEmailIgnoreCaseAndCreatedAtAfter(
                email, LocalDateTime.now().minusMinutes(WINDOW_MINUTES));
        if (recent >= MAX_PER_EMAIL) {
            throw new ApiException(HttpStatus.TOO_MANY_REQUESTS,
                    "Bạn đã gửi liên hệ, vui lòng chờ phản hồi trước khi gửi yêu cầu mới!");
        }
        Contact c = new Contact();
        c.setUserId(userId);
        c.setFullName(req.fullName().trim());
        c.setEmail(email);
        c.setPhone(Texts.blankToNull(req.phone()));
        c.setSubject(req.subject().trim());
        c.setMessage(req.message().trim());
        contactRepository.save(c);

        mailService.sendNewContactToAdmin(props.mail().adminEmail(), c.getFullName(), c.getEmail(),
                c.getSubject(), c.getMessage());
        return new MessageResponse("Gửi liên hệ thành công, chúng tôi sẽ phản hồi trong thời gian sớm nhất!");
    }
}
