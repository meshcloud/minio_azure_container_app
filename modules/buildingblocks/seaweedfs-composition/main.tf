locals {
  unique_name = "${var.name}-${random_string.suffix.result}"
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
    tags         = yamldecode(var.project_tags_yaml)
  }
}

resource "meshstack_tenant_v4" "tenant" {
  wait_for_completion = false
  metadata = {
    owned_by_workspace = meshstack_project.project.metadata.owned_by_workspace
    owned_by_project   = meshstack_project.project.metadata.name
  }
  spec = {
    platform_identifier     = var.platform_identifier
    landing_zone_identifier = var.landing_zone_identifier
  }
}

resource "meshstack_building_block_v2" "ionos_seaweedfs_namespace" {
  count = local.is_azure ? 0 : 1
  spec = {
    building_block_definition_version_ref = {
      uuid = var.namespace_definition_version_uuid
    }
    target_ref = {
      kind = "meshTenant"
      uuid = meshstack_tenant_v4.tenant.metadata.uuid
    }
    display_name = "Namespace ${local.unique_name}"
    inputs = {
      namespace                 = { value_string = local.unique_name }
      storage_class_name        = { value_string = "ionos-enterprise-hdd" }
      seaweedfs_domain          = { value_string = "storage.${local.unique_name}" }
      keycloak_domain           = { value_string = "keycloak.${local.unique_name}" }
      email_lets_encrypt        = { value_string = local.creator_email }
      allowed_ip_addresses      = { value_string = var.allowed_ip_addresses }
      redirect_http_to_https    = { value_bool = false }
      lets_encrypt_challenge    = { value_string = "dns" }
      lets_encrypt_dns_provider = { value_string = "ionoscloud" }
      worker_node_ip            = { value_string = var.worker_node_ip }
    }
  }
}

resource "meshstack_building_block_v2" "az_seaweedfs_namespace" {
  count = local.is_azure ? 1 : 0
  spec = {
    building_block_definition_version_ref = {
      uuid = var.namespace_definition_version_uuid
    }
    target_ref = {
      kind = "meshTenant"
      uuid = meshstack_tenant_v4.tenant.metadata.uuid
    }
    display_name = "Namespace ${local.unique_name}"
    inputs = {
      namespace               = { value_string = local.unique_name }
      storage_class_name      = { value_string = "default" }
      seaweedfs_domain        = { value_string = "storage.${local.unique_name}" }
      keycloak_domain         = { value_string = "keycloak.${local.unique_name}" }
      email_lets_encrypt      = { value_string = local.creator_email }
      allowed_ip_addresses    = { value_string = var.allowed_ip_addresses }
      redirect_http_to_https  = { value_bool = true }
      lets_encrypt_challenge  = { value_string = "http" }
      worker_node_ip          = { value_string = var.worker_node_ip }
      dns_zone_name           = { value_string = var.dns_zone_name }
      dns_zone_resource_group = { value_string = var.dns_zone_resource_group }
    }
  }
}
