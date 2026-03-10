output "s3_api_url" {
  description = "SeaweedFS S3 API endpoint (via BunkerWeb ingress)"
  value       = "https://${var.seaweedfs_domain}"
}

output "keycloak_url" {
  description = "Keycloak URL"
  value       = "https://${var.keycloak_domain}"
}

output "keycloak_admin_console_url" {
  description = "Keycloak admin console URL"
  value       = "https://${var.keycloak_domain}/admin"
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

output "aws_cli_configure_command" {
  description = "Command to configure AWS CLI for SeaweedFS S3"
  value       = "aws configure --profile seaweedfs set endpoint_url https://${var.seaweedfs_domain}"
}

output "tenant_id" {
  value = kubernetes_namespace.this.id
}
