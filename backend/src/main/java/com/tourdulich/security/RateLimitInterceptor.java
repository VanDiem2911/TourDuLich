package com.tourdulich.security;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.tourdulich.exception.ErrorResponse;
import io.github.bucket4j.Bandwidth;
import io.github.bucket4j.Bucket;
import io.github.bucket4j.ConsumptionProbe;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import java.time.Duration;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.TimeUnit;

/**
 * Giới hạn tần suất request theo IP (Bucket4j). Vượt giới hạn trả HTTP 429.
 * Mức giới hạn theo đặc tả mục 9.3.
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class RateLimitInterceptor implements HandlerInterceptor {

    private record Rule(String method, String path, int limit, Duration window) {
        Rule(String method, String path, int limitPerMinute) {
            this(method, path, limitPerMinute, Duration.ofMinutes(1));
        }
    }

    private static final List<Rule> RULES = List.of(
            new Rule("POST", "/api/auth/login", 5),
            new Rule("POST", "/api/auth/register", 5),
            new Rule("POST", "/api/auth/refresh", 10),
            new Rule("POST", "/api/bookings", 10),
            new Rule("POST", "/api/contacts", 5, Duration.ofHours(1)),
            new Rule("POST", "/api/ai/chat", 15),          // mỗi câu hỏi tốn một lần gọi Gemini
            new Rule("POST", "/api/tracking/events", 90)   // frontend gom sự kiện theo lô nên ít request
    );

    private static final int MAX_TRACKED_BUCKETS = 10_000;

    private final ObjectMapper objectMapper;
    private final Map<String, Bucket> buckets = new ConcurrentHashMap<>();

    /** Các đường dẫn cần đăng ký interceptor (dùng trong WebConfig). */
    public static String[] protectedPaths() {
        return RULES.stream().map(Rule::path).distinct().toArray(String[]::new);
    }

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler)
            throws Exception {
        Rule rule = findRule(request);
        if (rule == null) {
            return true;
        }
        if (buckets.size() > MAX_TRACKED_BUCKETS) {
            buckets.clear(); // tránh phình bộ nhớ khi bị quét IP hàng loạt
        }
        String key = request.getRemoteAddr() + "|" + rule.path();
        Bucket bucket = buckets.computeIfAbsent(key, k -> Bucket.builder()
                .addLimit(Bandwidth.builder()
                        .capacity(rule.limit())
                        .refillIntervally(rule.limit(), rule.window())
                        .build())
                .build());

        ConsumptionProbe probe = bucket.tryConsumeAndReturnRemaining(1);
        if (probe.isConsumed()) {
            return true;
        }

        long retryAfter = Math.max(1, TimeUnit.NANOSECONDS.toSeconds(probe.getNanosToWaitForRefill()) + 1);
        log.warn("Rate limit: IP {} vượt giới hạn tại {} {}", request.getRemoteAddr(), rule.method(), rule.path());
        response.setStatus(HttpStatus.TOO_MANY_REQUESTS.value());
        response.setHeader("Retry-After", String.valueOf(retryAfter));
        response.setContentType(MediaType.APPLICATION_JSON_VALUE);
        response.setCharacterEncoding("UTF-8");
        objectMapper.writeValue(response.getWriter(), ErrorResponse.of(HttpStatus.TOO_MANY_REQUESTS,
                "Bạn thao tác quá nhanh, vui lòng thử lại sau " + retryAfter + " giây!", request.getRequestURI()));
        return false;
    }

    private Rule findRule(HttpServletRequest request) {
        String path = request.getRequestURI();
        for (Rule rule : RULES) {
            if (rule.method().equalsIgnoreCase(request.getMethod()) && rule.path().equals(path)) {
                return rule;
            }
        }
        return null;
    }
}
