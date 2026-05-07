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
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
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
            return ResponseEntity.status(401).body(Map.of("error", "Non authentifié"));
        }
        Map<String, Object> result = constatService.createConstat(user, data);
        return ResponseEntity.ok(result);
    }

    @GetMapping
    public ResponseEntity<?> getConstats(@AuthenticationPrincipal User user) {
        if (user == null) {
            return ResponseEntity.status(401).body(Map.of("error", "Non authentifié"));
        }
        List<Map<String, Object>> constats = constatService.getUserConstats(user);
        return ResponseEntity.ok(constats);
    }

    /** Dashboard: Get all constats, optionally filtered by statut */
    @GetMapping("/all")
    public ResponseEntity<?> getAllConstats(
            @AuthenticationPrincipal User user,
            @RequestParam(required = false) String statut) {
        if (user == null) {
            return ResponseEntity.status(401).body(Map.of("error", "Non authentifié"));
        }
        // Les employés ne voient que les constats "Non examiné" + ceux qu'ils traitent
        if ("employe".equals(user.getRole())) {
            List<Map<String, Object>> constats = constatService.getConstatsForEmploye(user);
            return ResponseEntity.ok(constats);
        }
        // Admin voit tout
        List<Map<String, Object>> constats = constatService.getAllConstats(statut);
        return ResponseEntity.ok(constats);
    }

    /** Dashboard: Update statut of a constat */
    @PutMapping("/{id}/statut")
    public ResponseEntity<?> updateStatut(
            @AuthenticationPrincipal User user,
            @PathVariable Long id,
            @RequestBody Map<String, String> body) {
        if (user == null) {
            return ResponseEntity.status(401).body(Map.of("error", "Non authentifié"));
        }
        String newStatut = body.get("statut");
        if (newStatut == null || newStatut.isBlank()) {
            return ResponseEntity.badRequest().body(Map.of("error", "Statut requis"));
        }
        boolean updated = constatService.updateConstatStatut(id, newStatut, user);
        if (updated) {
            return ResponseEntity.ok(Map.of("success", true, "message", "Statut mis à jour"));
        }
        return ResponseEntity.status(409).body(Map.of("error", "Ce constat est déjà en cours de traitement par un autre employé"));
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
            return ResponseEntity.status(401).body(Map.of("error", "Non authentifié"));
        }

        try {
            String uploadDir = "uploads/constats/" + id + "/";
            File dir = new File(uploadDir);
            if (!dir.exists()) dir.mkdirs();

            String croquisPath = null;
            if (croquis != null && !croquis.isEmpty()) {
                croquisPath = uploadDir + "croquis_" + System.currentTimeMillis() + ".png";
                croquis.transferTo(new File(dir.getAbsolutePath() + "/croquis_" + System.currentTimeMillis() + ".png"));
            }

            String sigAPath = null;
            if (signatureA != null && !signatureA.isEmpty()) {
                sigAPath = uploadDir + "sigA_" + System.currentTimeMillis() + ".png";
                signatureA.transferTo(new File(dir.getAbsolutePath() + "/sigA_" + System.currentTimeMillis() + ".png"));
            }

            String sigBPath = null;
            if (signatureB != null && !signatureB.isEmpty()) {
                sigBPath = uploadDir + "sigB_" + System.currentTimeMillis() + ".png";
                signatureB.transferTo(new File(dir.getAbsolutePath() + "/sigB_" + System.currentTimeMillis() + ".png"));
            }

            List<String> photosPaths = new ArrayList<>();
            if (photos != null) {
                for (int i = 0; i < photos.length; i++) {
                    if (!photos[i].isEmpty()) {
                        String p = uploadDir + "photo_" + i + "_" + System.currentTimeMillis() + ".jpg";
                        photos[i].transferTo(new File(dir.getAbsolutePath() + "/photo_" + i + "_" + System.currentTimeMillis() + ".jpg"));
                        photosPaths.add(p);
                    }
                }
            }

            constatService.saveConstatFiles(id, croquisPath, sigAPath, sigBPath, 
                    photosPaths.isEmpty() ? null : String.join(",", photosPaths));

            return ResponseEntity.ok(Map.of("success", true, "message", "Fichiers sauvegardés"));
        } catch (IOException e) {
            return ResponseEntity.status(500).body(Map.of("success", false, "message", "Erreur lors de la sauvegarde des fichiers"));
        }
    }
}
