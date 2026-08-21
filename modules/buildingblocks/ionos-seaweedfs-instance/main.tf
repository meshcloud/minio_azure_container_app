locals {
  # Platform-specific Kubernetes configs
  config_path    = var.ionos_config_path
  config_context = var.ionos_config_context

  # Prefer the scoped deployer token; fall back to kubeconfig when not provided.
  use_token = var.deployer_token != ""

  create_dns_records = var.ionos_dns_zone_id != "" && var.worker_node_ip != ""
}

# DNS A record for Keycloak
resource "ionoscloud_dns_record" "keycloak" {
  count   = local.create_dns_records ? 1 : 0
  zone_id = var.ionos_dns_zone_id
  name    = var.keycloak_domain
  type    = "A"
  content = var.worker_node_ip
  ttl     = 300
  enabled = true
}

# DNS A record for SeaweedFS
resource "ionoscloud_dns_record" "seaweedfs" {
  count   = local.create_dns_records ? 1 : 0
  zone_id = var.ionos_dns_zone_id
  name    = var.seaweedfs_domain
  type    = "A"
  content = var.worker_node_ip
  ttl     = 300
  enabled = true
}

resource "kubernetes_namespace" "this" {
  metadata {
    name = var.namespace
  }
}

resource "random_password" "mariadb_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "random_password" "keycloak_client_secret" {
  length  = 32
  special = false
  upper   = true
  lower   = true
  numeric = true
}

resource "random_password" "seaweedfs_sts_signing_key" {
  length  = 32
  special = false
}

resource "random_password" "keycloak_admin_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "random_password" "keycloak_test_user_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "random_password" "seaweedfs_admin_secret" {
  length  = 32
  special = false
}

resource "random_password" "client_app_1_secret" {
  length  = 32
  special = false
}

resource "random_password" "client_app_2_secret" {
  length  = 32
  special = false
}
