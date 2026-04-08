package com.smartconstat.repository;

import com.smartconstat.model.HealthcareProfessional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface HealthcareProfessionalRepository extends JpaRepository<HealthcareProfessional, Long> {
    List<HealthcareProfessional> findByType(String type);
}
