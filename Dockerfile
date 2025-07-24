# Build stage
FROM golang:1.24-alpine AS builder

# Install Hugo and dependencies
RUN apk add --no-cache git hugo tzdata

# Set timezone environment
ENV TZ=America/New_York

WORKDIR /app

# Copy go mod files
COPY go.mod go.sum ./
RUN go mod download

# Copy source code
COPY . .

# Build Hugo site
RUN hugo --gc --minify

# Build Go binary
RUN go build -o claude-diagrams

# Runtime stage
FROM alpine:latest

RUN apk --no-cache add ca-certificates tzdata

# Set timezone environment
ENV TZ=America/New_York

WORKDIR /root/

# Copy the binary from builder
COPY --from=builder /app/claude-diagrams .

# Expose port
EXPOSE 8080

# Run the binary
CMD ["./claude-diagrams"]