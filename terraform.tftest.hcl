run "complete_minio_deployment" {
  command = plan

  variables {
    resource_group_name        = "test-minio-rg"
    location                  = "West Europe"
    minio_root_user          = "minioadmin"
    minio_root_password      = "SuperSecret123!"
    container_image          = "quay.io/minio/minio:RELEASE.2025-09-07T16-13-09Z"
    cert_name               = "minio-cert.pfx"
    cert_password           = "CertPassword123!"
    storage_share_size      = 100
    storage_account_name    = "testminiostorage001"
    public_url_domain_name  = "testminio"

  }

  # Test core MinIO container deployment
  assert {
    condition     = azurerm_container_group.minio_aci_container_group.name == "minio-aci-container-group"
    error_message = "MinIO container group should be named 'minio-aci-container-group'"
  }

  assert {
    condition     = length(azurerm_container_group.minio_aci_container_group.container) == 2
    error_message = "Container group should have exactly 2 containers (MinIO and nginx)"
  }

  assert {
    condition     = azurerm_container_group.minio_aci_container_group.container[0].image == var.container_image
    error_message = "MinIO container should use the specified container image"
  }

  assert {
    condition     = azurerm_container_group.minio_aci_container_group.container[1].image == "mcr.microsoft.com/azurelinux/base/nginx:1.25"
    error_message = "nginx container should use Azure Linux nginx image"
  }

  # Test exposed ports configuration
  assert {
    condition = contains([
      for port in azurerm_container_group.minio_aci_container_group.exposed_port : port.port
    ], 443)
    error_message = "Container group should expose HTTPS port 443"
  }

  assert {
    condition = contains([
      for port in azurerm_container_group.minio_aci_container_group.exposed_port : port.port
    ], 80)
    error_message = "Container group should expose HTTP port 80"
  }

  assert {
    condition = contains([
      for port in azurerm_container_group.minio_aci_container_group.exposed_port : port.port
    ], 9443)
    error_message = "Container group should expose MinIO API port 9443"
  }

  # Test storage configuration
  assert {
    condition     = azurerm_storage_account.minio_storage_account.name == var.storage_account_name
    error_message = "Storage account should use the specified name"
  }

  assert {
    condition     = azurerm_storage_share.minio_storage_share.quota == var.storage_share_size
    error_message = "Storage share should use the specified size"
  }

  assert {
    condition     = azurerm_storage_account.minio_storage_account.account_tier == "Standard"
    error_message = "Storage account should use Standard tier"
  }

  assert {
    condition     = azurerm_storage_account.minio_storage_account.account_replication_type == "LRS"
    error_message = "Storage account should use LRS replication"
  }

  # Test MinIO volume mount
  assert {
    condition = length([
      for vol in azurerm_container_group.minio_aci_container_group.container[0].volume : vol
      if vol.name == "minio-volume"
    ]) == 1
    error_message = "MinIO container should have storage volume mounted"
  }

  # Test Log Analytics workspace
  assert {
    condition     = length(azurerm_log_analytics_workspace.minio_law) > 0
    error_message = "Log Analytics workspace should be created"
  }
}

run "nginx_ssl_configuration" {
  command = plan

  variables {
    resource_group_name        = "test-minio-rg"
    location                  = "West Europe"
    minio_root_user          = "minioadmin"
    minio_root_password      = "SuperSecret123!"
    cert_name               = "minio-cert.pfx"
    cert_password           = "CertPassword123!"
    storage_share_size      = 100
    storage_account_name    = "testminiostorage002"
    public_url_domain_name  = "testminio2"
  }

  # Test nginx SSL certificates volume
  assert {
    condition = length([
      for vol in azurerm_container_group.minio_aci_container_group.container[1].volume : vol
      if vol.name == "ssl-certs"
    ]) == 1
    error_message = "nginx should have SSL certificates volume mounted"
  }

  # Test nginx configuration volume
  assert {
    condition = length([
      for vol in azurerm_container_group.minio_aci_container_group.container[1].volume : vol
      if vol.name == "nginx-config"
    ]) == 1
    error_message = "nginx should have configuration volume mounted"
  }

  # Test nginx environment variables
  assert {
    condition = contains(keys(azurerm_container_group.minio_aci_container_group.container[1].environment_variables), "MINIO_BACKEND_UI")
    error_message = "nginx should have MinIO UI backend environment variable"
  }

  assert {
    condition = contains(keys(azurerm_container_group.minio_aci_container_group.container[1].environment_variables), "MINIO_BACKEND_API")
    error_message = "nginx should have MinIO API backend environment variable"
  }
}

run "storage_size_validation" {
  command = plan

  variables {
    resource_group_name        = "test-minio-rg"
    location                  = "West Europe"
    minio_root_user          = "minioadmin"
    minio_root_password      = "SuperSecret123!"
    cert_name               = "minio-cert.pfx"
    cert_password           = "CertPassword123!"
    storage_share_size      = 1000
    storage_account_name    = "testminiostorage003"
    public_url_domain_name  = "testminio3"
  }

  assert {
    condition     = azurerm_storage_share.minio_storage_share.quota == 1000
    error_message = "Storage share should accept large sizes up to 5TB"
  }
}

run "invalid_storage_size" {
  command = plan
  expect_failures = [
    var.storage_share_size,
  ]

  variables {
    resource_group_name        = "test-minio-rg"
    location                  = "West Europe"
    minio_root_user          = "minioadmin"
    minio_root_password      = "SuperSecret123!"
    cert_name               = "minio-cert.pfx"
    cert_password           = "CertPassword123!"
    storage_share_size      = 0
    storage_account_name    = "testminiostorage004"
    public_url_domain_name  = "testminio4"
  }
}

run "invalid_storage_size_too_large" {
  command = plan
  expect_failures = [
    var.storage_share_size,
  ]

  variables {
    resource_group_name        = "test-minio-rg"
    location                  = "West Europe"
    minio_root_user          = "minioadmin"
    minio_root_password      = "SuperSecret123!"
    cert_name               = "minio-cert.pfx"
    cert_password           = "CertPassword123!"
    storage_share_size      = 6000
    storage_account_name    = "testminiostorage005"
    public_url_domain_name  = "testminio5"
  }
}

run "empty_credentials" {
  command = plan
  expect_failures = [
    var.minio_root_user,
    var.minio_root_password,
  ]

  variables {
    resource_group_name        = "test-minio-rg"
    location                  = "West Europe"
    minio_root_user          = ""
    minio_root_password      = ""
    cert_name               = "minio-cert.pfx"
    cert_password           = "CertPassword123!"
    storage_share_size      = 100
    storage_account_name    = "testminiostorage006"
    public_url_domain_name  = "testminio6"
  }
}

run "missing_certificate" {
  command = plan
  expect_failures = [
    var.cert_password,
  ]

  variables {
    resource_group_name        = "test-minio-rg"
    location                  = "West Europe"
    minio_root_user          = "minioadmin"
    minio_root_password      = "SuperSecret123!"
    cert_name               = "minio-cert.pfx"
    cert_password           = ""
    storage_share_size      = 100
    storage_account_name    = "testminiostorage007"
    public_url_domain_name  = "testminio7"
  }
}

