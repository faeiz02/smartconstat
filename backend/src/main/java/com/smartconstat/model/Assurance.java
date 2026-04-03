package com.smartconstat.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;

@Entity
@Table(name = "assurances")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Assurance {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false)
    private String assuranceId;

    private String nom;
    private String prenom;

    @Column(nullable = false)
    private String cin;

    private String phone;
    private String vehicleBrand;
    private String vehicleModel;
    private String vehiclePlate;
    private String compagnie;
    private LocalDate dateExpiration;
}
