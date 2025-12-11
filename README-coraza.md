# Coraza-Caddy WAF for MinIO

A modern Web Application Firewall built with [Coraza](https://coraza.io) and [Caddy](https://caddyserver.com) to protect MinIO deployments. This container provides enterprise-grade WAF protection with multi-backend routing capabilities.

## Features

- ✅ **OWASP Core Rule Set v4** - Latest security rules
- ✅ **Multi-backend routing** - Single WAF protects MinIO UI + API + Keycloak
- ✅ **Security headers** - Production-ready security configuration
- ✅ **Health checks** - Built-in monitoring endpoints
- ✅ **Rate limiting** - API protection against abuse
- ✅ **Audit logging** - JSON-formatted security logs
- ✅ **Non-root execution** - Security-hardened container

## Quick Start

### GitHub Container Registry

The container is automatically built and published to GitHub Container Registry:

```bash
docker pull ghcr.io/YOUR_USERNAME/minio_azure_container_app/coraza-caddy:latest
```

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `MINIO_UI_BACKEND` | `localhost:9001` | MinIO Console backend |
| `MINIO_API_BACKEND` | `localhost:9000` | MinIO S3 API backend |
| `KEYCLOAK_BACKEND` | `localhost:8083` | Keycloak backend (Azure only) |

### Basic Usage

```bash
docker run -d \
  --name minio-waf \
  -p 8080:8080 \
  -p 8443:8443 \
  -e MINIO_UI_BACKEND=minio-server:9001 \
  -e MINIO_API_BACKEND=minio-server:9000 \
  ghcr.io/YOUR_USERNAME/minio_azure_container_app/coraza-caddy:latest
```

## Architecture

```
Caddy WAF (8080) → MinIO UI (9001)
          (8081) → MinIO API (9000)
          (8082) → Keycloak (8083) [Azure only]
          (8443) → Keycloak HTTPS (8083) [Local dev only]
```

### Port Mapping

| Port | Service | WAF Enabled | Environment |
|------|---------|-------------|-------------|
| 8080 | MinIO UI | ✅ Yes | Both |
| 8081 | MinIO API | ✅ Yes | Both |
| 8082 | Keycloak HTTP | ❌ No (proxy only) | Azure |
| 8443 | Keycloak HTTPS | ❌ No (proxy only) | Local dev |

### Request Routing

**MinIO UI (port 8080):**
- **`/`** → MinIO Console (UI)
- **`/ws/*`** → WebSocket connections (WAF bypassed)
- **`/health`** → Health check endpoint

**MinIO API (port 8081):**
- **All paths** → MinIO S3 API
- **`/health`** → Health check endpoint

**Keycloak (port 8082/8443):**
- **All paths** → Keycloak authentication service

## Security Features

### WAF Protection (MinIO UI & API only)

Keycloak endpoints use simple reverse proxy without WAF to avoid conflicts with authentication flows.

- SQL injection prevention
- XSS protection
- Command injection blocking
- Path traversal prevention
- Rate limiting (100 req/min per IP for API endpoints)

### Custom MinIO Rules
- Logs all DELETE operations for audit
- Rate limits API endpoints

### Security Headers
- HSTS with preload
- Content-Type sniffing prevention
- Clickjacking protection
- XSS protection
- Referrer policy

## Azure Container Apps Deployment

This container is designed for Azure Container Apps deployment:

### Environment Configuration
```yaml
env:
  - name: MINIO_UI_BACKEND
    value: "localhost:9001"
  - name: MINIO_API_BACKEND
    value: "localhost:9000"
  - name: KEYCLOAK_BACKEND
    value: "localhost:8083"
```

### Health Check
The container exposes `/health` endpoints:
- Port 8080: MinIO UI health check
- Port 8081: MinIO API health check

## Development

### Building Locally

```bash
docker build -t coraza-caddy .
```

### Custom Configuration

Mount your own `Caddyfile`:

```bash
docker run -v ./custom-Caddyfile:/etc/caddy/Caddyfile coraza-caddy
```

### GitHub Actions

The container is automatically built on:
- Weekly schedule (Mondays 2 AM UTC)
- Push to main branch
- Manual workflow dispatch

## Monitoring

### Logs
Security events are logged in JSON format to stdout:

```bash
docker logs minio-waf | jq '.audit'
```

### Health Check
```bash
# MinIO UI health check
curl http://localhost:8080/health

# MinIO API health check
curl http://localhost:8081/health
```

### WAF Status
The WAF processes all requests and logs security events. Check the audit logs for detailed security information.

## Security Considerations

- Container runs as non-root user (UID 1001)
- Multi-arch support (AMD64, ARM64)
- Weekly security updates via automated builds
- Vulnerability scanning with Trivy
- Security hardened base image (Alpine)

## License

Apache 2.0 - Same as OWASP Coraza

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test the build
5. Submit a pull request

The GitHub Actions workflow will automatically build and test your changes.
