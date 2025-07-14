output "azurerm_container_app_url" {
  value = azurerm_container_app.minio_container_app.latest_revision_fqdn
}