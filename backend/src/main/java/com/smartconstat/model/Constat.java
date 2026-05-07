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

    @Column(length = 1000)
    private String degatsApparentsA;

    @Column(length = 1000)
    private String degatsApparentsB;

    @Column(length = 1000)
    private String autresDegats;

    @Column(length = 2000)
    private String circonstances; // stored as comma-separated

    @Column(length = 2000)
    private String observations;

    private String temoins;
    private boolean blesses = false;
    private boolean degatsMaterielsAutres = false;
    private boolean interventionPolice = false;

    private String croquisPath;
    private String signatureAPath;
    private String signatureBPath;
    
    @Column(length = 2000)
    private String photosPaths;

    // Employé qui traite ce constat
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "traite_par_id")
    private User traitePar;

    private String traiteParNom;

    @Column(updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        if (statut == null) statut = "Non examiné";
    }
}
