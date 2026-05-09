package com.smartconstat.controller;

import com.smartconstat.model.Assurance;
import com.smartconstat.model.User;
import com.smartconstat.repository.AssuranceRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/assurances")
@RequiredArgsConstructor
public class AssuranceController {

    private final AssuranceRepository assuranceRepository;

    private ResponseEntity<?> requireAdmin(User user) {
        if (user == null) return ResponseEntity.status(401).body(Map.of("error", "Non authentifié"));
        if (!"admin".equals(user.getRole())) return ResponseEntity.status(403).body(Map.of("error", "Accès réservé aux administrateurs"));
        return null;
    }

    @GetMapping("/all")
    public ResponseEntity<?> getAllAssurances(@AuthenticationPrincipal User user) {
        ResponseEntity<?> check = requireAdmin(user);
        if (check != null) return check;
        return ResponseEntity.ok(assuranceRepository.findAll());
    }

    @PostMapping
    public ResponseEntity<?> createAssurance(@AuthenticationPrincipal User user, @RequestBody Assurance assurance) {
        ResponseEntity<?> check = requireAdmin(user);
        if (check != null) return check;
        if (assurance.getAssuranceId() == null || assurance.getAssuranceId().isBlank()) {
            return ResponseEntity.badRequest().body(Map.of("error", "L'ID d'assurance est requis"));
        }
        if (assuranceRepository.findByAssuranceId(assurance.getAssuranceId()).isPresent()) {
            return ResponseEntity.status(409).body(Map.of("error", "Cet ID d'assurance existe déjà"));
        }
        Assurance saved = assuranceRepository.save(assurance);
        return ResponseEntity.ok(saved);
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> updateAssurance(@AuthenticationPrincipal User user, @PathVariable Long id, @RequestBody Assurance updated) {
        ResponseEntity<?> check = requireAdmin(user);
        if (check != null) return check;
        return assuranceRepository.findById(id)
                .map(existing -> {
                    if (updated.getNom() != null) existing.setNom(updated.getNom());
                    if (updated.getPrenom() != null) existing.setPrenom(updated.getPrenom());
                    if (updated.getCin() != null) existing.setCin(updated.getCin());
                    if (updated.getPhone() != null) existing.setPhone(updated.getPhone());
                    if (updated.getVehicleBrand() != null) existing.setVehicleBrand(updated.getVehicleBrand());
                    if (updated.getVehicleModel() != null) existing.setVehicleModel(updated.getVehicleModel());
                    if (updated.getVehiclePlate() != null) existing.setVehiclePlate(updated.getVehiclePlate());
                    if (updated.getCompagnie() != null) existing.setCompagnie(updated.getCompagnie());
                    if (updated.getDateExpiration() != null) existing.setDateExpiration(updated.getDateExpiration());
                    return ResponseEntity.ok(assuranceRepository.save(existing));
                })
                .orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteAssurance(@AuthenticationPrincipal User user, @PathVariable Long id) {
        ResponseEntity<?> check = requireAdmin(user);
        if (check != null) return check;
        if (!assuranceRepository.existsById(id)) {
            return ResponseEntity.notFound().build();
        }
        assuranceRepository.deleteById(id);
        return ResponseEntity.ok(Map.of("message", "Assurance supprimée"));
    }
}
