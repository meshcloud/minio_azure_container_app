
output "platform_tenant_id" {
  value = azurerm_container_group.minio_aci_container_group.name
}
output "console_url" {
  value = "https://${azurerm_public_ip.minio_pip.fqdn}:9001"
}
output "api_url" {
  value = "https://${azurerm_public_ip.minio_pip.fqdn}:9000"
}
output "minio_username" {
  value = var.minio_root_user
}