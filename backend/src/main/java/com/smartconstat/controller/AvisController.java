package com.smartconstat.controller;

import com.smartconstat.dto.AvisDto;
import com.smartconstat.dto.AvisRequestDto;
import com.smartconstat.service.AvisService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
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
