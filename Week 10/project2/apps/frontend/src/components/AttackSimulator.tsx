import { useState } from "react";

const steps = [
  "Incoming Request",
  "Suspicious Pattern Detected",
  "WAF Triggered",
  "Request Blocked",
  "System Safe",
];

const AttackSimulator = () => {
  const [currentStep, setCurrentStep] = useState<number>(-1);

  const simulateAttack = () => {
    setCurrentStep(0);

    let i = 0;
    const interval = setInterval(() => {
      i++;
      setCurrentStep(i);

      if (i === steps.length - 1) {
        clearInterval(interval);
      }
    }, 800);
  };

  return (
    <div style={{ marginTop: "20px" }}>
      <button onClick={simulateAttack}>Simulate Attack</button>

      <ul>
        {steps.map((step, index) => (
          <li
            key={index}
            style={{
              color:
                index === currentStep
                  ? "orange"
                  : index < currentStep
                  ? "green"
                  : "gray",
            }}
          >
            {step}
          </li>
        ))}
      </ul>
    </div>
  );
};

export default AttackSimulator;
