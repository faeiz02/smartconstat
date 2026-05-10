package com.smartconstat.repository;

import com.smartconstat.model.ConstatAction;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ConstatActionRepository extends JpaRepository<ConstatAction, Long> {
    List<ConstatAction> findByConstatIdOrderByCreatedAtDesc(Long constatId);
}
