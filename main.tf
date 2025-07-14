resource "azurerm_resource_group" "minio_rg" {
  name     = "minio-rg"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "minio_law" {
  name                = "acctest-01"
  location            = azurerm_resource_group.minio_rg.location
  resource_group_name = azurerm_resource_group.minio_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_container_app_environment" "minio_app_env" {
  name                       = "Minio-Environment"
  location                   = azurerm_resource_group.minio_rg.location
  resource_group_name        = azurerm_resource_group.minio_rg.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.minio_law.id
}

resource "azurerm_container_app" "minio_container_app" {
  name                         = "minio-app"
  container_app_environment_id = azurerm_container_app_environment.minio_app_env.id
  resource_group_name          = azurerm_resource_group.minio_rg.name
  revision_mode                = "Single"

  template {
    min_replicas = 1
    container {
      name   = "minio-container-app"
      image  = "docker.io/infrastructureascode/hello-world:2.4.0"
      cpu    = 0.25
      memory = "0.5Gi"
    }
    volume {
      name = "minio-volume"
      storage_name = azurerm_container_app_environment_storage.minio_app_storage.name
      storage_type = "AzureFile"
    }
  }

  ingress {
    allow_insecure_connections = true
    target_port = 8080
    transport = "auto"
    external_enabled = true

    traffic_weight {
      percentage = 100
      latest_revision = true
    }

    ip_security_restriction {
      name = "IP Restrictions for UI"
      action = "Allow"
      ip_address_range = "79.207.219.193"
    }
  }

  
}