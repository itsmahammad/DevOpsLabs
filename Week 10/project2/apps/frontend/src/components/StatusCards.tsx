const StatusCards = () => {
  const cards = [
    { title: "System Status", value: "Secure" },
    { title: "WAF Status", value: "Active" },
    { title: "Public Entry Points", value: "1" },
    { title: "Backend Health", value: "Healthy" },
    { title: "Database Access", value: "Private Endpoint" },
    { title: "Last Attack", value: "Blocked" },
  ];

  return (
    <div style={{ display: "flex", flexWrap: "wrap", gap: "10px" }}>
      {cards.map((card, i) => (
        <div
          key={i}
          style={{
            border: "1px solid #444",
            padding: "10px",
            borderRadius: "8px",
            width: "200px",
          }}
        >
          <h4>{card.title}</h4>
          <p>{card.value}</p>
        </div>
      ))}
    </div>
  );
};

export default StatusCards;
