
locals {
  # Platform-specific Kubernetes configs
  config_path    = var.k8s_platform == "azure" ? var.azure_config_path : var.ionos_config_path
  config_context = var.k8s_platform == "azure" ? var.azure_config_context : var.ionos_config_context
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
