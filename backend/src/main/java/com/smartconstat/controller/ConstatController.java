package com.smartconstat.controller;

import com.smartconstat.model.User;
import com.smartconstat.service.ConstatService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

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
}
