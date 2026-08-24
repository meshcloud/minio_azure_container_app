#!/usr/bin/env bash
#
# Wire the outputs of the cloud infrastructure stacks (azure-k8s-terrafrom /
# ionos-k8s-terrafrom) into a temporary JSON tfvars file and run OpenTofu here
# in meshstack-terraform — so you don't have to copy cluster host / CA / deployer
# token by hand.
#
# Outputs are read once per stack with `output -json` (which returns "{}" cleanly
# when a stack has no outputs) and mapped to variables with jq. Values are passed
# as JSON via -var-file, so multi-line values (PEM/CA) and special
# characters are handled safely. The temp file lives outside the repo and is
# deleted when the script exits.
#
# Usage:
#   ./sync-from-clouds.sh              # -> tofu plan   (default)
#   ./sync-from-clouds.sh apply        # -> tofu apply
#   ./sync-from-clouds.sh apply -auto-approve
#
# Overridable via env:  TF=terraform  AZ_DIR=../foo  IONOS_DIR=../bar
#
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

TF="${TF:-tofu}"
AZ_DIR="${AZ_DIR:-../azure-k8s-terrafrom}"
IONOS_DIR="${IONOS_DIR:-../ionos-k8s-terrafrom}"

# All outputs of a stack as one JSON object; "{}" if none / not applied.
read_json() { "$TF" -chdir="$1" output -json 2>/dev/null || echo '{}'; }

# Temp tfvars.json outside the repo; removed on exit (keeps secrets off disk).
tmpd="$(mktemp -d)"
vars_json="$tmpd/from-clouds.auto.tfvars.json"
trap 'rm -rf "$tmpd"' EXIT

az_json="$(read_json "$AZ_DIR")"
io_json="$(read_json "$IONOS_DIR")"

[ "$az_json" != "{}" ] && echo "→ using Azure outputs from $AZ_DIR" || echo "‼ no Azure outputs in $AZ_DIR — var.azure will be missing (it is required)" >&2
[ "$io_json" != "{}" ] && echo "→ using IONOS outputs from $IONOS_DIR" || echo "… no IONOS outputs in $IONOS_DIR — ionos vars left at defaults / empty" >&2

# Map stack outputs -> meshstack-terraform variables. jq escapes newlines and
# special characters; `// ""` tolerates missing individual outputs. Azure/IONOS
# blocks are only emitted when that stack actually has outputs.
jq -n --argjson az "$az_json" --argjson io "$io_json" '
  (if ($az | length) > 0 then {
    azure: {
      worker_node_ip:          ($az.lb_public_ip.value             // ""),
      dns_zone_name:           ($az.dns_zone_name.value            // ""),
      dns_zone_resource_group: ($az.dns_zone_resource_group.value  // ""),
      cluster_host:            ($az.cluster_host.value             // ""),
      cluster_ca:              ($az.cluster_ca_certificate.value   // ""),
      tenant_id:               ($az.dns_tenant_id.value            // ""),
      subscription_id:         ($az.dns_subscription_id.value      // ""),
      client_id:               ($az.dns_client_id.value            // "")
    },
    az_deployer_token:      ($az.deployer_token.value          // ""),
    az_uami_id:             ($az.dns_uami_id.value             // ""),
    az_uami_resource_group: ($az.dns_uami_resource_group.value // "")
  } else {} end)
  +
  (if ($io | length) > 0 then {
    ionos: {
      worker_node_ip: ($io.worker_node_ips.value[0]      // ""),
      cluster_host:   ($io.cluster_host.value            // ""),
      cluster_ca:     ($io.cluster_ca_certificate.value  // "")
    },
    ionos_deployer_token: ($io.deployer_token.value // "")
  } else {} end)
  ' > "$vars_json"

cmd="${1:-plan}"
shift || true
echo "→ running: $TF $cmd -var-file=<generated> $*"
"$TF" "$cmd" -var-file="$vars_json" "$@"
