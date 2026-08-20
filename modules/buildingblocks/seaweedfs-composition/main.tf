locals {
  unique_name = "${var.name}-${random_string.suffix.result}"
  identifier  = lower(trim(replace(local.unique_name, "/[\\s\\-\\_]+/", "-"), "-"))

  is_azure = var.cloud_provider == "azure"

  creator_data  = jsondecode(var.creator)
  creator_email = local.creator_data.email

  project_tags = try(yamldecode(var.project_tags_yaml), {})
}

resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}

resource "meshstack_project" "project" {
  metadata = {
    name               = local.identifier
    owned_by_workspace = var.owned_by_workspace
  }
  spec = {
    display_name = var.name
    tags         = local.project_tags
  }
}

# Resolve the platform identifier (e.g. "storage-service-test.global") to its
# UUID — the tenant API requires spec.platformRef.uuid to be a real UUID.
data "meshstack_platforms" "target" {
  identifier = var.platform_identifier
}

resource "meshstack_tenant" "tenant" {
  wait_for_completion = false
  metadata = {
    owned_by_workspace = meshstack_project.project.metadata.owned_by_workspace
    owned_by_project   = meshstack_project.project.metadata.name
  }
  spec = {
    platform_ref = one(data.meshstack_platforms.target.platforms).ref
    landing_zone_ref = {
      name = var.landing_zone_identifier
    }
  }
}

resource "meshstack_building_block" "ionos_seaweedfs_namespace" {
  count = local.is_azure ? 0 : 1
  spec = {
    building_block_definition_version_ref = {
      uuid = var.ionos_instance_version_uuid
    }
    target_ref = {
      kind = "meshTenant"
      uuid = meshstack_tenant.tenant.metadata.uuid
    }
    display_name = "Namespace ${local.unique_name}"
    inputs = {
      namespace                 = { value = jsonencode(local.unique_name) }
      storage_class_name        = { value = jsonencode("ionos-enterprise-hdd") }
      seaweedfs_domain          = { value = jsonencode("storage.${local.unique_name}") }
      keycloak_domain           = { value = jsonencode("keycloak.${local.unique_name}") }
      email_lets_encrypt        = { value = jsonencode(local.creator_email) }
      allowed_ip_addresses      = { value = jsonencode(var.allowed_ip_addresses) }
      redirect_http_to_https    = { value = jsonencode(false) }
      lets_encrypt_challenge    = { value = jsonencode("dns") }
      lets_encrypt_dns_provider = { value = jsonencode("ionoscloud") }
      worker_node_ip            = { value = jsonencode(var.ionos_worker_node_ip) }
    }
  }
}

resource "meshstack_building_block" "az_seaweedfs_namespace" {
  count = local.is_azure ? 1 : 0
  spec = {
    building_block_definition_version_ref = {
      uuid = var.azure_instance_version_uuid
    }
    target_ref = {
      kind = "meshTenant"
      uuid = meshstack_tenant.tenant.metadata.uuid
    }
    display_name = "Namespace ${local.unique_name}"
    inputs = {
      namespace              = { value = jsonencode(local.unique_name) }
      storage_class_name     = { value = jsonencode("default") }
      seaweedfs_domain       = { value = jsonencode("storage.${local.unique_name}") }
      keycloak_domain        = { value = jsonencode("keycloak.${local.unique_name}") }
      email_lets_encrypt     = { value = jsonencode(local.creator_email) }
      allowed_ip_addresses   = { value = jsonencode(var.allowed_ip_addresses) }
      redirect_http_to_https = { value = jsonencode(true) }
      lets_encrypt_challenge = { value = jsonencode("http") }
      #worker_node_ip          = { value = jsonencode(var.azure_worker_node_ip) }
      dns_zone_name           = { value = jsonencode(var.dns_zone_name) }
      dns_zone_resource_group = { value = jsonencode(var.dns_zone_resource_group) }
    }
  }
}
