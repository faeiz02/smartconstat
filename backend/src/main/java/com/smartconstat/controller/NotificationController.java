package com.smartconstat.controller;

import com.smartconstat.model.ClientNotification;
import com.smartconstat.model.User;
import com.smartconstat.repository.ClientNotificationRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.LinkedHashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/notifications")
@RequiredArgsConstructor
public class NotificationController {

    private final ClientNotificationRepository notificationRepository;

    @GetMapping
    public ResponseEntity<?> getMyNotifications(@AuthenticationPrincipal User user) {
        if (user == null) {
            return ResponseEntity.status(401).body(Map.of("error", "Non authentifie"));
        }
        return ResponseEntity.ok(notificationRepository.findByUserOrderByCreatedAtDesc(user)
                .stream()
                .map(this::toMap)
                .toList());
    }

    @PutMapping("/{id}/read")
    public ResponseEntity<?> markAsRead(@AuthenticationPrincipal User user, @PathVariable Long id) {
        if (user == null) {
            return ResponseEntity.status(401).body(Map.of("error", "Non authentifie"));
        }
        var opt = notificationRepository.findById(id)
                .filter(n -> n.getUser() != null && n.getUser().getId().equals(user.getId()));
        if (opt.isEmpty()) {
            return ResponseEntity.status(404).body(Map.of("error", "Notification non trouvee"));
        }

        ClientNotification notification = opt.get();
        notification.setReadFlag(true);
        notificationRepository.save(notification);
        return ResponseEntity.ok(Map.of("success", true));
    }

    private Map<String, Object> toMap(ClientNotification notification) {
        Map<String, Object> map = new LinkedHashMap<>();
        map.put("id", notification.getId());
        map.put("title", notification.getTitle());
        map.put("message", notification.getMessage());
        map.put("type", notification.getType());
        map.put("read", notification.isReadFlag());
        map.put("createdAt", notification.getCreatedAt() != null ? notification.getCreatedAt().toString() : null);
        if (notification.getConstat() != null) {
            map.put("constatId", notification.getConstat().getId());
        }
        return map;
    }
}
