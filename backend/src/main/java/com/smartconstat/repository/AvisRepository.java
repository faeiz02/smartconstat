package com.smartconstat.repository;

import com.smartconstat.model.Avis;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface AvisRepository extends JpaRepository<Avis, Long> {
    List<Avis> findByHealthcareProfessionalIdOrderByCreatedAtDesc(Long professionalId);
    java.util.Optional<Avis> findByUserIdAndHealthcareProfessionalId(Long userId, Long professionalId);
}
