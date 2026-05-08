import { useEffect, useMemo, useState } from "react";
import "./App.css";

type ScanResult = {
  url?: string;
  status?: string;
  score?: number;
  issues?: string[] | string;
  error?: boolean;
};

const trustBadges = [
  "Trusted HTTPS",
  "Private Azure Architecture",
  "WAF Protected",
  "Monitored",
];

const steps = [
  "Paste URL",
  "Analyze Signals",
  "Get Safety Feedback",
];

function normalizeIssues(issues: ScanResult["issues"]) {
  if (!issues) return [];
  if (Array.isArray(issues)) return issues;
  return issues
    .split(",")
    .map((item) => item.trim())
    .filter(Boolean);
}

export default function App() {
  const [url, setUrl] = useState("");
  const [result, setResult] = useState<ScanResult | null>(null);
  const [loading, setLoading] = useState(false);
const [history, setHistory] = useState<ScanResult[]>([]);

  const issues = useMemo(() => normalizeIssues(result?.issues), [result]);

const dashboard = useMemo(() => {
  const total = history.length;
  const safe = history.filter((item) => item.status?.toLowerCase() === "safe").length;
  const suspicious = history.filter((item) => item.status?.toLowerCase() === "suspicious").length;
  const invalid = history.filter((item) => item.status?.toLowerCase() === "invalid").length;

  return { total, safe, suspicious, invalid };
}, [history]);

  const isSafe =
    result?.status?.toLowerCase() === "safe" ||
    result?.status?.toLowerCase() === "likely_safe";

useEffect(() => {
  fetch("/api/scans")
    .then((res) => res.json())
    .then((data) => {
      if (Array.isArray(data)) {
        setHistory(data.reverse().slice(0, 8));
      }
    })
    .catch((err) => console.error("History load error:", err));
}, []);
  const analyze = async () => {
    if (!url.trim()) return;

    setLoading(true);
    setResult(null);

    try {
      const response = await fetch("/api/analyze", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ url: url.trim() }),
      });

      if (!response.ok) {
        throw new Error(`Request failed with ${response.status}`);
      }

      const data = await response.json();
      setResult(data);
setHistory((prev) => [data, ...prev].slice(0, 8));
    } catch (error) {
      console.error("Analyze error:", error);
      setResult({ error: true });
    } finally {
      setLoading(false);
    }
  };

  return (
    <main className="app-shell">
      <div className="orb orb-one" />
      <div className="orb orb-two" />
      <div className="grid-overlay" />

      <section className="hero-section">
        <div className="hero-copy">
          <div className="top-badge">
            <span className="pulse-dot" />
            Secure URL Safety Checker
          </div>

          <h1>LinkGuardian</h1>

          <p className="subtitle">
            Check suspicious links before you click.
          </p>

          <p className="supporting-text">
            A simple URL safety checker backed by secure, automated,
            monitored cloud engineering.
          </p>
        </div>

        <section className="analyzer-card" aria-label="URL analyzer">
          <div className="card-header">
            <div>
              <p className="eyebrow">URL analysis</p>
              <h2>Analyze link signals</h2>
            </div>
            <div className="status-pill">Live</div>
          </div>

          <label className="input-label" htmlFor="url-input">
            URL to analyze
          </label>

          <div className="input-row">
            <input
              id="url-input"
              value={url}
              onChange={(event) => setUrl(event.target.value)}
              onKeyDown={(event) => {
                if (event.key === "Enter") analyze();
              }}
              placeholder="Paste a URL to analyze..."
              autoComplete="off"
            />

            <button onClick={analyze} disabled={loading || !url.trim()}>
              {loading ? (
                <>
                  <span className="spinner" />
                  Analyzing...
                </>
              ) : (
                "Analyze URL"
              )}
            </button>
          </div>

          <div className="result-area" aria-live="polite">
            {!result && !loading && (
              <div className="empty-state">
                <div className="empty-icon">⌁</div>
                <p>Enter a URL to begin safety analysis.</p>
              </div>
            )}

            {loading && (
              <div className="loading-state">
                <div className="scan-line" />
                <p>Analyzing link signals...</p>
              </div>
            )}

            {result?.error && (
              <div className="result-card danger">
                <h3>Analysis unavailable</h3>
                <p>
                  The request could not be completed. Please try again in a few
                  seconds.
                </p>
              </div>
            )}

            {result && !result.error && (
              <div className={`result-card ${isSafe ? "safe" : "danger"}`}>
                <div className="result-top">
                  <div>
                    <p className="eyebrow">Result</p>
                    <h3>{isSafe ? "Likely Safe" : "Suspicious Link"}</h3>
                  </div>

                  <div className="score-ring">
                    <span>{result.score ?? 0}</span>
                    <small>%</small>
                  </div>
                </div>

                <p className="result-summary">
                  {isSafe
                    ? "No major suspicious indicators detected."
                    : "This URL contains signals that may require caution."}
                </p>

                {issues.length > 0 && (
                  <div className="issue-list">
                    {issues.map((issue, index) => (
                      <span key={`${issue}-${index}`} className="issue-chip">
                        {issue}
                      </span>
                    ))}
                  </div>
                )}

                {result.url && <code className="url-preview">{result.url}</code>}
              </div>
            )}
          </div>

          <p className="microcopy">
            LinkGuardian helps identify suspicious patterns, but no tool can
            guarantee 100% safety.
          </p>
        </section>

        <div className="trust-row">
          {trustBadges.map((badge) => (
            <span key={badge}>{badge}</span>
          ))}
        </div>

        <div className="how-it-works">
          {steps.map((step, index) => (
            <div className="step" key={step}>
              <span>{index + 1}</span>
              <p>{step}</p>
            </div>
          ))}
        </div>

{history.length > 0 && (
  <section className="dashboard-grid">
    <div className="metric-card">
      <p>Total scans</p>
      <strong>{dashboard.total}</strong>
    </div>
    <div className="metric-card safe-metric">
      <p>Likely safe</p>
      <strong>{dashboard.safe}</strong>
    </div>
    <div className="metric-card danger-metric">
      <p>Suspicious</p>
      <strong>{dashboard.suspicious}</strong>
    </div>
    <div className="metric-card invalid-metric">
      <p>Invalid</p>
      <strong>{dashboard.invalid}</strong>
    </div>
  </section>
)}

{history.length > 0 && (
  <section className="history-card">
    <div className="history-header">
      <div>
        <p className="eyebrow">Recent scans</p>
        <h2>Scan history</h2>
      </div>
      <span>{history.length} saved</span>
    </div>

    <div className="history-list">
      {history.map((item, index) => {
        const safe =
          item.status?.toLowerCase() === "safe" ||
          item.status?.toLowerCase() === "likely_safe";

        return (
          <div className="history-item" key={`${item.url}-${index}`}>
            <div>
              <strong>{item.url}</strong>
              <p>{safe ? "Likely Safe" : "Suspicious Link"}</p>
            </div>

            <span className={safe ? "history-safe" : "history-danger"}>
              {item.score ?? 0}%
            </span>
          </div>
        );
      })}
    </div>
  </section>
)}
      </section>
    </main>
  );
}
