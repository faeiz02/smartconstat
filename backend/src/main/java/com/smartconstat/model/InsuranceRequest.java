package com.smartconstat.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "insurance_requests")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class InsuranceRequest {

    public static final String STATUS_PENDING = "EN_ATTENTE";
    public static final String STATUS_APPROVED = "APPROUVEE";
    public static final String STATUS_REJECTED = "REJETEE";

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @JsonIgnore
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(nullable = false)
    private String type;

    @Column(nullable = false)
    private String title;

    private String price;

    @Column(name = "details_json", columnDefinition = "TEXT")
    private String detailsJson;

    @Builder.Default
    @Column(nullable = false)
    private String status = STATUS_PENDING;

    @Column(columnDefinition = "TEXT")
    private String decisionComment;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "processed_by_id")
    private User processedBy;

    private LocalDateTime processedAt;

    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = createdAt;
        if (status == null) status = STATUS_PENDING;
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
