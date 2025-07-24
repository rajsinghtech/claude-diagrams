---
title: "NAT Traversal and Connection Upgrade Flow"
description: "Flowchart showing Tailscale's NAT traversal process and how connections upgrade from DERP relay to direct peer-to-peer"
date: 2025-01-24
categories: ["flowcharts"]
tags: ["nat-traversal", "stun", "disco", "connection-upgrade", "p2p", "derp", "wireguard"]
---

This flowchart illustrates how Tailscale attempts to establish direct connections between peers and upgrades from DERP relay when possible.

```mermaid
graph TD
    Start[New Connection Request<br/>Node A → Node B] --> GetInfo{Peer Info<br/>Available?}
    
    GetInfo -->|No| QueryControl[Query Control Server<br/>for peer endpoints]
    GetInfo -->|Yes| CheckDirect{Can reach<br/>directly?}
    
    QueryControl --> StoreInfo[Store peer info:<br/>- Public IPs<br/>- DERP regions<br/>- Endpoints]
    StoreInfo --> CheckDirect
    
    CheckDirect -->|Public IP available| TryDirect[Attempt direct<br/>UDP connection]
    CheckDirect -->|Behind NAT| StartDERP[Establish DERP<br/>relay connection]
    
    StartDERP --> DERPActive[DERP Connection Active<br/>✓ Packets flowing]
    
    DERPActive --> StartDisco[Start DISCO Protocol<br/>in parallel]
    
    StartDisco --> SendSTUN[Send STUN-like probes<br/>to all known endpoints]
    
    SendSTUN --> MultiProbe[Probe multiple paths:<br/>- Last known endpoint<br/>- STUN discovered IPs<br/>- Local network IPs<br/>- IPv6 addresses]
    
    MultiProbe --> AnalyzeResponses{Received<br/>probe response?}
    
    AnalyzeResponses -->|Yes| ValidatePath[Validate path:<br/>- Latency check<br/>- Packet loss test<br/>- MTU discovery]
    AnalyzeResponses -->|No| RetryProbes{Retry<br/>limit reached?}
    
    RetryProbes -->|No| SendSTUN
    RetryProbes -->|Yes| StayOnDERP[Continue using<br/>DERP relay]
    
    ValidatePath --> PathGood{Path quality<br/>acceptable?}
    
    PathGood -->|Yes| EstablishDirect[Establish direct<br/>WireGuard tunnel]
    PathGood -->|No| TryAltPath{Alternative<br/>paths available?}
    
    TryAltPath -->|Yes| MultiProbe
    TryAltPath -->|No| StayOnDERP
    
    EstablishDirect --> MigrateDirect[Migrate traffic<br/>to direct path]
    
    MigrateDirect --> MonitorDirect[Monitor connection:<br/>- Heartbeat packets<br/>- Quality metrics]
    
    MonitorDirect --> DirectStable{Connection<br/>stable?}
    
    DirectStable -->|Yes| DirectActive[Direct P2P Active<br/>✓ Optimal performance]
    DirectStable -->|No| FallbackDERP[Fallback to DERP]
    
    FallbackDERP --> DERPActive
    
    TryDirect --> DirectSuccess{Connection<br/>successful?}
    DirectSuccess -->|Yes| DirectActive
    DirectSuccess -->|No| StartDERP
    
    %% Styling
    style Start fill:#1976d2,stroke:#fff,stroke-width:2px,color:#fff
    style DERPActive fill:#f57c00,stroke:#fff,stroke-width:2px,color:#fff
    style DirectActive fill:#388e3c,stroke:#fff,stroke-width:2px,color:#fff
    style StayOnDERP fill:#d32f2f,stroke:#fff,stroke-width:2px,color:#fff
    style QueryControl fill:#e3f2fd,stroke:#000,stroke-width:1px,color:#000
    style SendSTUN fill:#fff3e0,stroke:#000,stroke-width:1px,color:#000
    style MonitorDirect fill:#e8f5e9,stroke:#000,stroke-width:1px,color:#000
```

## Key Concepts

### DISCO Protocol
- **Purpose**: Discover optimal network paths between peers
- **Method**: Sends encrypted probe packets to multiple potential endpoints
- **Parallel Operation**: Runs alongside active DERP connection

### Connection States
1. **DERP Relay**: Initial connection through relay server
2. **Probing**: Attempting to find direct path while maintaining DERP
3. **Direct P2P**: Optimal state with direct UDP connection
4. **Fallback**: Return to DERP if direct connection fails

### Endpoint Discovery Methods
- **STUN Servers**: Discover public IP and port mappings
- **Local Discovery**: Find peers on same network
- **Cached Endpoints**: Try previously successful endpoints
- **IPv6**: Prefer IPv6 when available for better connectivity