package com.jugaad.devops.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.Instant;
import java.util.HashMap;
import java.util.Map;

@RestController
public class HealthController {

    @GetMapping("/health")
    public ResponseEntity<Map<String, Object>> healthCheck() {
        Map<String, Object> response = new HashMap<>();
        response.put("status", "UP");
        response.put("service", "project-jugaad-api");
        response.put("timestamp", Instant.now().toString());
        response.put("deploymentMode", "Zero-Touch CI/CD Automated");
        return ResponseEntity.ok(response);
    }

    @GetMapping("/info")
    public ResponseEntity<Map<String, Object>> getInfo() {
        Map<String, Object> info = new HashMap<>();
        info.put("appName", "DevOps Java Pipeline Application");
        info.put("version", "1.0.0");
        info.put("description", "Automated deployment pipeline target app built with Spring Boot & Docker.");
        return ResponseEntity.ok(info);
    }
}
