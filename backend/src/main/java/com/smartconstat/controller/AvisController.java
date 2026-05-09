package com.smartconstat.controller;

import com.smartconstat.dto.AvisDto;
import com.smartconstat.dto.AvisRequestDto;
import com.smartconstat.model.User;
import com.smartconstat.service.AvisService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/avis")
@RequiredArgsConstructor
public class AvisController {

    private final AvisService avisService;

    @GetMapping("/professional/{id}")
    public ResponseEntity<List<AvisDto>> getAvisForProfessional(@PathVariable Long id) {
        return ResponseEntity.ok(avisService.getAvisForProfessional(id));
    }

    @GetMapping("/all")
    public ResponseEntity<?> getAllAvis(@AuthenticationPrincipal User user) {
        if (user == null) return ResponseEntity.status(401).body(Map.of("error", "Non authentifié"));
        if (!"admin".equals(user.getRole())) return ResponseEntity.status(403).body(Map.of("error", "Accès réservé aux administrateurs"));
        return ResponseEntity.ok(avisService.getAllAvis());
    }

    @DeleteMapping("/admin/{id}")
    public ResponseEntity<?> adminDeleteAvis(@AuthenticationPrincipal User user, @PathVariable Long id) {
        if (user == null) return ResponseEntity.status(401).body(Map.of("error", "Non authentifié"));
        if (!"admin".equals(user.getRole())) return ResponseEntity.status(403).body(Map.of("error", "Accès réservé aux administrateurs"));
        try {
            avisService.adminDeleteAvis(id);
            return ResponseEntity.ok(Map.of("message", "Avis supprimé par l'administrateur"));
        } catch (RuntimeException e) {
            return ResponseEntity.status(404).body(Map.of("error", e.getMessage()));
        }
    }

    @PostMapping("/add")
    public ResponseEntity<?> addAvis(@RequestBody AvisRequestDto request) {
        try {
            AvisDto result = avisService.addAvis(request);
            return ResponseEntity.ok(result);
        } catch (RuntimeException e) {
            if ("ALREADY_REVIEWED".equals(e.getMessage())) {
                return ResponseEntity.status(409).body(Map.of("error", "ALREADY_REVIEWED"));
            }
            return ResponseEntity.status(500).body(Map.of("error", e.getMessage()));
        }
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> updateAvis(@PathVariable Long id, @RequestBody AvisRequestDto request) {
        try {
            AvisDto result = avisService.updateAvis(id, request);
            return ResponseEntity.ok(result);
        } catch (RuntimeException e) {
            return ResponseEntity.status(403).body(Map.of("error", e.getMessage()));
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteAvis(@PathVariable Long id) {
        try {
            avisService.deleteAvis(id);
            return ResponseEntity.ok(Map.of("message", "Avis supprimé"));
        } catch (RuntimeException e) {
            return ResponseEntity.status(403).body(Map.of("error", e.getMessage()));
        }
    }
}
