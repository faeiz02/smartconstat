package com.smartconstat.controller;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.smartconstat.model.InsuranceRequest;
import com.smartconstat.model.User;
import com.smartconstat.repository.InsuranceRequestRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/insurance-requests")
@RequiredArgsConstructor
public class InsuranceRequestController {

    private final InsuranceRequestRepository insuranceRequestRepository;
    private final ObjectMapper objectMapper;

    @PostMapping
    public ResponseEntity<?> createRequest(
            @AuthenticationPrincipal User user,
            @RequestBody Map<String, Object> body) {
        if (user == null) {
            return ResponseEntity.status(401).body(Map.of("error", "Non authentifie"));
        }

        String type = asString(body.get("type"));
        String title = asString(body.get("title"));
        if (type == null || type.isBlank() || title == null || title.isBlank()) {
            return ResponseEntity.badRequest().body(Map.of("error", "Le type et le titre de l'assurance sont requis"));
        }

        try {
            InsuranceRequest request = InsuranceRequest.builder()
                    .user(user)
                    .type(type)
                    .title(title)
                    .price(asString(body.get("price")))
                    .detailsJson(objectMapper.writeValueAsString(detailsFromBody(body.get("details"))))
                    .status(InsuranceRequest.STATUS_PENDING)
                    .build();

            request = insuranceRequestRepository.save(request);

            Map<String, Object> response = new LinkedHashMap<>();
            response.put("success", true);
            response.put("message", "Demande de souscription envoyee. Elle est en attente de validation.");
            response.put("request", toMap(request));
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", "Donnees invalides: " + e.getMessage()));
        }
    }

    @GetMapping
    public ResponseEntity<?> getMyRequests(@AuthenticationPrincipal User user) {
        if (user == null) {
            return ResponseEntity.status(401).body(Map.of("error", "Non authentifie"));
        }
        return ResponseEntity.ok(insuranceRequestRepository.findByUserOrderByCreatedAtDesc(user)
                .stream()
                .map(this::toMap)
                .toList());
    }

    @GetMapping("/all")
    public ResponseEntity<?> getAllRequests(
            @AuthenticationPrincipal User user,
            @RequestParam(required = false) String status) {
        ResponseEntity<?> check = requireAdmin(user);
        if (check != null) return check;

        List<InsuranceRequest> requests = status != null && !status.isBlank()
                ? insuranceRequestRepository.findByStatusOrderByCreatedAtDesc(status)
                : insuranceRequestRepository.findAllByOrderByCreatedAtDesc();

        return ResponseEntity.ok(requests.stream().map(this::toMap).toList());
    }

    @PutMapping("/{id}/status")
    public ResponseEntity<?> updateStatus(
            @AuthenticationPrincipal User user,
            @PathVariable Long id,
            @RequestBody Map<String, Object> body) {
        ResponseEntity<?> check = requireAdmin(user);
        if (check != null) return check;

        String status = asString(body.get("status"));
        if (!isValidStatus(status)) {
            return ResponseEntity.badRequest().body(Map.of("error", "Statut invalide"));
        }

        return insuranceRequestRepository.findById(id)
                .map(request -> {
                    request.setStatus(status);
                    request.setDecisionComment(asString(body.get("comment")));
                    request.setProcessedBy(user);
                    request.setProcessedAt(LocalDateTime.now());
                    InsuranceRequest saved = insuranceRequestRepository.save(request);
                    return ResponseEntity.ok(Map.of(
                            "success", true,
                            "message", "Demande mise a jour",
                            "request", toMap(saved)
                    ));
                })
                .orElse(ResponseEntity.status(404).body(Map.of("error", "Demande non trouvee")));
    }

    private ResponseEntity<?> requireAdmin(User user) {
        if (user == null) return ResponseEntity.status(401).body(Map.of("error", "Non authentifie"));
        if (!"admin".equals(user.getRole())) {
            return ResponseEntity.status(403).body(Map.of("error", "Acces reserve aux administrateurs"));
        }
        return null;
    }

    private boolean isValidStatus(String status) {
        return InsuranceRequest.STATUS_PENDING.equals(status)
                || InsuranceRequest.STATUS_APPROVED.equals(status)
                || InsuranceRequest.STATUS_REJECTED.equals(status);
    }

    private Map<String, String> detailsFromBody(Object details) {
        Map<String, String> result = new LinkedHashMap<>();
        if (details instanceof Map<?, ?> map) {
            for (Map.Entry<?, ?> entry : map.entrySet()) {
                if (entry.getKey() != null) {
                    result.put(entry.getKey().toString(), entry.getValue() != null ? entry.getValue().toString() : "");
                }
            }
        }
        return result;
    }

    private Map<String, Object> toMap(InsuranceRequest request) {
        Map<String, Object> map = new LinkedHashMap<>();
        map.put("id", request.getId());
        map.put("type", request.getType());
        map.put("title", request.getTitle());
        map.put("price", request.getPrice());
        map.put("details", readDetails(request.getDetailsJson()));
        map.put("status", request.getStatus());
        map.put("decisionComment", request.getDecisionComment());
        map.put("createdAt", request.getCreatedAt() != null ? request.getCreatedAt().toString() : null);
        map.put("updatedAt", request.getUpdatedAt() != null ? request.getUpdatedAt().toString() : null);
        map.put("processedAt", request.getProcessedAt() != null ? request.getProcessedAt().toString() : null);

        User owner = request.getUser();
        if (owner != null) {
            map.put("userId", owner.getId());
            map.put("userName", fullName(owner));
            map.put("userEmail", owner.getEmail());
            map.put("assuranceId", owner.getAssuranceId());
        }

        User processedBy = request.getProcessedBy();
        if (processedBy != null) {
            map.put("processedById", processedBy.getId());
            map.put("processedByName", fullName(processedBy));
        }
        return map;
    }

    private Map<String, Object> readDetails(String detailsJson) {
        if (detailsJson == null || detailsJson.isBlank()) {
            return Map.of();
        }
        try {
            return objectMapper.readValue(detailsJson, new TypeReference<>() {});
        } catch (Exception e) {
            return Map.of("raw", detailsJson);
        }
    }

    private String fullName(User user) {
        String nom = user.getNom() != null ? user.getNom() : "";
        String prenom = user.getPrenom() != null ? user.getPrenom() : "";
        String fullName = (nom + " " + prenom).trim();
        return fullName.isEmpty() ? user.getEmail() : fullName;
    }

    private String asString(Object value) {
        return value == null ? null : value.toString();
    }
}
