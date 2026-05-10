package com.smartconstat.controller;

import com.smartconstat.model.User;
import com.smartconstat.repository.ConstatRepository;
import com.smartconstat.repository.UserRepository;
import com.smartconstat.service.AuthService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.*;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    private final UserRepository userRepository;
    private final ConstatRepository constatRepository;
    private final AuthService authService;
    private final PasswordEncoder passwordEncoder;

    @GetMapping("/me")
    public ResponseEntity<?> getCurrentUser(@AuthenticationPrincipal User currentUser) {
        if (currentUser == null) {
            return ResponseEntity.status(401).body(Map.of("error", "Non authentifie"));
        }
        return ResponseEntity.ok(authService.getUserProfile(currentUser));
    }

    @PutMapping("/me")
    public ResponseEntity<?> updateCurrentUser(
            @AuthenticationPrincipal User currentUser,
            @RequestBody Map<String, String> updates) {
        if (currentUser == null) {
            return ResponseEntity.status(401).body(Map.of("error", "Non authentifie"));
        }
        return ResponseEntity.ok(authService.updateProfile(currentUser, updates));
    }

    @GetMapping("/all")
    public ResponseEntity<?> getAllUsers(@AuthenticationPrincipal User currentUser) {
        if (currentUser == null) {
            return ResponseEntity.status(401).body(Map.of("error", "Non authentifié"));
        }
        if (!"admin".equals(currentUser.getRole())) {
            return ResponseEntity.status(403).body(Map.of("error", "Accès réservé aux administrateurs"));
        }

        List<User> users = userRepository.findAll();
        List<Map<String, Object>> result = users.stream().map(this::userToMap).collect(Collectors.toList());

        return ResponseEntity.ok(result);
    }

    /** Create a staff/admin account from the admin dashboard */
    @PostMapping("/create")
    public ResponseEntity<?> createUser(
            @AuthenticationPrincipal User currentUser,
            @RequestBody Map<String, String> body) {
        if (currentUser == null) {
            return ResponseEntity.status(401).body(Map.of("error", "Non authentifie"));
        }
        if (!"admin".equals(currentUser.getRole())) {
            return ResponseEntity.status(403).body(Map.of("error", "Acces reserve aux administrateurs"));
        }

        String email = blankToNull(body.get("email"));
        String password = blankToNull(body.get("password"));
        String role = blankToNull(body.get("role"));

        if (email == null || password == null || role == null) {
            return ResponseEntity.badRequest().body(Map.of("error", "Email, mot de passe et role sont requis"));
        }
        if (!List.of("client", "employe", "admin").contains(role)) {
            return ResponseEntity.badRequest().body(Map.of("error", "Role invalide. Valeurs acceptees: client, employe, admin"));
        }
        if (userRepository.existsByEmail(email)) {
            return ResponseEntity.status(409).body(Map.of("error", "Cette adresse email est deja utilisee"));
        }

        String assuranceId = blankToNull(body.get("assuranceId"));
        if (assuranceId == null) {
            assuranceId = "client".equals(role)
                    ? null
                    : role.toUpperCase() + "_" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
        }
        if (assuranceId == null) {
            return ResponseEntity.badRequest().body(Map.of("error", "L'ID assurance est requis pour un client"));
        }
        if (userRepository.existsByAssuranceId(assuranceId)) {
            return ResponseEntity.status(409).body(Map.of("error", "Cet ID assurance est deja utilise"));
        }

        User user = User.builder()
                .email(email)
                .passwordHash(passwordEncoder.encode(password))
                .nom(blankToNull(body.get("nom")))
                .prenom(blankToNull(body.get("prenom")))
                .cin(blankToNull(body.get("cin")))
                .phone(blankToNull(body.get("phone")))
                .assuranceId(assuranceId)
                .role(role)
                .isVerified(true)
                .active(true)
                .build();

        User saved = userRepository.save(user);
        return ResponseEntity.ok(Map.of(
                "success", true,
                "message", "Utilisateur cree avec succes",
                "user", userToMap(saved)
        ));
    }

    /** Update user role (admin only) */
    @PutMapping("/{id}/role")
    public ResponseEntity<?> updateUserRole(
            @AuthenticationPrincipal User currentUser,
            @PathVariable Long id,
            @RequestBody Map<String, String> body) {
        if (currentUser == null) {
            return ResponseEntity.status(401).body(Map.of("error", "Non authentifié"));
        }
        if (!"admin".equals(currentUser.getRole())) {
            return ResponseEntity.status(403).body(Map.of("error", "Accès réservé aux administrateurs"));
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

    @PutMapping("/{id}/active")
    public ResponseEntity<?> updateActiveStatus(
            @AuthenticationPrincipal User currentUser,
            @PathVariable Long id,
            @RequestBody Map<String, Boolean> body) {
        if (currentUser == null) {
            return ResponseEntity.status(401).body(Map.of("error", "Non authentifie"));
        }
        if (!"admin".equals(currentUser.getRole())) {
            return ResponseEntity.status(403).body(Map.of("error", "Acces reserve aux administrateurs"));
        }
        if (currentUser.getId().equals(id)) {
            return ResponseEntity.badRequest().body(Map.of("error", "Vous ne pouvez pas desactiver votre propre compte"));
        }
        Optional<User> opt = userRepository.findById(id);
        if (opt.isEmpty()) {
            return ResponseEntity.status(404).body(Map.of("error", "Utilisateur non trouve"));
        }
        Boolean active = body.get("active");
        if (active == null) {
            return ResponseEntity.badRequest().body(Map.of("error", "Statut actif requis"));
        }
        User user = opt.get();
        user.setActive(active);
        userRepository.save(user);
        return ResponseEntity.ok(Map.of("success", true, "message", active ? "Compte active" : "Compte desactive", "user", userToMap(user)));
    }

    @PutMapping("/{id}/reset-password")
    public ResponseEntity<?> resetUserPassword(
            @AuthenticationPrincipal User currentUser,
            @PathVariable Long id,
            @RequestBody(required = false) Map<String, String> body) {
        if (currentUser == null) {
            return ResponseEntity.status(401).body(Map.of("error", "Non authentifie"));
        }
        if (!"admin".equals(currentUser.getRole())) {
            return ResponseEntity.status(403).body(Map.of("error", "Acces reserve aux administrateurs"));
        }
        Optional<User> opt = userRepository.findById(id);
        if (opt.isEmpty()) {
            return ResponseEntity.status(404).body(Map.of("error", "Utilisateur non trouve"));
        }
        String password = body != null ? blankToNull(body.get("password")) : null;
        if (password == null) {
            password = "SC-" + UUID.randomUUID().toString().substring(0, 8);
        }
        User user = opt.get();
        user.setPasswordHash(passwordEncoder.encode(password));
        userRepository.save(user);
        return ResponseEntity.ok(Map.of(
                "success", true,
                "message", "Mot de passe reinitialise",
                "temporaryPassword", password
        ));
    }

    /** Delete a user (admin only) */
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteUser(
            @AuthenticationPrincipal User currentUser,
            @PathVariable Long id) {
        if (currentUser == null) {
            return ResponseEntity.status(401).body(Map.of("error", "Non authentifié"));
        }
        if (!"admin".equals(currentUser.getRole())) {
            return ResponseEntity.status(403).body(Map.of("error", "Accès réservé aux administrateurs"));
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
        map.put("active", user.isActive());
        map.put("assuranceId", user.getAssuranceId());
        map.put("vehicleBrand", user.getVehicleBrand());
        map.put("vehicleModel", user.getVehicleModel());
        map.put("vehiclePlate", user.getVehiclePlate());
        map.put("isVerified", user.isVerified());
        map.put("lastLoginAt", user.getLastLoginAt() != null ? user.getLastLoginAt().toString() : null);
        map.put("createdAt", user.getCreatedAt() != null ? user.getCreatedAt().toString() : null);
        if ("employe".equals(user.getRole()) || "admin".equals(user.getRole())) {
            map.put("assignedConstats", constatRepository.countByTraitePar(user));
            map.put("treatedConstats", constatRepository.countByTraiteParAndStatut(user, "Traité"));
            map.put("rejectedConstats", constatRepository.countByTraiteParAndStatut(user, "Rejeté"));
        }
        return map;
    }

    private String blankToNull(String value) {
        return value == null || value.isBlank() ? null : value.trim();
    }
}
