resource "azurerm_storage_account" "minio_storage_account" {
  name                              = "miniostorageaccount"
  resource_group_name               = azurerm_resource_group.minio_rg.name
  location                          = var.location
  account_tier                      = "Standard"
  account_replication_type          = "LRS"
  account_kind                      = "StorageV2" # Required for infrastructure_encryption_enabled
  access_tier                       = "Hot"
  infrastructure_encryption_enabled = true
}

resource "azurerm_storage_share" "minio_storage_share" {
  name                 = "miniostorageshare"
  storage_account_id   = azurerm_storage_account.minio_storage_account.id
  quota                = 5 # size in GBs
}

resource "azurerm_container_app_environment_storage" "minio_app_storage" {
  name                         = "miniocontainerappstorage"
  container_app_environment_id = azurerm_container_app_environment.minio_app_env.id
  account_name                 = azurerm_storage_account.minio_storage_account.name
  share_name                   = azurerm_storage_share.minio_storage_share.name
  access_key                   = azurerm_storage_account.minio_storage_account.primary_access_key
  access_mode                  = "ReadWrite"
}