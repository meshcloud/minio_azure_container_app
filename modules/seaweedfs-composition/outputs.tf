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
- **Groups**: `developers` (S3WriteRole)

---

## Next Steps

### 1. Configure AWS CLI

```bash
# Configure S3 endpoint for SeaweedFS
aws configure set endpoint_url https://storage.${local.selected_sub}.meshcloud.io --profile seaweedfs
aws configure set region us-east-1 --profile seaweedfs

# Or set via environment variable
export AWS_ENDPOINT_URL=https://storage.${local.selected_sub}.meshcloud.io
```

### 2. Authenticate via Keycloak

Retrieve temporary AWS credentials using OIDC web identity:

```bash
# Get access token from Keycloak
TOKEN=$(curl -X POST "https://keycloak.${local.selected_sub}.meshcloud.io/realms/seaweedfs/protocol/openid-connect/token" \
  -d "grant_type=password" \
  -d "client_id=seaweedfs-client" \
  -d "username=testuser" \
  -d "password=YOUR_PASSWORD" | jq -r '.access_token')

# Exchange token for AWS credentials via SeaweedFS STS
CREDS=$(curl -X POST "https://storage.${local.selected_sub}.meshcloud.io/sts" \
  -d "Action=AssumeRoleWithWebIdentity" \
  -d "WebIdentityToken=$TOKEN" \
  -d "RoleArn=arn:aws:iam::role/S3WriteRole" \
  -d "RoleSessionName=testuser-session")

# Configure AWS CLI with temporary credentials
export AWS_ACCESS_KEY_ID=$(echo $CREDS | xmllint --xpath 'string(//AccessKeyId)' -)
export AWS_SECRET_ACCESS_KEY=$(echo $CREDS | xmllint --xpath 'string(//SecretAccessKey)' -)
export AWS_SESSION_TOKEN=$(echo $CREDS | xmllint --xpath 'string(//SessionToken)' -)
```

### 3. Use S3 API

```bash
# List buckets
aws s3 ls --profile seaweedfs --endpoint-url https://storage.${local.selected_sub}.meshcloud.io

# Create a bucket
aws s3 mb s3://my-bucket --profile seaweedfs --endpoint-url https://storage.${local.selected_sub}.meshcloud.io

# Upload a file
aws s3 cp file.txt s3://my-bucket/ --profile seaweedfs --endpoint-url https://storage.${local.selected_sub}.meshcloud.io

# Download a file
aws s3 cp s3://my-bucket/file.txt ./downloaded-file.txt --profile seaweedfs --endpoint-url https://storage.${local.selected_sub}.meshcloud.io

# List objects in a bucket
aws s3 ls s3://my-bucket --profile seaweedfs --endpoint-url https://storage.${local.selected_sub}.meshcloud.io
```

### 4. Manage Access & Roles

Keycloak provides three pre-configured groups with different S3 permissions:

- **admins** → `S3AdminRole` (full S3 access: `s3:*`)
- **developers** → `S3WriteRole` (read/write/delete: `s3:List*`, `s3:Get*`, `s3:Put*`, `s3:Delete*`)
- **readers** → `S3ReadOnlyRole` (read-only: `s3:List*`, `s3:Get*`)

[Manage Groups & Users](https://keycloak.${local.selected_sub}.meshcloud.io/admin/master/console/#/seaweedfs/groups)

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
