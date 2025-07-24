---
title: "Tailscale UDP Peer Relay Flow"
description: "Visualizing how Tailscale uses DERP servers for UDP relay and connection establishment"
date: 2025-07-24
categories: ["network"]
tags: ["tailscale", "derp", "udp", "relay", "nat-traversal", "mesh-vpn", "p2p"]
---

## Overview

This diagram illustrates the basic UDP peer relay flow in Tailscale, showing how DERP (Designated Encrypted Relay Points) servers facilitate connection establishment and serve as fallback relays when direct peer-to-peer connections are not possible.

```mermaid
graph TD
    subgraph "Node A Network"
        NodeA[Node A<br/>100.64.1.10<br/>Behind NAT]
    end
    
    subgraph "DERP Infrastructure"
        DERP[DERP Server<br/>nyc.derp.example<br/>Relay Only]
    end
    
    subgraph "Node B Network"
        NodeB[Node B<br/>100.64.2.20<br/>Behind NAT]
    end
    
    subgraph "Connection Flow"
        NodeA -->|1. Initial Connection<br/>via DERP| DERP
        DERP -->|2. Relay Encrypted<br/>WireGuard Traffic| NodeB
        NodeA -.->|3. Attempt Direct<br/>Connection<br/>NAT Traversal| NodeB
        NodeA ==>|4. Upgrade to Direct<br/>P2P Connection<br/>When Successful| NodeB
    end
    
    style NodeA fill:#1976d2,stroke:#fff,stroke-width:2px,color:#fff
    style NodeB fill:#1976d2,stroke:#fff,stroke-width:2px,color:#fff
    style DERP fill:#f57c00,stroke:#fff,stroke-width:2px,color:#fff
    
    classDef relay stroke-dasharray: 5 5
    class DERP relay
```

## Key Points

1. **Initial Connection**: All connections start through DERP for instant connectivity
2. **Encrypted Relay**: DERP servers only relay encrypted WireGuard packets, they cannot decrypt the traffic
3. **Parallel Discovery**: While maintaining DERP connection, nodes attempt direct NAT traversal
4. **Transparent Upgrade**: When direct connection succeeds, traffic seamlessly switches from relay to P2P

## Connection Types

- **Solid Lines**: Active data flow
- **Dashed Lines**: NAT traversal attempts
- **Double Lines**: Upgraded direct P2P connection