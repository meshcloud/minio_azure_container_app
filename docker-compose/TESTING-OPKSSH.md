# Testing opkssh with Keycloak

This guide covers SSH authentication using OpenID Connect (OIDC) via Keycloak, managed by opkssh.

## What is opkssh?

opkssh enables SSH authentication using OpenID Connect identities (like `test@test.com`) instead of traditional SSH keys. Your OIDC identity token is embedded in a temporary SSH certificate that expires after 24 hours.

## Prerequisites

### 1. Kubernetes Stack Running

The Keycloak instance must be running in kind via Terraform:

```bash
cd ..
terraform apply
```

Verify Keycloak is accessible:

```bash
curl http://auth.localhost/realms/seaweedfs/.well-known/openid-configuration
```

### 2. Install opkssh

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

**Windows:**
```powershell
curl https://github.com/openpubkey/opkssh/releases/latest/download/opkssh-windows-amd64.exe -o opkssh.exe
```

### 3. Start the SSH Test Server

```bash
./setup-local.sh
```

## Testing Steps

### Step 1: Login with opkssh

```bash
opkssh login --provider="http://auth.localhost/realms/seaweedfs,opkssh-client"
```

This will:
- Open your browser to Keycloak login
- Use credentials: `test@test.com` / `test`
- Generate an SSH certificate valid for 24 hours

### Step 2: SSH to the Test Server

```bash
ssh -p 2222 testuser@localhost
```

You should be logged in without entering a password. The SSH server:
1. Receives your SSH certificate
2. Extracts the OIDC token from it
3. Verifies the token against Keycloak at `http://auth.localhost/realms/seaweedfs`
4. Checks `/etc/opk/auth_id` to confirm `test@test.com` can login as `testuser`

### Step 3: Verify

```bash
whoami      # Output: testuser
hostname    # Output: (container hostname)
exit
```

### Step 4: Inspect Your SSH Certificate

```bash
ssh-keygen -L -f ~/.ssh/id_ecdsa-cert.pub
```

You'll see:
- **Valid:** Current time to expiration (24h from login)
- **Principals:** testuser
- **Extensions:** Contains your OIDC identity token

## Configuration Details

### Keycloak

- **Realm:** `seaweedfs`
- **Client ID:** `opkssh-client`
- **Client Type:** Public (no client secret needed)
- **Redirect URIs:** `http://localhost:3000/login-callback` (and 10001, 11110)

### SSH Server

**Provider Configuration (`/etc/opk/providers`):**
```
http://auth.localhost/realms/seaweedfs opkssh-client 24h
```

**Authorization Configuration (`/etc/opk/auth_id`):**
```
testuser test@test.com http://auth.localhost/realms/seaweedfs
```

## Troubleshooting

### SSH Connection Refused

```bash
docker ps | grep ssh-test-server
docker logs ssh-test-server
```

### Authentication Failed

1. Check your SSH certificate:
   ```bash
   ls -la ~/.ssh/id_ecdsa*
   ssh-keygen -L -f ~/.ssh/id_ecdsa-cert.pub
   ```

2. Re-login if expired:
   ```bash
   opkssh login --provider="http://auth.localhost/realms/seaweedfs,opkssh-client"
   ```

### Verify opkssh on Server

```bash
docker exec ssh-test-server /usr/local/bin/opkssh verify testuser "$(cat ~/.ssh/id_ecdsa-cert.pub)" ecdsa-sha2-nistp256
```

### Check Keycloak Connectivity from Container

```bash
docker exec ssh-test-server curl http://auth.localhost/realms/seaweedfs/.well-known/openid-configuration
```

### Enable SSH Debug Mode

```bash
ssh -vvv -p 2222 testuser@localhost
```

## Adding More Users

### 1. Add User in Keycloak

- URL: `http://auth.localhost`
- Admin credentials: `admin` / `admin`
- Navigate to: Users -> Add User

### 2. Authorize for SSH

Edit `opk-auth_id-local/auth_id`:
```
testuser alice@example.com http://auth.localhost/realms/seaweedfs
```

Rebuild:
```bash
docker-compose build ssh-server && docker-compose up -d ssh-server
```

## Group-Based Access

### 1. Configure Groups in Keycloak

1. Create group: Groups -> New -> `ssh-users`
2. Add client scope: Client Scopes -> Create -> `groups`
3. Add mapper: Group Membership with token claim `groups`
4. Attach to client: Clients -> opkssh-client -> Client Scopes -> Add `groups`

### 2. Update Authorization

Edit `opk-auth_id-local/auth_id`:
```
testuser oidc:groups:ssh-users http://auth.localhost/realms/seaweedfs
```

Now any user in `ssh-users` can SSH as `testuser`.

## Cleanup

```bash
docker-compose down
rm ~/.ssh/id_ecdsa*
```

## Resources

- [opkssh GitHub](https://github.com/openpubkey/opkssh)
- [OpenPubkey Documentation](https://github.com/openpubkey/openpubkey)
- [Keycloak Documentation](https://www.keycloak.org/documentation)
