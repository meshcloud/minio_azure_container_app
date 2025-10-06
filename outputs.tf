output "console_url" {
  description = "MinIO Web Console URL"
  value       = "https://${azurerm_container_group.minio_aci_container_group.fqdn}"
}

output "s3_api_url" {
  description = "MinIO S3 API endpoint"
  value       = "https://${azurerm_container_group.minio_aci_container_group.fqdn}:8443"
}

output "fqdn" {
  description = "Fully qualified domain name"
  value       = azurerm_container_group.minio_aci_container_group.fqdn
}

output "public_ip" {
  description = "Public IP address"
  value       = azurerm_container_group.minio_aci_container_group.ip_address
}

output "mc_alias_command" {
  description = "MinIO client setup command"
  value       = "mc alias set myminio https://${azurerm_container_group.minio_aci_container_group.fqdn}:8443 --insecure"
}

output "storage_account_name" {
  description = "Azure Storage Account name"
  value       = azurerm_storage_account.minio_storage_account.name
}
