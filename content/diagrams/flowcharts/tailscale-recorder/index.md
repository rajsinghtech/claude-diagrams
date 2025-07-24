---
title: "Tailscale Recorder Flow"
description: "Session recording and audit trail flow for SSH connections in Tailscale"
date: 2025-07-24
categories: ["flowcharts"]
tags: ["tailscale", "recording", "ssh", "audit", "compliance", "security", "session-recording"]
---

The Tailscale Recorder enables organizations to record SSH sessions for audit and compliance purposes. This diagram illustrates the complete flow from session initiation to playback.

## Overview

Tailscale's session recording feature provides:
- Real-time SSH session recording
- Secure storage of session data
- Playback capabilities for audit review
- Integration with existing compliance workflows

## Key Components

- **SSH Client**: User's terminal or SSH application
- **Tailscale Node**: The target machine with recording enabled
- **Recorder Service**: Handles session capture and streaming
- **Storage Backend**: Secure storage for recorded sessions
- **Audit Console**: Interface for reviewing recorded sessions

## Recording Flow

```mermaid
graph TD
    %% Define nodes with descriptive labels
    User[SSH User] --> SSHClient[SSH Client]
    SSHClient -->|Tailscale SSH| TSNode[Tailscale Node]
    
    TSNode --> RecCheck{Recording<br/>Enabled?}
    RecCheck -->|No| DirectSSH[Direct SSH Session]
    RecCheck -->|Yes| RecorderInit[Initialize Recorder]
    
    RecorderInit --> SessionStart[Start Session Recording]
    SessionStart --> PTY[PTY Allocation]
    PTY --> DataCapture[Capture I/O Streams]
    
    DataCapture --> Multiplexer[Stream Multiplexer]
    Multiplexer -->|Live Session| SSHSession[SSH Session]
    Multiplexer -->|Recording Stream| Encoder[Session Encoder]
    
    Encoder --> Compression[Compress Data]
    Compression --> Encryption[Encrypt Recording]
    Encryption --> Storage[(Storage Backend)]
    
    %% Metadata flow
    SessionStart --> Metadata[Collect Metadata]
    Metadata --> MetaStore[(Metadata Store)]
    
    %% Playback flow
    Storage -->|Playback Request| AuditConsole[Audit Console]
    MetaStore -->|Session Info| AuditConsole
    AuditConsole --> Decrypt[Decrypt Recording]
    Decrypt --> Decompress[Decompress Data]
    Decompress --> Player[Session Player]
    
    %% Apply Tailscale color scheme
    style User fill:#2196f3,stroke:#fff,stroke-width:2px,color:#fff
    style SSHClient fill:#607d8b,stroke:#fff,stroke-width:2px,color:#fff
    style TSNode fill:#4caf50,stroke:#fff,stroke-width:2px,color:#fff
    style RecCheck fill:#ff9800,stroke:#fff,stroke-width:2px,color:#fff
    style Storage fill:#2196f3,stroke:#fff,stroke-width:2px,color:#fff
    style MetaStore fill:#2196f3,stroke:#fff,stroke-width:2px,color:#fff
    style AuditConsole fill:#607d8b,stroke:#fff,stroke-width:2px,color:#fff
    style Player fill:#4caf50,stroke:#fff,stroke-width:2px,color:#fff
```

## Recording Details

### Session Metadata
The recorder captures comprehensive metadata for each session:
- User identity and authentication method
- Source IP and Tailscale node information
- Timestamp and duration
- Commands executed
- File transfers

### Security Features
- End-to-end encryption of recorded data
- Access controls for playback permissions
- Tamper-proof session integrity
- Automatic retention policies

### Storage Options
Organizations can configure storage backends:
- Local filesystem (for testing)
- Cloud object storage (S3, GCS, Azure Blob)
- Compliance-certified storage solutions
- Custom storage integrations

## Compliance Benefits

The Tailscale Recorder helps organizations meet various compliance requirements:
- **SOC 2**: Audit trail for privileged access
- **PCI DSS**: Recording of administrative sessions
- **HIPAA**: Access logging for systems containing PHI
- **ISO 27001**: Evidence of access controls