package com.smartconstat.dto;

import lombok.*;

import java.util.Map;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class AuthResponse {
    private boolean success;
    private String message;
    private String token;
    private Map<String, Object> user;
}
