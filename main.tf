data "azurerm_resource_group" "minio_aci_rg" {
  name     = var.resource_group_name
}

data "azurerm_container_registry" "minioimage" {
  name = "minioacr"
  resource_group_name = var.resource_group_name
}

resource "azurerm_container_group" "minio_aci_container_group" {
  name                = "minio-aci-container-group"
  location            = data.azurerm_resource_group.minio_aci_rg.location
  resource_group_name = data.azurerm_resource_group.minio_aci_rg.name
  # ip_address_type     = "Private"
  ip_address_type     = "Public"
  os_type             = "Linux"
  # subnet_ids = [azurerm_subnet.minio_subnet.id]

  image_registry_credential {
    server   = data.azurerm_container_registry.minioimage.login_server
    username = data.azurerm_container_registry.minioimage.admin_username
    password = data.azurerm_container_registry.minioimage.admin_password
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
        MINIO_ROOT_USER = var.minio_root_user
        MINIO_ROOT_PASSWORD = var.minio_root_password
    }

    volume {
      name = "minio-volume"
      mount_path = "/data"
      storage_account_name = azurerm_storage_account.minio_storage_account.name
      storage_account_key = azurerm_storage_account.minio_storage_account.primary_access_key
      share_name = azurerm_storage_share.minio_storage_share.name
    }

    commands = [ "minio", "server", "/data", "--console-address", ":9001" ]
  }
}