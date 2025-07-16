output "azurerm_container_app_url" {
  value = azurerm_container_app.minio_container_app.latest_revision_fqdn
}
output "public_ip_address" {
  value = azurerm_public_ip.minio_pip.ip_address
}
output "application_gateway_id" {
  value = azurerm_application_gateway.minio_appgw.id
}
output "web_application_firewall_policy_id" {
  value = azurerm_web_application_firewall_policy.minio_waf_policy.id
}