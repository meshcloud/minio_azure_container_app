resource "azurerm_storage_account" "minio_storage_account" {
  name                              = var.storage_account_name
  resource_group_name               = azurerm_resource_group.minio_aci_rg.name
  location                          = var.location
  account_tier                      = "Standard"
  account_replication_type          = "LRS"
  account_kind                      = "StorageV2" # Required for infrastructure_encryption_enabled
  access_tier                       = "Hot"
  infrastructure_encryption_enabled = true
  shared_access_key_enabled         = true
  public_network_access_enabled     = true
  allowed_copy_scope                = "AAD"
  https_traffic_only_enabled        = true

  network_rules {
    default_action             = "Deny"
    virtual_network_subnet_ids = [azurerm_subnet.minio_ag_subnet.id, azurerm_subnet.minio_subnet.id]
  }
}

resource "azurerm_storage_share" "minio_storage_share" {
  name               = "miniostorageshare"
  storage_account_id = azurerm_storage_account.minio_storage_account.id
  quota              = var.storage_share_size # size in GBs
}