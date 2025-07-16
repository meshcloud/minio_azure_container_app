data "azurerm_virtual_network" "minio_vnet" {
  name                = vnet_name
  resource_group_name = azurerm_resource_group.minio_rg.name
}

data "azurerm_subnet" "minio_subnet" {
  name                 = var.subnet_name
  virtual_network_name = azurerm_virtual_network.minio_vnet.name
  resource_group_name  = azurerm_resource_group.minio_rg.name
}

data "azurerm_subnet" "minio_ag_subnet" {
  name                 = var.ag_subnet_name
  virtual_network_name = azurerm_virtual_network.minio_vnet.name
  resource_group_name  = azurerm_resource_group.minio_rg.name
}

resource "azurerm_public_ip" "minio_pip" {
  name                = "minio-pip"
  location            = azurerm_resource_group.minio_rg.location
  resource_group_name = azurerm_resource_group.minio_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}