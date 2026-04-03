package com.smartconstat.repository;

import com.smartconstat.model.Assurance;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface AssuranceRepository extends JpaRepository<Assurance, Long> {
    Optional<Assurance> findByAssuranceId(String assuranceId);
    Optional<Assurance> findByAssuranceIdAndCin(String assuranceId, String cin);
}
