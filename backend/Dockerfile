# Build context = thư mục gốc repo (xem render.yaml: dockerContext "."), nên đường dẫn bắt đầu bằng backend/
# Build thử trên máy: docker build -f backend/Dockerfile -t tourdulich-backend .

# ---------- Giai đoạn 1: biên dịch ----------
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /build
COPY backend/pom.xml .
RUN mvn -B -q dependency:go-offline
COPY backend/src ./src
RUN mvn -B -q -DskipTests package

# ---------- Giai đoạn 2: chạy ----------
FROM eclipse-temurin:21-jre
WORKDIR /app
# Chạy bằng user thường, không dùng root. /app/uploads là nơi ảnh admin upload (mất khi redeploy nếu không gắn disk)
RUN useradd --system --uid 1001 app && mkdir -p /app/uploads && chown -R app /app
COPY --from=build /build/target/*.jar app.jar
USER app
# Gói free của Render chỉ có 512 MB RAM: giới hạn heap theo bộ nhớ của container và dùng GC nhẹ
ENV JAVA_TOOL_OPTIONS="-XX:MaxRAMPercentage=65 -XX:+UseSerialGC -Xss512k"
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
