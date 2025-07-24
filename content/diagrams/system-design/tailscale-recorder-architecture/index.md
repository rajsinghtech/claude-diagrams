---
title: "Tailscale Session Recorder Architecture"
description: "Comprehensive diagram showing how Tailscale SSH session recording works, including data flow, components, and storage options"
date: 2025-01-24
categories: ["system-design"]
tags: ["tailscale", "ssh", "session-recording", "security", "compliance", "tsrecorder", "asciinema"]
---

## Overview

This diagram illustrates the architecture and data flow of Tailscale's SSH session recording feature, showing how terminal sessions are captured, streamed, and stored securely within a tailnet.

```mermaid
graph TB
    subgraph "User Workstation"
        U[User] -->|SSH Connection| TC[Tailscale Client]
    end
    
    subgraph "Tailscale SSH Server Node"
        TC -->|WireGuard Tunnel| TS[Tailscale SSH Server]
        TS --> SR[Session Recorder Client]
        SR --> TIO[Terminal I/O Wrapper]
        TIO --> ASC[Asciinema Formatter]
    end
    
    subgraph "Control Plane"
        CP[Coordination Server] -.->|ACL Policy| TS
        CP -.->|Recorder Config| SR
        CP -.->|Node Registry| RN
    end
    
    subgraph "Recorder Infrastructure"
        subgraph "Primary Recorder Node"
            RN[tsrecorder Service]
            RN --> API{API Version}
            API -->|v2| V2[HTTP/2 Handler]
            API -->|v1| V1[HTTP Handler]
            V2 --> ACK[Acknowledgment Stream]
            V2 --> ST[Storage Handler]
            V1 --> ST
        end
        
        subgraph "Storage Backends"
            ST --> FS[Filesystem Backend]
            ST --> S3[S3 Backend]
            FS --> DISK[(Local Disk)]
            S3 --> CLOUD[(S3/R2/B2)]
        end
        
        subgraph "Optional UI"
            WEB[Web UI :443] --> RN
            WEB --> PLAYER[Asciinema Player]
        end
    end
    
    subgraph "Failover Recorder Nodes"
        RN2[Recorder 2] -.->|Failover| ST
        RN3[Recorder 3] -.->|Failover| ST
    end
    
    SR -->|Stream Recording| RN
    SR -.->|If Primary Fails| RN2
    SR -.->|If Secondary Fails| RN3
    
    style U fill:#1976d2,stroke:#fff,stroke-width:2px,color:#fff
    style CP fill:#1976d2,stroke:#fff,stroke-width:2px,color:#fff
    style RN fill:#388e3c,stroke:#fff,stroke-width:2px,color:#fff
    style CLOUD fill:#f57c00,stroke:#fff,stroke-width:2px,color:#fff
    style DISK fill:#455a64,stroke:#fff,stroke-width:2px,color:#fff
```

## Data Flow Sequence

```mermaid
sequenceDiagram
    participant User
    participant SSH Server
    participant Recorder Client
    participant tsrecorder
    participant Storage
    
    User->>SSH Server: SSH Connection Request
    SSH Server->>SSH Server: Check ACL Policy
    
    alt Recording Required
        SSH Server->>Recorder Client: Start Recording
        Recorder Client->>tsrecorder: Probe v2 Support (HEAD /v2/record)
        tsrecorder-->>Recorder Client: HTTP 200 (v2 supported)
        
        Recorder Client->>tsrecorder: POST /v2/record (HTTP/2)
        Note over Recorder Client,tsrecorder: Send Asciinema Header
        tsrecorder->>Storage: Initialize Recording
        
        loop Session Active
            SSH Server->>Recorder Client: Terminal Output
            Recorder Client->>Recorder Client: Format as Asciinema
            Recorder Client->>tsrecorder: Stream Data
            tsrecorder->>Storage: Write Data
            
            alt Every 5 seconds (v2)
                tsrecorder-->>Recorder Client: Acknowledgment Frame
            end
        end
        
        User->>SSH Server: Exit Session
        Recorder Client->>tsrecorder: Close Stream
        tsrecorder->>Storage: Finalize Recording
    else Recording Not Required
        SSH Server->>User: Normal SSH Session
    end
```

## Recording Format Structure

```mermaid
graph LR
    subgraph "Asciinema v2 Format"
        H[Header JSON] --> |Contains| M[Metadata]
        M --> W[Width/Height]
        M --> T[Timestamp]
        M --> N[Node Info]
        M --> U[User Details]
        
        B[Body Lines] --> |Contains| E[Events]
        E --> TS[Timestamp]
        E --> ET[Event Type]
        E --> ED[Event Data]
    end
    
    style H fill:#1976d2,stroke:#fff,stroke-width:2px,color:#fff
    style B fill:#388e3c,stroke:#fff,stroke-width:2px,color:#fff
```

## ACL Configuration Flow

```mermaid
graph TD
    A[SSH Access Rule] --> B{Recording Config?}
    B -->|Yes| C[recorders: tag:recorder]
    B -->|No| D[No Recording]
    
    C --> E{enforceRecorder?}
    E -->|true| F[Fail Closed]
    E -->|false| G[Fail Open]
    
    F --> H[Reject if Recording Fails]
    G --> I[Allow Even if Recording Fails]
    
    style A fill:#1976d2,stroke:#fff,stroke-width:2px,color:#fff
    style F fill:#d32f2f,stroke:#fff,stroke-width:2px,color:#fff
    style G fill:#f57c00,stroke:#fff,stroke-width:2px,color:#fff
```

## Storage Backend Options

```mermaid
graph TD
    R[tsrecorder] --> SH{Storage Handler}
    
    SH --> FS[Filesystem Backend]
    SH --> S3[S3 Backend]
    
    FS --> FP[File Path Structure]
    FP --> |Format| FSS[basePath/NodeID/timestamp.cast]
    
    S3 --> S3C{S3 Provider}
    S3C --> AWS[AWS S3]
    S3C --> CF[Cloudflare R2]
    S3C --> BB[Backblaze B2]
    S3C --> GCS[Google Cloud Storage]
    S3C --> MIN[MinIO]
    
    style R fill:#388e3c,stroke:#fff,stroke-width:2px,color:#fff
    style AWS fill:#f57c00,stroke:#fff,stroke-width:2px,color:#fff
    style CF fill:#f57c00,stroke:#fff,stroke-width:2px,color:#fff
```

## Failure Handling States

```mermaid
stateDiagram-v2
    [*] --> Connecting: SSH Session Start
    Connecting --> CheckPolicy: Validate ACL
    
    CheckPolicy --> NoRecording: Recording Not Required
    CheckPolicy --> FindRecorder: Recording Required
    
    FindRecorder --> TryPrimary: Get Recorder IPs
    TryPrimary --> Connected: Success
    TryPrimary --> TryFailover: Connection Failed
    
    TryFailover --> Connected: Failover Success
    TryFailover --> RecordingFailed: All Recorders Down
    
    RecordingFailed --> SessionRejected: enforceRecorder=true
    RecordingFailed --> SessionAllowed: enforceRecorder=false
    
    Connected --> Streaming: Start Recording
    Streaming --> SessionComplete: Normal Exit
    Streaming --> ConnectionLost: Recorder Down
    
    ConnectionLost --> SessionTerminated: enforceRecorder=true
    ConnectionLost --> ContinueUnrecorded: enforceRecorder=false
    
    NoRecording --> SessionComplete
    SessionAllowed --> SessionComplete
    ContinueUnrecorded --> SessionComplete
    SessionComplete --> [*]
    SessionRejected --> [*]
    SessionTerminated --> [*]
```

## Customer-Facing Overview

```mermaid
graph LR
    subgraph "Your Organization"
        subgraph "Users"
            U1[👤 Developer]
            U2[👤 Admin]
            U3[👤 Support]
        end
        
        subgraph "Your Servers"
            S1[🖥️ Production Server]
            S2[🖥️ Database Server]
            S3[🖥️ Web Server]
        end
        
        subgraph "Your Recording Infrastructure"
            R[📹 Recorder Node]
            ST[(💾 Storage)]
            R --> ST
        end
    end
    
    U1 & U2 & U3 -.->|🔐 Secure SSH| S1 & S2 & S3
    S1 & S2 & S3 -->|📝 Session Recording| R
    
    subgraph "Benefits"
        B1[✅ Compliance]
        B2[🔍 Audit Trail]
        B3[🛡️ Security]
        B4[🎯 Troubleshooting]
    end
    
    ST -.-> B1 & B2 & B3 & B4
    
    style U1 fill:#1976d2,stroke:#000,stroke-width:2px,color:#fff
    style U2 fill:#1976d2,stroke:#000,stroke-width:2px,color:#fff
    style U3 fill:#1976d2,stroke:#000,stroke-width:2px,color:#fff
    style R fill:#388e3c,stroke:#000,stroke-width:2px,color:#fff
    style ST fill:#f57c00,stroke:#000,stroke-width:2px,color:#fff
    style B1 fill:#388e3c,stroke:#fff,stroke-width:2px,color:#fff
    style B2 fill:#388e3c,stroke:#fff,stroke-width:2px,color:#fff
    style B3 fill:#388e3c,stroke:#fff,stroke-width:2px,color:#fff
    style B4 fill:#388e3c,stroke:#fff,stroke-width:2px,color:#fff
```

## How Session Recording Works (Simplified)

```mermaid
graph TD
    A[1. User connects via SSH] --> B[2. System checks policy]
    B --> C{Recording enabled?}
    C -->|Yes| D[3. Start recording session]
    C -->|No| E[Regular SSH session]
    
    D --> F[4. Capture terminal output]
    F --> G[5. Stream to recorder]
    G --> H[6. Save to storage]
    H --> I[7. Available for review]
    
    style A fill:#1976d2,stroke:#000,stroke-width:2px,color:#fff
    style D fill:#388e3c,stroke:#000,stroke-width:2px,color:#fff
    style G fill:#f57c00,stroke:#000,stroke-width:2px,color:#fff
    style I fill:#7b1fa2,stroke:#000,stroke-width:2px,color:#fff
```

## Setting Up Recording (3 Easy Steps)

```mermaid
graph LR
    subgraph "Step 1: Deploy Recorder"
        D1[🐳 Docker Container]
        D2[☸️ Kubernetes]
        D3[🖥️ VM/Server]
        D1 & D2 & D3 --> R1[Recorder Running]
    end
    
    subgraph "Step 2: Configure Storage"
        R1 --> S1[💾 Local Disk]
        R1 --> S2[☁️ AWS S3]
        R1 --> S3[🌐 Other S3]
    end
    
    subgraph "Step 3: Update ACL Policy"
        P[📋 ACL Policy] --> |Define| WHO[Who gets recorded]
        P --> |Define| WHERE[Which servers]
        P --> |Define| HOW[Storage location]
    end
    
    style R1 fill:#388e3c,stroke:#000,stroke-width:2px,color:#fff
    style P fill:#1976d2,stroke:#000,stroke-width:2px,color:#fff
```

## Privacy & Security Guarantees

```mermaid
graph TD
    subgraph "What We See"
        T1[❌ Nothing]
        T2[Your data never leaves your network]
    end
    
    subgraph "What You Control"
        Y1[✅ All recordings]
        Y2[✅ Storage location]
        Y3[✅ Access policies]
        Y4[✅ Retention rules]
    end
    
    subgraph "Security Features"
        S1[🔐 End-to-end encrypted]
        S2[🛡️ Zero-trust access]
        S3[📝 Audit logging]
        S4[🚫 No passwords recorded]
    end
    
    style T1 fill:#d32f2f,stroke:#000,stroke-width:2px,color:#fff
    style Y1 fill:#388e3c,stroke:#000,stroke-width:2px,color:#fff
    style Y2 fill:#388e3c,stroke:#000,stroke-width:2px,color:#fff
    style Y3 fill:#388e3c,stroke:#000,stroke-width:2px,color:#fff
    style Y4 fill:#388e3c,stroke:#000,stroke-width:2px,color:#fff
```

## Common Use Cases

```mermaid
graph TD
    subgraph "Compliance & Audit"
        C1[📊 SOC2/ISO27001]
        C2[🏛️ Regulatory Requirements]
        C3[📋 Internal Policies]
    end
    
    subgraph "Security Operations"
        S1[🔍 Incident Investigation]
        S2[🚨 Threat Detection]
        S3[👀 Activity Monitoring]
    end
    
    subgraph "Operations & Support"
        O1[🐛 Troubleshooting]
        O2[📚 Training & Documentation]
        O3[🤝 Vendor Support]
    end
    
    R[Session Recordings] --> C1 & C2 & C3
    R --> S1 & S2 & S3
    R --> O1 & O2 & O3
    
    style R fill:#388e3c,stroke:#000,stroke-width:2px,color:#fff
    style C1 fill:#1976d2,stroke:#fff,stroke-width:2px,color:#fff
    style S1 fill:#f57c00,stroke:#fff,stroke-width:2px,color:#fff
    style O1 fill:#7b1fa2,stroke:#fff,stroke-width:2px,color:#fff
```

## Key Features

- **End-to-End Encryption**: All recordings streamed over WireGuard-encrypted tailnet connections
- **Privacy by Design**: Recordings stored on user-controlled infrastructure, never visible to Tailscale
- **Flexible Storage**: Support for local filesystem or S3-compatible object storage
- **High Availability**: Multiple recorder nodes with automatic failover
- **Compliance Ready**: Asciinema format allows searching and auditing of sessions
- **Access Control**: Fine-grained ACL policies determine which sessions are recorded
- **Fail-Safe Options**: Configurable behavior when recording infrastructure is unavailable