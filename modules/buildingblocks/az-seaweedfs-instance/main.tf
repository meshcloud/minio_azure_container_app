locals {
  config_path    = var.kubeconfig_path
  config_context = var.kubeconfig_context

  create_dns_records = var.worker_node_ip != ""

  seaweedfs_fqdn = "${var.seaweedfs_domain}.${var.dns_zone_name}"
  keycloak_fqdn  = "${var.keycloak_domain}.${var.dns_zone_name}"
}

resource "azurerm_dns_a_record" "seaweedfs" {
  count               = local.create_dns_records ? 1 : 0
  name                = var.seaweedfs_domain
  zone_name           = azurerm_dns_zone.this.name
  resource_group_name = var.dns_zone_resource_group
  ttl                 = 300
  records             = [var.worker_node_ip]
}

resource "azurerm_dns_a_record" "keycloak" {
  count               = local.create_dns_records ? 1 : 0
  name                = var.keycloak_domain
  zone_name           = azurerm_dns_zone.this.name
  resource_group_name = var.dns_zone_resource_group
  ttl                 = 300
  records             = [var.worker_node_ip]
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
