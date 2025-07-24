---
title: "Tailscale Identity Provider (tsidp) Authentication Flow"
description: "How tsidp enables OIDC authentication using Tailscale identities for SSO within your tailnet"
date: 2025-01-24
categories: ["architecture"]
tags: ["authentication", "oidc", "sso", "identity-provider", "tsidp", "tailscale"]
---

## Overview

tsidp (Tailscale Identity Provider) is an OIDC Identity Provider server that integrates with your Tailscale network. It allows applications that support OpenID Connect to authenticate users using their Tailscale identities, enabling single sign-on (SSO) capabilities within your tailnet.

This diagram shows the complete authentication flow when an application uses tsidp for authentication.

```mermaid
sequenceDiagram
    participant App as Application<br/>(OIDC Client)
    participant User as User Browser
    participant TSIDP as tsidp Server<br/>(OIDC Provider)
    participant TSCoord as Tailscale<br/>Coordination Server
    participant ExtIdP as External IdP<br/>(Google/GitHub/Okta)
    
    rect rgb(245, 245, 245)
        Note over App,User: 1. User Accesses Protected Resource
        App->>User: Redirect to tsidp /authorize
        User->>TSIDP: GET /authorize<br/>(client_id, redirect_uri, scope, state)
    end
    
    rect rgb(232, 242, 253)
        Note over TSIDP,ExtIdP: 2. Tailscale Authentication Check
        TSIDP->>TSIDP: Check Tailscale session
        
        alt No valid Tailscale session
            TSIDP->>User: Redirect to Tailscale login
            User->>TSCoord: Tailscale login request
            TSCoord->>User: Redirect to External IdP
            User->>ExtIdP: Authenticate (OAuth2/SAML)
            ExtIdP-->>User: Auth response + tokens
            User-->>TSCoord: Auth tokens
            TSCoord->>TSCoord: Create Tailscale session
            TSCoord-->>User: Tailscale session cookie
            User-->>TSIDP: Return with session
        else Valid Tailscale session exists
            Note over TSIDP: Use existing session
        end
    end
    
    rect rgb(232, 253, 232)
        Note over User,TSIDP: 3. Authorization Grant
        TSIDP->>TSIDP: Validate client_id & redirect_uri
        TSIDP->>User: Show consent screen<br/>(if required)
        User->>TSIDP: Approve access
        TSIDP->>TSIDP: Generate authorization code
        TSIDP-->>User: Redirect to app<br/>(code, state)
    end
    
    rect rgb(253, 245, 232)
        Note over App,TSIDP: 4. Token Exchange
        User-->>App: Authorization code
        App->>TSIDP: POST /token<br/>(code, client_id, client_secret)
        TSIDP->>TSIDP: Validate code & client
        TSIDP->>TSIDP: Generate tokens<br/>(access_token, id_token)
        TSIDP-->>App: Tokens response
    end
    
    rect rgb(245, 232, 253)
        Note over App,TSIDP: 5. User Information Retrieval
        App->>TSIDP: GET /userinfo<br/>(Bearer access_token)
        TSIDP->>TSIDP: Validate access token
        TSIDP->>TSCoord: Get user details
        TSCoord-->>TSIDP: User information
        TSIDP-->>App: User profile<br/>(email, name, tailnet_name)
    end
    
    rect rgb(232, 253, 245)
        Note over App,User: 6. Application Access
        App->>App: Create app session
        App-->>User: Access granted<br/>(app session cookie)
    end
```

## Key Components

### tsidp Server
- Implements OIDC provider endpoints:
  - `/authorize` - Authorization endpoint
  - `/token` - Token exchange endpoint
  - `/userinfo` - User information endpoint
  - `/.well-known/openid-configuration` - Discovery endpoint
- Runs within your tailnet
- Uses Tailscale authentication for user verification

### Integration Points
1. **Application to tsidp**: Standard OIDC flow
2. **tsidp to Tailscale**: Session validation and user info
3. **Tailscale to External IdP**: Actual user authentication

### Security Features
- No password management in tsidp or Tailscale
- Leverages existing enterprise SSO providers
- Automatic key rotation through Tailscale
- MFA/2FA support through external IdP

## Common Use Cases

tsidp enables authentication for:
- Self-hosted applications (Grafana, Proxmox, Synology)
- Internal tools and services
- Any OIDC-compatible application within your tailnet