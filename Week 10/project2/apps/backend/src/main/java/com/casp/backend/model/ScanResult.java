package com.casp.backend.model;

import jakarta.persistence.*;

@Entity
public class ScanResult {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String url;
    private String status;
    private int score;

    @Column(length = 2000)
    private String issues;

    public ScanResult() {}

    public ScanResult(String url, String status, int score, String issues) {
        this.url = url;
        this.status = status;
        this.score = score;
        this.issues = issues;
    }

    public Long getId() { return id; }
    public String getUrl() { return url; }
    public String getStatus() { return status; }
    public int getScore() { return score; }
    public String getIssues() { return issues; }
}
