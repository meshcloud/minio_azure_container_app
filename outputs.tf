output "azurerm_container_app_url" {
  value = azurerm_container_app.minio_container_app.ingress[0].fqdn
}
output "public_ip_address" {
  value = azurerm_public_ip.minio_pip.ip_address
}
output "application_gateway_id" {
  value = azurerm_application_gateway.minio_appgw.id
}
output "minio_root_username" {
  value = var.minio_root_user
}