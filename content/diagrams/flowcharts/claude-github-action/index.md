---
title: "Claude GitHub Action Workflow"
description: "How the Claude GitHub Action processes issue comments and updates diagrams"
date: 2025-01-24
categories: ["flowcharts"]
tags: ["github-actions", "automation", "claude", "ci-cd", "workflow"]
---

This diagram illustrates how the Claude GitHub Action workflow processes issue comments and updates diagrams in the repository.

```mermaid
flowchart TD
    A[User creates issue comment with @claude] --> B{Comment contains @claude?}
    B -->|No| C[Action ignored]
    B -->|Yes| D[GitHub Action triggered]
    
    D --> E[Extract comment content]
    E --> F[Send request to Claude API]
    
    F --> G{Claude generates response}
    G -->|Diagram update request| H[Claude modifies SVG files]
    G -->|Code changes| I[Claude updates code files]
    G -->|Information only| J[Claude posts comment reply]
    
    H --> K[Create new branch]
    I --> K
    K --> L[Commit changes]
    L --> M[Create pull request]
    
    M --> N[Post PR link as comment]
    J --> O[End workflow]
    N --> O
    
    subgraph "GitHub Action Environment"
        D
        E
        K
        L
        M
    end
    
    subgraph "Claude API Processing"
        F
        G
        H
        I
        J
    end
    
    style A fill:#1976d2,stroke:#000,stroke-width:2px,color:#fff
    style O fill:#388e3c,stroke:#000,stroke-width:2px,color:#fff
    style C fill:#d32f2f,stroke:#000,stroke-width:2px,color:#fff
```

## Key Components

1. **Trigger**: User mentions `@claude` in an issue comment
2. **GitHub Action**: Processes the comment and orchestrates the workflow
3. **Claude API**: Analyzes the request and generates appropriate responses
4. **Version Control**: Creates branches and pull requests for changes
5. **Feedback Loop**: Posts PR links or responses back to the issue

## Workflow Steps

1. User creates an issue comment mentioning `@claude`
2. GitHub Action checks if the comment contains the trigger
3. Comment content is extracted and sent to Claude API
4. Claude analyzes the request and determines the action type
5. For file changes, a new branch is created
6. Changes are committed and a pull request is opened
7. The PR link is posted back to the original issue