resource "meshstack_building_block_v2" "seaweedfs_dns_record" {
  spec = {
    building_block_definition_version_ref = {
      uuid = var.dns_definition_version_uuid
    }
    target_ref = {
      kind = "meshTenant"
      uuid = meshstack_tenant_v4.dev.metadata.uuid
    }
    display_name = "Namespace Dev"
    inputs = {
      namespace_name = {
        value_string = "${var.name}-dev"
      }
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
      uuid = meshstack_tenant_v4.prod.metadata.uuid
    }
    display_name = "Namespace Prod"
    inputs = {
      namespace_name = {
        value_string = "${var.name}-prod"
      }
    }
  }
}

