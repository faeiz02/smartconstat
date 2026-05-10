package com.smartconstat.controller;

import com.smartconstat.model.User;
import com.smartconstat.service.ConstatService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/constats")
@RequiredArgsConstructor
public class ConstatController {

    private final ConstatService constatService;

    @PostMapping
    public ResponseEntity<?> createConstat(
            @AuthenticationPrincipal User user,
            @RequestBody Map<String, Object> data) {
        if (user == null) {
            return ResponseEntity.status(401).body(Map.of("error", "Non authentifie"));
        }
        Map<String, Object> result = constatService.createConstat(user, data);
        return ResponseEntity.ok(result);
    }

    @GetMapping
    public ResponseEntity<?> getConstats(@AuthenticationPrincipal User user) {
        if (user == null) {
            return ResponseEntity.status(401).body(Map.of("error", "Non authentifie"));
        }
        List<Map<String, Object>> constats = constatService.getUserConstats(user);
        return ResponseEntity.ok(constats);
    }

    /** Dashboard: get constats. Admin sees all; employees see queue + assigned cases. */
    @GetMapping("/all")
    public ResponseEntity<?> getAllConstats(
            @AuthenticationPrincipal User user,
            @RequestParam(required = false) String statut) {
        if (user == null) {
            return ResponseEntity.status(401).body(Map.of("error", "Non authentifie"));
        }
        if ("employe".equals(user.getRole())) {
            return ResponseEntity.ok(constatService.getConstatsForEmploye(user));
        }
        if (!"admin".equals(user.getRole())) {
            return ResponseEntity.status(403).body(Map.of("error", "Acces reserve au dashboard admin/employe"));
        }
        return ResponseEntity.ok(constatService.getAllConstats(statut));
    }

    /** Dashboard: update statut of a constat. */
    @PutMapping("/{id}/statut")
    public ResponseEntity<?> updateStatut(
            @AuthenticationPrincipal User user,
            @PathVariable Long id,
            @RequestBody Map<String, String> body) {
        if (user == null) {
            return ResponseEntity.status(401).body(Map.of("error", "Non authentifie"));
        }
        if (!isDashboardRole(user)) {
            return ResponseEntity.status(403).body(Map.of("error", "Acces reserve aux administrateurs et employes"));
        }

        String newStatut = body.get("statut");
        if (newStatut == null || newStatut.isBlank()) {
            return ResponseEntity.badRequest().body(Map.of("error", "Statut requis"));
        }
        if (!ConstatService.STATUTS.contains(newStatut)) {
            return ResponseEntity.badRequest().body(Map.of("error", "Statut invalide"));
        }
        if (!constatService.constatExists(id)) {
            return ResponseEntity.status(404).body(Map.of("error", "Constat non trouve"));
        }

        String comment = body.get("comment");
        if ("Rejeté".equals(newStatut) && (comment == null || comment.isBlank())) {
            return ResponseEntity.badRequest().body(Map.of("error", "Motif de rejet requis"));
        }
        boolean updated = constatService.updateConstatStatut(id, newStatut, user, comment);
        if (updated) {
            return ResponseEntity.ok(Map.of("success", true, "message", "Statut mis a jour"));
        }
        return ResponseEntity.status(409).body(Map.of("error", "Ce constat est deja en cours de traitement par un autre employe"));
    }

    @PutMapping("/{id}/assign")
    public ResponseEntity<?> assignConstat(
            @AuthenticationPrincipal User user,
            @PathVariable Long id,
            @RequestBody Map<String, Object> body) {
        if (user == null) {
            return ResponseEntity.status(401).body(Map.of("error", "Non authentifie"));
        }
        Object employeIdRaw = body.get("employeId");
        if (employeIdRaw == null) {
            return ResponseEntity.badRequest().body(Map.of("error", "Employe requis"));
        }
        Long employeId = employeIdRaw instanceof Number number
                ? number.longValue()
                : Long.parseLong(employeIdRaw.toString());
        boolean assigned = constatService.assignConstat(id, employeId, user, (String) body.get("comment"));
        if (!assigned) {
            return ResponseEntity.status(400).body(Map.of("error", "Affectation impossible"));
        }
        return ResponseEntity.ok(Map.of("success", true, "message", "Constat affecte"));
    }

    @PutMapping("/{id}/tracking")
    public ResponseEntity<?> updateTracking(
            @AuthenticationPrincipal User user,
            @PathVariable Long id,
            @RequestBody Map<String, Object> body) {
        if (user == null) {
            return ResponseEntity.status(401).body(Map.of("error", "Non authentifie"));
        }
        boolean updated = constatService.updateTracking(id, user, body);
        if (!updated) {
            return ResponseEntity.status(403).body(Map.of("error", "Mise a jour non autorisee"));
        }
        return ResponseEntity.ok(Map.of("success", true, "message", "Suivi mis a jour"));
    }

    @GetMapping("/{id}/history")
    public ResponseEntity<?> getHistory(
            @AuthenticationPrincipal User user,
            @PathVariable Long id) {
        if (user == null) {
            return ResponseEntity.status(401).body(Map.of("error", "Non authentifie"));
        }
        if (!constatService.canAccessConstat(id, user)) {
            return ResponseEntity.status(403).body(Map.of("error", "Acces non autorise a ce constat"));
        }
        return ResponseEntity.ok(constatService.getConstatHistory(id));
    }

    @GetMapping("/admin/notifications")
    public ResponseEntity<?> getAdminNotifications(@AuthenticationPrincipal User user) {
        if (user == null) {
            return ResponseEntity.status(401).body(Map.of("error", "Non authentifie"));
        }
        if (!"admin".equals(user.getRole())) {
            return ResponseEntity.status(403).body(Map.of("error", "Acces reserve aux administrateurs"));
        }
        return ResponseEntity.ok(constatService.getAdminNotifications());
    }

    @GetMapping("/admin/performance")
    public ResponseEntity<?> getEmployeePerformance(@AuthenticationPrincipal User user) {
        if (user == null) {
            return ResponseEntity.status(401).body(Map.of("error", "Non authentifie"));
        }
        if (!"admin".equals(user.getRole())) {
            return ResponseEntity.status(403).body(Map.of("error", "Acces reserve aux administrateurs"));
        }
        return ResponseEntity.ok(constatService.getEmployeePerformance());
    }

    @PostMapping("/{id}/uploads")
    public ResponseEntity<?> uploadConstatFiles(
            @PathVariable Long id,
            @AuthenticationPrincipal User user,
            @RequestParam(value = "croquis", required = false) MultipartFile croquis,
            @RequestParam(value = "signatureA", required = false) MultipartFile signatureA,
            @RequestParam(value = "signatureB", required = false) MultipartFile signatureB,
            @RequestParam(value = "photos", required = false) MultipartFile[] photos) {

        if (user == null) {
            return ResponseEntity.status(401).body(Map.of("error", "Non authentifie"));
        }
        if (!constatService.constatExists(id)) {
            return ResponseEntity.status(404).body(Map.of("error", "Constat non trouve"));
        }
        if (!constatService.canAccessConstat(id, user)) {
            return ResponseEntity.status(403).body(Map.of("error", "Acces non autorise a ce constat"));
        }

        try {
            String uploadDir = "uploads/constats/" + id + "/";
            File dir = new File(uploadDir);
            if (!dir.exists()) dir.mkdirs();

            String croquisPath = null;
            if (croquis != null && !croquis.isEmpty()) {
                String filename = "croquis_" + System.currentTimeMillis() + ".png";
                croquisPath = uploadDir + filename;
                croquis.transferTo(new File(dir.getAbsolutePath() + "/" + filename));
            }

            String sigAPath = null;
            if (signatureA != null && !signatureA.isEmpty()) {
                String filename = "sigA_" + System.currentTimeMillis() + ".png";
                sigAPath = uploadDir + filename;
                signatureA.transferTo(new File(dir.getAbsolutePath() + "/" + filename));
            }

            String sigBPath = null;
            if (signatureB != null && !signatureB.isEmpty()) {
                String filename = "sigB_" + System.currentTimeMillis() + ".png";
                sigBPath = uploadDir + filename;
                signatureB.transferTo(new File(dir.getAbsolutePath() + "/" + filename));
            }

            List<String> photosPaths = new ArrayList<>();
            if (photos != null) {
                for (int i = 0; i < photos.length; i++) {
                    if (!photos[i].isEmpty()) {
                        String filename = "photo_" + i + "_" + System.currentTimeMillis() + ".jpg";
                        photos[i].transferTo(new File(dir.getAbsolutePath() + "/" + filename));
                        photosPaths.add(uploadDir + filename);
                    }
                }
            }

            constatService.saveConstatFiles(id, croquisPath, sigAPath, sigBPath,
                    photosPaths.isEmpty() ? null : String.join(",", photosPaths));

            return ResponseEntity.ok(Map.of("success", true, "message", "Fichiers sauvegardes"));
        } catch (IOException e) {
            return ResponseEntity.status(500).body(Map.of("success", false, "message", "Erreur lors de la sauvegarde des fichiers"));
        }
    }

    private boolean isDashboardRole(User user) {
        return "admin".equals(user.getRole()) || "employe".equals(user.getRole());
    }
}
