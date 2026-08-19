# SeaweedFS S3 Storage Instance (Azure AKS)

## What is it?

A deployed SeaweedFS instance on Azure AKS providing S3-compatible object storage with Keycloak OIDC authentication, protected by the shared BunkerWeb WAF.

## Resources Deployed

- **Kubernetes Namespace**: Isolated environment for your storage instance
- **SeaweedFS**: S3-compatible object storage server with persistent volume (`default` storage class)
- **Keycloak**: OIDC identity provider with pre-configured realm, clients, test user, and service accounts
- **MariaDB**: Database backend for Keycloak
- **Azure DNS A Records**: A records in the `<your-domain>` zone for SeaweedFS and Keycloak subdomains
- **Ingress Rules**: Routes traffic through existing BunkerWeb WAF with Let's Encrypt TLS (HTTP challenge)
- **Persistent Storage**: PVCs for SeaweedFS data, Keycloak data, and MariaDB data

## Endpoints

- **S3 API**: `https://<seaweedfs-domain>.<your-domain>`
- **Keycloak**: `https://<keycloak-domain>.<your-domain>`
- **Keycloak Admin**: `https://<keycloak-domain>.<your-domain>/admin`

## Authentication & Access Control

Access to S3 buckets is controlled via Keycloak realm roles. Users and service accounts authenticate with Keycloak and exchange their token for temporary AWS STS credentials.

| Keycloak Realm Role | IAM Role        | Bucket Access | Permissions  |
|---------------------|-----------------|---------------|--------------|
| `customer-1`        | `Airliner1Role` | `airliner-1`  | Full (`s3:*`) |
| `customer-2`        | `Airliner2Role` | `airliner-2`  | Full (`s3:*`) |

**Admin credentials** (static, bypass OIDC) are provided separately for bucket provisioning only.

## Platform Details

| Setting              | Value          |
|----------------------|----------------|
| Storage Class        | `default`      |
| Let's Encrypt Method | HTTP challenge |
| HTTP→HTTPS Redirect  | Enabled        |
| Ingress Class        | `bunkerweb`    |
| DNS Zone             | `<your-domain>` (delegated from Route53) |

## Shared Responsibilities

| Responsibility                                     | Platform Team | App Team |
|----------------------------------------------------|:---:|:---:|
| Deploy and maintain SeaweedFS, Keycloak, MariaDB  | ✅ | ❌ |
| Configure Ingress rules and TLS certificates       | ✅ | ❌ |
| Manage Keycloak realm and OIDC clients             | ✅ | ❌ |
| Manage Azure DNS records                           | ✅ | ❌ |
| Create and manage S3 buckets                       | ❌ | ✅ |
| Manage object lifecycle (upload/download/delete)   | ❌ | ✅ |
| Configure AWS CLI or S3 clients                    | ❌ | ✅ |
| Monitor storage usage                              | ❌ | ✅ |

## Security Features

- **WAF Protection**: BunkerWeb with ModSecurity OWASP Core Rule Set
- **TLS Encryption**: Automatic Let's Encrypt certificates via HTTP challenge
- **Temporary Credentials**: STS tokens expire after 1 hour
- **OIDC-based access**: All user/app access via Keycloak JWT tokens
- **IP Whitelisting**: Configurable CIDR allowlist per instance

## Contact

- **Platform Team**: [platform-team@example.com](mailto:platform-team@example.com)
- **Support Tickets**: [Support Portal Link]
