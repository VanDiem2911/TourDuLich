package com.tourdulich.config;

import com.tourdulich.repository.CategoryRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.core.annotation.Order;
import org.springframework.core.io.FileSystemResource;
import org.springframework.jdbc.datasource.init.ResourceDatabasePopulator;
import org.springframework.stereotype.Component;

import javax.sql.DataSource;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;

/**
 * Dev: nếu bảng categories còn trống thì tự chạy file SQL dữ liệu mẫu (app.seed.sql-path, mặc định
 * ../database/seed.sql; thử thêm database/seed.sql). Không có file thì bỏ qua êm. Chạy sau DataInitializer.
 */
@Slf4j
@Order(2)
@Component
@RequiredArgsConstructor
public class SqlDataSeeder implements CommandLineRunner {

    private final CategoryRepository categoryRepository;
    private final DataSource dataSource;
    private final AppProperties props;

    private final JdbcTemplate jdbc;

    /** Đặt SEED_RESET=true (một lần) để xóa tour/danh mục/đơn/liên hệ mẫu rồi nạp lại từ file SQL. */
    @Value("${app.seed.reset:false}")
    private boolean reset;

    @Override
    public void run(String... args) {
        if (reset) {
            resetSampleData();
        }
        if (categoryRepository.count() > 0) {
            return;
        }
        Path file = resolveSqlFile();
        if (file == null) {
            log.info("Bảng categories trống nhưng không tìm thấy file seed SQL ({}), bỏ qua.", props.seed().sqlPath());
            return;
        }
        try {
            ResourceDatabasePopulator populator =
                    new ResourceDatabasePopulator(false, false, "UTF-8", new FileSystemResource(file));
            populator.execute(dataSource);
            log.info("Đã nạp dữ liệu mẫu từ {}", file.toAbsolutePath().normalize());
        } catch (Exception ex) {
            log.error("Nạp dữ liệu mẫu từ {} thất bại: {}", file, ex.getMessage());
        }
    }

    /** Chỉ xóa dữ liệu nghiệp vụ mẫu; giữ nguyên Admin và mọi tài khoản không phải khách demo. */
    private void resetSampleData() {
        log.warn("SEED_RESET=true: xóa dữ liệu mẫu (đơn, liên hệ, tour, danh mục, khách demo) để nạp lại.");
        jdbc.execute("SET FOREIGN_KEY_CHECKS = 0");
        try {
            for (String table : List.of("payment_transactions", "booking_items", "bookings", "contacts", "tours", "categories")) {
                jdbc.execute("DELETE FROM " + table);
                jdbc.execute("ALTER TABLE " + table + " AUTO_INCREMENT = 1");
            }
            jdbc.update("DELETE FROM users WHERE email LIKE 'khachhang%@example.com'");
        } finally {
            jdbc.execute("SET FOREIGN_KEY_CHECKS = 1");
        }
    }

    private Path resolveSqlFile() {
        List<Path> candidates = new ArrayList<>();
        String configured = props.seed().sqlPath();
        if (configured != null && !configured.isBlank()) {
            candidates.add(Paths.get(configured));
        }
        candidates.add(Paths.get("database", "seed.sql"));
        candidates.add(Paths.get("..", "database", "seed.sql"));
        for (Path p : candidates) {
            if (Files.isRegularFile(p)) {
                return p;
            }
        }
        return null;
    }
}
