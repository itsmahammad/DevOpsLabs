package com.casp.backend.controller;

import com.casp.backend.model.ScanResult;
import com.casp.backend.repository.ScanResultRepository;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@CrossOrigin
public class ScanController {

    private final ScanResultRepository repository;

    public ScanController(ScanResultRepository repository) {
        this.repository = repository;
    }

    @GetMapping({"/api/scans", "/scans"})
    public List<ScanResult> getScans() {
        return repository.findAll();
    }
}
