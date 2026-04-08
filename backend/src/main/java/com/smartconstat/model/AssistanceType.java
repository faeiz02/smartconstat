package com.smartconstat.model;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "assistance_types")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class AssistanceType {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String title;
    private String description;
    private String iconStr;
}
