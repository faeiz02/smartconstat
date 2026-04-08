package com.smartconstat.model;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "healthcare_professionals")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class HealthcareProfessional {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;
    private String type; // "Clinique", "Généraliste", "Dentiste" etc.
    private String address;
    private String distanceStr; // e.g. "1.2 km" for mocking, or we calculate it. Let's keep it simple for now.
    private String phone;
    private double rating;
    private int reviewCount;
    private String bio;
}
