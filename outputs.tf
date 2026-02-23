output "team_alpha_s3_api_url" {
  description = "Team Alpha: SeaweedFS S3 API endpoint"
  value       = module.team_alpha.s3_api_url
}

output "team_alpha_keycloak_url" {
  description = "Team Alpha: Keycloak URL"
  value       = module.team_alpha.keycloak_url
}

output "team_alpha_keycloak_admin_console_url" {
  description = "Team Alpha: Keycloak admin console URL"
  value       = module.team_alpha.keycloak_admin_console_url
}

output "team_alpha_keycloak_client_secret" {
  description = "Team Alpha: Keycloak OIDC client secret for SeaweedFS"
  value       = module.team_alpha.keycloak_client_secret
  sensitive   = true
}

output "team_alpha_mariadb_password" {
  description = "Team Alpha: MariaDB password"
  value       = module.team_alpha.mariadb_password
  sensitive   = true
}

output "team_alpha_keycloak_admin_password" {
  description = "Team Alpha: Keycloak admin password"
  value       = module.team_alpha.keycloak_admin_password
  sensitive   = true
}

output "team_alpha_keycloak_test_user_password" {
  description = "Team Alpha: Keycloak test user password"
  value       = module.team_alpha.keycloak_test_user_password
  sensitive   = true
}

output "team_alpha_aws_cli_configure_command" {
  description = "Team Alpha: AWS CLI configure command for SeaweedFS S3"
  value       = module.team_alpha.aws_cli_configure_command
}

output "team_beta_s3_api_url" {
  description = "Team Beta: SeaweedFS S3 API endpoint"
  value       = module.team_beta.s3_api_url
}

output "team_beta_keycloak_url" {
  description = "Team Beta: Keycloak URL"
  value       = module.team_beta.keycloak_url
}

output "team_beta_keycloak_admin_console_url" {
  description = "Team Beta: Keycloak admin console URL"
  value       = module.team_beta.keycloak_admin_console_url
}

output "team_beta_keycloak_client_secret" {
  description = "Team Beta: Keycloak OIDC client secret for SeaweedFS"
  value       = module.team_beta.keycloak_client_secret
  sensitive   = true
}

output "team_beta_mariadb_password" {
  description = "Team Beta: MariaDB password"
  value       = module.team_beta.mariadb_password
  sensitive   = true
}

output "team_beta_keycloak_admin_password" {
  description = "Team Beta: Keycloak admin password"
  value       = module.team_beta.keycloak_admin_password
  sensitive   = true
}

output "team_beta_keycloak_test_user_password" {
  description = "Team Beta: Keycloak test user password"
  value       = module.team_beta.keycloak_test_user_password
  sensitive   = true
}

output "team_beta_aws_cli_configure_command" {
  description = "Team Beta: AWS CLI configure command for SeaweedFS S3"
  value       = module.team_beta.aws_cli_configure_command
}
