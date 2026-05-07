package com.smartconstat.repository;

import com.smartconstat.model.Constat;
import com.smartconstat.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.util.List;

public interface ConstatRepository extends JpaRepository<Constat, Long> {
    List<Constat> findByUserOrderByCreatedAtDesc(User user);
    List<Constat> findAllByOrderByCreatedAtDesc();
    List<Constat> findByStatutOrderByCreatedAtDesc(String statut);

    // Constats visibles par un employé :
    // - Tous les "Non examiné" (disponibles)
    // - Ceux assignés à cet employé (en cours de traitement par lui)
    @Query("SELECT c FROM Constat c WHERE c.statut = 'Non examiné' OR c.traitePar = :employe ORDER BY c.createdAt DESC")
    List<Constat> findConstatsForEmploye(@Param("employe") User employe);
}
