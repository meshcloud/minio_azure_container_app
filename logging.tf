resource "azurerm_log_analytics_workspace" "minio_law" {
  name                = "minio-law"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# App Gateway logs
resource "azurerm_monitor_diagnostic_setting" "minio_diagnostic_setting" {
  name                       = "minio-diagnostic-setting"
  target_resource_id         = azurerm_application_gateway.minio_appgw.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.minio_law.id

  enabled_log {
    category = "ApplicationGatewayAccessLog"
  }

  enabled_log {
    category = "ApplicationGatewayFirewallLog"
  }

  enabled_log {
    category = "ApplicationGatewayPerformanceLog"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}

# Storage Account logs
resource "azurerm_monitor_diagnostic_setting" "storage_account_logs" {
  name                       = "storage-diagnostic-setting"
  target_resource_id         = "${azurerm_storage_account.minio_storage_account.id}/blobServices/default/"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.minio_law.id

  enabled_log {
    category = "StorageRead"
  }

  enabled_log {
    category = "StorageWrite"
  }

  enabled_log {
    category = "StorageDelete"
  }

  enabled_metric {
    category = "Transaction"
  }
}