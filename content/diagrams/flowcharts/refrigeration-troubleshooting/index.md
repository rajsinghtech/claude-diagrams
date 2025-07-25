---
title: "Supermarket Refrigeration Over-Temperature Alarm Troubleshooting"
description: "Systematic flowchart for diagnosing and resolving over-temperature alarms in commercial refrigeration cases"
date: 2025-01-25
categories: ["flowcharts"]
tags: ["refrigeration", "troubleshooting", "maintenance", "commercial", "hvac", "diagnostics"]
---

## Supermarket Refrigeration Over-Temperature Alarm Troubleshooting

This flowchart provides a systematic approach to diagnose over-temperature alarms in supermarket refrigeration cases. Follow the decision tree from initial alarm activation through various diagnostic steps to identify and resolve the issue.

### Key Decision Points:
- **Temperature Verification**: Confirm actual vs. setpoint temperature
- **Airflow Inspection**: Check for obstructions or ice buildup
- **Component Testing**: Evaluate fans, compressor, and refrigerant system
- **Resolution Paths**: DIY fixes vs. professional service requirements

### Color Legend:
- 🔴 **Red**: Alarm/Problem state
- 🔵 **Blue**: Decision/Check points
- 🟢 **Green**: Problem resolved
- 🟠 **Orange**: Call service technician

```mermaid
graph TD
    Start[Over-Temperature Alarm Activated] --> A{Verify Actual<br/>Temperature}
    A -->|Above Setpoint| B[Check Temperature<br/>Controller Settings]
    A -->|Normal| Z[Check Alarm<br/>System/Sensors]
    
    B -->|Incorrect| B1[Adjust Setpoint<br/>34-38°F]
    B -->|Correct| C{Inspect Airflow}
    
    C -->|Blocked| C1[Clear Product<br/>From Evaporator]
    C -->|Ice Buildup| C2[Check Defrost<br/>System]
    C -->|Clear| D{Check Door<br/>Seals}
    
    D -->|Damaged| D1[Replace Gaskets/<br/>Adjust Door]
    D -->|Good| E{Inspect Condenser<br/>Coils}
    
    E -->|Dirty| E1[Clean Condenser<br/>Coils]
    E -->|Clean| F{Test Fans}
    
    F -->|Not Running| F1[Check Fan Motors/<br/>Replace if Needed]
    F -->|Running| G{Compressor<br/>Operation}
    
    G -->|Short Cycling| H[Check Refrigerant<br/>Pressures]
    G -->|Not Running| G1[Check Power/<br/>Electrical]
    G -->|Continuous Run| H
    
    H -->|Low| H1[Possible Refrigerant<br/>Leak]
    H -->|High| H2[Check Condenser/<br/>Airflow Issues]
    H -->|Normal| I[Check Control<br/>System]
    
    B1 --> Fixed[Problem<br/>Resolved]
    C1 --> Fixed
    C2 --> Tech
    D1 --> Fixed
    E1 --> Fixed
    F1 --> Fixed
    G1 --> Tech[Call Service<br/>Technician]
    H1 --> Tech
    H2 --> Fixed
    I --> Tech
    Z --> Tech
    
    style Start fill:#d32f2f,stroke:#fff,stroke-width:2px,color:#fff
    style Fixed fill:#388e3c,stroke:#fff,stroke-width:2px,color:#fff
    style Tech fill:#f57c00,stroke:#fff,stroke-width:2px,color:#fff
    style A fill:#1976d2,stroke:#fff,stroke-width:2px,color:#fff
    style C fill:#1976d2,stroke:#fff,stroke-width:2px,color:#fff
    style D fill:#1976d2,stroke:#fff,stroke-width:2px,color:#fff
    style E fill:#1976d2,stroke:#fff,stroke-width:2px,color:#fff
    style F fill:#1976d2,stroke:#fff,stroke-width:2px,color:#fff
    style G fill:#1976d2,stroke:#fff,stroke-width:2px,color:#fff
```

### Critical Temperature Thresholds:
- **Refrigerated Cases**: Should maintain 34-38°F (1-3°C)
- **Freezer Cases**: Should maintain below 0°F (-18°C)
- **Alarm Triggers**: Typically activate when temperature exceeds setpoint by 10°F for more than 90 minutes

### Common Causes:
1. **Airflow Issues** (40% of cases): Product blocking evaporator, dirty coils
2. **Door Seal Problems** (25% of cases): Worn gaskets, misaligned doors
3. **Mechanical Failures** (20% of cases): Fan motors, compressor issues
4. **Refrigerant Problems** (15% of cases): Leaks, improper charge

### When to Call a Technician:
- Refrigerant system issues (requires EPA certification)
- Electrical problems or compressor failure
- Control system malfunctions
- Repeated alarms after basic troubleshooting