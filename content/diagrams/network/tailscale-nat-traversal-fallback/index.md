---
title: "Tailscale NAT Traversal and Fallback Mechanism"
description: "Comprehensive diagram showing Tailscale's multi-technique NAT traversal approach and fallback to DERP relay"
date: 2025-07-24
categories: ["network"]
tags: ["tailscale", "nat-traversal", "stun", "upnp", "derp", "fallback", "cgnat", "firewall"]
---

## Overview

This diagram illustrates Tailscale's sophisticated NAT traversal techniques and the decision flow for using direct connections versus DERP relay fallback.

```mermaid
graph TD
    Start[Connection Request] --> GetInfo[Gather Network Info]
    
    GetInfo --> STUN[STUN Discovery<br/>Get Public IP:Port]
    GetInfo --> UPnP[Try UPnP/NAT-PMP<br/>Port Mapping]
    GetInfo --> Local[Detect Local<br/>Network Interfaces]
    
    STUN --> Analysis{Analyze NAT Type}
    UPnP --> Analysis
    Local --> Analysis
    
    Analysis -->|Easy NAT| EasyNAT[Full Cone NAT<br/>or Port Restricted]
    Analysis -->|Hard NAT| HardNAT[Symmetric NAT<br/>or CGNAT]
    Analysis -->|No UDP| NoUDP[UDP Blocked<br/>TCP Only]
    
    EasyNAT --> DirectAttempt[Attempt Direct<br/>Connection]
    HardNAT --> AdvancedNAT[Advanced NAT<br/>Traversal]
    
    DirectAttempt --> SimulTX[Simultaneous<br/>Transmission]
    SimulTX --> DISCO[DISCO Protocol<br/>Endpoint Discovery]
    
    AdvancedNAT --> Birthday[Birthday Paradox<br/>Port Prediction]
    AdvancedNAT --> MultiPath[Try Multiple<br/>Source Ports]
    Birthday --> DISCO
    MultiPath --> DISCO
    
    DISCO --> Success{Connection<br/>Established?}
    
    Success -->|Yes| Direct[Direct P2P<br/>WireGuard Tunnel<br/>✓ Low Latency<br/>✓ High Throughput]
    Success -->|No| DERPRelay[DERP Relay<br/>Fallback<br/>○ Reliable<br/>○ Higher Latency]
    
    NoUDP --> DERPRelay
    
    DERPRelay --> Monitor[Monitor for<br/>Network Changes]
    Monitor --> Retry[Periodic Retry<br/>Direct Connection]
    Retry --> DirectAttempt
    
    style Start fill:#1976d2,stroke:#fff,stroke-width:2px,color:#fff
    style Direct fill:#388e3c,stroke:#fff,stroke-width:2px,color:#fff
    style DERPRelay fill:#f57c00,stroke:#fff,stroke-width:2px,color:#fff
    style NoUDP fill:#d32f2f,stroke:#fff,stroke-width:2px,color:#fff
    
    classDef technique fill:#e3f2fd,stroke:#1976d2,stroke-width:1px,color:#000
    class STUN,UPnP,Local,SimulTX,Birthday,MultiPath technique
    
    classDef decision fill:#fff3e0,stroke:#f57c00,stroke-width:2px,color:#000
    class Analysis,Success decision
```

## NAT Traversal Techniques

### Primary Methods

1. **STUN (Session Traversal Utilities for NAT)**
   - Discovers public IP and port mappings
   - Identifies NAT behavior characteristics

2. **Simultaneous Transmission**
   - Both peers send packets at the same time
   - Opens bidirectional firewall holes

3. **Port Mapping Protocols**
   - UPnP (Universal Plug and Play)
   - NAT-PMP (NAT Port Mapping Protocol)
   - Creates persistent port forwards

### Advanced Techniques

1. **Birthday Paradox**
   - Statistical approach for symmetric NATs
   - Tries multiple port combinations

2. **Multi-Path Probing**
   - Tests various source ports
   - Increases connection success probability

### Fallback Strategy

When all NAT traversal techniques fail, Tailscale falls back to DERP relay:
- **Instant Connectivity**: No connection failures from user perspective
- **Continuous Optimization**: Keeps trying direct connection in background
- **Seamless Transition**: Switches to direct when possible without disruption

## Network Scenarios

- **Easy NAT**: Full cone or restricted cone NAT - usually succeeds with basic techniques
- **Hard NAT**: Symmetric NAT or CGNAT - requires advanced techniques
- **No UDP**: Corporate firewalls blocking UDP - must use DERP over HTTPS/TCP