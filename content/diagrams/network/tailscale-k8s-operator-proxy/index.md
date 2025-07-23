---
title: "Tailscale Kubernetes Operator Proxy Architecture"
description: "Technical diagram showing Tailscale Kubernetes Operator ingress and egress proxy flows for connecting external Tailscale clients to K8s services and K8s workloads to external resources"
date: 2025-07-23
categories: ["network"]
tags: ["tailscale", "kubernetes", "operator", "proxy", "ingress", "egress", "service-mesh"]
---

This diagram illustrates the Tailscale Kubernetes Operator proxy architecture, showing:

- **Ingress Proxy**: External Tailscale clients accessing Kubernetes services through proxy pods
- **Egress Proxy**: Kubernetes workloads connecting to external Tailscale resources
- **ProxyClass Resources**: Configuration management for different proxy types
- **Operator Controller**: Automated deployment and management of proxy pods
- **Traffic Flows**: Secure WireGuard tunnels for both inbound and outbound connections

The operator enables seamless integration between Tailscale's zero-trust network and Kubernetes clusters, providing secure connectivity without complex networking configurations.