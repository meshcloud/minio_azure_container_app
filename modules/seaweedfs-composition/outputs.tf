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

### Test User Credentials
- **Username**: `testuser`
- **Email**: `testuser@example.com`
- **Password**: Check building block outputs (sensitive)
- **Assigned Roles**: `customer-2` (access to `airliner-2` bucket)

---

## Authentication & Authorization Overview

SeaweedFS integrates with **Keycloak OIDC** for federated identity and role-based access control (RBAC).

### Two Access Patterns

1. **Admin Access (Static Credentials)**
   - Used **only by administrators** to provision buckets and manage policies
   - Credentials: `admin_access_key` + `admin_secret_key` (from building block outputs)
   - **Does NOT use OIDC** – direct S3 API access
   - Use AWS CLI or MinIO Client (`mc`)

2. **User Access (OIDC + STS)**
   - Used by **end users and applications** to access buckets
   - Flow: Authenticate with Keycloak → Get OIDC token → Exchange for AWS STS credentials
   - Roles mapped from Keycloak realm roles: `customer-1`, `customer-2`
   - Temporary credentials (default: 1 hour)

### Role Mapping

User permissions are controlled through **Keycloak realm role membership**:

| Keycloak Role | SeaweedFS Role | Permissions | Buckets |
|---------------|----------------|-------------|---------|
| `customer-1` | `Airliner1Role` | Full S3 access (`s3:*`) | `airliner-1` |
| `customer-2` | `Airliner2Role` | Full S3 access (`s3:*`) | `airliner-2` |

> **Note**: The `dummy` role is available as a placeholder for users with resource-based bucket policies only.

---

## Next Steps

### 1. Admin: Create Buckets Using Static Credentials

**Administrators** provision buckets using **static admin credentials** (not OIDC). These credentials are available in the building block outputs.

```bash
# Configure AWS CLI with admin credentials (retrieve from building block outputs)
export AWS_ACCESS_KEY_ID="<admin_access_key>"
export AWS_SECRET_ACCESS_KEY="<admin_secret_key>"
export AWS_ENDPOINT_URL=https://storage.${local.selected_sub}.meshcloud.io

# Create buckets for your users/teams
aws s3 mb s3://airliner-1
aws s3 mb s3://airliner-2
aws s3 mb s3://shared-data

# List all buckets
aws s3 ls
```

**Alternative: Use MinIO Client (`mc`) for advanced bucket management**

```bash
# Configure mc with admin credentials
mc alias set seaweedfs https://storage.${local.selected_sub}.meshcloud.io <admin_access_key> <admin_secret_key>

# Create buckets
mc mb seaweedfs/airliner-1

# Apply dynamic bucket policies (user home folders with OIDC claims)
mc anonymous set-json policy.json seaweedfs/airliner-1
```

> ⚠️ **Note**: Admin credentials bypass OIDC authentication and should be used **only for initial bucket provisioning and policy management**.

---

### 2. Users: Access Buckets with OIDC Authentication

**End users** authenticate via **Keycloak OIDC** and receive temporary AWS credentials mapped to their assigned roles.

#### Step 2.1: Authenticate with Keycloak and Get OIDC Token

```bash
# Obtain OIDC ID token from Keycloak
export ID_TOKEN=$(curl -s -X POST "https://keycloak.${local.selected_sub}.meshcloud.io/realms/seaweedfs/protocol/openid-connect/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=password" \
  -d "username=testuser" \
  -d "password=<testuser_password>" \
  -d "client_id=seaweedfs-client" \
  -d "scope=openid profile" | jq -r '.id_token')
```

#### Step 2.2: Exchange OIDC Token for AWS STS Credentials

```bash
# Request temporary AWS credentials via STS AssumeRoleWithWebIdentity
aws sts assume-role-with-web-identity \
  --endpoint-url "https://storage.${local.selected_sub}.meshcloud.io" \
  --role-arn "arn:aws:iam::role/Airliner2Role" \
  --role-session-name "testuser-session-$(date +%s)" \
  --web-identity-token "$ID_TOKEN" \
  --duration-seconds 3600 \
  --output json > /tmp/sts-creds.json

# Extract and configure temporary credentials
export AWS_ACCESS_KEY_ID=$(jq -r '.Credentials.AccessKeyId' /tmp/sts-creds.json)
export AWS_SECRET_ACCESS_KEY=$(jq -r '.Credentials.SecretAccessKey' /tmp/sts-creds.json)
export AWS_SESSION_TOKEN=$(jq -r '.Credentials.SessionToken' /tmp/sts-creds.json)
export AWS_ENDPOINT_URL=https://storage.${local.selected_sub}.meshcloud.io
```

#### Step 2.3: Use S3 API with User Credentials

```bash
# List accessible buckets (based on role permissions)
aws s3 ls

# Upload a file to authorized bucket
aws s3 cp file.txt s3://airliner-2/

# Download a file
aws s3 cp s3://airliner-2/file.txt ./downloaded-file.txt

# List objects in bucket
aws s3 ls s3://airliner-2
```

---

### 3. Manage Access & Roles

Keycloak provides two pre-configured realm roles for customer bucket access:

- **customer-1** → `Airliner1Role` (full access to `airliner-1` bucket)
- **customer-2** → `Airliner2Role` (full access to `airliner-2` bucket)

**To add new users or change role assignments**, access the Keycloak admin console:

[Manage Users & Roles](https://keycloak.${local.selected_sub}.meshcloud.io/admin/master/console/#/seaweedfs/users)

**To add new buckets and roles**, you must:
1. Create the bucket using admin credentials (see Step 1)
2. Update the SeaweedFS IAM configuration to add new policies and roles (requires configuration change + restart)
3. OR use dynamic bucket policies via MinIO Client (`mc anonymous set-json`) with the `dummy` role

---

### 4. Application Authentication (Client Credentials Flow)

Applications use **client credentials grant** (machine-to-machine) instead of user passwords. This is the recommended approach for automated systems and service accounts.

**Pre-configured service accounts**:
- `client-app-1` → Role: `customer-1` (access to `airliner-1`)
- `client-app-2` → Role: `customer-2` (access to `airliner-2`)

Client secrets are available in the building block outputs.

#### Complete Example: End-to-End Workflow

Here's a complete working example that demonstrates the full workflow from admin bucket creation to client application access:

```bash
# ============================================================================
# STEP 1: ADMIN - Create Bucket with Static Credentials
# ============================================================================
# Retrieve admin credentials from building block outputs
export AWS_ACCESS_KEY_ID="<admin_access_key>"
export AWS_SECRET_ACCESS_KEY="<admin_secret_key>"
export AWS_ENDPOINT_URL="https://storage.${local.selected_sub}.meshcloud.io"

# Create bucket for client-app-1 (customer-1 role = airliner-1)
aws s3 mb s3://airliner-1

# Verify bucket creation
aws s3 ls

# ============================================================================
# STEP 2: APPLICATION - Access Bucket via Client Credentials + OIDC
# ============================================================================
# Obtain access token using client credentials (machine-to-machine auth)
export ACCESS_TOKEN=$(curl -s -X POST "https://keycloak.${local.selected_sub}.meshcloud.io/realms/seaweedfs/protocol/openid-connect/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "client_id=client-app-1" \
  -d "client_secret=<client_app_1_secret>" \
  -d "grant_type=client_credentials" | jq -r '.access_token')

# Exchange OIDC token for temporary AWS STS credentials
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

# ============================================================================
# STEP 3: USE S3 API WITH CLIENT APPLICATION CREDENTIALS
# ============================================================================
# List accessible buckets (should see airliner-1)
aws s3 ls

# Upload a file to the bucket
echo "Hello from client-app-1!" > test-file.txt
aws s3 cp test-file.txt s3://airliner-1/test-file.txt

# List objects in bucket
aws s3 ls s3://airliner-1/

# Download the file
aws s3 cp s3://airliner-1/test-file.txt ./downloaded-file.txt
```

**Important Notes:**
- ⚠️ The scope parameter in the token request should **NOT** include `profile` for client credentials flow (only `openid` or omit entirely)
- ✅ Admin credentials bypass OIDC and should only be used for bucket provisioning
- ✅ Client credentials are temporary (default: 1 hour) and automatically include the service account's assigned roles
- ✅ Each client application is isolated to its assigned bucket via role-based access control

---

### 5. Access Kubernetes Resources

Platform: **${var.k8s_platform}**  
Namespace: **${local.unique_name}**

[View Namespace](#/w/${var.owned_by_workspace}/p/${meshstack_project.project.metadata.name}/i/${var.platform_identifier}/overview/kubernetes)

---

## Security Notes

- ✅ SSL/TLS enabled via Let's Encrypt (email: ${local.creator_email})
- ✅ ModSecurity WAF active on all ingresses
- ✅ IP whitelisting configured: `${var.allowed_ip_addresses}`
- ✅ OIDC authentication required for S3 access
- ✅ Role-based access control via Keycloak groups
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

Check the status of deployed building blocks in the meshStack panel:
- [SeaweedFS DNS Record](#/w/${var.owned_by_workspace}/p/${meshstack_project.project.metadata.name}/t/${meshstack_tenant_v4.tenant.metadata.uuid}/bb/${meshstack_building_block_v2.seaweedfs_dns_record.metadata.uuid})
- [Keycloak DNS Record](#/w/${var.owned_by_workspace}/p/${meshstack_project.project.metadata.name}/t/${meshstack_tenant_v4.tenant.metadata.uuid}/bb/${meshstack_building_block_v2.keycloak_dns_record.metadata.uuid})
- [Namespace Building Block](#/w/${var.owned_by_workspace}/p/${meshstack_project.project.metadata.name}/t/${meshstack_tenant_v4.tenant.metadata.uuid}/bb/${meshstack_building_block_v2.namespace.metadata.uuid})

---

## Quick Reference

| Resource | Value |
|----------|-------|
| S3 Endpoint | `https://storage.${local.selected_sub}.meshcloud.io` |
| Keycloak URL | `https://keycloak.${local.selected_sub}.meshcloud.io` |
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
