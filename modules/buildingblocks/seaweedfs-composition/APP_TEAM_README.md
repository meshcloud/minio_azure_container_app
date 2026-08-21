# S3 Storage Service

## What is it?

The **S3 Storage Service** gives your team a fully managed, self-hosted S3-compatible object storage environment on Kubernetes — with Keycloak OIDC authentication, BunkerWeb WAF, and automatic DNS setup. Pick your target cloud with **`cloud_provider`** (`azure` or `ionos`); the composition deploys the matching instance. No cloud vendor lock-in, no shared buckets.

## When to use it?

- You need private S3-compatible storage on Azure AKS or IONOS Kubernetes
- You want OIDC-based authentication with role-based bucket access
- You need enterprise security (WAF, TLS, IP whitelisting) on your storage endpoints

## What gets created?

| Resource | Details |
|----------|---------|
| meshProject + meshTenant | Dedicated project + tenant on the selected platform |
| DNS Records | `<seaweedfs-domain>` and `<keycloak-domain>` A records in the delegated zone |
| Kubernetes Namespace | Isolated namespace for all storage resources |
| SeaweedFS | S3 server with a persistent volume (storage class depends on cloud) |
| Keycloak | OIDC provider with pre-configured realm, 2 service accounts, 1 test user |
| MariaDB | Keycloak database with persistent volume |
| BunkerWeb Ingress | WAF + Let's Encrypt TLS on both endpoints |

## Access & Credentials

All credentials are shown in the **Summary** output after deployment.

### Admin (bucket provisioning only)

```bash
export AWS_ACCESS_KEY_ID="<seaweedfs_admin_access_key>"
export AWS_SECRET_ACCESS_KEY="<seaweedfs_admin_secret_key>"
export AWS_ENDPOINT_URL="https://<seaweedfs-domain>.<your-domain>"

aws s3 mb s3://airliner-1
aws s3 mb s3://airliner-2
aws s3 ls
```

### User access (interactive login)

Users with the `customer-2` realm role get access to `airliner-2`:

```bash
ID_TOKEN=$(curl -s -X POST "https://<keycloak-domain>.<your-domain>/realms/seaweedfs/protocol/openid-connect/token" \
  -d "grant_type=password&username=testuser&password=<testpw>&client_id=seaweedfs-s3&scope=openid profile" \
  | jq -r '.id_token')

CREDS=$(aws sts assume-role-with-web-identity \
  --endpoint-url "https://<seaweedfs-domain>.<your-domain>" \
  --role-arn "arn:aws:iam::role/Airliner2Role" \
  --role-session-name "session" \
  --web-identity-token "$ID_TOKEN")

export AWS_ACCESS_KEY_ID=$(echo "$CREDS" | jq -r '.Credentials.AccessKeyId')
export AWS_SECRET_ACCESS_KEY=$(echo "$CREDS" | jq -r '.Credentials.SecretAccessKey')
export AWS_SESSION_TOKEN=$(echo "$CREDS" | jq -r '.Credentials.SessionToken')
```

### Application access (service accounts)

```bash
ACCESS_TOKEN=$(curl -s -X POST "https://<keycloak-domain>.<your-domain>/realms/seaweedfs/protocol/openid-connect/token" \
  -d "client_id=client-app-1&client_secret=<app1_secret>&grant_type=client_credentials" \
  | jq -r '.access_token')

CREDS=$(aws sts assume-role-with-web-identity \
  --endpoint-url "https://<seaweedfs-domain>.<your-domain>" \
  --role-arn "arn:aws:iam::role/Airliner1Role" \
  --role-session-name "app-session" \
  --web-identity-token "$ACCESS_TOKEN")
```

## Role Mapping

| Keycloak Realm Role | IAM Role        | Bucket       |
|---------------------|-----------------|--------------|
| `customer-1`        | `Airliner1Role` | `airliner-1` |
| `customer-2`        | `Airliner2Role` | `airliner-2` |

## Platform Details

Cloud-specific settings depend on the `cloud_provider` you choose:

| Setting             | Azure (AKS)      | IONOS Kubernetes       |
|---------------------|------------------|------------------------|
| Storage Class       | `default`        | `ionos-enterprise-hdd` |
| Let's Encrypt       | HTTP challenge   | DNS challenge          |
| HTTP→HTTPS Redirect | Enabled          | Disabled               |

## Shared Responsibilities

| Responsibility                                    | Platform Team | App Team |
|---------------------------------------------------|:---:|:---:|
| Provision the Kubernetes cluster (AKS / IONOS)    | ✅ | ❌ |
| Deploy SeaweedFS, Keycloak, MariaDB, BunkerWeb    | ✅ | ❌ |
| Manage DNS records and TLS certificates           | ✅ | ❌ |
| Create and manage S3 buckets                      | ❌ | ✅ |
| Manage object lifecycle (upload/download/delete)  | ❌ | ✅ |
| Assign users to Keycloak realm roles              | ❌ | ✅ |
| Configure AWS CLI or S3 clients                   | ❌ | ✅ |

## Contact

- **Platform Team**: [platform-team@example.com](mailto:platform-team@example.com)
- **Support Tickets**: [Support Portal Link]
