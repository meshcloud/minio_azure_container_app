output "s3_api_url" {
  description = "SeaweedFS S3 API endpoint (via BunkerWeb ingress)"
  value       = "https://${local.seaweedfs_fqdn}"
}

output "keycloak_url" {
  description = "Keycloak URL"
  value       = "https://${local.keycloak_fqdn}"
}

output "keycloak_admin_console_url" {
  description = "Keycloak admin console URL"
  value       = "https://${local.keycloak_fqdn}/admin"
}

output "keycloak_client_secret" {
  description = "Generated Keycloak OIDC client secret for SeaweedFS"
  value       = random_password.keycloak_client_secret.result
  sensitive   = true
}

output "mariadb_password" {
  description = "Generated MariaDB password"
  value       = random_password.mariadb_password.result
  sensitive   = true
}

output "keycloak_admin_password" {
  description = "Generated Keycloak admin password"
  value       = random_password.keycloak_admin_password.result
  sensitive   = true
}

output "keycloak_test_user_password" {
  description = "Generated Keycloak test user password"
  value       = random_password.keycloak_test_user_password.result
  sensitive   = true
}

output "seaweedfs_admin_access_key" {
  description = "SeaweedFS admin access key"
  value       = var.seaweedfs_admin_access_key
  sensitive   = true
}

output "seaweedfs_admin_secret_key" {
  description = "SeaweedFS admin secret key"
  value       = random_password.seaweedfs_admin_secret.result
  sensitive   = true
}

output "client_app_1_secret" {
  description = "Client application 1 secret for machine-to-machine authentication"
  value       = random_password.client_app_1_secret.result
  sensitive   = true
}

output "client_app_2_secret" {
  description = "Client application 2 secret for machine-to-machine authentication"
  value       = random_password.client_app_2_secret.result
  sensitive   = true
}

output "aws_cli_configure_command" {
  description = "Command to configure AWS CLI for SeaweedFS S3"
  value       = "aws configure --profile seaweedfs set endpoint_url https://${local.seaweedfs_fqdn}"
}

output "tenant_id" {
  value = kubernetes_namespace.this.id
}

