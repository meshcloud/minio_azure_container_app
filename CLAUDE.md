# CLAUDE.md — project context for agent sessions

Multi-cloud, S3-compatible object storage (SeaweedFS + Keycloak OIDC + MariaDB +
BunkerWeb WAF) delivered as **meshStack self-service building blocks**, deployed
onto **Azure AKS** or **IONOS Kubernetes**. There is **no local/kind workflow** —
deployment runs through meshStack onto real clusters.

## Layout

| Path | Purpose |
|---|---|
| `meshstack-terraform/` | meshStack platform type/platform/landing zone + **building block definitions** (BBDs) + `sync-from-clouds.sh`. This is the control plane. |
| `azure-k8s-terrafrom/` | Azure infra: AKS, LB (public IP for BunkerWeb), DNS zone, deployer SA (`rbac.tf`), DNS UAMI (`dns-uami.tf`). |
| `ionos-k8s-terrafrom/` | IONOS infra: managed k8s, node pool, DNS, deployer SA (`rbac.tf`). |
| `modules/buildingblocks/seaweedfs-composition/` | Composition module: creates project+tenant, then the matching instance BB. |
| `modules/buildingblocks/az-seaweedfs-instance/` | App deployment on AKS (SeaweedFS/Keycloak/MariaDB, DNS A records, ingress). |
| `modules/buildingblocks/ionos-seaweedfs-instance/` | Same, on IONOS. |
| `docker-compose/` | opkssh test harness — **legacy/non-functional**, ignore. |

Note the dir name is `azure-k8s-terrafrom` (typo "terrafrom" is intentional/existing — don't "fix" it).

## Deployment flow

1. `cd azure-k8s-terrafrom && tofu apply` (and/or `ionos-k8s-terrafrom`) — cluster + scoped identities.
2. `cd meshstack-terraform && ./sync-from-clouds.sh apply` — reads the cloud stacks' outputs (`tofu output -json`), builds a temp JSON var-file, runs tofu. Registers/updates the BBDs. **Always use this script**, don't hand-copy outputs.
3. App team orders the "S3 Storage Service" BB in meshStack, picks `cloud_provider` (`azure`/`ionos`).

Uses **OpenTofu (`tofu`)**, not `terraform`. meshStack provider is **v0.25** (`>= 0.22`).

## Auth model (both secretless / least-privilege)

- **Kubernetes:** instance modules authenticate the `kubernetes` provider with a scoped **deployer ServiceAccount token** (host/CA/token), NOT kubeconfig, NOT cluster-admin. Bootstrapped in `*-k8s-terrafrom/rbac.tf` (namespace lifecycle + built-in `edit` clusterrole).
- **Azure DNS:** a **User-Assigned Managed Identity** federated to meshStack via Workload Identity Federation — **no client secret**. `azure-k8s-terrafrom` makes the UAMI + `DNS Zone Contributor` role on the zone; `meshstack-terraform` makes the `azurerm_federated_identity_credential` because its OIDC **subject is per BBD**: `system:serviceaccount:<mesh-ns>:workspace.<workspace>.buildingblockdefinition.<bbd-uuid>`. Issuer/audience from `data.meshstack_integrations` (an "Other issuer" federation, not AKS workload identity). Instance run uses `ARM_USE_OIDC=true` + `ARM_OIDC_TOKEN_FILE_PATH=/var/run/secrets/workload-identity/azure/token`.

## meshStack provider gotchas (learned the hard way — check these first)

- **BB inputs:** `inputs = { key = { value = jsonencode(x) } }`. `value` is **always** `jsonencode`'d, including strings (`jsonencode("dev")` → `"dev"`). Old `value_string`/`value_bool` don't exist.
- **BB outputs:** `status.outputs[k].value` is JSON-encoded → `jsondecode(...)` to use.
- **STATIC vs USER_INPUT:** the composition (`meshstack_building_block`) may only pass **USER_INPUT** inputs. Passing an input that is `STATIC` in the BBD → apply error `element "<x>" has vanished`. STATIC values live only in the BBD.
- **Secrets in a BBD input:** `sensitive = { argument = { secret_value = local.x, secret_version = nonsensitive(sha256(local.x)) } }`. `secret_value` is write-only → `secret_version` (hash) drives rotation; `= null` means it never updates. **Empty `secret_value` is rejected** → use a non-empty placeholder local when the real value isn't set yet.
- **`is_environment = true`** input → exported as an OS env var for the run (that's how `ARM_*` reach the azurerm provider).
- **`selectable_values`** = list of plain strings, not objects.
- **`default_value`** must be a string → `jsonencode(map)` / `yamlencode(map)`, never a raw map.
- **`readme`** on a BBD is loaded via `file("${path.module}/../modules/buildingblocks/<x>/APP_TEAM_README.md")`.
- **tenant refs:** `spec.platform_ref = { uuid = <platform uuid> }` (resolve identifier→uuid via `data.meshstack_platforms`), `spec.landing_zone_ref = { name = <lz name> }`.
- **`environment` project tag** is policy-governed (SUBSET): a project's `environment` must be ⊆ its workspace's allowed environments, or creation 403s. Not fixable in TF — fix the workspace tags in meshStack.
- Tag values are `map(list(string))` → `confidentiality = ["Internal"]`, not `"Internal"`.

## Validate

```bash
for d in meshstack-terraform azure-k8s-terrafrom ionos-k8s-terrafrom \
         modules/buildingblocks/*; do (cd "$d" && tofu validate); done
```
Pre-commit: `pre-commit run --all-files` (fmt/docs/tflint via root `.tflint.hcl` referenced with `__GIT_WORKING_DIR__`/tfupdate). CI runs the same.
