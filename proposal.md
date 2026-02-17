# Migration Proposal: SeaweedFS + BunkerWeb on Kubernetes

## Status

**Draft** — for review and discussion.

## Motivation

The current stack runs on Azure Container Instances (ACI) with Azure-specific infrastructure (App Gateway, Key Vault, Azure File Shares, NSGs). We want to:

1. **Move to Kubernetes** — portable across AKS, IONOS, StackIT, and other providers
2. **Replace MinIO with SeaweedFS** — Apache-2.0 licensed, avoids MinIO's AGPL concerns
3. **Replace the custom Coraza-Caddy WAF with BunkerWeb** — maintained project (10k+ stars, active releases) instead of a self-built container depending on the small coraza-caddy community module

## Current Architecture (as-is)

```
Internet → Azure App Gateway (TLS, IP filtering, ports 443/8443/8444)
               ↓
         ACI Container Group (shared localhost)
         ├── Coraza WAF (Caddy + Coraza, custom-built image)
         │   ├── :8080 → MinIO UI (:9001)     [WAF + rate limiting]
         │   ├── :8081 → MinIO API (:9000)     [WAF + rate limiting]
         │   └── :8082 → Keycloak (:8083)      [reverse proxy, no WAF]
         ├── MinIO (S3 storage, OIDC via Keycloak)
         ├── Keycloak (identity provider)
         ├── MariaDB (Keycloak backend DB)
         └── Azure File Shares (persistence for all three)
```

### Current components

| Component | Role | Image |
|-----------|------|-------|
| MinIO | S3 object storage + web console | `quay.io/minio/minio:RELEASE.2025-04-22T22-12-26Z` |
| Keycloak | OIDC identity provider | `quay.io/keycloak/keycloak:latest` |
| MariaDB | Keycloak database | `mariadb:11` |
| Coraza WAF | WAF + reverse proxy (custom build) | `ghcr.io/meshcloud/minio_azure_container_app/coraza-caddy:*` |
| Azure App Gateway | TLS termination, IP filtering, routing | Azure PaaS |
| Azure File Shares | Persistent volumes | Azure PaaS |
| Azure Key Vault | Certificate storage | Azure PaaS |
| NSGs | IP allowlisting | Azure PaaS |

## Proposed Architecture (to-be)

```
Internet → BunkerWeb Ingress Controller (TLS + WAF + antibot + rate limiting + IP filtering)
               ↓ (Kubernetes Services)
         ┌─────────────────────────────────────────────┐
         │  SeaweedFS          Keycloak      MariaDB   │
         │  (S3 API)           (OIDC)        (DB)      │
         │  PVC: data          PVC: data     PVC: data │
         └─────────────────────────────────────────────┘
```

### Component mapping

| Current | Proposed | Notes |
|---------|----------|-------|
| MinIO | **SeaweedFS** (`weed server -s3`) | Apache-2.0. Single S3 port instead of separate UI + API ports. No web console. Native OIDC support via `-iam.config`. |
| Coraza WAF (custom Caddy build) | **BunkerWeb** (NGINX + ModSecurity) | Official images, Helm chart, native K8s Ingress Controller. AGPL-3.0. |
| Azure App Gateway | **BunkerWeb as Ingress Controller** | TLS termination, IP filtering, WAF — all in one. Replaces both App Gateway and Coraza. |
| Azure File Shares | **PersistentVolumeClaims** | Provider-specific StorageClass (AKS managed disks, IONOS block storage, etc.) |
| Azure Key Vault + self-signed cert | **cert-manager + Let's Encrypt** (or BunkerWeb built-in LE) | BunkerWeb has native Let's Encrypt support. |
| NSG IP allowlisting | **BunkerWeb IP whitelist settings** | `WHITELIST_COUNTRY`, `BLACKLIST_IP`, or custom IP lists |
| Keycloak | **Keycloak** (unchanged) | Same image and config |
| MariaDB | **MariaDB** (unchanged) | Same image and config |

## BunkerWeb: Why and How

### Why BunkerWeb over the custom Coraza-Caddy container

| | Custom Coraza-Caddy | BunkerWeb |
|---|---|---|
| **Maintenance** | We build and maintain the image ourselves. Depends on `coraza-caddy` community module. | Official maintained images with regular releases (v1.6.8, Feb 2026). |
| **WAF engine** | Coraza (ModSecurity-compatible) | ModSecurity + OWASP CRS built-in (also has Coraza as optional plugin) |
| **Rate limiting** | Hand-rolled SecRule in Caddyfile | Built-in `USE_LIMIT_REQ`, `LIMIT_REQ_RATE` settings |
| **Antibot** | None | Captcha, hCaptcha, reCAPTCHA, JS challenges |
| **IP blacklists** | None | Built-in DNSBL + external blacklists |
| **Let's Encrypt** | External | Built-in `AUTO_LETS_ENCRYPT=yes` |
| **Kubernetes** | Manual Deployment + Service | **Native Ingress Controller** with Helm chart and autoconf |
| **Web UI** | None | Full management UI for WAF config and monitoring |
| **Config model** | Caddyfile (manual editing) | Environment variables / K8s annotations |
| **License** | Apache-2.0 | **AGPL-3.0** (fine for internal infra, not for redistribution) |

### BunkerWeb Kubernetes integration

BunkerWeb runs as a Kubernetes Ingress Controller. It watches Ingress resources and ConfigMaps and automatically configures NGINX + WAF rules. Official Helm chart: [bunkerity/bunkerweb-helm](https://github.com/bunkerity/bunkerweb-helm).

Architecture in Kubernetes:

```
Internet
   ↓
BunkerWeb Pod(s)  ←── reads Ingress resources + ConfigMaps
   │                    (TLS termination, WAF, rate limiting, antibot, IP filtering)
   ├──→ seaweedfs-s3 Service (:8333)
   ├──→ keycloak Service (:8080)
   └──→ (future services)
```

BunkerWeb replaces **three** current components:
1. Azure Application Gateway (TLS, routing)
2. Coraza WAF container (WAF rules, rate limiting)
3. The Caddyfile reverse proxy config (upstream routing)

### BunkerWeb configuration (example)

Per-service settings via environment variables or Kubernetes annotations:

```yaml
# SeaweedFS S3 API
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: seaweedfs-s3
  annotations:
    bunkerweb.io/USE_MODSECURITY: "yes"
    bunkerweb.io/USE_LIMIT_REQ: "yes"
    bunkerweb.io/LIMIT_REQ_RATE: "50r/m"
    bunkerweb.io/WHITELIST_IP: "203.0.113.0/32 198.51.100.0/24"
    bunkerweb.io/AUTO_LETS_ENCRYPT: "yes"
spec:
  ingressClassName: bunkerweb
  rules:
    - host: s3.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: seaweedfs-s3
                port:
                  number: 8333
---
# Keycloak
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: keycloak
  annotations:
    bunkerweb.io/USE_MODSECURITY: "yes"
    bunkerweb.io/USE_ANTIBOT: "cookie"
    bunkerweb.io/AUTO_LETS_ENCRYPT: "yes"
spec:
  ingressClassName: bunkerweb
  rules:
    - host: auth.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: keycloak
                port:
                  number: 8080
```

## SeaweedFS: Architecture Decisions

### Topology: `weed server -s3` (all-in-one)

For a single-node or small deployment, SeaweedFS supports an all-in-one mode that bundles master, volume server, filer, and S3 gateway in one process. This matches the simplicity of the current single-MinIO-container setup.

For HA later, the components can be split into separate Deployments.

### S3 API port

SeaweedFS S3 gateway listens on port **8333** by default (configurable). This replaces both MinIO ports:
- MinIO `:9000` (S3 API) → SeaweedFS `:8333`
- MinIO `:9001` (Web Console) → **removed** (SeaweedFS has no web console)

### No web console

MinIO had a built-in web UI for bucket management. SeaweedFS does not. Options:
- **Accept CLI-only access** via `aws s3` CLI or `weed shell` — simplest
- **Deploy a third-party S3 browser** (e.g., [S3 Browser](https://s3browser.com/), [Filestash](https://github.com/mickael-kerjean/filestash)) — if a UI is needed
- **Use BunkerWeb's web UI** for WAF management (separate concern)

> **Decision needed:** Is a bucket browser UI required?

### OIDC / Keycloak Integration

SeaweedFS S3 gateway has [native OIDC support](https://github.com/seaweedfs/seaweedfs/wiki/OIDC-Integration) via the `-s3.iam.config` / `-iam.config` option. This is a direct replacement for MinIO's OIDC integration.

How it works:
1. **Bearer token auth** — S3 clients send `Authorization: Bearer $OIDC_TOKEN` directly to the SeaweedFS S3 gateway. No proxy-level auth needed.
2. **Role mapping** — Keycloak groups/claims are mapped to IAM-style roles with fine-grained S3 policies (e.g. `admins` → full access, `developers` → read/write, default → read-only).
3. **STS support** — SeaweedFS implements `AssumeRoleWithWebIdentity` for temporary credentials via OIDC tokens.
4. **IAM policies** — AWS-compatible policy documents control per-role S3 permissions (`s3:Get*`, `s3:Put*`, `s3:List*`, etc.).

Configuration is via an `iam.json` file that defines OIDC providers, policies, and roles:

```json
{
  "sts": {
    "tokenDuration": "1h",
    "maxSessionLength": "12h",
    "issuer": "seaweedfs-sts",
    "signingKey": "<base64-encoded-32-byte-key>"
  },
  "providers": [{
    "name": "keycloak",
    "type": "oidc",
    "enabled": true,
    "config": {
      "issuer": "https://KEYCLOAK/realms/seaweedfs",
      "clientId": "seaweedfs-s3",
      "jwksUri": "https://KEYCLOAK/realms/seaweedfs/protocol/openid-connect/certs",
      "userInfoUri": "https://KEYCLOAK/realms/seaweedfs/protocol/openid-connect/userinfo",
      "scopes": ["openid", "profile", "email", "roles", "groups"],
      "roleMapping": {
        "rules": [
          { "claim": "groups", "value": "admins", "role": "arn:aws:iam::role/S3AdminRole" },
          { "claim": "groups", "value": "developers", "role": "arn:aws:iam::role/S3WriteRole" }
        ],
        "defaultRole": "arn:aws:iam::role/S3ReadOnlyRole"
      }
    }
  }],
  "policies": [
    { "name": "S3ReadOnlyPolicy", "document": { "Version": "2012-10-17", "Statement": [{ "Effect": "Allow", "Action": ["s3:List*", "s3:Get*"], "Resource": ["*"] }] } },
    { "name": "S3WritePolicy", "document": { "Version": "2012-10-17", "Statement": [{ "Effect": "Allow", "Action": ["s3:List*", "s3:Get*", "s3:Put*", "s3:DeleteObject"], "Resource": ["*"] }] } },
    { "name": "S3AdminPolicy", "document": { "Version": "2012-10-17", "Statement": [{ "Effect": "Allow", "Action": ["s3:*"], "Resource": ["*"] }] } }
  ],
  "roles": [
    { "roleName": "S3ReadOnlyRole", "roleArn": "arn:aws:iam::role/S3ReadOnlyRole", "attachedPolicies": ["S3ReadOnlyPolicy"], "trustPolicy": { "Version": "2012-10-17", "Statement": [{ "Effect": "Allow", "Principal": { "Federated": "*" }, "Action": ["sts:AssumeRoleWithWebIdentity"], "Condition": { "StringEquals": { "seaweed:Issuer": "https://KEYCLOAK/realms/seaweedfs" } } }] } },
    { "roleName": "S3WriteRole", "roleArn": "arn:aws:iam::role/S3WriteRole", "attachedPolicies": ["S3WritePolicy"], "trustPolicy": { "Version": "2012-10-17", "Statement": [{ "Effect": "Allow", "Principal": { "Federated": "*" }, "Action": ["sts:AssumeRoleWithWebIdentity"], "Condition": { "StringEquals": { "seaweed:Issuer": "https://KEYCLOAK/realms/seaweedfs" } } }] } },
    { "roleName": "S3AdminRole", "roleArn": "arn:aws:iam::role/S3AdminRole", "attachedPolicies": ["S3AdminPolicy"], "trustPolicy": { "Version": "2012-10-17", "Statement": [{ "Effect": "Allow", "Principal": { "Federated": "*" }, "Action": ["sts:AssumeRoleWithWebIdentity"], "Condition": { "StringEquals": { "seaweed:Issuer": "https://KEYCLOAK/realms/seaweedfs" } } }] } }
  ]
}
```

The gateway is started with:
```
weed s3 -filer=filer:8888 -port=8333 -iam.config=/etc/seaweed/iam.json
```

### Keycloak realm config changes

The current `minio-realm-config.json.tpl` defines:
- `minio-client` — OIDC client for MinIO SSO (redirect to MinIO console)
- `opkssh-client` — OIDC client for OpenPubkey SSH

With SeaweedFS:
- **Replace `minio-client` with `seaweedfs-s3`** — new OIDC client for SeaweedFS S3 gateway (public or confidential, no redirect URI needed since it uses Bearer tokens, not browser login flows)
- **Add a "Group Membership" mapper** to the `seaweedfs-s3` client that emits a top-level `groups` claim in access tokens (required for SeaweedFS role mapping)
- **Keep `opkssh-client`** (unchanged)

## Infrastructure Approach

**Pure Terraform** using the Kubernetes provider (`kubernetes_deployment`, `kubernetes_service`, `kubernetes_persistent_volume_claim`, `kubernetes_secret`, `kubernetes_ingress_v1`, etc.) for all resources we own. The only exception is BunkerWeb, which uses `helm_release` because its official Helm chart handles complex controller + autoconf + scheduler setup that would be tedious to replicate with raw `kubernetes_*` resources.

Environment differences (AKS vs. IONOS vs. StackIT vs. local) are handled entirely via `.tfvars` — no per-environment YAML files.

### Why Terraform over Helm for our own resources

| | Helm chart | Terraform `kubernetes_*` |
|---|---|---|
| **State** | No real state (or Helm release secrets) | Terraform state — drift detection, `plan` before `apply` |
| **Typing** | Go templates, no type checking | HCL variables with types, validation blocks |
| **Multi-provider** | K8s only | Can manage DNS, cloud storage, IAM in the same root module |
| **Env differences** | `values-*.yaml` files | `.tfvars` files — same mechanism used for everything |
| **Existing codebase** | New tooling | Repo already uses Terraform |

## Repo Structure (proposed)

```
.
├── main.tf                         # REWRITE — kubernetes_* resources for SeaweedFS, Keycloak, MariaDB, Ingress
├── variables.tf                    # REWRITE — K8s cluster config, domain names, storage classes, secrets
├── outputs.tf                      # REWRITE — service endpoints, ingress IPs
├── providers.tf                    # REWRITE — kubernetes + helm providers
├── versions.tf                     # REWRITE — required_providers (kubernetes, helm)
├── bunkerweb.tf                    # NEW — helm_release for BunkerWeb Ingress Controller
├── seaweedfs.tf                    # NEW — kubernetes_deployment, service, pvc, iam-config secret
├── keycloak.tf                     # NEW — kubernetes_deployment, service, pvc, realm configmap
├── mariadb.tf                      # NEW — kubernetes_deployment (or stateful_set), service, pvc
├── ingress.tf                      # NEW — kubernetes_ingress_v1 resources (BunkerWeb annotations)
│
├── terraform.tfvars.example        # REWRITE — example values for all environments
├── envs/
│   ├── local.tfvars                # docker-desktop / kind
│   ├── aks.tfvars                  # Azure Kubernetes Service
│   ├── ionos.tfvars                # IONOS Kubernetes
│   └── stackit.tfvars              # StackIT Kubernetes
│
├── docker-compose/
│   ├── docker-compose.yml          # keep for opkssh external testing
│   ├── setup-local.sh
│   └── ...
│
├── Dockerfile                      # REMOVE (no more custom WAF build)
├── Caddyfile                       # REMOVE
├── Caddyfile.azure                 # REMOVE
│
├── minio-realm-config.json.tpl     # ADAPT (replace minio-client with seaweedfs-s3, add groups mapper, keep opkssh-client)
├── README.md                       # REWRITE
└── proposal.md                     # this file
```

## Migration Phases

### Phase 1: Local Kubernetes (kind)

Spin up a local kind cluster and run `terraform apply -var-file=envs/local.tfvars` to deploy the full stack. Validate:
- SeaweedFS S3 API works (create bucket, upload/download objects)
- SeaweedFS OIDC integration works (obtain Keycloak token, access S3 with Bearer auth)
- SeaweedFS role mapping works (groups claim → correct IAM role/policy)
- BunkerWeb protects SeaweedFS and Keycloak (WAF rules, rate limiting)
- Keycloak still works for opkssh
- opkssh flow still works end-to-end

### Phase 2: Cloud deployment

Create `envs/*.tfvars` for each target cloud:
- **AKS** (`aks.tfvars`): Azure managed disks StorageClass, Azure DNS zone for cert-manager
- **IONOS** (`ionos.tfvars`): IONOS block storage StorageClass, IONOS DNS
- **StackIT** (`stackit.tfvars`): StackIT storage StorageClass, StackIT DNS

Run `terraform apply -var-file=envs/aks.tfvars` (etc.) per environment.

### Phase 3: Cleanup

- Remove custom WAF build (`Dockerfile`, `Caddyfile`, `Caddyfile.azure`)
- Remove GitHub Actions workflow for container build (`build-container.yml`)
- Remove old Azure-specific Terraform code (replaced in Phase 2)
- Rename repo (if desired)

## Open Decisions

| # | Question | Options | Recommendation |
|---|----------|---------|----------------|
| 1 | Is a bucket browser UI needed? | CLI only / Filestash / other | CLI only for now |
| 2 | SeaweedFS topology? | All-in-one (`weed server -s3`) / split components | All-in-one, split later for HA |
| 3 | Repo rename? | e.g. `s3-waf-kubernetes`, `seaweedfs-bunkerweb-k8s` | TBD |
| 4 | AGPL-3.0 acceptable for BunkerWeb? | Yes (internal) / No (need alternative) | Yes, for internal infrastructure |
| 5 | Keep opkssh in scope? | Yes / separate repo | Keep — it's tightly coupled to Keycloak |
| 6 | OIDC role mapping granularity? | Per-group roles / per-user roles / default-only | Per-group (admins, developers, default read-only) |

## License Implications

| Component | License | Implication |
|-----------|---------|-------------|
| SeaweedFS | Apache-2.0 | No restrictions |
| BunkerWeb | AGPL-3.0 | Must share source if you modify and offer as a network service. Fine for internal use. If distributing to customers, need legal review. |
| Keycloak | Apache-2.0 | No restrictions |
| MariaDB | GPL-2.0 | Standard — using the official image, not modifying source |
