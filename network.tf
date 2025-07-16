resource "azurerm_virtual_network" "minio_vnet" {
  name                = "minio-vnet"
  address_space       = [var.vnet_cidr_range]
  location            = azurerm_resource_group.minio_rg.location
  resource_group_name = azurerm_resource_group.minio_rg.name
}


resource "azurerm_subnet" "minio_subnet" {
  name                                          = "minio-subnet"
  resource_group_name                           = azurerm_resource_group.minio_rg.name
  virtual_network_name                          = azurerm_virtual_network.minio_vnet.name
  address_prefixes                              = [var.subnet_cidr_range]
  service_endpoints                             = ["Microsoft.Storage"]
  private_link_service_network_policies_enabled = false
}

resource "azurerm_subnet" "minio_ag_subnet" {
  name                 = "minio-ag-subnet"
  resource_group_name  = azurerm_resource_group.minio_rg.name
  virtual_network_name = azurerm_virtual_network.minio_vnet.name
  address_prefixes     = [var.ag_subnet_cidr_range]
  service_endpoints    = ["Microsoft.Storage"]
}

resource "azurerm_public_ip" "minio_pip" {
  name                = "minio-pip"
  location            = azurerm_resource_group.minio_rg.location
  resource_group_name = azurerm_resource_group.minio_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}