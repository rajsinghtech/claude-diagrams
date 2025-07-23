# Claude Diagrams

[![Deploy to GitHub Pages](https://github.com/rajsinghtech/claude-diagrams/actions/workflows/deploy.yml/badge.svg)](https://github.com/rajsinghtech/claude-diagrams/actions/workflows/deploy.yml)
[![Deploy PR Preview](https://github.com/rajsinghtech/claude-diagrams/actions/workflows/preview.yml/badge.svg)](https://github.com/rajsinghtech/claude-diagrams/actions/workflows/preview.yml)

A gallery application for showcasing technical diagrams built with Go, Hugo, and the hugo-theme-gallery. This project provides a simple way to host and organize SVG diagrams with automated updates via Claude through GitHub Actions.

## Features

- 🎨 Beautiful gallery interface using hugo-theme-gallery
- 📊 Optimized for SVG technical diagrams
- 🚀 Single binary deployment with embedded assets
- 🐳 Docker support for containerized deployment
- 🤖 GitHub Actions integration for Claude-powered diagram updates
- 🔄 Hot-reload development mode
- 📱 Responsive design
- 🌐 GitHub Pages deployment with PR previews

## Quick Start

### Prerequisites

- Go 1.20 or higher
- Hugo Extended v0.123.0 or higher
- Docker (optional, for containerized deployment)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/rajsinghtech/claude-diagrams.git
cd claude-diagrams
```

2. Install Hugo modules:
```bash
hugo mod get
```

3. Build and run:
```bash
# Development mode with live reload
go run main.go -dev

# Or build and run production server
hugo --gc --minify
go build -o claude-diagrams
./claude-diagrams
```

The application will be available at http://localhost:8080

### Docker Deployment

Build and run with Docker:
```bash
docker build -t claude-diagrams .
docker run -p 8080:8080 claude-diagrams
```

### GitHub Pages Deployment

This project automatically deploys to GitHub Pages when changes are pushed to the main branch. Pull requests also get preview deployments.

#### Setup GitHub Pages

1. Go to Settings > Pages in your GitHub repository
2. Set "Source" to "GitHub Actions"
3. The site will be available at `https://rajsinghtech.github.io/claude-diagrams/`

#### PR Previews

Pull request previews are automatically deployed to:
`https://rajsinghtech.github.io/claude-diagrams/pr-preview/pr-[number]/`

These previews are automatically cleaned up when the PR is closed.

## Project Structure

```
claude-diagrams/
├── .github/workflows/    # GitHub Actions for Claude integration
├── config/              # Hugo configuration
├── content/             # Diagram content and metadata
│   └── diagrams/        # Diagram categories
│       ├── architecture/
│       ├── flowcharts/
│       ├── network/
│       └── system-design/
├── layouts/             # Custom Hugo layouts for SVG support
├── public/              # Hugo build output (embedded in binary)
├── main.go              # Go web server
├── Dockerfile           # Docker configuration
└── CLAUDE.md            # Project standards for Claude
```

## Adding Diagrams

1. Create a directory for your diagram in the appropriate category:
```bash
mkdir content/diagrams/architecture/my-diagram
```

2. Add your SVG file and create an `index.md`:
```markdown
---
title: "My Architecture Diagram"
description: "Description of the diagram"
date: 2025-01-23
categories: ["Technical"]
tags: ["architecture", "microservices"]
---

Detailed description of the diagram...
```

3. Place your SVG file in the same directory
4. Rebuild the site

## Claude Integration

This project includes GitHub Actions integration for updating diagrams using Claude. To update a diagram:

1. Create an issue or pull request
2. Comment with `@claude` followed by your request:
```
@claude update the microservices architecture diagram to add a caching layer
```

3. Claude will process your request and update the SVG files automatically

### Setup Claude Integration

1. Install the Claude GitHub App on your repository
2. Add your Anthropic API key as a repository secret: `ANTHROPIC_API_KEY`
3. The workflow will automatically trigger on comments containing `@claude`

## Command Line Options

```bash
Usage: ./claude-diagrams [options]

Options:
  -port string      Port to run the server on (default "8080")
  -host string      Host to bind the server to (default "0.0.0.0")
  -dev              Run in development mode with Hugo live reload
  -build            Build Hugo site before starting server
```

## Development

### Local Development

Run in development mode for live reload:
```bash
go run main.go -dev
```

### Building for Production

1. Build the Hugo site:
```bash
hugo --gc --minify
```

2. Build the Go binary:
```bash
go build -o claude-diagrams
```

## Contributing

1. Follow the coding standards in `CLAUDE.md`
2. Ensure SVG files follow the project color scheme and standards
3. Test locally before submitting pull requests
4. Use clear commit messages prefixed with type (feat:, fix:, docs:, diagram:)

## License

This project is open source. See LICENSE file for details.