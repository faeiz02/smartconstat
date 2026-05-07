package com.smartconstat.controller;

import com.smartconstat.model.User;
import com.smartconstat.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.*;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    private final UserRepository userRepository;

    @GetMapping("/all")
    public ResponseEntity<?> getAllUsers(@RequestHeader(value = "Authorization", required = false) String authHeader) {
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            return ResponseEntity.status(401).body(Map.of("error", "Non authentifié"));
        }

        List<User> users = userRepository.findAll();
        List<Map<String, Object>> result = users.stream().map(this::userToMap).collect(Collectors.toList());

        return ResponseEntity.ok(result);
    }

    /** Update user role (admin only) */
    @PutMapping("/{id}/role")
    public ResponseEntity<?> updateUserRole(
            @RequestHeader(value = "Authorization", required = false) String authHeader,
            @PathVariable Long id,
            @RequestBody Map<String, String> body) {
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            return ResponseEntity.status(401).body(Map.of("error", "Non authentifié"));
        }
        String newRole = body.get("role");
        if (newRole == null || newRole.isBlank()) {
            return ResponseEntity.badRequest().body(Map.of("error", "Rôle requis"));
        }
        // Validate role value
        if (!List.of("client", "employe", "admin").contains(newRole)) {
            return ResponseEntity.badRequest()
                    .body(Map.of("error", "Rôle invalide. Valeurs acceptées: client, employe, admin"));
        }
        Optional<User> opt = userRepository.findById(id);
        if (opt.isEmpty()) {
            return ResponseEntity.status(404).body(Map.of("error", "Utilisateur non trouvé"));
        }
        User user = opt.get();
        user.setRole(newRole);
        userRepository.save(user);
        return ResponseEntity.ok(Map.of("success", true, "message", "Rôle mis à jour", "user", userToMap(user)));
    }

    /** Delete a user (admin only) */
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteUser(
            @RequestHeader(value = "Authorization", required = false) String authHeader,
            @PathVariable Long id) {
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            return ResponseEntity.status(401).body(Map.of("error", "Non authentifié"));
        }
        Optional<User> opt = userRepository.findById(id);
        if (opt.isEmpty()) {
            return ResponseEntity.status(404).body(Map.of("error", "Utilisateur non trouvé"));
        }
        userRepository.deleteById(id);
        return ResponseEntity.ok(Map.of("success", true, "message", "Utilisateur supprimé"));
    }

    private Map<String, Object> userToMap(User user) {
        Map<String, Object> map = new LinkedHashMap<>();
        map.put("id", user.getId());
        map.put("email", user.getEmail());
        map.put("nom", user.getNom());
        map.put("prenom", user.getPrenom());
        map.put("cin", user.getCin());
        map.put("phone", user.getPhone());
        map.put("role", user.getRole() != null ? user.getRole() : "client");
        map.put("assuranceId", user.getAssuranceId());
        map.put("vehicleBrand", user.getVehicleBrand());
        map.put("vehicleModel", user.getVehicleModel());
        map.put("vehiclePlate", user.getVehiclePlate());
        map.put("isVerified", user.isVerified());
        map.put("createdAt", user.getCreatedAt() != null ? user.getCreatedAt().toString() : null);
        return map;
    }
}
