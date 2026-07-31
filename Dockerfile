# Stage 1: Builder
FROM golang:alpine AS builder

# Set working directory
WORKDIR /app

# Copy source code
COPY . .

# Install dependencies sesuai instruksi
RUN go mod tidy

# Build aplikasi Golang
RUN go build -o main .

# Stage 2: Runner (Minimal Image)
FROM alpine:latest

WORKDIR /app

# Copy hasil build dari stage builder
COPY --from=builder /app/main .

# Expose port sesuai instruksi
EXPOSE 3000

# Run aplikasi Fiber
CMD ["./main"]
