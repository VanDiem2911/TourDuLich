package com.tourdulich.security;

import com.tourdulich.config.AppProperties;
import com.tourdulich.entity.User;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.stereotype.Service;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;
import java.util.Optional;

/** Sinh và kiểm tra JWT (chữ ký HS256 + thời hạn). Có 2 loại token: access và refresh. */
@Service
public class JwtService {

    public static final String TYPE_ACCESS = "access";
    public static final String TYPE_REFRESH = "refresh";

    private final SecretKey key;
    private final long accessExpirationMs;
    private final long refreshExpirationMs;

    public JwtService(AppProperties props) {
        byte[] secret = props.jwt().secret().getBytes(StandardCharsets.UTF_8);
        if (secret.length < 32) {
            throw new IllegalStateException("app.jwt.secret phải dài tối thiểu 32 ký tự");
        }
        this.key = Keys.hmacShaKeyFor(secret);
        this.accessExpirationMs = props.jwt().accessExpirationMs();
        this.refreshExpirationMs = props.jwt().refreshExpirationMs();
    }

    public String generateAccessToken(User user) {
        return build(user, TYPE_ACCESS, accessExpirationMs);
    }

    public String generateRefreshToken(User user) {
        return build(user, TYPE_REFRESH, refreshExpirationMs);
    }

    public long getAccessExpirationSeconds() {
        return accessExpirationMs / 1000;
    }

    /** Trả về userId nếu token hợp lệ (đúng chữ ký, còn hạn, đúng loại), ngược lại trả rỗng. */
    public Optional<Long> parseUserId(String token, String expectedType) {
        try {
            Claims claims = Jwts.parser().verifyWith(key).build().parseSignedClaims(token).getPayload();
            if (!expectedType.equals(claims.get("type", String.class))) {
                return Optional.empty();
            }
            return Optional.of(Long.parseLong(claims.getSubject()));
        } catch (JwtException | IllegalArgumentException ex) {
            return Optional.empty();
        }
    }

    private String build(User user, String type, long ttlMs) {
        Date now = new Date();
        return Jwts.builder()
                .subject(String.valueOf(user.getId()))
                .claim("email", user.getEmail())
                .claim("role", user.getRole().name())
                .claim("type", type)
                .issuedAt(now)
                .expiration(new Date(now.getTime() + ttlMs))
                .signWith(key)
                .compact();
    }
}
