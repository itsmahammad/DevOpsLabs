const LogsPanel = () => {
  const logs = [
    { time: "12:00", severity: "HIGH", message: "SQL Injection attempt detected" },
    { time: "12:01", severity: "MEDIUM", message: "WAF rule triggered" },
    { time: "12:02", severity: "INFO", message: "Request blocked successfully" },
  ];

  return (
    <div style={{ marginTop: "20px" }}>
      <h3>Logs</h3>
      <ul>
        {logs.map((log, i) => (
          <li key={i}>
            [{log.time}] ({log.severity}) - {log.message}
          </li>
        ))}
      </ul>
    </div>
  );
};

export default LogsPanel;
