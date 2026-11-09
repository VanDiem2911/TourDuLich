package com.tourdulich.service;

import com.tourdulich.config.AppProperties;
import com.tourdulich.exception.ApiException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.UUID;

/** Lưu ảnh upload (jpg/png/webp, tối đa 5MB) vào thư mục app.upload.dir. */
@Slf4j
@Service
@RequiredArgsConstructor
public class FileStorageService {

    private static final long MAX_BYTES = 5L * 1024 * 1024;

    private final AppProperties props;

    /** Trả về đường dẫn công khai, ví dụ /uploads/3f2a....jpg. */
    public String storeImage(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw ApiException.badRequest("Vui lòng chọn file ảnh để tải lên");
        }
        if (file.getSize() > MAX_BYTES) {
            throw ApiException.badRequest("Ảnh không được vượt quá 5MB");
        }
        try {
            byte[] head;
            try (InputStream in = file.getInputStream()) {
                head = in.readNBytes(16);
            }
            // Xác định loại ảnh theo nội dung thực (không tin Content-Type/tên file do client gửi)
            String ext = detectExtension(head);
            if (ext == null) {
                throw ApiException.badRequest("Chỉ chấp nhận ảnh định dạng JPG, PNG hoặc WEBP");
            }
            Path dir = Paths.get(props.upload().dir()).toAbsolutePath().normalize();
            Files.createDirectories(dir);
            String name = UUID.randomUUID().toString().replace("-", "") + "." + ext;
            Path target = dir.resolve(name).normalize();
            if (!target.startsWith(dir)) {
                throw ApiException.badRequest("Tên file không hợp lệ");
            }
            try (InputStream in = file.getInputStream()) {
                Files.copy(in, target, StandardCopyOption.REPLACE_EXISTING);
            }
            return "/uploads/" + name;
        } catch (IOException e) {
            log.error("Không lưu được file upload", e);
            throw new ApiException(org.springframework.http.HttpStatus.INTERNAL_SERVER_ERROR,
                    "Không thể tải ảnh lên, vui lòng thử lại sau!");
        }
    }

    private static String detectExtension(byte[] h) {
        if (h.length >= 3 && (h[0] & 0xFF) == 0xFF && (h[1] & 0xFF) == 0xD8 && (h[2] & 0xFF) == 0xFF) {
            return "jpg";
        }
        if (h.length >= 8 && (h[0] & 0xFF) == 0x89 && h[1] == 'P' && h[2] == 'N' && h[3] == 'G') {
            return "png";
        }
        if (h.length >= 12 && h[0] == 'R' && h[1] == 'I' && h[2] == 'F' && h[3] == 'F'
                && h[8] == 'W' && h[9] == 'E' && h[10] == 'B' && h[11] == 'P') {
            return "webp";
        }
        return null;
    }
}
