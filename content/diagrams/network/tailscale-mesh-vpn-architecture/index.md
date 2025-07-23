---
title: "Tailscale Mesh VPN Architecture"
description: "Technical diagram showing Tailscale's mesh VPN architecture with control plane, data plane, and DERP relay servers"
date: 2025-01-23
categories: ["network"]
tags: ["vpn", "tailscale", "mesh-network", "wireguard", "zero-trust"]
---

This diagram illustrates the architecture of Tailscale's mesh VPN, showing:
- Hybrid control/data plane architecture
- Peer-to-peer WireGuard connections between nodes
- DERP relay servers for NAT traversal fallback
- Centralized coordination server for key exchange and policy distribution