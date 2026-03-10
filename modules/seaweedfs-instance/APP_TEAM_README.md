# SeaweedFS S3 Storage Instance

## What is it?

A deployed SeaweedFS instance providing S3-compatible object storage with Keycloak OIDC authentication in your Kubernetes namespace, protected by the existing BunkerWeb WAF infrastructure.

## Resources Deployed

- **Kubernetes Namespace**: Isolated environment for your storage instance
- **SeaweedFS**: S3-compatible object storage server with persistent volume
- **Keycloak**: OIDC identity provider with pre-configured realm, clients, and test user
- **MariaDB**: Database backend for Keycloak
- **Ingress Rules**: Routes traffic through existing BunkerWeb WAF with Let's Encrypt TLS
- **Persistent Storage**: PVCs for SeaweedFS data, Keycloak data, and MariaDB data

## Endpoints

- **S3 API**: `https://storage.<subdomain>.<platform>`
- **Keycloak**: `https://keycloak.<subdomain>.<platform>`
- **Keycloak Admin**: `https://keycloak.<subdomain>.<platform>/admin`

## Authentication & Access Control

| Keycloak Group | S3 IAM Role       | Permissions                                    |
| -------------- | ----------------- | ---------------------------------------------- |
| `admins`       | `S3AdminRole`     | Full S3 access (`s3:*`)                        |
| `developers`   | `S3WriteRole`     | List, Get, Put, Delete objects and buckets     |
| _(default)_    | `S3ReadOnlyRole`  | List and Get objects (read-only)               |

**Access Flow**:
1. User authenticates with Keycloak to obtain JWT token
2. Token is exchanged for temporary S3 credentials via STS `AssumeRoleWithWebIdentity`
3. User accesses S3 API with AWS CLI or any S3-compatible client using temporary credentials

## Platform Support

| Platform | Storage Class          | Ingress Class | HTTP→HTTPS Redirect |
| -------- | ---------------------- | ------------- | ------------------- |
| Azure    | `default` (azurefile)  | `bunkerweb`   | Enabled             |
| IONOS    | `ionos-enterprise-hdd` | `bunkerweb`   | Disabled*           |

_*IONOS requires HTTP access initially for Let's Encrypt certificate validation._

## Shared Responsibilities

| Responsibility                                      | Platform Team | Application Team |
| --------------------------------------------------- | ------------- | ---------------- |
| Deploy and maintain SeaweedFS, Keycloak, MariaDB   | ✅           | ❌               |
| Configure Ingress rules and TLS certificates       | ✅           | ❌               |
| Manage Keycloak realm and OIDC clients             | ✅           | ❌               |
| Create and manage S3 buckets                       | ❌           | ✅               |
| Manage object lifecycle (upload/download/delete)   | ❌           | ✅               |
| Assign users to Keycloak groups (admins/developers) | ❌           | ✅               |
| Configure AWS CLI or S3 clients                    | ❌           | ✅               |
| Monitor storage usage and quota management         | ❌           | ✅               |

## Security Features

- **WAF Protection**: Traffic routed through BunkerWeb with ModSecurity OWASP Core Rule Set
- **TLS Encryption**: Automatic Let's Encrypt certificates via BunkerWeb
- **Temporary Credentials**: STS tokens expire after 1 hour, reducing credential exposure
- **OIDC-Only Access**: No static access keys; all authentication via Keycloak JWT tokens
- **Custom ModSecurity Rules**: Tailored exclusions for SeaweedFS and Keycloak compatibility

## Contact

- **Platform Team**: [platform-team@example.com](mailto:platform-team@example.com)
- **Documentation**: [Internal Wiki Link]
- **Support Tickets**: [Support Portal Link]
