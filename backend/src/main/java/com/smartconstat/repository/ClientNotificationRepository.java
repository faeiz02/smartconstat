package com.smartconstat.repository;

import com.smartconstat.model.ClientNotification;
import com.smartconstat.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ClientNotificationRepository extends JpaRepository<ClientNotification, Long> {
    List<ClientNotification> findByUserOrderByCreatedAtDesc(User user);
    long countByUserAndReadFlagFalse(User user);
}
