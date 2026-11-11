package com.tourdulich.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

import java.util.List;

/** Các cấu hình tùy biến của ứng dụng (tiền tố "app" trong application.yml). */
@ConfigurationProperties(prefix = "app")
public record AppProperties(Cors cors, Jwt jwt, Mail mail, Seed seed, Payment payment, Upload upload, Ai ai) {

    public record Cors(List<String> allowedOrigins) {
    }

    public record Jwt(String secret, long accessExpirationMs, long refreshExpirationMs) {
    }

    public record Mail(boolean enabled, String from, String adminEmail) {
    }

    /**
     * adminEmail/adminPassword/adminFullName: tài khoản Admin mặc định.
     * sqlPath: file SQL dữ liệu mẫu, tự chạy nếu bảng categories còn trống (bỏ qua nếu không có file).
     * demoData: tự tạo khách hàng + đơn đặt tour + liên hệ mẫu khi CSDL chưa có đơn nào.
     */
    public record Seed(String adminEmail, String adminPassword, String adminFullName, String sqlPath,
                       boolean demoData) {
    }

    /**
     * Thông tin nhận chuyển khoản (VietQR). bankCode là mã/BIN ngân hàng dùng trong URL ảnh QR.
     * webhookKey: khóa xác thực webhook ngân hàng (header Authorization: Apikey ...).
     * simulateEnabled: cho phép giả lập thanh toán (chỉ nên bật ở môi trường dev/demo).
     */
    public record Payment(String bankName, String bankCode, String accountNumber, String accountName,
                          String webhookKey, boolean simulateEnabled) {
    }

    /**
     * Trợ lý AI (RAG). knowledgeDir: thư mục tài liệu bổ sung ngoài classpath (mỗi file .md/.txt là một tài liệu).
     * storePath: file lưu vector (SimpleVectorStore). topK/similarityThreshold: số đoạn lấy ra và ngưỡng giống nhau tối thiểu.
     * maxHistory: số tin nhắn gần nhất được gửi kèm; maxMessageChars: độ dài tối đa mỗi tin.
     */
    public record Ai(String knowledgeDir, String storePath, int topK, double similarityThreshold, int maxHistory,
                     int maxMessageChars) {
    }

    public record Upload(String dir) {
    }
}
