---
title: "DERP UDP Relay Overview"
description: "Technical flowchart showing how Tailscale's DERP (Designated Encrypted Relay for Packets) system handles UDP relay for NAT traversal"
date: 2025-01-24
categories: ["flowcharts"]
tags: ["derp", "udp", "relay", "nat-traversal", "wireguard", "mesh-vpn", "p2p"]
---

This diagram illustrates how Tailscale's DERP relay system works for UDP packet forwarding when direct peer-to-peer connections cannot be established.

```mermaid
graph TD
    subgraph "Node A Network"
        A[Node A<br/>100.64.1.5<br/>Behind NAT]
    end
    
    subgraph "DERP Relay Infrastructure"
        D[DERP Server<br/>Public IP<br/>relay.tailscale.com]
        D1[UDP Socket<br/>Port 3478]
        D2[Connection Table<br/>Node Mappings]
    end
    
    subgraph "Node B Network"
        B[Node B<br/>100.64.1.6<br/>Behind NAT]
    end
    
    subgraph "Control Plane"
        C[Coordination Server<br/>control.tailscale.com]
        C1[DERP Server Selection]
        C2[Node Registry]
    end
    
    %% Control plane connections
    A -.->|1. Register<br/>Get DERP info| C
    B -.->|1. Register<br/>Get DERP info| C
    C -.->|2. Assign nearest<br/>DERP server| A
    C -.->|2. Assign nearest<br/>DERP server| B
    
    %% Initial DERP connections
    A -->|3. Establish<br/>WebSocket/HTTPS| D
    B -->|3. Establish<br/>WebSocket/HTTPS| D
    
    %% UDP relay flow
    A -->|4. Send encrypted<br/>WireGuard packet| D1
    D1 -->|5. Lookup<br/>destination| D2
    D2 -->|6. Forward packet<br/>to Node B| B
    
    %% Return path
    B -->|7. Reply packet| D1
    D1 -->|8. Lookup<br/>source| D2
    D2 -->|9. Forward reply<br/>to Node A| A
    
    %% Parallel STUN attempts
    A -.->|STUN probes| B
    B -.->|STUN probes| A
    
    %% Styling
    style A fill:#1976d2,stroke:#fff,stroke-width:2px,color:#fff
    style B fill:#1976d2,stroke:#fff,stroke-width:2px,color:#fff
    style D fill:#455a64,stroke:#fff,stroke-width:2px,color:#fff
    style C fill:#e3f2fd,stroke:#000,stroke-width:1px,color:#000
    style D1 fill:#f5f5f5,stroke:#000,stroke-width:1px,color:#000
    style D2 fill:#f5f5f5,stroke:#000,stroke-width:1px,color:#000
    style C1 fill:#f5f5f5,stroke:#000,stroke-width:1px,color:#000
    style C2 fill:#f5f5f5,stroke:#000,stroke-width:1px,color:#000
```

## Key Components

- **DERP Server**: Public relay server that forwards encrypted WireGuard packets between peers
- **Control Plane**: Manages DERP server selection and node registration
- **UDP Relay**: Encapsulates WireGuard UDP packets for transport through restrictive networks
- **Connection Table**: Maps node IDs to active connections for packet routing