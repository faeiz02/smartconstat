package com.smartconstat.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AvisDto {
    private Long id;
    private double rating;
    private String comment;
    private LocalDateTime createdAt;
    private String userName;
    private Long userId;
    private Long professionalId;
}
