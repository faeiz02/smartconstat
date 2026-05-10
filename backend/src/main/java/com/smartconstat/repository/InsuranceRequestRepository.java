package com.smartconstat.repository;

import com.smartconstat.model.InsuranceRequest;
import com.smartconstat.model.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface InsuranceRequestRepository extends JpaRepository<InsuranceRequest, Long> {
    List<InsuranceRequest> findByUserOrderByCreatedAtDesc(User user);
    List<InsuranceRequest> findAllByOrderByCreatedAtDesc();
    List<InsuranceRequest> findByStatusOrderByCreatedAtDesc(String status);
}
