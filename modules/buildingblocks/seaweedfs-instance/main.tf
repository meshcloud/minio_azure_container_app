
locals {
  # Platform-specific Kubernetes configs
  config_path    = var.k8s_platform == "azure" ? var.azure_config_path : var.ionos_config_path
  config_context = var.k8s_platform == "azure" ? var.azure_config_context : var.ionos_config_context

  # DNS record configuration
  keycloak_subdomain  = split(".", var.keycloak_domain)[0]
  seaweedfs_subdomain = split(".", var.seaweedfs_domain)[0]
  create_dns_records  = var.ionos_dns_zone_id != "" && length(var.worker_node_ips) > 0
}

# DNS A records for Keycloak - one per worker node IP
resource "ionoscloud_dns_record" "keycloak" {
  count   = local.create_dns_records ? length(var.worker_node_ips) : 0
  zone_id = var.ionos_dns_zone_id
  name    = local.keycloak_subdomain
  type    = "A"
  content = var.worker_node_ips[count.index]
  ttl     = 300
  enabled = true
}

# DNS A records for SeaweedFS - one per worker node IP
resource "ionoscloud_dns_record" "seaweedfs" {
  count   = local.create_dns_records ? length(var.worker_node_ips) : 0
  zone_id = var.ionos_dns_zone_id
  name    = local.seaweedfs_subdomain
  type    = "A"
  content = var.worker_node_ips[count.index]
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
