resource "azurerm_resource_group" "minio_aci_rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_container_group" "minio_aci_container_group" {
  name                = "minio-aci-container-group"
  location            = azurerm_resource_group.minio_aci_rg.location
  resource_group_name = azurerm_resource_group.minio_aci_rg.name
  ip_address_type     = "Public"
  os_type             = "Linux"
  dns_name_label      = var.public_url_domain_name
  restart_policy      = "OnFailure" # Prevent infinite restarts

  diagnostics {
    log_analytics {
      workspace_id  = azurerm_log_analytics_workspace.minio_law.workspace_id
      workspace_key = azurerm_log_analytics_workspace.minio_law.primary_shared_key
    }
  }

  # HTTP port (redirects to HTTPS)
  exposed_port {
    port     = 80
    protocol = "TCP"
  }

  # HTTPS port (MinIO Console UI)
  exposed_port {
    port     = 443
    protocol = "TCP"
  }

  # HTTPS API port (MinIO S3 API)
  exposed_port {
    port     = 8443
    protocol = "TCP"
  }

  container {
    name   = "minio"
    image  = var.minio_image
    cpu    = "0.5"
    memory = "1.5"

    # Resource limits to prevent runaway consumption
    cpu_limit    = 1.0
    memory_limit = 2.0

    ports {
      port     = 9001
      protocol = "TCP"
    }
    ports {
      port     = 9000
      protocol = "TCP"
    }

    environment_variables = {
      MINIO_ROOT_USER     = var.minio_root_user
      MINIO_ROOT_PASSWORD = var.minio_root_password
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

    liveness_probe {
      http_get {
        path   = "/minio/health/live"
        port   = 9000
        scheme = "http"
      }
      initial_delay_seconds = 30
      period_seconds        = 10
      timeout_seconds       = 5
      failure_threshold     = 3
    }
  }

  container {
    name   = "nginx"
    image  = var.nginx_image
    cpu    = "0.5"
    memory = "1.0"

    # Resource limits to prevent runaway consumption
    cpu_limit    = 1.0
    memory_limit = 2.0

    ports {
      port     = 80
      protocol = "TCP"
    }

    ports {
      port     = 443
      protocol = "TCP"
    }

    ports {
      port     = 8443
      protocol = "TCP"
    }

    commands = ["sh", "-c", "sed -i 's|include /etc/nginx/nginx.conf.default;|include /etc/nginx/conf.d/*.conf;|' /etc/nginx/nginx.conf && nginx -g 'daemon off;'"]

    volume {
      name       = "nginx-config"
      mount_path = "/etc/nginx/conf.d"
      read_only  = true

      secret = {
        "default.conf" = base64encode(templatefile("${path.module}/nginx-frontend.conf.tpl", {
          server_name       = "${var.public_url_domain_name}.${azurerm_resource_group.minio_aci_rg.location}.azurecontainer.io"
          minio_ui_backend  = "localhost:8080"
          minio_api_backend = "localhost:8081"
        }))
      }
    }

    volume {
      name       = "ssl-certs"
      mount_path = "/etc/ssl/certs"
      read_only  = true

      secret = {
        "server.crt" = filebase64(var.ssl_cert_file)
        "server.key" = filebase64(var.ssl_key_file)
      }
    }
  }

  container {
    name         = "coraza-waf"
    image        = var.coraza_waf_image
    cpu          = "1.0"
    memory       = "1.0"
    cpu_limit    = 1.0
    memory_limit = 2.0

    ports {
      port     = 8080 # WAF endpoint for MinIO UI
      protocol = "TCP"
    }

    ports {
      port     = 8081 # WAF endpoint for MinIO API
      protocol = "TCP"
    }

    environment_variables = {
      MINIO_UI_BACKEND  = "localhost:9001"
      MINIO_API_BACKEND = "localhost:9000"
    }

    liveness_probe {
      http_get {
        path   = "/health"
        port   = 8080
        scheme = "http"
      }
      initial_delay_seconds = 30
      period_seconds        = 10
      timeout_seconds       = 5
      failure_threshold     = 3
    }

    readiness_probe {
      http_get {
        path   = "/health"
        port   = 8080
        scheme = "http"
      }
      initial_delay_seconds = 30
      period_seconds        = 5
      timeout_seconds       = 3
      failure_threshold     = 3
    }
  }

}

resource "azurerm_log_analytics_workspace" "minio_law" {
  name                = "minio-law"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_storage_account" "minio_storage_account" {
  name                              = var.storage_account_name
  resource_group_name               = azurerm_resource_group.minio_aci_rg.name
  location                          = var.location
  account_tier                      = "Standard"
  account_replication_type          = "LRS"
  account_kind                      = "StorageV2" # Required for infrastructure_encryption_enabled
  access_tier                       = "Hot"
  infrastructure_encryption_enabled = true
  shared_access_key_enabled         = true
  public_network_access_enabled     = true
  allowed_copy_scope                = "AAD"
  https_traffic_only_enabled        = true

  network_rules {
    default_action = "Allow"
  }
}

resource "azurerm_storage_share" "minio_storage_share" {
  name               = "miniostorageshare"
  storage_account_id = azurerm_storage_account.minio_storage_account.id
  quota              = var.storage_share_size # size in GBs
}
