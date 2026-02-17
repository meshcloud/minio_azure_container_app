# opkssh Test Environment

This directory contains a Docker Compose setup for testing opkssh SSH certificate authentication against the Kubernetes-hosted Keycloak instance.

## Architecture

```
[Your Machine]                    [Kubernetes (kind)]
     |                                 |
     | 1. opkssh login                 |
     |-------------------------------->| Keycloak (http://auth.localhost)
     | 2. Browser opens                |
     | 3. Login with test@test.com     |
     |<--------------------------------|
     | 4. SSH certificate generated    |
     |                                 |
     |    [Docker Compose]             |
     |    ssh -p 2222 testuser@localhost|
     |-------------------------------->| SSH Server (verifies via opkssh)
     | 5. Logged in!                   |   (reaches Keycloak via host-gateway)
```

The SSH server container uses `extra_hosts: auth.localhost:host-gateway` to reach Keycloak running in kind on the host.

## Prerequisites

- Docker and Docker Compose
- Kubernetes (kind) cluster with Terraform resources applied (`terraform apply` in parent directory)
- Keycloak accessible at `http://auth.localhost`
- opkssh CLI tool

## Quick Start

### 1. Deploy Kubernetes Resources

```bash
cd ..
terraform init
terraform apply
```

### 2. Start the SSH Test Server

```bash
./setup-local.sh
```

### 3. Install opkssh

**macOS:**
```bash
brew tap openpubkey/opkssh
brew install opkssh
```

**Linux:**
```bash
curl -L https://github.com/openpubkey/opkssh/releases/latest/download/opkssh-linux-amd64 -o opkssh
chmod +x opkssh
sudo mv opkssh /usr/local/bin/
```

### 4. Login with opkssh

```bash
opkssh login --provider="http://auth.localhost/realms/seaweedfs,opkssh-client"
```

Credentials: `test@test.com` / `test`

### 5. SSH to Test Server

```bash
ssh -p 2222 testuser@localhost
```

## Directory Structure

```
docker-compose/
├── setup-local.sh                    # Local setup script
├── setup-azure-config.sh             # External deployment config helper
├── docker-compose.yml                # SSH server (local)
├── docker-compose.external-test.yml  # SSH server (external deployment)
├── Dockerfile.ssh-server             # Local SSH server with opkssh
├── Dockerfile.ssh-external-test      # External SSH server for remote Keycloak
├── docker-entrypoint.sh              # SSH server startup script
├── opk-providers-local/providers     # opkssh provider config (local)
├── opk-auth_id-local/auth_id         # opkssh auth mapping (local)
├── opk-providers-azure/providers     # opkssh provider config (external, gitignored content)
├── opk-auth_id-azure/auth_id         # opkssh auth mapping (external, gitignored content)
├── README.md                         # This file
└── TESTING-OPKSSH.md                 # Detailed opkssh testing guide
```

## Configuration

### Local (opk-*-local/)

Used by `docker-compose.yml`:
- **Issuer:** `http://auth.localhost/realms/seaweedfs`
- **Client:** `opkssh-client` (public)
- **Test user:** `test@test.com` -> Linux user `testuser`

### External (opk-*-azure/)

Used by `docker-compose.external-test.yml` for testing against a remote Keycloak deployment.
File contents are gitignored. Generate them with:

```bash
./setup-azure-config.sh https://auth.example.com
```

## Testing Against External Deployment

```bash
./setup-azure-config.sh <KEYCLOAK_URL>
docker-compose -f docker-compose.external-test.yml up -d
opkssh login --provider="<KEYCLOAK_URL>/realms/seaweedfs,opkssh-client"
ssh -p 2223 testuser@localhost
```

The external test server runs on port **2223** to avoid conflicts with local testing.

## Common Operations

```bash
docker-compose logs -f              # View logs
docker-compose restart ssh-server   # Restart SSH server
docker-compose build ssh-server     # Rebuild after config changes
docker-compose down                 # Stop
```

## Troubleshooting

### SSH Authentication Fails

```bash
ssh-keygen -L -f ~/.ssh/id_ecdsa-cert.pub   # Check certificate
opkssh login --provider="http://auth.localhost/realms/seaweedfs,opkssh-client"  # Re-login
```

### Cannot Reach Keycloak from Container

```bash
docker exec ssh-test-server curl http://auth.localhost/realms/seaweedfs/.well-known/openid-configuration
```

### Permission Denied

```bash
docker exec ssh-test-server ls -la /etc/opk/   # Check file permissions (should be 640)
docker-compose restart ssh-server               # Entrypoint fixes permissions on start
```

## Additional Documentation

- [TESTING-OPKSSH.md](./TESTING-OPKSSH.md) - Detailed opkssh testing guide
- [opkssh GitHub](https://github.com/openpubkey/opkssh)
- [Keycloak Docs](https://www.keycloak.org/documentation)
