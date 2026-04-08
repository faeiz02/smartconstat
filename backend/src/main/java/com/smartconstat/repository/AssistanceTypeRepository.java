package com.smartconstat.repository;

import com.smartconstat.model.AssistanceType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface AssistanceTypeRepository extends JpaRepository<AssistanceType, Long> {
}
