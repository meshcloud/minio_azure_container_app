resource "azurerm_resource_group" "minio_aci_rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_container_group" "minio_aci_container_group" {
  name                = "minio-aci-container-group"
  location            = azurerm_resource_group.minio_aci_rg.location
  resource_group_name = azurerm_resource_group.minio_aci_rg.name
  ip_address_type     = "Private"
  os_type             = "Linux"
  subnet_ids          = [azurerm_subnet.minio_subnet.id]
  diagnostics {
    log_analytics {
      workspace_id  = azurerm_log_analytics_workspace.minio_law.workspace_id
      workspace_key = azurerm_log_analytics_workspace.minio_law.primary_shared_key
    }
  }

  exposed_port {
    port     = var.port_ui
    protocol = "TCP"
  }

  exposed_port {
    port     = var.port_api
    protocol = "TCP"
  }

  container {
    name   = "minio"
    image  = var.container_image
    cpu    = "0.5"
    memory = "1.5"

    ports {
      port     = var.port_ui
      protocol = "TCP"
    }
    ports {
      port     = var.port_api
      protocol = "TCP"
    }

    environment_variables = {
      MINIO_ROOT_USER            = var.minio_root_user
      MINIO_ROOT_PASSWORD        = var.minio_root_password
      MINIO_BROWSER_REDIRECT_URL = "https://${azurerm_public_ip.minio_pip.fqdn}:9001"
    }

    volume {
      name                 = "minio-volume"
      mount_path           = "/data"
      read_only            = false
      storage_account_name = azurerm_storage_account.minio_storage_account.name
      storage_account_key  = azurerm_storage_account.minio_storage_account.primary_access_key
      share_name           = azurerm_storage_share.minio_storage_share.name
    }

    security {
      privilege_enabled = true
    }

    commands = ["minio", "server", "/data", "--console-address", ":9001", "--address", ":9000"]
  }
}