package com.smartconstat.repository;

import com.smartconstat.model.Constat;
import com.smartconstat.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface ConstatRepository extends JpaRepository<Constat, Long> {
    List<Constat> findByUserOrderByCreatedAtDesc(User user);
}
