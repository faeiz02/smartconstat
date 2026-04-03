package com.smartconstat.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class InsuranceVerifyRequest {
    @NotBlank(message = "L'ID d'assurance est requis")
    private String assuranceId;

    @NotBlank(message = "Le CIN est requis")
    private String cin;
}
