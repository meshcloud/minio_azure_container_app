# Dedicated Service Principal for the seaweedfs instance building block to manage
# DNS records (Let's Encrypt / A records) in the delegated zone. Least privilege:
# scoped to "DNS Zone Contributor" on THIS DNS zone only — nothing else.

data "azurerm_client_config" "current" {}

resource "azuread_application" "dns" {
  display_name = "${var.aks_cluster_name}-seaweedfs-dns"
}

resource "azuread_service_principal" "dns" {
  client_id = azuread_application.dns.client_id
}

resource "azuread_service_principal_password" "dns" {
  service_principal_id = azuread_service_principal.dns.id
}

resource "azurerm_role_assignment" "dns_contributor" {
  scope                = azurerm_dns_zone.main.id
  role_definition_name = "DNS Zone Contributor"
  principal_id         = azuread_service_principal.dns.object_id
}
