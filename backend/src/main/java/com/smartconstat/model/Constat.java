package com.smartconstat.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "constats")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Constat {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    private String lieu;
    private LocalDateTime dateTime;

    // Statut du constat (Non examiné, En cours d'exécution, Traité, Rejeté)
    @Builder.Default
    private String statut = "Non examiné";

    @Builder.Default
    private String priorite = "Normale"; // "Basse", "Normale", "Haute", "Urgente"

    // Véhicule A
    private String assureurA;
    private String contratA;
    private String nomA;
    private String prenomA;
    private String adresseA;
    private String vehiculeMarqueA;
    private String vehiculeModeleA;
    private String immatriculationA;
    private String paysA;
    private String sensSuiviA;

    // Véhicule B
    private String assureurB;
    private String contratB;
    private String nomB;
    private String prenomB;
    private String adresseB;
    private String vehiculeMarqueB;
    private String vehiculeModeleB;
    private String immatriculationB;
    private String paysB;
    private String sensSuiviB;

    // Dégâts
    private String pointChocInitial;

    @Column(columnDefinition = "TEXT")
    private String degatsApparentsA;

    @Column(columnDefinition = "TEXT")
    private String degatsApparentsB;

    @Column(columnDefinition = "TEXT")
    private String autresDegats;

    @Column(columnDefinition = "TEXT")
    private String circonstances; // stored as comma-separated

    @Column(columnDefinition = "TEXT")
    private String observations;

    private String temoins;
    @Builder.Default
    private boolean blesses = false;
    @Builder.Default
    private boolean degatsMaterielsAutres = false;
    @Builder.Default
    private boolean interventionPolice = false;

    private String croquisPath;
    private String signatureAPath;
    private String signatureBPath;
    
    @Column(columnDefinition = "TEXT")
    private String photosPaths;

    // Employé qui traite ce constat
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "traite_par_id")
    private User traitePar;

    private String traiteParNom;

    private LocalDateTime dateLimite;

    @Column(columnDefinition = "TEXT")
    private String noteInterne;

    @Column(columnDefinition = "TEXT")
    private String documentsManquants;

    @Column(columnDefinition = "TEXT")
    private String motifRejet;

    @Column(columnDefinition = "TEXT")
    private String commentaireDecision;

    private String responsabiliteEstimee;
    private Double montantEstime;
    @Builder.Default
    private boolean escalade = false;
    private String escaladeRaison;
    @Builder.Default
    private String factureStatut = "Non demandee";
    @Builder.Default
    private Double montantFacturesTotal = 0.0;
    @Builder.Default
    private Integer nombreFactures = 0;

    @Column(columnDefinition = "TEXT")
    private String priseEnChargeDecision;

    private LocalDateTime updatedAt;

    @Column(updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        if (statut == null) statut = "Non examiné";
        if (priorite == null) priorite = "Normale";
        if (factureStatut == null) factureStatut = "Non demandee";
        if (montantFacturesTotal == null) montantFacturesTotal = 0.0;
        if (nombreFactures == null) nombreFactures = 0;
        if (dateLimite == null) dateLimite = createdAt.plusDays(3);
        updatedAt = createdAt;
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
