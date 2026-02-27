resource "meshstack_building_block_v2" "seaweedfs_dns_record" {
  spec = {
    building_block_definition_version_ref = {
      uuid = var.dns_definition_version_uuid
    }
    target_ref = {
      kind = "meshTenant"
      uuid = var.dev_tenant_uuid
    }
    display_name = "Namespace Dev"
    inputs = {
      zone_name = { value_single_select = var.zone_name }
      sub       = { value_string = var.sub }
      type      = { value_single_select = var.dns_record_type }
      ttl       = { value_string = var.ttl }
    }
  }
}

resource "meshstack_building_block_v2" "namespace_dns_record" {
  spec = {
    building_block_definition_version_ref = {
      uuid = var.dns_definition_version_uuid
    }
    target_ref = {
      kind = "meshTenant"
      uuid = var.prod_tenant_uuid
    }
    display_name = "Namespace Prod"
    inputs = {
      inputs = {
      zone_name = { value_single_select = var.zone_name }
      sub       = { value_string = var.sub }
      type      = { value_single_select = var.dns_record_type }
      ttl       = { value_string = var.ttl }
    }
  }
}
