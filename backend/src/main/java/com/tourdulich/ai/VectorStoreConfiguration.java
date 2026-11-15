package com.tourdulich.ai;

import org.springframework.ai.embedding.EmbeddingModel;
import org.springframework.ai.vectorstore.VectorStore;
import org.springframework.ai.vectorstore.mariadb.MariaDBVectorStore;
import org.springframework.ai.vectorstore.mariadb.MariaDBVectorStore.MariaDBDistanceType;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Conditional;
import org.springframework.context.annotation.Configuration;
import org.springframework.jdbc.core.JdbcTemplate;

/**
 * Vector store CHÍNH THỨC của Spring AI cho MariaDB: tự tạo bảng {@code vector_store}
 * (id UUID, content TEXT, metadata JSON, embedding VECTOR(n) kèm chỉ mục vector) và tìm kiếm ngay trong database
 * bằng độ đo cosine. Cần MariaDB 11.7 trở lên (kiểu VECTOR).
 *
 * <p>Bật cùng điều kiện với mô hình AI (có ít nhất một API key), nên khi AI tắt thì không đụng tới bảng này.
 * Số chiều của cột VECTOR lấy từ mô hình embedding ({@code app.ai.embedding-dimensions}); đổi số chiều thì phải xóa bảng
 * {@code vector_store} để được tạo lại.
 */
@Configuration
@Conditional(AiModelsConfiguration.HasAiKeys.class)
public class VectorStoreConfiguration {

    @Bean
    public VectorStore aiVectorStore(JdbcTemplate jdbcTemplate, EmbeddingModel embeddingModel) {
        return MariaDBVectorStore.builder(jdbcTemplate, embeddingModel)
                .distanceType(MariaDBDistanceType.COSINE)
                .initializeSchema(true)
                .build();
    }
}
