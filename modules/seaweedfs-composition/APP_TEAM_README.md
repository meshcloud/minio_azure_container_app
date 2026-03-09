# Multi-Cloud S3 Storage Service

## What is it?

The **S3 Storage Service** provides application teams with a secure, self-hosted, S3-compatible object storage platform with enterprise-grade authentication and WAF protection. It automates the deployment of SeaweedFS storage, Keycloak OIDC authentication, and BunkerWeb WAF on Kubernetes (Azure AKS or IONOS).

## When to use it?

This building block is ideal for teams that:

- Need S3-compatible object storage without vendor lock-in to AWS or cloud-specific services.
- Require OIDC-based authentication with group-based access control for storage buckets.
- Want portable storage infrastructure that works across multiple cloud providers (Azure, IONOS, etc.).
- Need enterprise security (WAF, rate limiting, IP whitelisting) for their storage endpoints.

## Usage Examples

1. **Application artifact storage**: Teams can store container images, build artifacts, or backups in S3 buckets with role-based access control (admins have full access, developers can read/write, others read-only).
2. **Data lake for analytics**: Store datasets in S3 buckets accessible via standard AWS CLI tools, with authentication enforced via Keycloak groups.
3. **Multi-tenant storage**: Deploy separate instances per team/project with isolated namespaces and DNS subdomains (e.g., `storage.team-a.azure`, `storage.team-b.ionos`).

## Resources Created

This building block automates the creation of the following resources:

- **DNS Records**: Subdomain entries for SeaweedFS S3 API (`storage.<sub>.<platform>`) and Keycloak (`keycloak.<sub>.<platform>`).
- **Kubernetes Namespace**: Isolated environment for the storage instance.
  - **SeaweedFS Deployment**: S3-compatible object storage server with persistent volume.
  - **Keycloak Deployment**: OIDC identity provider with pre-configured realm and clients.
  - **MariaDB Deployment**: Database backend for Keycloak.
  - **BunkerWeb Ingress**: WAF-protected ingress with Let's Encrypt TLS, ModSecurity rules, rate limiting, and IP whitelisting.
  - **Persistent Storage**: PVCs for SeaweedFS data, Keycloak data, and MariaDB data (platform-specific storage classes).

## Authentication & Access Control

| Keycloak Group | S3 IAM Role       | Permissions                                    |
| -------------- | ----------------- | ---------------------------------------------- |
| `admins`       | `S3AdminRole`     | Full S3 access (`s3:*`)                        |
| `developers`   | `S3WriteRole`     | List, Get, Put, Delete objects and buckets     |
| _(default)_    | `S3ReadOnlyRole`  | List and Get objects (read-only)               |

**Access Flow**:
1. User authenticates with Keycloak to obtain JWT token.
2. Token is exchanged for temporary S3 credentials via STS `AssumeRoleWithWebIdentity`.
3. User accesses S3 API with AWS CLI or any S3-compatible client using temporary credentials.

## Platform Support

| Platform | Storage Class          | Ingress Class | HTTP→HTTPS Redirect | Kubernetes Config          |
| -------- | ---------------------- | ------------- | ------------------- | -------------------------- |
| Azure    | `azurefile` (default)  | `bunkerweb`   | Enabled             | `~/.kube/config-azure`     |
| IONOS    | `ionos-enterprise-hdd` | `bunkerweb`   | Disabled*           | `~/.kube/config-ionos`     |

_*IONOS requires HTTP access initially for Let's Encrypt certificate validation._

## Shared Responsibilities

| Responsibility                                     | Platform Team | Application Team |
| -------------------------------------------------- | ------------- | ---------------- |
| Provision and manage Kubernetes cluster (AKS/IONOS) | ✅           | ❌               |
| Deploy and maintain SeaweedFS, Keycloak, MariaDB  | ✅           | ❌               |
| Configure BunkerWeb WAF, TLS, and ingress rules   | ✅           | ❌               |
| Manage DNS records for storage and auth endpoints | ✅           | ❌               |
| Manage Keycloak realm and OIDC clients            | ✅           | ❌               |
| Create and manage S3 buckets                      | ❌           | ✅               |
| Manage object lifecycle (upload/download/delete)  | ❌           | ✅               |
| Assign users to Keycloak groups (admins/developers) | ❌           | ✅               |
| Configure AWS CLI or S3 clients                   | ❌           | ✅               |
| Monitor storage usage and quota management        | ❌           | ✅               |

## Security Features

- **WAF Protection**: ModSecurity with OWASP Core Rule Set blocks common attacks (SQL injection, XSS, etc.).
- **Rate Limiting**: Configurable request rate limits per service (default: 30 req/s).
- **IP Whitelisting**: Restrict access to specific CIDR ranges.
- **TLS Encryption**: Automatic Let's Encrypt certificates via BunkerWeb.
- **Temporary Credentials**: STS tokens expire after 1 hour, reducing credential exposure.
- **OIDC-Only Access**: No static access keys; all authentication via Keycloak JWT tokens.

### Contact

- **Platform Team**: [platform-team@example.com](mailto:platform-team@example.com)
- **Documentation**: [Internal Wiki Link]
- **Support Tickets**: [Support Portal Link]
