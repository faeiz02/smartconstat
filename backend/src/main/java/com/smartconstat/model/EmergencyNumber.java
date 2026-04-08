package com.smartconstat.model;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "emergency_numbers")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class EmergencyNumber {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String label;
    private String number;
    private String iconStr; // e.g., "Icons.car_repair_outlined" mapping to frontend
}
