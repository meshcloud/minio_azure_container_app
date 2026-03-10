locals {
  unique_name = "${var.name}-${random_string.suffix.result}"
  identifier  = lower(trim(replace(local.unique_name, "/[\\s\\-\\_]+/", "-"), "-"))

  azure_sub    = "${local.unique_name}.azure"
  ionos_sub    = "${local.unique_name}.ionos"
  selected_sub = var.k8s_platform == "azure" ? local.azure_sub : local.ionos_sub

  # Platform-specific configs
  storage_class_name     = var.k8s_platform == "azure" ? "default" : "ionos-enterprise-hdd"
  bunkerweb_cluster_ip   = var.k8s_platform == "azure" ? var.az_cluster_ip : var.ionos_cluster_ip
  redirect_http_to_https = var.k8s_platform == "azure" ? true : false

  # Parse creator JSON to extract email
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
    tags = {
      Environment    = ["Dev"]
      ProjectContact = [var.creator]
      AccessLevel    = ["public"]
    }
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

resource "meshstack_building_block_v2" "seaweedfs_dns_record" {
  spec = {
    building_block_definition_version_ref = {
      uuid = var.dns_definition_version_uuid
    }
    target_ref = {
      kind = "meshTenant"
      uuid = meshstack_tenant_v4.tenant.metadata.uuid
    }
    display_name = "seaweedfs dnsrecord: ${local.unique_name}"
    inputs = {
      zone_name = { value_single_select = var.zone_name }
      sub       = { value_string = "storage.${local.selected_sub}" }
      type      = { value_single_select = var.dns_record_type }
      ttl       = { value_string = var.ttl }
    }
  }
}

resource "meshstack_building_block_v2" "keycloak_dns_record" {
  spec = {
    building_block_definition_version_ref = {
      uuid = var.dns_definition_version_uuid
    }
    target_ref = {
      kind = "meshTenant"
      uuid = meshstack_tenant_v4.tenant.metadata.uuid
    }
    display_name = "keycloak dnsrecord: ${local.unique_name}"
    inputs = {
      zone_name = { value_single_select = var.zone_name }
      sub       = { value_string = "keycloak.${local.selected_sub}" }
      type      = { value_single_select = var.dns_record_type }
      ttl       = { value_string = var.ttl }
    }
  }
}

resource "meshstack_building_block_v2" "namespace" {
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
      namespace            = { value_string = local.unique_name }
      k8s_platform         = { value_single_select = var.k8s_platform }
      storage_class_name   = { value_string = local.storage_class_name }
      seaweedfs_domain     = { value_string = "storage.${local.selected_sub}" }
      keycloak_domain      = { value_string = "keycloak.${local.selected_sub}" }
      email_lets_encrypt   = { value_string = local.creator_email }
      ingress_class_name   = { value_string = "bunkerweb" }
      bunkerweb_cluster_ip = { value_string = local.bunkerweb_cluster_ip }
      allowed_ip_addresses = { value_string = var.allowed_ip_addresses }
      redirect_http_to_https = { value_bool = local.redirect_http_to_https }
    }
  }
}
