package com.smartconstat.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class ResetPasswordRequest {
    @NotBlank(message = "L'email est requis")
    @Email(message = "Format email invalide")
    private String email;
}
