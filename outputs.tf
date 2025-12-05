output "console_url" {
  description = "MinIO Web Console URL"
  value       = "https://${azurerm_public_ip.agw_pip.fqdn}"
}

output "s3_api_url" {
  description = "MinIO S3 API endpoint"
  value       = "https://${azurerm_public_ip.agw_pip.fqdn}:8443"
}

output "keycloak_url" {
  description = "Keycloak admin console URL"
  value       = "https://${azurerm_public_ip.agw_pip.fqdn}:8444"
}

output "fqdn" {
  description = "Fully qualified domain name"
  value       = azurerm_public_ip.agw_pip.fqdn
}

output "public_ip" {
  description = "Public IP address"
  value       = azurerm_public_ip.agw_pip.ip_address
}

output "mc_alias_command" {
  description = "MinIO client setup command"
  value       = "mc alias set myminio https://${azurerm_public_ip.agw_pip.fqdn}:8443 --insecure"
}

output "storage_account_name" {
  description = "Azure Storage Account name"
  value       = azurerm_storage_account.minio_storage_account.name
}

output "keycloak_client_secret" {
  description = "Generated Keycloak OIDC client secret for MinIO"
  value       = random_password.keycloak_client_secret.result
  sensitive   = true
}

output "certificate_pem" {
  description = "Self-signed certificate in PEM format (public cert)"
  value = format("-----BEGIN CERTIFICATE-----\n%s\n-----END CERTIFICATE-----\n",
    join("\n", regexall(".{1,64}", azurerm_key_vault_certificate.minio_cert.certificate_data_base64))
  )
  sensitive = true
}

output "certificate_download_command" {
  description = "Command to download certificate locally"
  value       = "terraform output -raw certificate_pem > minio-cert.pem"
}
