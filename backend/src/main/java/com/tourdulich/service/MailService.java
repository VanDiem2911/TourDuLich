package com.tourdulich.service;

import com.tourdulich.config.AppProperties;
import com.tourdulich.entity.User;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

/**
 * Gửi email bất đồng bộ. Lỗi gửi mail chỉ được ghi log, không làm hỏng nghiệp vụ chính
 * (đăng ký, đặt tour...). Khi app.mail.enabled=false thì chỉ ghi log để dev không cần SMTP.
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class MailService {

    private final ObjectProvider<JavaMailSender> mailSender;
    private final AppProperties props;

    @Async
    public void send(String to, String subject, String body) {
        if (!props.mail().enabled()) {
            log.info("[MAIL tắt] To={} | Subject={}\n{}", to, subject, body);
            return;
        }
        JavaMailSender sender = mailSender.getIfAvailable();
        if (sender == null) {
            log.warn("Chưa cấu hình SMTP (spring.mail.host) nên không gửi được mail tới {}", to);
            return;
        }
        try {
            SimpleMailMessage msg = new SimpleMailMessage();
            msg.setFrom(props.mail().from());
            msg.setTo(to);
            msg.setSubject(subject);
            msg.setText(body);
            sender.send(msg);
        } catch (Exception ex) {
            log.warn("Gửi mail tới {} thất bại: {}", to, ex.getMessage());
        }
    }

    public void sendBookingCreated(String to, String contactName, String bookingCode, long totalAmount) {
        send(to,
                "Xác nhận đặt tour " + bookingCode,
                "Xin chào " + contactName + ",\n\n"
                        + "Đơn đặt tour " + bookingCode + " của bạn đã được ghi nhận với tổng tiền "
                        + String.format("%,d", totalAmount) + " VND. "
                        + "Vui lòng thanh toán để chúng tôi xác nhận chỗ cho bạn.\n\n"
                        + "Trân trọng,\nWebsite Tour Du Lịch");
    }

    public void sendPaymentSuccess(String to, String contactName, String bookingCode) {
        send(to,
                "Thanh toán thành công đơn " + bookingCode,
                "Xin chào " + contactName + ",\n\n"
                        + "Chúng tôi đã nhận được thanh toán cho đơn đặt tour " + bookingCode + ". "
                        + "Cảm ơn bạn đã tin tưởng chúng tôi!\n\n"
                        + "Trân trọng,\nWebsite Tour Du Lịch");
    }

    public void sendBookingCancelled(String to, String contactName, String bookingCode, String reason) {
        send(to,
                "Đơn đặt tour " + bookingCode + " đã được hủy",
                "Xin chào " + contactName + ",\n\n"
                        + "Đơn đặt tour " + bookingCode + " đã được hủy."
                        + (reason == null || reason.isBlank() ? "" : "\nLý do: " + reason) + "\n\n"
                        + "Trân trọng,\nWebsite Tour Du Lịch");
    }

    public void sendNewContactToAdmin(String adminEmail, String fromName, String fromEmail, String subject, String message) {
        send(adminEmail,
                "[Liên hệ mới] " + subject,
                "Có liên hệ mới từ " + fromName + " <" + fromEmail + ">:\n\n" + message);
    }

    public void sendContactReply(String to, String fullName, String subject, String replyContent) {
        send(to,
                "Phản hồi: " + subject,
                "Xin chào " + fullName + ",\n\n" + replyContent + "\n\nTrân trọng,\nWebsite Tour Du Lịch");
    }

    public void sendRegistrationSuccess(User user) {
        send(user.getEmail(),
                "Đăng ký tài khoản thành công",
                "Xin chào " + user.getFullName() + ",\n\n"
                        + "Tài khoản của bạn đã được tạo thành công. Bạn có thể đăng nhập và đặt tour ngay bây giờ.\n\n"
                        + "Trân trọng,\nWebsite Tour Du Lịch");
    }
}
