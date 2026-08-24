# Secretless DNS access for the seaweedfs instance building block: a
# User-Assigned Managed Identity federated to the meshStack replicator (which
# executes building block runs). The instance BB assumes it via OIDC — no client
# secret to store or rotate. Least privilege: DNS Zone Contributor on THIS zone.

data "azurerm_client_config" "current" {}

resource "azurerm_user_assigned_identity" "dns" {
  name                = "${var.aks_cluster_name}-seaweedfs-dns"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
}

# NOTE: the federated identity credential is created in meshstack-terraform,
# where the building block definition UUID (needed for the OIDC subject) is
# available in the same apply.

resource "azurerm_role_assignment" "dns_contributor" {
  scope                = azurerm_dns_zone.main.id
  role_definition_name = "DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.dns.principal_id
}
