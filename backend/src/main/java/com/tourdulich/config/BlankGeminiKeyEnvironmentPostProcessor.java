package com.tourdulich.config;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.env.EnvironmentPostProcessor;
import org.springframework.core.Ordered;
import org.springframework.core.env.ConfigurableEnvironment;
import org.springframework.core.env.MapPropertySource;

import java.util.Map;

/**
 * Biến GEMINI_API_KEY để trống (ví dụ dòng "GEMINI_API_KEY=" trong .env) khiến giá trị mặc định
 * {@code ${GEMINI_API_KEY:chua-cau-hinh}} không được dùng (biến tồn tại nhưng rỗng) và auto-config embedding của Spring AI
 * làm ứng dụng không khởi động được. Ở đây coi biến rỗng như chưa đặt. Chạy sau khi file .env đã được nạp.
 */
public class BlankGeminiKeyEnvironmentPostProcessor implements EnvironmentPostProcessor, Ordered {

    @Override
    public void postProcessEnvironment(ConfigurableEnvironment environment, SpringApplication application) {
        String key = environment.getProperty("GEMINI_API_KEY");
        if (key != null && key.isBlank()) {
            environment.getPropertySources().addFirst(
                    new MapPropertySource("blankGeminiKeyFix", Map.of("GEMINI_API_KEY", "chua-cau-hinh")));
        }
    }

    @Override
    public int getOrder() {
        return Ordered.LOWEST_PRECEDENCE;
    }
}
