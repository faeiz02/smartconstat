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

    // ─── Helper : vérification du rôle admin ───
    private ResponseEntity<?> requireAdmin(User user) {
        if (user == null) {
            return ResponseEntity.status(401).body(Map.of("error", "Non authentifié"));
        }
        if (!"admin".equals(user.getRole())) {
            return ResponseEntity.status(403).body(Map.of("error", "Accès réservé aux administrateurs"));
        }
        return null;
    }

    @GetMapping("/factures")
    public ResponseEntity<?> getFactures(
            @AuthenticationPrincipal User user,
            @RequestParam(required = false) String type) {
        if (user == null) {
            return ResponseEntity.status(401).body(Map.of("error", "Non authentifié"));
        }
        if (type != null && !type.isBlank()) {
            return ResponseEntity.ok(appServicesService.getUserFacturesByType(user, type));
        }
        return ResponseEntity.ok(appServicesService.getUserFactures(user));
    }

    @DeleteMapping("/factures/{id}")
    public ResponseEntity<?> deleteFacture(
            @AuthenticationPrincipal User user,
            @PathVariable Long id) {
        if (user == null) {
            return ResponseEntity.status(401).body(Map.of("error", "Non authentifié"));
        }
        boolean deleted = appServicesService.deleteFacture(id, user);
        if (deleted) {
            return ResponseEntity.ok(Map.of("success", true, "message", "Facture supprimée"));
        }
        return ResponseEntity.status(404).body(Map.of("error", "Facture non trouvée ou non autorisé"));
    }

    @PostMapping("/factures")
    public ResponseEntity<?> createFacture(
            @AuthenticationPrincipal User user,
            @RequestBody Map<String, Object> body) {
        if (user == null) {
            return ResponseEntity.status(401).body(Map.of("error", "Non authentifié"));
        }
        try {
            String mois = (String) body.get("mois");
            Double montant = body.get("montant") != null ? ((Number) body.get("montant")).doubleValue() : 0.0;
            String echeance = (String) body.get("echeance");
            String typeFacture = (String) body.get("typeFacture");
            Long constatId = null;
            Object constatIdRaw = body.get("constatId");
            if (constatIdRaw instanceof Number number) {
                constatId = number.longValue();
            } else if (constatIdRaw != null && !constatIdRaw.toString().isBlank()) {
                constatId = Long.parseLong(constatIdRaw.toString());
            }
            var facture = appServicesService.createFacture(user, mois, montant, echeance, typeFacture, constatId);
            return ResponseEntity.ok(Map.of("success", true, "id", facture.getId()));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", "Données invalides: " + e.getMessage()));
        }
    }

    @PostMapping("/factures/{id}/upload")
    public ResponseEntity<?> uploadFacturePhoto(
            @PathVariable Long id,
            @AuthenticationPrincipal User user,
            @RequestParam("photo") org.springframework.web.multipart.MultipartFile photo) {
        if (user == null) {
            return ResponseEntity.status(401).body(Map.of("error", "Non authentifié"));
        }
        try {
            String uploadDir = "uploads/factures/" + id + "/";
            java.io.File dir = new java.io.File(uploadDir);
            if (!dir.exists()) dir.mkdirs();

            if (photo != null && !photo.isEmpty()) {
                String filename = "photo_" + System.currentTimeMillis() + ".jpg";
                String photoPath = uploadDir + filename;
                photo.transferTo(new java.io.File(dir.getAbsolutePath() + "/" + filename));
                
                boolean updated = appServicesService.saveFacturePhoto(id, photoPath, user);
                if (updated) {
                    return ResponseEntity.ok(Map.of("success", true, "photoUrl", photoPath));
                } else {
                    return ResponseEntity.status(404).body(Map.of("error", "Facture non trouvée ou non autorisé"));
                }
            }
            return ResponseEntity.badRequest().body(Map.of("error", "Fichier vide"));
        } catch (java.io.IOException e) {
            return ResponseEntity.status(500).body(Map.of("error", "Erreur lors de l'enregistrement de l'image"));
        }
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

    /** Admin: Get ALL factures across all users */
    @GetMapping("/factures/all")
    public ResponseEntity<?> getAllFactures(@AuthenticationPrincipal User user) {
        ResponseEntity<?> check = requireAdmin(user);
        if (check != null) return check;
        return ResponseEntity.ok(appServicesService.getAllFactures());
    }

    /** Admin: Delete any facture */
    @DeleteMapping("/factures/admin/{id}")
    public ResponseEntity<?> adminDeleteFacture(
            @AuthenticationPrincipal User user,
            @PathVariable Long id) {
        ResponseEntity<?> check = requireAdmin(user);
        if (check != null) return check;
        if (appServicesService.adminDeleteFacture(id)) {
            return ResponseEntity.ok(Map.of("success", true, "message", "Facture supprimée"));
        }
        return ResponseEntity.status(404).body(Map.of("error", "Facture non trouvée"));
    }

    // ═══ HEALTHCARE CRUD ═══
    @PostMapping("/healthcare")
    public ResponseEntity<?> createHealthcare(
            @AuthenticationPrincipal User user,
            @RequestBody com.smartconstat.model.HealthcareProfessional hp) {
        ResponseEntity<?> check = requireAdmin(user);
        if (check != null) return check;
        var created = appServicesService.createHealthcareProfessional(hp);
        return ResponseEntity.ok(Map.of("success", true, "id", created.getId()));
    }

    @PutMapping("/healthcare/{id}")
    public ResponseEntity<?> updateHealthcare(
            @AuthenticationPrincipal User user,
            @PathVariable Long id,
            @RequestBody com.smartconstat.model.HealthcareProfessional hp) {
        ResponseEntity<?> check = requireAdmin(user);
        if (check != null) return check;
        var updated = appServicesService.updateHealthcareProfessional(id, hp);
        if (updated != null) return ResponseEntity.ok(Map.of("success", true));
        return ResponseEntity.status(404).body(Map.of("error", "Non trouvé"));
    }

    @DeleteMapping("/healthcare/{id}")
    public ResponseEntity<?> deleteHealthcare(
            @AuthenticationPrincipal User user,
            @PathVariable Long id) {
        ResponseEntity<?> check = requireAdmin(user);
        if (check != null) return check;
        if (appServicesService.deleteHealthcareProfessional(id))
            return ResponseEntity.ok(Map.of("success", true, "message", "Supprimé"));
        return ResponseEntity.status(404).body(Map.of("error", "Non trouvé"));
    }

    // ═══ EMERGENCY NUMBERS CRUD ═══
    @PostMapping("/assistance-numbers")
    public ResponseEntity<?> createEmergencyNumber(
            @AuthenticationPrincipal User user,
            @RequestBody com.smartconstat.model.EmergencyNumber en) {
        ResponseEntity<?> check = requireAdmin(user);
        if (check != null) return check;
        var created = appServicesService.createEmergencyNumber(en);
        return ResponseEntity.ok(Map.of("success", true, "id", created.getId()));
    }

    @PutMapping("/assistance-numbers/{id}")
    public ResponseEntity<?> updateEmergencyNumber(
            @AuthenticationPrincipal User user,
            @PathVariable Long id,
            @RequestBody com.smartconstat.model.EmergencyNumber en) {
        ResponseEntity<?> check = requireAdmin(user);
        if (check != null) return check;
        var updated = appServicesService.updateEmergencyNumber(id, en);
        if (updated != null) return ResponseEntity.ok(Map.of("success", true));
        return ResponseEntity.status(404).body(Map.of("error", "Non trouvé"));
    }

    @DeleteMapping("/assistance-numbers/{id}")
    public ResponseEntity<?> deleteEmergencyNumber(
            @AuthenticationPrincipal User user,
            @PathVariable Long id) {
        ResponseEntity<?> check = requireAdmin(user);
        if (check != null) return check;
        if (appServicesService.deleteEmergencyNumber(id))
            return ResponseEntity.ok(Map.of("success", true, "message", "Supprimé"));
        return ResponseEntity.status(404).body(Map.of("error", "Non trouvé"));
    }

    // ═══ ASSISTANCE TYPES CRUD ═══
    @PostMapping("/assistance-types")
    public ResponseEntity<?> createAssistanceType(
            @AuthenticationPrincipal User user,
            @RequestBody com.smartconstat.model.AssistanceType at) {
        ResponseEntity<?> check = requireAdmin(user);
        if (check != null) return check;
        var created = appServicesService.createAssistanceType(at);
        return ResponseEntity.ok(Map.of("success", true, "id", created.getId()));
    }

    @PutMapping("/assistance-types/{id}")
    public ResponseEntity<?> updateAssistanceType(
            @AuthenticationPrincipal User user,
            @PathVariable Long id,
            @RequestBody com.smartconstat.model.AssistanceType at) {
        ResponseEntity<?> check = requireAdmin(user);
        if (check != null) return check;
        var updated = appServicesService.updateAssistanceType(id, at);
        if (updated != null) return ResponseEntity.ok(Map.of("success", true));
        return ResponseEntity.status(404).body(Map.of("error", "Non trouvé"));
    }

    @DeleteMapping("/assistance-types/{id}")
    public ResponseEntity<?> deleteAssistanceType(
            @AuthenticationPrincipal User user,
            @PathVariable Long id) {
        ResponseEntity<?> check = requireAdmin(user);
        if (check != null) return check;
        if (appServicesService.deleteAssistanceType(id))
            return ResponseEntity.ok(Map.of("success", true, "message", "Supprimé"));
        return ResponseEntity.status(404).body(Map.of("error", "Non trouvé"));
    }
}
