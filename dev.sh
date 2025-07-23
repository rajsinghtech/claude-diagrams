#!/bin/bash
# Development script for claude-diagrams

echo "Starting Claude Diagrams in development mode..."
echo "Server will be available at http://localhost:1313"
echo "Press Ctrl+C to stop"
echo ""

# Run the Go server in development mode
go run main.go -dev -port 1313