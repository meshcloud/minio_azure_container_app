resource "random_string" "storage_suffix" {
  length  = 4
  special = false
  upper   = false
}

resource "azurerm_virtual_network" "minio_vnet" {
  name                = "minio-vnet"
  address_space       = ["10.10.0.0/16"]
  location            = azurerm_resource_group.minio_rg.location
  resource_group_name = azurerm_resource_group.minio_rg.name
}

resource "azurerm_subnet" "agw_subnet" {
  name                 = "agw-subnet"
  resource_group_name  = azurerm_resource_group.minio_rg.name
  virtual_network_name = azurerm_virtual_network.minio_vnet.name
  address_prefixes     = ["10.10.1.0/24"]
}

resource "azurerm_subnet" "aci_subnet" {
  name                 = "aci-subnet"
  resource_group_name  = azurerm_resource_group.minio_rg.name
  virtual_network_name = azurerm_virtual_network.minio_vnet.name
  address_prefixes     = ["10.10.2.0/24"]
  service_endpoints    = ["Microsoft.Storage"]

  delegation {
    name = "aci-delegation"

    service_delegation {
      name = "Microsoft.ContainerInstance/containerGroups"
      actions = [
      "Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_resource_group" "minio_rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_log_analytics_workspace" "minio_law" {
  name                = "minio-law"
  location            = var.location
  resource_group_name = azurerm_resource_group.minio_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_storage_account" "minio_storage_account" {
  name                              = "${var.storage_account_name}${random_string.storage_suffix.result}"
  resource_group_name               = azurerm_resource_group.minio_rg.name
  location                          = var.location
  account_tier                      = "Standard"
  account_replication_type          = "LRS"
  account_kind                      = "StorageV2"
  infrastructure_encryption_enabled = true
  https_traffic_only_enabled        = true

  network_rules {
    default_action             = "Deny"
    virtual_network_subnet_ids = [azurerm_subnet.aci_subnet.id]
  }
}

resource "azurerm_storage_share" "minio_share" {
  name               = "miniostorageshare"
  storage_account_id = azurerm_storage_account.minio_storage_account.id
  quota              = var.storage_share_size
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "minio_kv" {
  name                       = "${azurerm_resource_group.minio_rg.name}-kv-${random_string.storage_suffix.result}"
  location                   = var.location
  resource_group_name        = azurerm_resource_group.minio_rg.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  purge_protection_enabled   = true
  soft_delete_retention_days = 7
}

resource "azurerm_key_vault_access_policy" "tf" {
  key_vault_id = azurerm_key_vault.minio_kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  certificate_permissions = ["Get", "List", "Create", "Import"]
  secret_permissions      = ["Get", "List"]
}

resource "azurerm_key_vault_certificate" "minio_cert" {
  name         = "minio-cert"
  key_vault_id = azurerm_key_vault.minio_kv.id

  certificate_policy {
    issuer_parameters {
      name = "Self"
    }
    key_properties {
      exportable = true
      key_size   = 2048
      key_type   = "RSA"
      reuse_key  = true
    }
    secret_properties {
      content_type = "application/x-pkcs12"
    }
    x509_certificate_properties {
      subject            = "CN=${azurerm_public_ip.agw_pip.fqdn}"
      validity_in_months = 12
      key_usage          = ["digitalSignature", "keyEncipherment", "keyAgreement", "dataEncipherment", "keyCertSign"]

    }
  }
}

resource "azurerm_user_assigned_identity" "agw_identity" {
  name                = "minio-agw-identity"
  resource_group_name = azurerm_resource_group.minio_rg.name
  location            = var.location
}

resource "azurerm_key_vault_access_policy" "agw_policy" {
  key_vault_id            = azurerm_key_vault.minio_kv.id
  tenant_id               = data.azurerm_client_config.current.tenant_id
  object_id               = azurerm_user_assigned_identity.agw_identity.principal_id
  secret_permissions      = ["Get"]
  certificate_permissions = ["Get"]
}

resource "azurerm_public_ip" "agw_pip" {
  name                = "minio-agw-pip"
  location            = var.location
  resource_group_name = azurerm_resource_group.minio_rg.name
  allocation_method   = "Static"
  domain_name_label   = var.public_url_domain_name
  sku                 = "Standard"
}

resource "azurerm_network_security_group" "agw_nsg" {
  name                = "minio-agw-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.minio_rg.name
}

locals {
  allowed_ips_list = [
    for ip in split(",", var.allowed_ip_addresses) : trimspace(ip)
  ]
}

resource "azurerm_network_security_rule" "allow_https_ui" {
  count                       = length(local.allowed_ips_list)
  name                        = "AllowHTTPS-UI-${count.index}"
  priority                    = 100 + count.index
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = local.allowed_ips_list[count.index]
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.minio_rg.name
  network_security_group_name = azurerm_network_security_group.agw_nsg.name
}

resource "azurerm_network_security_rule" "allow_https_api" {
  count                       = length(local.allowed_ips_list)
  name                        = "AllowHTTPS-API-${count.index}"
  priority                    = 200 + count.index
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "8443"
  source_address_prefix       = local.allowed_ips_list[count.index]
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.minio_rg.name
  network_security_group_name = azurerm_network_security_group.agw_nsg.name
}

resource "azurerm_network_security_rule" "allow_agw_management" {
  name                        = "AllowApplicationGatewayManagement"
  priority                    = 300
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "65200-65535"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.minio_rg.name
  network_security_group_name = azurerm_network_security_group.agw_nsg.name
}

resource "azurerm_network_security_rule" "allow_azureloadbalancer" {
  name                        = "AllowAzureLoadBalancer"
  priority                    = 400
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "AzureLoadBalancer"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.minio_rg.name
  network_security_group_name = azurerm_network_security_group.agw_nsg.name
}

resource "azurerm_network_security_rule" "deny_all" {
  name                        = "DenyAll"
  priority                    = 4000
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.minio_rg.name
  network_security_group_name = azurerm_network_security_group.agw_nsg.name
}

resource "azurerm_subnet_network_security_group_association" "agw_nsg_association" {
  subnet_id                 = azurerm_subnet.agw_subnet.id
  network_security_group_id = azurerm_network_security_group.agw_nsg.id
}

resource "azurerm_application_gateway" "minio_agw" {
  name                = "minio-agw"
  location            = var.location
  resource_group_name = azurerm_resource_group.minio_rg.name

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 1
  }

  gateway_ip_configuration {
    name      = "gw-ipconfig"
    subnet_id = azurerm_subnet.agw_subnet.id
  }

  frontend_ip_configuration {
    name                 = "public-ip"
    public_ip_address_id = azurerm_public_ip.agw_pip.id
  }

  frontend_port {
    name = "https-ui"
    port = 443
  }

  frontend_port {
    name = "https-api"
    port = 8443
  }

  ssl_certificate {
    name                = "minio-cert"
    key_vault_secret_id = azurerm_key_vault_certificate.minio_cert.secret_id
  }

  backend_address_pool {
    name         = "coraza-backend-pool"
    ip_addresses = [azurerm_container_group.minio_aci_container_group.ip_address]
  }

  probe {
    name                                      = "ui-health-probe"
    protocol                                  = "Http"
    path                                      = "/health"
    host                                      = azurerm_container_group.minio_aci_container_group.ip_address
    interval                                  = 30
    timeout                                   = 20
    unhealthy_threshold                       = 3
    port                                      = 8080
    pick_host_name_from_backend_http_settings = false
  }

  probe {
    name                                      = "api-health-probe"
    protocol                                  = "Http"
    path                                      = "/health"
    host                                      = azurerm_container_group.minio_aci_container_group.ip_address
    interval                                  = 30
    timeout                                   = 20
    unhealthy_threshold                       = 3
    port                                      = 8081
    pick_host_name_from_backend_http_settings = false
  }

  backend_http_settings {
    name                                = "ui-http"
    port                                = 8080
    protocol                            = "Http"
    request_timeout                     = 300
    pick_host_name_from_backend_address = false
    cookie_based_affinity               = "Disabled"
    probe_name                          = "ui-health-probe"

    connection_draining {
      enabled           = true
      drain_timeout_sec = 300
    }

  }

  backend_http_settings {
    name                                = "api-http"
    port                                = 8081
    protocol                            = "Http"
    request_timeout                     = 300
    pick_host_name_from_backend_address = false
    cookie_based_affinity               = "Disabled"
    probe_name                          = "api-health-probe"
    connection_draining {
      enabled           = true
      drain_timeout_sec = 300
    }

  }

  http_listener {
    name                           = "listener-ui"
    frontend_ip_configuration_name = "public-ip"
    frontend_port_name             = "https-ui"
    protocol                       = "Https"
    ssl_certificate_name           = "minio-cert"
  }

  http_listener {
    name                           = "listener-api"
    frontend_ip_configuration_name = "public-ip"
    frontend_port_name             = "https-api"
    protocol                       = "Https"
    ssl_certificate_name           = "minio-cert"
  }

  request_routing_rule {
    name                       = "rule-ui"
    rule_type                  = "Basic"
    http_listener_name         = "listener-ui"
    backend_address_pool_name  = "coraza-backend-pool"
    backend_http_settings_name = "ui-http"
    priority                   = 10
  }

  request_routing_rule {
    name                       = "rule-api"
    rule_type                  = "Basic"
    http_listener_name         = "listener-api"
    backend_address_pool_name  = "coraza-backend-pool"
    backend_http_settings_name = "api-http"
    priority                   = 20
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.agw_identity.id]
  }

  depends_on = [
    azurerm_subnet_network_security_group_association.agw_nsg_association
  ]
}

resource "azurerm_container_group" "minio_aci_container_group" {
  name                = "minio-aci-container-group"
  location            = azurerm_resource_group.minio_rg.location
  resource_group_name = azurerm_resource_group.minio_rg.name
  ip_address_type     = "Private"
  os_type             = "Linux"

  restart_policy = "OnFailure"
  subnet_ids     = [azurerm_subnet.aci_subnet.id]

  diagnostics {
    log_analytics {
      workspace_id  = azurerm_log_analytics_workspace.minio_law.workspace_id
      workspace_key = azurerm_log_analytics_workspace.minio_law.primary_shared_key
    }
  }

  container {
    name         = "minio"
    image        = var.minio_image
    cpu          = "0.5"
    memory       = "1.5"
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
      MINIO_ROOT_USER            = var.minio_root_user
      MINIO_ROOT_PASSWORD        = var.minio_root_password
      MINIO_BROWSER_REDIRECT_URL = "https://${azurerm_public_ip.agw_pip.fqdn}"
    }

    volume {
      name                 = "minio-volume"
      mount_path           = "/data"
      read_only            = false
      storage_account_name = azurerm_storage_account.minio_storage_account.name
      storage_account_key  = azurerm_storage_account.minio_storage_account.primary_access_key
      share_name           = azurerm_storage_share.minio_share.name
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
    name         = "coraza-waf"
    image        = var.coraza_waf_image
    cpu          = "1.0"
    memory       = "1.0"
    cpu_limit    = 1.0
    memory_limit = 2.0
    ports {
      port     = 8080
      protocol = "TCP"
    }
    ports {
      port     = 8081
      protocol = "TCP"
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
    # The Caddyfile is included as part of the container build.
    # If you are testing or want to use a different configuration, you can provide your own
    # volume {
    #   name       = "caddyfile"
    #   mount_path = "/etc/caddy"
    #   read_only  = true

    #   secret = {
    #     "Caddyfile" = base64encode(templatefile("${path.module}/Caddyfile.working.tpl", {
    #     }))
    #   }
    # }

  }
}
