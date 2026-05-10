package com.smartconstat.repository;

import com.smartconstat.model.Facture;
import com.smartconstat.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface FactureRepository extends JpaRepository<Facture, Long> {
    List<Facture> findByUserOrderByEcheanceDesc(User user);
    List<Facture> findByUserAndTypeFactureOrderByEcheanceDesc(User user, String typeFacture);
    List<Facture> findByConstatIdOrderByEcheanceDesc(Long constatId);
    List<Facture> findByConstatId(Long constatId);
}
