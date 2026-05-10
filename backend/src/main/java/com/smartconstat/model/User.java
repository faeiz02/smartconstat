package com.smartconstat.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "users")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false)
    private String email;

    @Column(nullable = false)
    private String passwordHash;

    private String nom;
    private String prenom;

    @Column(unique = true)
    private String cin;

    private String phone;
    private String vehicleBrand;
    private String vehicleModel;
    private String vehiclePlate;

    @Column(unique = true)
    private String assuranceId;

    @Column(updatable = false)
    private LocalDateTime createdAt;

    @Column(nullable = false)
    @Builder.Default
    private String role = "client"; // "client", "admin", "employe"

    @Column(nullable = false)
    @Builder.Default
    private boolean isVerified = false;

    @Column(nullable = false)
    @Builder.Default
    private boolean active = true;

    private LocalDateTime lastLoginAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
}
