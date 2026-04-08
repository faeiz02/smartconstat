package com.smartconstat.controller;

import com.smartconstat.model.User;
import com.smartconstat.service.AppServicesService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/services")
@RequiredArgsConstructor
public class ServiceController {

    private final AppServicesService appServicesService;

    @GetMapping("/factures")
    public ResponseEntity<?> getFactures(@AuthenticationPrincipal User user) {
        if (user == null) {
            return ResponseEntity.status(401).body(Map.of("error", "Non authentifié"));
        }
        return ResponseEntity.ok(appServicesService.getUserFactures(user));
    }

    @GetMapping("/assistance-numbers")
    public ResponseEntity<?> getEmergencyNumbers() {
        return ResponseEntity.ok(appServicesService.getEmergencyNumbers());
    }

    @GetMapping("/assistance-types")
    public ResponseEntity<?> getAssistanceTypes() {
        return ResponseEntity.ok(appServicesService.getAssistanceTypes());
    }

    @GetMapping("/healthcare")
    public ResponseEntity<?> getHealthcareProfessionals() {
        return ResponseEntity.ok(appServicesService.getHealthcareProfessionals());
    }

    @PostMapping("/devis")
    public ResponseEntity<?> requestDevis(
            @AuthenticationPrincipal User user,
            @RequestBody Map<String, Object> data) {
        if (user == null) {
            return ResponseEntity.status(401).body(Map.of("error", "Non authentifié"));
        }
        return ResponseEntity.ok(appServicesService.createDevisRequest(user, data));
    }

}
