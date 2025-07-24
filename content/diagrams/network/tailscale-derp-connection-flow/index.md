---
title: "Tailscale DERP Connection Establishment Flow"
description: "Detailed sequence diagram showing how Tailscale establishes connections using DERP servers and DISCO protocol"
date: 2025-07-24
categories: ["network"]
tags: ["tailscale", "derp", "disco", "connection-establishment", "wireguard", "nat-traversal"]
---

## Overview

This diagram shows the detailed connection establishment flow in Tailscale, including DERP home selection, DISCO protocol messages, and the transition from relayed to direct connections.

```mermaid
sequenceDiagram
    participant NodeA as Node A<br/>100.64.1.10
    participant Coord as Coordination<br/>Server
    participant DERP1 as DERP nyc<br/>(Nearest)
    participant DERP2 as DERP fra<br/>(Node B Home)
    participant NodeB as Node B<br/>100.64.2.20
    
    Note over NodeA,NodeB: Initial Setup Phase
    NodeA->>Coord: Get DERP Map
    Coord-->>NodeA: DERP Server List
    NodeA->>DERP1: Latency Test
    NodeA->>DERP2: Latency Test
    NodeA->>DERP1: Select as DERP Home
    
    NodeB->>Coord: Get DERP Map
    Coord-->>NodeB: DERP Server List
    NodeB->>DERP2: Select as DERP Home
    
    Note over NodeA,NodeB: Connection Establishment
    NodeA->>Coord: Request to connect to Node B
    Coord-->>NodeA: Node B info + DERP Home (fra)
    
    NodeA->>DERP1: Connect (TLS)
    NodeA->>DERP2: Connect to Node B's DERP
    
    NodeA->>DERP2: DISCO Ping (encrypted)
    DERP2->>NodeB: Relay DISCO Ping
    NodeB-->>DERP2: DISCO Pong
    DERP2-->>NodeA: Relay DISCO Pong
    
    Note over NodeA,NodeB: NAT Traversal via DISCO
    NodeA->>NodeB: Direct DISCO Ping<br/>(multiple endpoints)
    NodeB->>NodeA: Direct DISCO Ping<br/>(multiple endpoints)
    
    NodeA->>DERP2: CallMeMaybe message
    DERP2->>NodeB: Relay CallMeMaybe
    NodeB->>NodeA: Attempt direct connection
    
    Note over NodeA,NodeB: Connection Upgrade
    NodeA<->NodeB: Direct WireGuard tunnel established
    NodeA--xDERP2: Close relay connection<br/>(optional, kept as fallback)
    
    style Coord fill:#e3f2fd,stroke:#1976d2,stroke-width:2px,color:#000
    style DERP1 fill:#f5f5f5,stroke:#455a64,stroke-width:2px,color:#000
    style DERP2 fill:#f5f5f5,stroke:#455a64,stroke-width:2px,color:#000
```

## Protocol Details

### DISCO Messages

- **DISCO Ping**: Contains transaction ID + sender's WireGuard public key
- **DISCO Pong**: Returns sender's observed IP:port (STUN-like functionality)
- **CallMeMaybe**: Requests recipient to initiate connection back to sender

### Connection States

1. **DERP Home Selection**: Each node selects nearest DERP based on latency
2. **Initial Relay**: All traffic flows through DERP servers
3. **Parallel Discovery**: DISCO protocol attempts direct connection
4. **Connection Upgrade**: Seamless switch to direct P2P when successful