output "summary" {
  description = "Summary with next steps and insights into created resources"
  value       = <<-EOT
# SeaweedFS S3-Compatible Storage

✅ **Your storage environment is ready!**

This composition has set up the following resources in workspace `${var.owned_by_workspace}`:

@project[${var.owned_by_workspace}.${meshstack_project.project.metadata.name}]\
&nbsp;&nbsp;&nbsp;&nbsp;@tenant[${meshstack_tenant_v4.tenant.metadata.uuid}]\
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@buildingblock[${meshstack_building_block_v2.seaweedfs_dns_record.metadata.uuid}]\
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@buildingblock[${meshstack_building_block_v2.keycloak_dns_record.metadata.uuid}]\
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@buildingblock[${meshstack_building_block_v2.namespace.metadata.uuid}]

---

## What's Included

Your S3-compatible storage includes:

- **SeaweedFS** - S3-compatible object storage server
- **Keycloak** - OIDC authentication & authorization
- **MariaDB** - Keycloak database backend
- **BunkerWeb** - Web Application Firewall with auto-SSL
- **IAM Integration** - AWS STS-compatible role-based access

---

## Access Your Services

### S3 API Endpoint
[storage.${local.selected_sub}.meshcloud.io](https://storage.${local.selected_sub}.meshcloud.io)

### Keycloak Identity Provider
- **URL**: [keycloak.${local.selected_sub}.meshcloud.io](https://keycloak.${local.selected_sub}.meshcloud.io)
- **Admin Console**: [keycloak.${local.selected_sub}.meshcloud.io/admin](https://keycloak.${local.selected_sub}.meshcloud.io/admin)
- **Admin Username**: `admin`
- **Admin Password**: Check building block outputs (sensitive)

### Credentials Reference

Retrieve these from building block outputs:

| Type | Username/Client ID | Password/Secret | Purpose |
|------|-------------------|-----------------|---------|
| **Admin (S3)** | `admin_access_key` | `admin_secret_key` | Bucket provisioning only |
| **Test User** | `testuser` | (see outputs) | Interactive user testing |
| **Service Account** | `client-app-1` | (see outputs) | Machine-to-machine for `customer-1` |
| **Service Account** | `client-app-2` | (see outputs) | Machine-to-machine for `customer-2` |

---

## Quick Start Guide

### Step 1: Admin - Create Buckets

**Administrators** provision buckets using **static admin credentials**. These credentials bypass OIDC and should only be used for initial setup.

```bash
# Configure AWS CLI with admin credentials (retrieve from building block outputs)
export AWS_ACCESS_KEY_ID="<admin_access_key>"
export AWS_SECRET_ACCESS_KEY="<admin_secret_key>"
export AWS_ENDPOINT_URL="https://storage.${local.selected_sub}.meshcloud.io"

# Create buckets
aws s3 mb s3://airliner-1
aws s3 mb s3://airliner-2

# Verify
aws s3 ls
```

**Alternative: MinIO Client for advanced management**

```bash
mc alias set seaweedfs https://storage.${local.selected_sub}.meshcloud.io <admin_access_key> <admin_secret_key>
mc mb seaweedfs/airliner-1
```

---

### Step 2: Understand Role-Based Access

User and application access is controlled through **Keycloak realm role membership**. When users or service accounts authenticate, their assigned roles determine which buckets they can access.

| Keycloak Realm Role | SeaweedFS IAM Role | Bucket Access | Permissions |
|---------------------|-------------------|---------------|-------------|
| `customer-1` | `Airliner1Role` | `airliner-1` | Full S3 access (`s3:*`) |
| `customer-2` | `Airliner2Role` | `airliner-2` | Full S3 access (`s3:*`) |
| `dummy` | N/A | Resource-based policies | Placeholder for dynamic policies |

**How it works:**
1. User/app authenticates with Keycloak → receives OIDC token containing realm roles
2. Token is exchanged for temporary AWS STS credentials via `AssumeRoleWithWebIdentity`
3. STS credentials are scoped to the permissions of the mapped IAM role
4. Temporary credentials expire after 1 hour (default)

---

### Step 3: User Access (Interactive Login)

**End users** authenticate with username/password to access buckets based on their assigned roles.

```bash
# Get OIDC token from Keycloak
export ID_TOKEN=$(curl -s -X POST "https://keycloak.${local.selected_sub}.meshcloud.io/realms/seaweedfs/protocol/openid-connect/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=password" \
  -d "username=testuser" \
  -d "password=<testuser_password>" \
  -d "client_id=seaweedfs-client" \
  -d "scope=openid profile" | jq -r '.id_token')

# Exchange token for AWS STS credentials (customer-2 → Airliner2Role → airliner-2)
CREDS=$(aws sts assume-role-with-web-identity \
  --endpoint-url "https://storage.${local.selected_sub}.meshcloud.io" \
  --role-arn "arn:aws:iam::role/Airliner2Role" \
  --role-session-name "testuser-session-$(date +%s)" \
  --web-identity-token "$ID_TOKEN" \
  --duration-seconds 3600)

# Configure AWS CLI with temporary credentials
export AWS_ACCESS_KEY_ID=$(echo "$CREDS" | jq -r '.Credentials.AccessKeyId')
export AWS_SECRET_ACCESS_KEY=$(echo "$CREDS" | jq -r '.Credentials.SecretAccessKey')
export AWS_SESSION_TOKEN=$(echo "$CREDS" | jq -r '.Credentials.SessionToken')
export AWS_ENDPOINT_URL="https://storage.${local.selected_sub}.meshcloud.io"

# Use S3 API
aws s3 ls
aws s3 cp file.txt s3://airliner-2/
aws s3 ls s3://airliner-2/
```

---

### Step 4: Application Access (Service Accounts)

**Applications** use **client credentials** (machine-to-machine) for automated access. This is the recommended approach for service accounts.

**Complete Example: Bucket Creation → Client Access**

```bash
# Step 1: Admin creates bucket (if not already done)
export AWS_ACCESS_KEY_ID="<admin_access_key>"
export AWS_SECRET_ACCESS_KEY="<admin_secret_key>"
export AWS_ENDPOINT_URL="https://storage.${local.selected_sub}.meshcloud.io"

aws s3 mb s3://airliner-1
aws s3 ls

# Step 2: Application accesses bucket via client credentials (client-app-1)
# Obtain access token using client credentials (no username/password needed)
export ACCESS_TOKEN=$(curl -s -X POST "https://keycloak.${local.selected_sub}.meshcloud.io/realms/seaweedfs/protocol/openid-connect/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "client_id=client-app-1" \
  -d "client_secret=<client_app_1_secret>" \
  -d "grant_type=client_credentials" | jq -r '.access_token')

# Exchange for AWS STS credentials (customer-1 → Airliner1Role → airliner-1)
CREDS=$(aws sts assume-role-with-web-identity \
  --endpoint-url "https://storage.${local.selected_sub}.meshcloud.io" \
  --role-arn "arn:aws:iam::role/Airliner1Role" \
  --role-session-name "app-session-$(date +%s)" \
  --web-identity-token "$ACCESS_TOKEN" \
  --duration-seconds 3600)

# Configure AWS CLI with temporary credentials
export AWS_ACCESS_KEY_ID=$(echo "$CREDS" | jq -r '.Credentials.AccessKeyId')
export AWS_SECRET_ACCESS_KEY=$(echo "$CREDS" | jq -r '.Credentials.SecretAccessKey')
export AWS_SESSION_TOKEN=$(echo "$CREDS" | jq -r '.Credentials.SessionToken')
export AWS_ENDPOINT_URL="https://storage.${local.selected_sub}.meshcloud.io"

# Step 3: Use S3 API with application credentials
# List accessible buckets
aws s3 ls

# Upload a file
echo "Hello from client-app-1!" > test-file.txt
aws s3 cp test-file.txt s3://airliner-1/

# List objects in bucket
aws s3 ls s3://airliner-1/
```

**Key Points:**
- ✅ Service accounts (`client-app-1`, `client-app-2`) are pre-configured with realm role assignments
- ✅ No `profile` scope needed for client credentials flow (only `openid` or omit entirely)
- ✅ Credentials are temporary (1 hour default) and scoped to the service account's role
- ✅ Each application is isolated to its assigned bucket via RBAC

---

### Step 5: Manage Users & Roles

To add users or change role assignments, use the Keycloak admin console:

[Manage Users & Roles](https://keycloak.${local.selected_sub}.meshcloud.io/admin/master/console/#/seaweedfs/users)

**To add new buckets and roles:**
1. Create the bucket using admin credentials (Step 1)
2. Update SeaweedFS IAM configuration to add new policies/roles (requires configuration change + restart)
3. **OR** use dynamic bucket policies with `mc anonymous set-json` and the `dummy` role

---

## Access Kubernetes Resources

Platform: **${var.k8s_platform}**  
Namespace: **${local.unique_name}**

[View Namespace](#/w/${var.owned_by_workspace}/p/${meshstack_project.project.metadata.name}/i/${var.platform_identifier}/overview/kubernetes)

---

## Security Notes

- ✅ SSL/TLS enabled via Let's Encrypt (email: ${local.creator_email})
- ✅ ModSecurity WAF active on all ingresses
- ✅ IP whitelisting configured: `${var.allowed_ip_addresses}`
- ✅ OIDC authentication required for user/app S3 access
- ✅ Role-based access control via Keycloak realm roles
- ⚠️ Admin credentials bypass OIDC - use only for bucket provisioning
${var.k8s_platform == "azure" ? "- ✅ HTTP to HTTPS redirect enabled" : ""}

---

## Troubleshooting

### Check Service Health

```bash
# Keycloak health check
curl https://keycloak.${local.selected_sub}.meshcloud.io/health

# Test S3 connectivity
curl -I https://storage.${local.selected_sub}.meshcloud.io
```

### View Building Block Status

- [SeaweedFS DNS Record](#/w/${var.owned_by_workspace}/p/${meshstack_project.project.metadata.name}/t/${meshstack_tenant_v4.tenant.metadata.uuid}/bb/${meshstack_building_block_v2.seaweedfs_dns_record.metadata.uuid})
- [Keycloak DNS Record](#/w/${var.owned_by_workspace}/p/${meshstack_project.project.metadata.name}/t/${meshstack_tenant_v4.tenant.metadata.uuid}/bb/${meshstack_building_block_v2.keycloak_dns_record.metadata.uuid})
- [Namespace Building Block](#/w/${var.owned_by_workspace}/p/${meshstack_project.project.metadata.name}/t/${meshstack_tenant_v4.tenant.metadata.uuid}/bb/${meshstack_building_block_v2.namespace.metadata.uuid})

---

## Quick Reference

| Resource | Value |
|----------|-------|
| S3 Endpoint | `https://storage.${local.selected_sub}.meshcloud.io` |
| Keycloak URL | `https://keycloak.${local.selected_sub}.meshcloud.io` |
| Keycloak Admin | `https://keycloak.${local.selected_sub}.meshcloud.io/admin` |
| Namespace | `${local.unique_name}` |
| Platform | `${var.k8s_platform}` |
| Storage Class | `${local.storage_class_name}` |

---

🎉 Happy storing!

**Questions?** Contact your platform team or check the [SeaweedFS documentation](https://github.com/seaweedfs/seaweedfs/wiki).
EOT
}

output "s3_endpoint" {
  description = "SeaweedFS S3 API endpoint"
  value       = "https://storage.${local.selected_sub}.meshcloud.io"
}

output "keycloak_url" {
  description = "Keycloak authentication URL"
  value       = "https://keycloak.${local.selected_sub}.meshcloud.io"
}

output "keycloak_admin_console_url" {
  description = "Keycloak admin console URL"
  value       = "https://keycloak.${local.selected_sub}.meshcloud.io/admin"
}

output "project_name" {
  description = "Created meshProject name"
  value       = meshstack_project.project.metadata.name
}

output "tenant_uuid" {
  description = "Created meshTenant UUID"
  value       = meshstack_tenant_v4.tenant.metadata.uuid
}

output "namespace" {
  description = "Kubernetes namespace identifier"
  value       = local.unique_name
}

output "aws_cli_configure_command" {
  description = "Command to configure AWS CLI for SeaweedFS S3"
  value       = "aws configure set endpoint_url https://storage.${local.selected_sub}.meshcloud.io --profile seaweedfs"
}
