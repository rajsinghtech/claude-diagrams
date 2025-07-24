---
title: "UDP Packet Flow Through DERP"
description: "Sequence diagram showing the detailed flow of UDP packets through Tailscale's DERP relay system"
date: 2025-01-24
categories: ["flowcharts"]
tags: ["derp", "udp", "packet-flow", "sequence-diagram", "wireguard", "relay", "nat-traversal"]
---

This sequence diagram shows the detailed packet flow when two Tailscale nodes communicate through a DERP relay server.

```mermaid
sequenceDiagram
    participant NA as Node A<br/>100.64.1.5
    participant NATA as NAT A<br/>Router
    participant DERP as DERP Server<br/>Public IP
    participant NATB as NAT B<br/>Router
    participant NB as Node B<br/>100.64.1.6
    participant CS as Control Server
    
    Note over NA,CS: Initial Setup Phase
    NA->>CS: Register node, request peer info
    CS-->>NA: Peer B info + DERP server assignment
    NB->>CS: Register node, request peer info
    CS-->>NB: Peer A info + DERP server assignment
    
    Note over NA,NB: DERP Connection Establishment
    NA->>NATA: HTTPS/WebSocket to DERP
    NATA->>DERP: Establish persistent connection
    DERP-->>NA: Connection established
    
    NB->>NATB: HTTPS/WebSocket to DERP
    NATB->>DERP: Establish persistent connection
    DERP-->>NB: Connection established
    
    Note over NA,NB: UDP Packet Relay Flow
    rect rgb(230, 240, 255)
        Note right of NA: WireGuard packet creation
        NA->>NA: Create WireGuard packet<br/>Dest: 100.64.1.6
        NA->>NA: Encrypt with peer B's key
        NA->>NA: Encapsulate in DERP frame
    end
    
    NA->>NATA: DERP frame over HTTPS
    NATA->>DERP: Forward to DERP server
    
    rect rgb(240, 240, 240)
        Note over DERP: DERP Processing
        DERP->>DERP: Extract destination node ID
        DERP->>DERP: Lookup Node B connection
        DERP->>DERP: Re-encapsulate packet
    end
    
    DERP->>NATB: Forward DERP frame
    NATB->>NB: Deliver to Node B
    
    rect rgb(230, 255, 230)
        Note left of NB: WireGuard packet processing
        NB->>NB: Extract DERP frame
        NB->>NB: Decrypt WireGuard packet
        NB->>NB: Process application data
    end
    
    Note over NA,NB: Parallel STUN/Disco Attempts
    par STUN Discovery
        NA-->>NB: STUN probe attempts
        NB-->>NA: STUN probe attempts
    and DERP Relay
        NA->>NB: Continue relay through DERP
    end
    
    Note over NA,NB: Connection Upgrade (if STUN succeeds)
    alt STUN Success
        NA->>NB: Direct UDP connection established
        Note over DERP: Connection upgraded, DERP no longer used
    else STUN Failure
        NA->>NB: Continue using DERP relay
    end
```

## Packet Structure

### DERP Frame Format
- **Frame Type**: Control or Data
- **Source Node ID**: Sender's Tailscale node ID
- **Destination Node ID**: Recipient's Tailscale node ID
- **Payload**: Encrypted WireGuard packet

### WireGuard UDP Packet
- **Type**: Data or Handshake
- **Sender Index**: WireGuard peer identifier
- **Packet Counter**: Anti-replay protection
- **Encrypted Payload**: Application data