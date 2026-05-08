package com.casp.backend.controller;

import com.casp.backend.model.ScanResult;
import com.casp.backend.repository.ScanResultRepository;
import com.casp.backend.security.UrlSecurityAnalyzer;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@CrossOrigin
public class AnalyzeController {

    private final ScanResultRepository repository;

    public AnalyzeController(ScanResultRepository repository) {
        this.repository = repository;
    }

    @PostMapping({"/api/analyze", "/analyze"})
    public Map<String, Object> analyze(@RequestBody Map<String, String> body) {
        String url = body.get("url");

        Map<String, Object> result = UrlSecurityAnalyzer.analyze(url);

        repository.save(new ScanResult(
                url,
                (String) result.get("status"),
                (Integer) result.get("score"),
                String.valueOf(result.get("issues"))
        ));

        return result;
    }
}
