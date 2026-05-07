package com.smartconstat.model;

import com.fasterxml.jackson.annotation.JsonIgnore;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;

@Entity
@Table(name = "factures")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Facture {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @JsonIgnore
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    private String mois;
    private Double montant;
    private LocalDate echeance;
    private String statut; // "Payée", "À payer"
    private String typeFacture; // "Maladie", "Réparation", "Visite technique", "Autre"
    private String photoUrl;
}
