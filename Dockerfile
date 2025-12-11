# Multi-stage build for Coraza-Caddy WAF

# --- Versions ---
ARG CADDY_VERSION=2.8
ARG CORAZA_VERSION=v2.0.0

# --- Build stage ---
FROM caddy:${CADDY_VERSION}-builder AS builder
ARG CORAZA_VERSION
ENV CORAZA_VERSION=${CORAZA_VERSION}

RUN xcaddy build \
    --with github.com/corazawaf/coraza-caddy@${CORAZA_VERSION}
    --with github.com/caddyserver/replace-response

# --- Runtime stage ---
FROM caddy:${CADDY_VERSION}-alpine
ARG CORAZA_VERSION
ENV CORAZA_VERSION=${CORAZA_VERSION}

COPY --from=builder /usr/bin/caddy /usr/bin/caddy

# Create non-root user for security
RUN addgroup -g 1001 -S caddy && \
    adduser -u 1001 -S caddy -G caddy

# Create directories with proper permissions
RUN mkdir -p /etc/caddy /var/lib/caddy /var/log/caddy && \
    chown -R caddy:caddy /etc/caddy /var/lib/caddy /var/log/caddy

# Copy Caddyfile template
COPY Caddyfile /etc/caddy/Caddyfile

# Install curl for health checks
RUN apk add --no-cache curl

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Switch to non-root user
USER caddy

# Expose ports (8080 = HTTP, 8443 = HTTPS)
EXPOSE 8080 8443

# Set working directory
WORKDIR /var/lib/caddy

# Start Caddy
CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
