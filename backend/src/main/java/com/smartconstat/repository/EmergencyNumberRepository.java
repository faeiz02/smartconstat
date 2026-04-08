package com.smartconstat.repository;

import com.smartconstat.model.EmergencyNumber;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface EmergencyNumberRepository extends JpaRepository<EmergencyNumber, Long> {
}
