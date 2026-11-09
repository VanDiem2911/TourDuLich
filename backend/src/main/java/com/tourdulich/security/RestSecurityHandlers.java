package com.tourdulich.security;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.tourdulich.exception.ErrorResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.AuthenticationEntryPoint;
import org.springframework.security.web.access.AccessDeniedHandler;
import org.springframework.stereotype.Component;

import java.io.IOException;

/** Trả lỗi 401/403 dạng JSON thay vì trang HTML mặc định của Spring Security. */
@Component
@RequiredArgsConstructor
public class RestSecurityHandlers implements AuthenticationEntryPoint, AccessDeniedHandler {

    private final ObjectMapper objectMapper;

    @Override
    public void commence(HttpServletRequest request, HttpServletResponse response, AuthenticationException ex)
            throws IOException {
        write(response, ErrorResponse.of(HttpStatus.UNAUTHORIZED,
                "Vui lòng đăng nhập để tiếp tục", request.getRequestURI()));
    }

    @Override
    public void handle(HttpServletRequest request, HttpServletResponse response, AccessDeniedException ex)
            throws IOException {
        write(response, ErrorResponse.of(HttpStatus.FORBIDDEN,
                "Bạn không có quyền truy cập chức năng này", request.getRequestURI()));
    }

    private void write(HttpServletResponse response, ErrorResponse body) throws IOException {
        response.setStatus(body.status());
        response.setContentType(MediaType.APPLICATION_JSON_VALUE);
        response.setCharacterEncoding("UTF-8");
        objectMapper.writeValue(response.getWriter(), body);
    }
}
