locals {
  azure_sub    = "${var.sub}.azure"
  ionos_sub    = "${var.sub}.ionos"
  selected_sub = var.k8s_platform == "azure" ? local.azure_sub : local.ionos_sub

  # Platform-specific configs
  storage_class_name     = var.k8s_platform == "azure" ? "default" : "ionos-enterprise-hdd"
  bunkerweb_cluster_ip   = var.k8s_platform == "azure" ? var.az_cluster_ip : var.ionos_cluster_ip
  redirect_http_to_https = var.k8s_platform == "azure" ? true : false
}

locals {
  identifier = lower(trim(replace(var.name, "/[\\s\\-\\_]+/", "-"), "-"))
}

resource "meshstack_project" "project" {
  metadata = {
    name               = local.identifier
    owned_by_workspace = var.owned_by_workspace
  }
  spec = {
    display_name = var.name
    tags = {
      Environment    = "Dev"
      ProjectContact = var.creator
      AccessLevel    = "public"
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
    display_name = "seaweedfs dnsrecord: ${var.name}"
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
    display_name = "keycloak dnsrecord: ${var.name}"
    inputs = {
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
      display_name = "Namespace ${var.name}"
      inputs = {
        inputs = {
          namespace            = { value_string = var.name }
          k8s_platform         = { value_single_select = var.k8s_platform }
          storage_class_name   = { value_string = local.storage_class_name }
          seaweedfs_domain     = { value_string = "storage.${local.selected_sub}" }
          keycloak_domain      = { value_string = "keycloak.${local.selected_sub}" }
          email_lets_encrypt   = { vaule_string = var.creator }
          ingress_class_name   = "bunkerweb"
          bunkerweb_cluster_ip = { value_string = local.bunkerweb_cluster_ip }
          allowed_ip_addresses = { value_string = var.allowed_ip_addresses }

          # IONOS: HTTP to HTTPS redirect works fine
          redirect_http_to_https = local.redirect_http_to_https
        }
      }
    }
  }
}
