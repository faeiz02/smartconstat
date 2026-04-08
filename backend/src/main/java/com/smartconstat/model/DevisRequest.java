package com.smartconstat.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "devis_requests")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class DevisRequest {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    private String assuranceType; // "Assurance Auto", "Assurance Habitation", etc.

    @Column(updatable = false)
    private LocalDateTime requestedAt;

    private String statut; // "En attente", "Traité"

    @PrePersist
    protected void onCreate() {
        requestedAt = LocalDateTime.now();
        if (statut == null) statut = "En attente";
    }
}
