package com.casp.backend.security;

import java.net.URI;
import java.util.*;

public class UrlSecurityAnalyzer {

    private static final List<String> SUSPICIOUS_KEYWORDS = List.of(
            "login", "verify", "password", "account",
            "suspended", "urgent", "confirm", "billing",
            "bank", "gift", "claim"
    );

    private static final Map<String, String> BRANDS = Map.of(
            "google", "google.com",
            "microsoft", "microsoft.com",
            "paypal", "paypal.com",
            "facebook", "facebook.com",
            "amazon", "amazon.com"
    );

    public static Map<String, Object> analyze(String input) {
        Map<String, Object> result = new HashMap<>();
        List<String> reasons = new ArrayList<>();

        if (input == null || input.trim().isEmpty()) {
            return invalid("Empty input");
        }

        input = input.trim();

        if (!input.startsWith("http://") && !input.startsWith("https://")) {
            return invalid("URL must include http:// or https://");
        }

        URI uri;
        try {
            uri = new URI(input);
        } catch (Exception e) {
            return invalid("Invalid URL format");
        }

        String host = uri.getHost();

        if (host == null || !host.contains(".")) {
            return invalid("Invalid host");
        }

        int score = 0;

        // HTTP (not HTTPS)
        if (uri.getScheme().equals("http")) {
            score += 20;
            reasons.add("Uses HTTP instead of HTTPS");
        }

        // Length
        if (input.length() > 100) {
            score += 10;
            reasons.add("URL is long");
        }

        // Keywords
        for (String kw : SUSPICIOUS_KEYWORDS) {
            if (input.toLowerCase().contains(kw)) {
                score += 10;
                reasons.add("Contains keyword: " + kw);
            }
        }

        // IP address
        if (host.matches("\\d+\\.\\d+\\.\\d+\\.\\d+")) {
            score += 30;
            reasons.add("Uses IP address instead of domain");
        }

        // Leetspeak (g00gle, paypa1 etc)
        String normalized = host.replace("0", "o")
                                .replace("1", "l")
                                .replace("3", "e");

        for (String brand : BRANDS.keySet()) {
            if (normalized.contains(brand) && !host.equals(BRANDS.get(brand))) {
                score += 25;
                reasons.add("Possible impersonation of " + brand);
            }
        }

        String status = score < 20 ? "SAFE" : "SUSPICIOUS";

        result.put("status", status);
        result.put("score", score);
        result.put("issues", String.join(", ", reasons));
        result.put("url", input);

        return result;
    }

    private static Map<String, Object> invalid(String msg) {
        Map<String, Object> r = new HashMap<>();
        r.put("status", "INVALID");
        r.put("score", 100);
        r.put("issues", msg);
        return r;
    }
}
