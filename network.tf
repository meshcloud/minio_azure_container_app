resource "azurerm_virtual_network" "minio_vnet" {
  name                = "minio-vnet"
  address_space       = [var.vnet_cidr_range]
  location            = azurerm_resource_group.minio_aci_rg.location
  resource_group_name = azurerm_resource_group.minio_aci_rg.name
}

resource "azurerm_subnet" "minio_subnet" {
  name                              = "minio-subnet"
  resource_group_name               = azurerm_resource_group.minio_aci_rg.name
  virtual_network_name              = azurerm_virtual_network.minio_vnet.name
  address_prefixes                  = [var.subnet_cidr_range]
  service_endpoints                 = ["Microsoft.Storage"]
  private_endpoint_network_policies = "Enabled"
  delegation {
    name = "delegation"
    service_delegation {
      name    = "Microsoft.ContainerInstance/containerGroups"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_subnet" "minio_ag_subnet" {
  name                                          = "minio-ag-subnet"
  resource_group_name                           = azurerm_resource_group.minio_aci_rg.name
  virtual_network_name                          = azurerm_virtual_network.minio_vnet.name
  address_prefixes                              = [var.ag_subnet_cidr_range]
  private_link_service_network_policies_enabled = false
  service_endpoints                             = ["Microsoft.Storage"]
}

resource "azurerm_subnet" "storage_account_subnet" {
  name                                          = "minio-storage-subnet"
  resource_group_name                           = azurerm_resource_group.minio_aci_rg.name
  virtual_network_name                          = azurerm_virtual_network.minio_vnet.name
  address_prefixes                              = [var.storage_account_subnet_cidr_range]
  service_endpoints                             = ["Microsoft.Storage"]
  private_link_service_network_policies_enabled = false
}

resource "azurerm_public_ip" "minio_pip" {
  name                = "minio-pip"
  location            = azurerm_resource_group.minio_aci_rg.location
  resource_group_name = azurerm_resource_group.minio_aci_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = "patrickminiotest"
}