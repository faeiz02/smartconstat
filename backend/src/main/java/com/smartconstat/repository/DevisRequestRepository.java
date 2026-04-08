package com.smartconstat.repository;

import com.smartconstat.model.DevisRequest;
import com.smartconstat.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface DevisRequestRepository extends JpaRepository<DevisRequest, Long> {
    List<DevisRequest> findByUserOrderByRequestedAtDesc(User user);
}
