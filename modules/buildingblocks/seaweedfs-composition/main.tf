locals {
  project_tags = try(yamldecode(var.project_tags_yaml), {})

  # First environment tag value (e.g. "dev"), if set — appended to the name.
  environment = try(local.project_tags.environment[0], "")

  base_name   = "${var.name}-${random_string.suffix.result}"
  unique_name = local.environment != "" ? "${local.base_name}-${local.environment}" : local.base_name
  identifier  = lower(trim(replace(local.unique_name, "/[\\s\\-\\_]+/", "-"), "-"))

  is_azure = var.cloud_provider == "azure"

  creator_data  = jsondecode(var.creator)
  creator_email = local.creator_data.email
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
    display_name = "Storage ${local.unique_name}"
    # Only USER_INPUT inputs are set here. STATIC inputs (storage_class_name,
    # lets_encrypt_*, redirect_http_to_https, worker_node_ip, …) come from the
    # building block definition — passing them here makes the provider drop them
    # ("element has vanished") on apply.
    inputs = {
      namespace            = { value = jsonencode(local.unique_name) }
      seaweedfs_domain     = { value = jsonencode("storage.${local.unique_name}") }
      keycloak_domain      = { value = jsonencode("keycloak.${local.unique_name}") }
      email_lets_encrypt   = { value = jsonencode(local.creator_email) }
      allowed_ip_addresses = { value = jsonencode(var.allowed_ip_addresses) }
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
    display_name = "Storage ${local.unique_name}"
    # Only USER_INPUT inputs are set here. STATIC inputs (storage_class_name,
    # lets_encrypt_challenge, redirect_http_to_https, dns_zone_*, …) come from the
    # building block definition — passing them here makes the provider drop them
    # ("element has vanished") on apply.
    inputs = {
      namespace            = { value = jsonencode(local.unique_name) }
      seaweedfs_domain     = { value = jsonencode("storage.${local.unique_name}") }
      keycloak_domain      = { value = jsonencode("keycloak.${local.unique_name}") }
      email_lets_encrypt   = { value = jsonencode(local.creator_email) }
      allowed_ip_addresses = { value = jsonencode(var.allowed_ip_addresses) }
    }
  }
}
