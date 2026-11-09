package com.tourdulich.dto.admin;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record ContactReplyRequest(
        @NotBlank(message = "Vui lòng nhập nội dung phản hồi hợp lệ!")
        @Size(min = 10, max = 5000, message = "Vui lòng nhập nội dung phản hồi hợp lệ!")
        String replyContent) {
}
