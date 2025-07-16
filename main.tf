data "azurerm_resource_group" "minio_rg" {
  name = var.resource_group_name
}

resource "azurerm_log_analytics_workspace" "minio_law" {
  name                = "minio-law"
  location            = var.location.value
  resource_group_name = azurerm_resource_group.minio_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_container_app_environment" "minio_app_env" {
  name                       = "minio-environment"
  location                   = var.location
  resource_group_name        = azurerm_resource_group.minio_rg.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.minio_law.id
  infrastructure_subnet_id   = azurerm_subnet.minio_subnet.id
}

resource "azurerm_container_app" "minio_container_app" {
  name                         = "minio-app"
  container_app_environment_id = azurerm_container_app_environment.minio_app_env.id
  resource_group_name          = azurerm_resource_group.minio_rg.name
  revision_mode                = "Single"

  template {
    min_replicas = 1
    max_replicas = 2
    container {
      name    = var.container_app_name
      image   = var.container_image
      command = ["minio", "server", "/data", "--console-address", ":9090"]
      cpu     = 2.0
      memory  = "4.0Gi"
      env {
        name  = "MINIO_ROOT_USER"
        value = var.minio_root_user
      }
      env {
        name  = "MINIO_ROOT_PASSWORD"
        value = var.minio_root_password
      }
    }
    volume {
      name         = "minio-volume"
      storage_name = azurerm_container_app_environment_storage.minio_app_storage.name
      storage_type = "AzureFile"
    }
  }

  # Console UI Port
  ingress {
    allow_insecure_connections = true
    target_port                = 9090
    transport                  = "auto"
    external_enabled           = true

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }

    ip_security_restriction {
      name             = "IP Restrictions for UI"
      action           = "Allow"
      ip_address_range = var.ingress_allow_ip_address_range
    }
  }

}