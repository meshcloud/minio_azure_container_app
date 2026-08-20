locals {
  namespace_bb     = local.is_azure ? meshstack_building_block.az_seaweedfs_namespace[0] : meshstack_building_block.ionos_seaweedfs_namespace[0]
  storage_class    = local.is_azure ? "default" : "ionos-enterprise-hdd"
  active_worker_ip = local.is_azure ? var.azure_worker_node_ip : var.ionos_worker_node_ip
}

output "summary" {
  description = "Summary with next steps and insights into created resources"
  value       = <<-EOT
# SeaweedFS S3-Compatible Storage

✅ **Your storage environment is ready!**

This composition has set up the following resources in workspace `${var.owned_by_workspace}`:

@project[${var.owned_by_workspace}.${meshstack_project.project.metadata.name}]\
&nbsp;&nbsp;&nbsp;&nbsp;@tenant[${meshstack_tenant.tenant.metadata.uuid}]\
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;@buildingblock[${local.namespace_bb.metadata.uuid}]

---

## DNS Records

The following DNS A records are automatically created pointing to the load balancer:

| Domain | Target IP |
|--------|-----------|
| `${local.namespace_bb.status.outputs.s3_api_url.value_string}` | `${local.active_worker_ip}` |
| `${local.namespace_bb.status.outputs.keycloak_url.value_string}` | `${local.active_worker_ip}` |

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
[${local.namespace_bb.status.outputs.s3_api_url.value_string}](${local.namespace_bb.status.outputs.s3_api_url.value_string})

### Keycloak Identity Provider
- **URL**: [${local.namespace_bb.status.outputs.keycloak_url.value_string}](${local.namespace_bb.status.outputs.keycloak_url.value_string})
- **Admin Console**: [${local.namespace_bb.status.outputs.keycloak_admin_console_url.value_string}](${local.namespace_bb.status.outputs.keycloak_admin_console_url.value_string})
- **Admin Username**: `admin`
- **Admin Password**: `${local.namespace_bb.status.outputs.keycloak_admin_password.value_string}`

### Credentials Reference

| Type | Username/Client ID | Password/Secret | Purpose |
|------|-------------------|-----------------|---------|
| **Admin (S3)** | `${local.namespace_bb.status.outputs.seaweedfs_admin_access_key.value_string}` | `${local.namespace_bb.status.outputs.seaweedfs_admin_secret_key.value_string}` | Bucket provisioning only |
| **Test User** | `testuser` | `${local.namespace_bb.status.outputs.keycloak_test_user_password.value_string}` | Interactive user testing |
| **Service Account** | `client-app-1` | `${local.namespace_bb.status.outputs.client_app_1_secret.value_string}` | Machine-to-machine for `customer-1` |
| **Service Account** | `client-app-2` | `${local.namespace_bb.status.outputs.client_app_2_secret.value_string}` | Machine-to-machine for `customer-2` |

---

## Quick Start Guide

### Step 1: Admin - Create Buckets

```bash
export AWS_ACCESS_KEY_ID="${local.namespace_bb.status.outputs.seaweedfs_admin_access_key.value_string}"
export AWS_SECRET_ACCESS_KEY="${local.namespace_bb.status.outputs.seaweedfs_admin_secret_key.value_string}"
export AWS_ENDPOINT_URL="${local.namespace_bb.status.outputs.s3_api_url.value_string}"

aws s3 mb s3://airliner-1
aws s3 mb s3://airliner-2
aws s3 ls
```

**Alternative: MinIO Client**

```bash
mc alias set seaweedfs ${local.namespace_bb.status.outputs.s3_api_url.value_string} ${local.namespace_bb.status.outputs.seaweedfs_admin_access_key.value_string} ${local.namespace_bb.status.outputs.seaweedfs_admin_secret_key.value_string}
mc mb seaweedfs/airliner-1
```

---

### Step 2: Role-Based Access

| Keycloak Realm Role | SeaweedFS IAM Role | Bucket Access | Permissions |
|---------------------|-------------------|---------------|-------------|
| `customer-1` | `Airliner1Role` | `airliner-1` | Full S3 access (`s3:*`) |
| `customer-2` | `Airliner2Role` | `airliner-2` | Full S3 access (`s3:*`) |

**How it works:**
1. User/app authenticates with Keycloak → receives OIDC token with realm roles
2. Token is exchanged for temporary AWS STS credentials via `AssumeRoleWithWebIdentity`
3. STS credentials are scoped to the mapped IAM role
4. Temporary credentials expire after 1 hour

---

### Step 3: User Access (Interactive Login)

```bash
export ID_TOKEN=$(curl -s -X POST "${local.namespace_bb.status.outputs.keycloak_url.value_string}/realms/seaweedfs/protocol/openid-connect/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=password" \
  -d "username=testuser" \
  -d "password=${local.namespace_bb.status.outputs.keycloak_test_user_password.value_string}" \
  -d "client_id=seaweedfs-s3" \
  -d "scope=openid profile" | jq -r '.id_token')

CREDS=$(aws sts assume-role-with-web-identity \
  --endpoint-url "${local.namespace_bb.status.outputs.s3_api_url.value_string}" \
  --role-arn "arn:aws:iam::role/Airliner2Role" \
  --role-session-name "testuser-session" \
  --web-identity-token "$ID_TOKEN" \
  --duration-seconds 3600)

export AWS_ACCESS_KEY_ID=$(echo "$CREDS" | jq -r '.Credentials.AccessKeyId')
export AWS_SECRET_ACCESS_KEY=$(echo "$CREDS" | jq -r '.Credentials.SecretAccessKey')
export AWS_SESSION_TOKEN=$(echo "$CREDS" | jq -r '.Credentials.SessionToken')
export AWS_ENDPOINT_URL="${local.namespace_bb.status.outputs.s3_api_url.value_string}"
```

---

### Step 4: Application Access (Service Accounts)

```bash
export ACCESS_TOKEN=$(curl -s -X POST "${local.namespace_bb.status.outputs.keycloak_url.value_string}/realms/seaweedfs/protocol/openid-connect/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "client_id=client-app-1" \
  -d "client_secret=${local.namespace_bb.status.outputs.client_app_1_secret.value_string}" \
  -d "grant_type=client_credentials" | jq -r '.access_token')

CREDS=$(aws sts assume-role-with-web-identity \
  --endpoint-url "${local.namespace_bb.status.outputs.s3_api_url.value_string}" \
  --role-arn "arn:aws:iam::role/Airliner1Role" \
  --role-session-name "app-session" \
  --web-identity-token "$ACCESS_TOKEN" \
  --duration-seconds 3600)
```

---

## Access Kubernetes Resources

Platform: **${var.cloud_provider}**
Namespace: **${local.unique_name}**

[View Namespace](#/w/${var.owned_by_workspace}/p/${meshstack_project.project.metadata.name}/i/${var.platform_identifier}/overview/kubernetes)

---

## Security Notes

- ✅ SSL/TLS enabled via Let's Encrypt (email: ${local.creator_email})
- ✅ ModSecurity WAF active on all ingresses
- ✅ IP whitelisting configured: `${var.allowed_ip_addresses}`
- ✅ OIDC authentication required for user/app S3 access
${local.is_azure ? "- ✅ HTTP to HTTPS redirect enabled" : "- ✅ DNS-01 Let's Encrypt challenge (IONOS)"}

---

## Quick Reference

| Resource | Value |
|----------|-------|
| S3 Endpoint | `${local.namespace_bb.status.outputs.s3_api_url.value_string}` |
| Keycloak URL | `${local.namespace_bb.status.outputs.keycloak_url.value_string}` |
| Keycloak Admin | `${local.namespace_bb.status.outputs.keycloak_admin_console_url.value_string}` |
| Namespace | `${local.unique_name}` |
| Platform | `${var.cloud_provider}` |
| Storage Class | `${local.storage_class}` |

---

🎉 Happy storing!
EOT
}

output "s3_endpoint" {
  description = "SeaweedFS S3 API endpoint"
  value       = local.namespace_bb.status.outputs.s3_api_url.value_string
}

output "keycloak_url" {
  description = "Keycloak authentication URL"
  value       = local.namespace_bb.status.outputs.keycloak_url.value_string
}

output "keycloak_admin_console_url" {
  description = "Keycloak admin console URL"
  value       = local.namespace_bb.status.outputs.keycloak_admin_console_url.value_string
}

output "project_name" {
  description = "Created meshProject name"
  value       = meshstack_project.project.metadata.name
}

output "tenant_uuid" {
  description = "Created meshTenant UUID"
  value       = meshstack_tenant.tenant.metadata.uuid
}

output "namespace" {
  description = "Kubernetes namespace identifier"
  value       = local.unique_name
}

output "aws_cli_configure_command" {
  description = "Command to configure AWS CLI for SeaweedFS S3"
  value       = "aws configure set endpoint_url ${local.namespace_bb.status.outputs.s3_api_url.value_string} --profile seaweedfs"
}
