resource "azurerm_public_ip" "lb" {
  name                = "${var.aks_cluster_name}-lb-ip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
}
