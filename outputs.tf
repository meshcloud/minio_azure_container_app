output "s3_api_url" {
  description = "SeaweedFS S3 API endpoint (via BunkerWeb ingress)"
  value       = module.team_alpha.s3_api_url
}

output "keycloak_url" {
  description = "Keycloak URL"
  value       = module.team_alpha.keycloak_url
}

output "keycloak_admin_console_url" {
  description = "Keycloak admin console URL"
  value       = module.team_alpha.keycloak_admin_console_url
}

output "keycloak_client_secret" {
  description = "Generated Keycloak OIDC client secret for SeaweedFS"
  value       = module.team_alpha.keycloak_client_secret
  sensitive   = true
}

output "mariadb_password" {
  description = "Generated MariaDB password"
  value       = module.team_alpha.mariadb_password
  sensitive   = true
}

output "keycloak_admin_password" {
  description = "Generated Keycloak admin password"
  value       = module.team_alpha.keycloak_admin_password
  sensitive   = true
}

output "keycloak_test_user_password" {
  description = "Generated Keycloak test user password"
  value       = module.team_alpha.keycloak_test_user_password
  sensitive   = true
}

output "aws_cli_configure_command" {
  description = "Command to configure AWS CLI for SeaweedFS S3"
  value       = module.team_alpha.aws_cli_configure_command
}
