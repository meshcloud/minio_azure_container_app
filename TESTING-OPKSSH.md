# Testing opkssh with Keycloak

This guide shows you how to test SSH authentication using OpenID Connect (OIDC) via Keycloak.

## What is opkssh?

opkssh enables SSH authentication using OpenID Connect identities (like `test@test.com`) instead of traditional SSH keys. Your OIDC identity token is embedded in a temporary SSH certificate that expires after 24 hours.

## Architecture

```
[Your Machine]                    [Docker Stack]
     |                                 |
     | 1. opkssh login                 |
     |-------------------------------->| Keycloak (OIDC Provider)
     | 2. Browser opens                |
     | 3. Login with test@test.com     |
     |<--------------------------------|
     | 4. SSH key generated            |
     |                                 |
     | 5. ssh -p 2222 testuser@localhost
     |-------------------------------->| SSH Server (verifies via opkssh)
     | 6. Logged in!                   |
```

## Prerequisites

### 1. Install opkssh on Your Local Machine

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
# Add to PATH or use ./opkssh.exe
```

### 2. Start the Docker Stack

```bash
docker-compose up -d
```

Wait for services to be healthy:
```bash
docker-compose ps
```

## Testing Steps

### Step 1: Login with opkssh

Run this command to authenticate with Keycloak:

```bash
opkssh login --provider="http://localhost:8082/realms/minio_realm,opkssh-client"
```

**What happens:**
1. Your browser opens to Keycloak login page
2. Login with:
   - **Username:** `testuser`
   - **Password:** `password`
3. opkssh generates an SSH certificate at `~/.ssh/id_ecdsa`
4. The certificate contains your OIDC identity token from Keycloak

### Step 2: SSH to the Test Server

Now SSH using your OIDC identity:

```bash
ssh -p 2222 testuser@localhost
```

**You should be logged in without entering a password!**

The SSH server verified your identity by:
1. Receiving your SSH certificate
2. Extracting the OIDC token from it
3. Verifying the token against Keycloak
4. Checking `/etc/opk/auth_id` to confirm `test@test.com` can login as `testuser`

### Step 3: Verify You're Logged In

Inside the SSH session:

```bash
whoami
# Output: testuser

hostname
# Output: (container hostname)

exit
```

### Step 4: Inspect Your SSH Certificate

On your local machine:

```bash
# View the SSH certificate
cat ~/.ssh/id_ecdsa-cert.pub

# View certificate details
ssh-keygen -L -f ~/.ssh/id_ecdsa-cert.pub
```

You'll see:
- **Valid:** Current time to expiration (24h from login)
- **Principals:** testuser
- **Extensions:** Contains your OIDC identity token

## Configuration Details

### Keycloak Configuration

- **Realm:** `minio_realm`
- **Client ID:** `opkssh-client`
- **Client Type:** Public (no client secret needed)
- **Redirect URIs:** `http://localhost:3000/login-callback` (and 10001, 11110)

### SSH Server Configuration

**Provider Configuration (`/etc/opk/providers`):**
```
http://coraza-waf:8082/realms/minio_realm opkssh-client 24h
```

**Authorization Configuration (`/etc/opk/auth_id`):**
```
testuser test@test.com http://coraza-waf:8082/realms/minio_realm
```

This allows the OIDC identity `test@test.com` to SSH as the Linux user `testuser`.

## Troubleshooting

### SSH Connection Refused

Check if the SSH server is running:
```bash
docker ps | grep ssh-test-server
docker logs ssh-test-server
```

### Authentication Failed

1. **Check your SSH certificate:**
   ```bash
   ls -la ~/.ssh/id_ecdsa*
   ```
   You should see:
   - `id_ecdsa` (private key)
   - `id_ecdsa.pub` (public key)
   - `id_ecdsa-cert.pub` (certificate)

2. **Verify certificate is valid:**
   ```bash
   ssh-keygen -L -f ~/.ssh/id_ecdsa-cert.pub
   ```
   Check that "Valid:" shows it hasn't expired.

3. **Re-login if expired:**
   ```bash
   opkssh login --provider="http://localhost:8082/realms/minio_realm,opkssh-client"
   ```

### Verify opkssh on Server

Check if the SSH server can verify your certificate:

```bash
# Copy your public key
cat ~/.ssh/id_ecdsa-cert.pub

# Test verification (replace <PUBKEY> with actual key)
docker exec ssh-test-server /usr/local/bin/opkssh verify testuser "<PUBKEY>" ssh-ed25519
```

### Check Keycloak Connectivity

Verify the SSH server can reach Keycloak:

```bash
docker exec ssh-test-server curl http://coraza-waf:8082/realms/minio_realm/.well-known/openid-configuration
```

Should return JSON with OIDC configuration.

### Enable SSH Debug Mode

For detailed SSH logs:

```bash
ssh -v -p 2222 testuser@localhost
```

Use `-vv` or `-vvv` for even more detail.

## Advanced: Adding More Users

### Add Another Keycloak User

1. **Access Keycloak Admin Console:**
   - URL: http://localhost:8082
   - Username: `admin`
   - Password: `admin`

2. **Go to:** Users → Add User
   - Username: `alice`
   - Email: `alice@example.com`
   - First Name: `Alice`
   - Save

3. **Set Password:** Credentials → Set Password

### Authorize the New User for SSH

Edit `opk-auth_id`:
```bash
echo "testuser alice@example.com http://coraza-waf:8082/realms/minio_realm" >> opk-auth_id
```

Restart SSH server:
```bash
docker-compose restart ssh-server
```

Now Alice can SSH after running:
```bash
opkssh login --provider="http://localhost:8082/realms/minio_realm,opkssh-client"
ssh -p 2222 testuser@localhost
```

## Advanced: Group-Based Access

### Add Groups to Keycloak

1. **Create Group:** Groups → New → Name: `ssh-users`
2. **Add to Client Scope:**
   - Client Scopes → Create → Name: `groups`
   - Mappers → Add Mapper → Group Membership
   - Token Claim Name: `groups`
3. **Add to Client:** Clients → opkssh-client → Client Scopes → Add client scope → `groups`

### Update Authorization

Edit `opk-auth_id`:
```bash
echo 'testuser oidc:groups:ssh-users http://coraza-waf:8082/realms/minio_realm' >> opk-auth_id
```

Now any user in the `ssh-users` group can SSH as `testuser`.

## Security Notes

1. **SSH certificates expire after 24h** - Users must run `opkssh login` daily
2. **No long-lived SSH keys** - Reduces risk if a machine is compromised
3. **Centralized access control** - Manage SSH access via Keycloak instead of distributing SSH keys
4. **Audit trail** - Keycloak logs all authentication events

## Cleanup

Stop and remove all containers:
```bash
docker-compose down
```

Remove your SSH certificate:
```bash
rm ~/.ssh/id_ecdsa*
```

## Next Steps

- Deploy to production servers (see [scripts/installing.md](scripts/installing.md))
- Integrate with your existing OIDC provider (Azure AD, Google, etc.)
- Configure more complex policies (see [docs/policyplugins.md](docs/policyplugins.md))
- Set up group-based access control
- Configure certificate expiration policies

## Resources

- [opkssh GitHub](https://github.com/openpubkey/opkssh)
- [OpenPubkey Documentation](https://github.com/openpubkey/openpubkey)
- [Keycloak Documentation](https://www.keycloak.org/documentation)
