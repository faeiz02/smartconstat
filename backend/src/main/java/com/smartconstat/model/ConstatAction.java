package com.smartconstat.model;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "constat_actions")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class ConstatAction {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "constat_id", nullable = false)
    private Constat constat;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "actor_id")
    private User actor;

    private String actorName;
    private String actionType;
    private String oldStatut;
    private String newStatut;

    @Column(length = 2000)
    private String comment;

    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
}
