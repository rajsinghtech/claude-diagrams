---
title: "Tailscale Connection State Machine"
description: "State diagram showing the various states of a Tailscale peer connection and transitions between them"
date: 2025-01-24
categories: ["flowcharts"]
tags: ["state-diagram", "connection-states", "peer-connection", "wireguard", "derp", "p2p"]
---

This state diagram illustrates the different states a Tailscale connection can be in and how it transitions between them.

```mermaid
stateDiagram-v2
    [*] --> Disconnected: Initial state
    
    Disconnected --> Authenticating: User login /<br/>Node registration
    
    Authenticating --> Authenticated: Auth success
    Authenticating --> Disconnected: Auth failure
    
    Authenticated --> Discovering: Peer connection<br/>requested
    
    Discovering --> DERPConnecting: DERP server<br/>assigned
    Discovering --> DirectConnecting: Public endpoint<br/>available
    
    DERPConnecting --> DERPConnected: DERP handshake<br/>complete
    DERPConnecting --> Discovering: DERP failure /<br/>Retry
    
    DirectConnecting --> DirectConnected: UDP handshake<br/>success
    DirectConnecting --> DERPConnecting: Direct connection<br/>failed
    
    DERPConnected --> Probing: Start DISCO<br/>protocol
    DERPConnected --> Idle: No traffic
    
    Probing --> DirectConnected: Path found &<br/>validated
    Probing --> DERPConnected: No viable<br/>path found
    
    DirectConnected --> Monitoring: Stable connection
    DirectConnected --> DERPConnected: Connection<br/>degraded
    
    Monitoring --> DirectConnected: Connection OK
    Monitoring --> Reconnecting: Connection lost
    
    Reconnecting --> DirectConnecting: Try direct
    Reconnecting --> DERPConnecting: Fallback to DERP
    
    Idle --> DERPConnected: Traffic resumes
    Idle --> Disconnected: Timeout /<br/>User logout
    
    DirectConnected --> Idle: No traffic
    DERPConnected --> Disconnected: User logout
    DirectConnected --> Disconnected: User logout
    
    state Discovering {
        [*] --> CollectingEndpoints
        CollectingEndpoints --> STUNQuery: Need public IP
        STUNQuery --> EndpointsReady: STUN response
        CollectingEndpoints --> EndpointsReady: Have endpoints
        EndpointsReady --> [*]
    }
    
    state Probing {
        [*] --> SendingProbes
        SendingProbes --> WaitingResponse: Probes sent
        WaitingResponse --> ValidatingPath: Response received
        WaitingResponse --> SendingProbes: Timeout / Retry
        ValidatingPath --> PathValidated: Quality OK
        ValidatingPath --> PathRejected: Quality poor
        PathValidated --> [*]
        PathRejected --> [*]
    }
    
    state Monitoring {
        [*] --> Healthy
        Healthy --> Degraded: Packet loss /<br/>High latency
        Degraded --> Healthy: Quality restored
        Degraded --> Failed: Threshold exceeded
        Failed --> [*]
    }
```

## Connection States Explained

### Primary States
- **Disconnected**: No active connection, node offline or logged out
- **Authenticated**: Node authenticated with control plane
- **DERPConnected**: Active connection through DERP relay
- **DirectConnected**: Direct peer-to-peer UDP connection established

### Transition States
- **Authenticating**: Logging in with identity provider
- **Discovering**: Finding peer endpoints and optimal paths
- **Connecting**: Establishing WireGuard handshake
- **Probing**: Running DISCO protocol to find direct paths
- **Monitoring**: Watching connection quality metrics
- **Reconnecting**: Re-establishing lost connection

### Sub-states
- **CollectingEndpoints**: Gathering all possible peer addresses
- **STUNQuery**: Discovering public IP via STUN
- **SendingProbes**: DISCO protocol active
- **ValidatingPath**: Testing discovered path quality

### State Transitions
- Automatic fallback from direct to DERP on failure
- Continuous optimization attempts while connected
- Graceful degradation based on network conditions
- Quick reconnection using cached endpoints