output "console_url" {
  value = "https://${azurerm_container_group.minio_aci_container_group.fqdn}"
}
output "api_url" {
  value = "https://${azurerm_container_group.minio_aci_container_group.fqdn}:9443"
}
output "minio_username" {
  value = var.minio_root_user
}