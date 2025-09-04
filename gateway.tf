resource "azurerm_web_application_firewall_policy" "newwafpolicy" {
  name                = "newwafpolicy"
  resource_group_name = data.azurerm_resource_group.minio_aci_rg.name
  location            = data.azurerm_resource_group.minio_aci_rg.location
  policy_settings {
    enabled = true
    mode    = "Prevention"
    log_scrubbing {
      enabled = false
    }
  }

  # Define managed rules for the WAF policy
  managed_rules {
    managed_rule_set {
      type    = "OWASP"
      version = "3.2"
    }
  }

  # Only Allow Traffic from specific IP range
  custom_rules {
    enabled   = true
    name      = "AllowIPRange"
    priority  = 1
    rule_type = "MatchRule"

    match_conditions {
      match_variables {
        variable_name = "RemoteAddr"
      }
      operator           = "IPMatch"
      negation_condition = true
      match_values       = split(";", var.ingress_allow_ip_address_range)
    }

    action = "Block"
  }
}

# Create the Application Gateway
resource "azurerm_application_gateway" "minio_appgw" {
  name                = "minio-appgw"
  location            = data.azurerm_resource_group.minio_aci_rg.location
  resource_group_name = data.azurerm_resource_group.minio_aci_rg.name
  firewall_policy_id  = azurerm_web_application_firewall_policy.newwafpolicy.id

  # Configure the SKU and capacity
  sku {
    name = "WAF_v2"
    tier = "WAF_v2"
  }

  # Enable autoscaling (optional)
  autoscale_configuration {
    min_capacity = 1
    max_capacity = 3
  }

  ssl_certificate {
    name     = var.cert_name
    data     = filebase64("./${var.cert_name}")
    password = var.cert_password
  }

  # Configure the gateway's IP settings
  gateway_ip_configuration {
    name      = "appgw-ip-config"
    subnet_id = azurerm_subnet.minio_ag_subnet.id
  }

  # Configure the frontend IP
  frontend_ip_configuration {
    name                 = "appgw-frontend-ip"
    public_ip_address_id = azurerm_public_ip.minio_pip.id
  }

  # Define the frontend port for the UI
  frontend_port {
    name = "appgw-frontend-port-ui"
    port = var.port_ui
  }

  # Define the frontend port for the API
  frontend_port {
    name = "appgw-frontend-port-api"
    port = var.port_api
  }

  # Define the backend address pool
  backend_address_pool {
    name         = "appgw-backend-pool"
    ip_addresses = [azurerm_container_group.minio_aci_container_group.ip_address]
  }

  # Configure backend HTTP settings for the UI
  backend_http_settings {
    name                                = "appgw-backend-http-settings-ui"
    probe_name                          = "ui-probe"
    cookie_based_affinity               = "Disabled"
    port                                = var.port_ui
    protocol                            = "Http"
    request_timeout                     = 20
    pick_host_name_from_backend_address = true
  }

  # Probe for the UI endpoint
  probe {
    name                                      = "ui-probe"
    pick_host_name_from_backend_http_settings = true
    port                                      = var.port_ui
    interval                                  = 30
    protocol                                  = "Http"
    path                                      = "/"
    timeout                                   = 30
    unhealthy_threshold                       = 3
    match {
      status_code = ["200-399"]
    }
  }

  # Configure backend HTTP settings for the API
  backend_http_settings {
    name                                = "appgw-backend-http-settings-api"
    probe_name                          = "api-probe"
    cookie_based_affinity               = "Disabled"
    port                                = var.port_api
    protocol                            = "Http"
    request_timeout                     = 20
    pick_host_name_from_backend_address = true
  }

  # Probe for the API endpoint
  probe {
    name                                      = "api-probe"
    pick_host_name_from_backend_http_settings = true
    port                                      = var.port_api
    interval                                  = 30
    protocol                                  = "Http"
    path                                      = "/minio/health/live"
    timeout                                   = 30
    unhealthy_threshold                       = 3
    match {
      status_code = ["200"]
    }
  }

  # Define the HTTP listener for the UI
  http_listener {
    name                           = "appgw-http-listener-ui"
    frontend_ip_configuration_name = "appgw-frontend-ip"
    frontend_port_name             = "appgw-frontend-port-ui"
    protocol                       = "Https"
    ssl_certificate_name           = var.cert_name
  }

  # Define the HTTP listener for the API
  http_listener {
    name                           = "appgw-http-listener-api"
    frontend_ip_configuration_name = "appgw-frontend-ip"
    frontend_port_name             = "appgw-frontend-port-api"
    protocol                       = "Https"
    ssl_certificate_name           = var.cert_name
  }

  rewrite_rule_set {
    name = "minio-rewrite-rule-set"
    rewrite_rule {
      name          = "minio-forwarded-host-rule"
      rule_sequence = 1
      request_header_configuration {
        header_name  = "X-Forwarded-Host"
        header_value = "\\{host\\}"
      }
    }
    rewrite_rule {
      name          = "remove-cache-rule"
      rule_sequence = 1
      request_header_configuration {
        header_name  = "Cache-Control"
        header_value = "no-store"
      }
    }
    rewrite_rule {
      name          = "clear-origin-rule"
      rule_sequence = 1
      request_header_configuration {
        header_name  = "Origin"
        header_value = ""
      }
    }
  }

  # Define the request routing rule for the UI
  request_routing_rule {
    name                       = "appgw-routing-rule-ui"
    priority                   = 1
    rule_type                  = "Basic"
    http_listener_name         = "appgw-http-listener-ui"
    backend_address_pool_name  = "appgw-backend-pool"
    backend_http_settings_name = "appgw-backend-http-settings-ui"
    rewrite_rule_set_name      = "minio-rewrite-rule-set"
  }

  # Define the request routing rule for the API
  request_routing_rule {
    name                       = "appgw-routing-rule-api"
    priority                   = 2
    rule_type                  = "Basic"
    http_listener_name         = "appgw-http-listener-api"
    backend_address_pool_name  = "appgw-backend-pool"
    backend_http_settings_name = "appgw-backend-http-settings-api"
    rewrite_rule_set_name      = "minio-rewrite-rule-set"
  }

  depends_on = [azurerm_web_application_firewall_policy.newwafpolicy]
}