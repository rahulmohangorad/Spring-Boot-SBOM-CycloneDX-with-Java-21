package com.example.sbomdemo.web;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@RestController
public class HelloController {

    @GetMapping("/api/hello")
    public ResponseEntity<Map<String, Object>> hello() {
        Map<String, Object> body = new HashMap<>();
        body.put("message", "SBOM demo is running");
        body.put("status", "ok");
        return ResponseEntity.ok(body);
    }
}
