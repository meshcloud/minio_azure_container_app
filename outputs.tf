
output "platform_tenant_id" {
  value = azurerm_container_group.minio_aci_container_group.name
}
output "minio_ip_address" {
  value = azurerm_public_ip.minio_pip.ip_address
}
output "web_console_port" {
  value = var.port_ui
}
output "api_port" {
  value = var.port_api
}
output "minio_username" {
  value = var.minio_root_user
}