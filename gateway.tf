resource "azurerm_web_application_firewall_policy" "minio_waf_policy" {
  name                = "minio-waf-policy"
  resource_group_name = var.resource_group_name
  location            = data.azurerm_resource_group.minio_rg.location
  policy_settings {
    enabled = true
    mode    = "Detection"
  }

  # Define managed rules for the WAF policy
  managed_rules {
    managed_rule_set {
      type    = "OWASP"
      version = "3.2"
    }
  }

  # Allow Traffic from an IP range
  custom_rules {
    enabled   = true
    name      = "AllowSpecificIP"
    priority  = 1
    rule_type = "MatchRule"

    match_conditions {
      match_variables {
        variable_name = "RemoteAddr"
      }
      operator           = "IPMatch"
      negation_condition = false
      match_values       = [var.ingress_allow_ip_address_range]
    }

    action = "Allow"
  }
}

# Create the Application Gateway
resource "azurerm_application_gateway" "minio_appgw" {
  name                = "minio-appgw"
  location            = data.azurerm_resource_group.minio_rg.location
  resource_group_name = var.resource_group_name

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

  # Configure the gateway's IP settings
  gateway_ip_configuration {
    name      = "appgw-ip-config"
    subnet_id = data.azurerm_subnet.minio_ag_subnet.id
  }

  # Configure the frontend IP
  frontend_ip_configuration {
    name                            = "appgw-frontend-ip"
    public_ip_address_id            = azurerm_public_ip.minio_pip.id
    private_link_configuration_name = "minio-container-private-link"
  }

  # Define the frontend port
  frontend_port {
    name = "appgw-frontend-port"
    port = 80
  }

  # Define the backend address pool with IP addresses
  backend_address_pool {
    name = "appgw-backend-pool"
    # ip_addresses = [azurerm_container_app.minio_container_app.latest_revision_fqdn]
    fqdns = [azurerm_container_app.minio_container_app.ingress[0].fqdn]
  }

  # Configure backend HTTP settings
  backend_http_settings {
    name                                = "appgw-backend-http-settings"
    cookie_based_affinity               = "Disabled"
    port                                = 80
    protocol                            = "Http"
    request_timeout                     = 20
    pick_host_name_from_backend_address = true
    # trusted_root_certificate_names = ["backend-root-cert"]
  }

  # Define the HTTP listener
  http_listener {
    name                           = "appgw-http-listener"
    frontend_ip_configuration_name = "appgw-frontend-ip"
    frontend_port_name             = "appgw-frontend-port"
    protocol                       = "Http"
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

  }

  # Define the request routing rule
  request_routing_rule {
    name                       = "appgw-routing-rule"
    priority                   = 1
    rule_type                  = "Basic"
    http_listener_name         = "appgw-http-listener"
    backend_address_pool_name  = "appgw-backend-pool"
    backend_http_settings_name = "appgw-backend-http-settings"
    rewrite_rule_set_name      = "minio-rewrite-rule-set"
  }

  private_link_configuration {
    name = "minio-container-private-link"
    ip_configuration {
      name                          = "minio-pl-config"
      subnet_id                     = data.azurerm_subnet.minio_subnet.id
      private_ip_address_allocation = "Dynamic"
      primary                       = true
    }
  }

  # Associate the WAF policy with the Application Gateway
  waf_configuration {
    enabled          = true
    firewall_mode    = "Prevention"
    rule_set_type    = "OWASP"
    rule_set_version = "3.2"
  }
}