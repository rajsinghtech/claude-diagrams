# Claude Diagrams Project Standards

This document defines coding standards and conventions for the claude-diagrams project.

## Project Overview

Claude Diagrams is a Go web application that hosts technical diagrams using Hugo static site generator with the hugo-theme-gallery. All diagrams are SVG files that can be updated through GitHub Actions using Claude. The site features a streamlined interface where all diagrams are displayed on the homepage with previews for quick access.

## SVG Diagram Standards

### File Organization
- All SVG diagrams must be placed in page bundles under `content/diagrams/[category]/[diagram-name]/`
- Categories: `architecture`, `flowcharts`, `network`, `system-design`
- Each diagram should be in a page bundle with:
  - `index.md` - Markdown metadata file
  - `[diagram-name].svg` - The SVG diagram file

### SVG Requirements
- Use viewBox for responsive scaling
- Include descriptive titles and text elements
- Use consistent color scheme:
  - Primary: #2196f3 (blue)
  - Success: #4caf50 (green) 
  - Warning: #ff9800 (orange)
  - Error: #f44336 (red)
  - Neutral: #607d8b (blue-grey)
- Maximum dimensions: 1200x900px
- Include proper labels and legends

### Metadata Format
Each diagram directory should have an `_index.md` or `index.md` with:
```yaml
---
title: "Diagram Title"
description: "Brief description"
date: YYYY-MM-DD
categories: ["Category"]
tags: ["tag1", "tag2"]
---
```

## Code Standards

### Go Code
- Follow standard Go formatting (use `gofmt`)
- Use meaningful variable names
- Add comments for exported functions
- Handle errors appropriately
- Keep functions focused and small

### Hugo Configuration
- Don't modify the gallery theme core files
- Use layout overrides in `layouts/` directory
- Keep configuration in `config/_default/`
- Custom layouts:
  - `layouts/index.html` - Homepage with diagram grid
  - `layouts/diagrams/single.html` - Individual diagram view
  - `layouts/diagrams/list.html` - Category listing with previews

## Updating Diagrams via Claude

When requesting diagram updates through GitHub comments:
1. Use `@claude` to trigger the action
2. Be specific about what needs to be changed
3. Include diagram file path if updating existing diagram
4. Specify diagram type for new diagrams

Example:
```
@claude update the microservices architecture diagram to include a new cache layer between the API gateway and services
```

### GitHub Action Setup
- Requires `ANTHROPIC_API_KEY` secret in repository settings
- Workflow file: `.github/workflows/claude-code.yml`
- Triggers on issue comments containing `@claude`

## Development Workflow

1. **Local Development**: Use `./dev.sh` or `go run main.go -dev` for Hugo live reload
2. **Building**: Run `hugo --gc --minify` before building Go binary
3. **Testing**: Ensure all SVG files render correctly in browser
4. **Docker**: Test Docker builds before pushing
5. **Viewing Diagrams**: Homepage shows all diagrams with previews - one click to view full size

## Commit Standards

- Use clear, descriptive commit messages
- Prefix diagram updates with `diagram:`
- Prefix code changes with appropriate prefix (`feat:`, `fix:`, `docs:`)
- Keep commits focused on single changes

## File Naming

- SVG files: `kebab-case.svg` (e.g., `system-architecture.svg`)
- Markdown files: Use `index.md` for page bundles, `_index.md` for sections
- Go files: Follow Go conventions
- Page bundles: Directory name should match the diagram name in kebab-case

## Site Navigation

- **Homepage**: Displays all diagrams in a grid with SVG previews
- **Category Pages**: Show diagrams filtered by category with previews
- **Diagram Pages**: Full-size diagram view with metadata and description
- **Direct Access**: All diagrams accessible with one click from homepage