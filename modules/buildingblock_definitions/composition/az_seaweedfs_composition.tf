resource "meshstack_building_block_definition" "az_seaweedfs_composition" {
  metadata = {
    owned_by_workspace = "meshcloud"
    tags               = {}
  }
  spec = {
    description              = "The Azure S3 Storage Service — SeaweedFS on AKS with Keycloak OIDC and BunkerWeb WAF."
    display_name             = "Azure S3 Storage Service"
    documentation_url        = null
    notification_subscribers = ["user:fnowarre@meshcloud.io"]
    readme                   = "# Azure S3 Storage Service\n\nProvisions a SeaweedFS S3-compatible storage environment on Azure AKS with Keycloak OIDC authentication and BunkerWeb WAF protection.\n\n## DNS\n\nSubdomains are created automatically in the `az-flo.msh.host` Azure DNS zone delegated from Route53.\n"
    run_transparency         = false
    support_url              = null
    supported_platforms      = null
    symbol                   = null
    target_type              = "WORKSPACE_LEVEL"
    use_in_landing_zones_only = false
  }
  version_latest_release = {}
  version_spec = {
    deletion_mode   = "DELETE"
    dependency_refs = []
    draft           = true
    implementation = {
      azure_devops_pipeline = null
      github_workflows      = null
      gitlab_pipeline       = null
      manual                = null
      terraform = {
        async                          = false
        pre_run_script                 = null
        ref_name                       = "feature/k8s-test"
        repository_path                = "modules/buildingblocks/az-seaweedfs-composition"
        repository_url                 = "https://github.com/meshcloud/minio_azure_container_app.git"
        ssh_known_host                 = null
        ssh_private_key                = null
        terraform_version              = "1.9.0"
        use_mesh_http_backend_fallback = true
      }
    }
    inputs = {
      # --- User provides ---
      name = {
        argument                       = null
        assignment_type                = "USER_INPUT"
        default_value                  = null
        description                    = "Base name for the storage environment. A random 4-character suffix will be appended."
        display_name                   = "Name your Storage"
        is_environment                 = false
        selectable_values              = null
        sensitive                      = null
        type                           = "STRING"
        updateable_by_consumer         = false
        validation_regex_error_message = "name must be 3-8 lowercase letters only."
        value_validation_regex         = "^[a-z]{3,8}$"
      }
      allowed_ip_addresses = {
        argument                       = null
        assignment_type                = "USER_INPUT"
        default_value                  = "\"0.0.0.0/0\""
        description                    = "Comma-separated CIDR list for BunkerWeb IP whitelist."
        display_name                   = "Allowed IP Addresses"
        is_environment                 = false
        selectable_values              = null
        sensitive                      = null
        type                           = "STRING"
        updateable_by_consumer         = true
        validation_regex_error_message = "allowed_ip_addresses must be a comma-separated list of valid CIDR blocks (e.g., '10.0.0.0/8,192.168.1.0/24')."
        value_validation_regex         = "^((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\\.){3}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])/(3[0-2]|[1-2]?[0-9])(,((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\\.){3}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])/(3[0-2]|[1-2]?[0-9]))*$"
      }
      project_tags_yaml = {
        argument                       = null
        assignment_type                = "USER_INPUT"
        default_value                  = null
        description                    = "YAML map of project tags."
        display_name                   = "Project Tags"
        is_environment                 = false
        selectable_values              = null
        sensitive                      = null
        type                           = "STRING"
        updateable_by_consumer         = false
        validation_regex_error_message = null
        value_validation_regex         = null
      }
      creator = {
        argument                       = null
        assignment_type                = "AUTHOR"
        default_value                  = null
        description                    = ""
        display_name                   = "Creator"
        is_environment                 = false
        selectable_values              = null
        sensitive                      = null
        type                           = "CODE"
        updateable_by_consumer         = false
        validation_regex_error_message = null
        value_validation_regex         = null
      }

      # --- Static platform values ---
      worker_node_ip = {
        argument                       = null # fill in: terraform output -raw lb_public_ip (from azure-infrastructure)
        assignment_type                = "STATIC"
        default_value                  = null
        description                    = "AKS LoadBalancer public IP (from azure-infrastructure lb_public_ip output)"
        display_name                   = "AKS LoadBalancer IP"
        is_environment                 = false
        selectable_values              = null
        sensitive                      = null
        type                           = "STRING"
        updateable_by_consumer         = false
        validation_regex_error_message = null
        value_validation_regex         = null
      }
      dns_zone_name = {
        argument                       = "\"az-flo.msh.host\""
        assignment_type                = "STATIC"
        default_value                  = null
        description                    = "Azure DNS zone name (from azure-infrastructure dns_zone_name output)"
        display_name                   = "DNS Zone Name"
        is_environment                 = false
        selectable_values              = null
        sensitive                      = null
        type                           = "STRING"
        updateable_by_consumer         = false
        validation_regex_error_message = null
        value_validation_regex         = null
      }
      dns_zone_resource_group = {
        argument                       = "\"meshcloud-aks-test\""
        assignment_type                = "STATIC"
        default_value                  = null
        description                    = "Resource group of the Azure DNS zone"
        display_name                   = "DNS Zone Resource Group"
        is_environment                 = false
        selectable_values              = null
        sensitive                      = null
        type                           = "STRING"
        updateable_by_consumer         = false
        validation_regex_error_message = null
        value_validation_regex         = null
      }
      kubeconfig_path = {
        argument                       = "\"az_kubeconfig.yaml\""
        assignment_type                = "STATIC"
        default_value                  = null
        description                    = "Path to AKS kubeconfig file on the runner"
        display_name                   = "Kubeconfig Path"
        is_environment                 = false
        selectable_values              = null
        sensitive                      = null
        type                           = "STRING"
        updateable_by_consumer         = false
        validation_regex_error_message = null
        value_validation_regex         = null
      }
      kubeconfig_context = {
        argument                       = "\"test-aks\""
        assignment_type                = "STATIC"
        default_value                  = null
        description                    = "AKS cluster context name"
        display_name                   = "Kubeconfig Context"
        is_environment                 = false
        selectable_values              = null
        sensitive                      = null
        type                           = "STRING"
        updateable_by_consumer         = false
        validation_regex_error_message = null
        value_validation_regex         = null
      }
      owned_by_workspace = {
        argument                       = "\"meshcloud\""
        assignment_type                = "STATIC"
        default_value                  = null
        description                    = "Workspace that owns the created resources"
        display_name                   = "Owned By Workspace"
        is_environment                 = false
        selectable_values              = null
        sensitive                      = null
        type                           = "STRING"
        updateable_by_consumer         = false
        validation_regex_error_message = null
        value_validation_regex         = null
      }
      platform_identifier = {
        argument                       = "\"storage-service.storage\""
        assignment_type                = "STATIC"
        default_value                  = null
        description                    = "Platform identifier for the AKS tenant"
        display_name                   = "Platform Identifier"
        is_environment                 = false
        selectable_values              = null
        sensitive                      = null
        type                           = "STRING"
        updateable_by_consumer         = false
        validation_regex_error_message = null
        value_validation_regex         = null
      }
      landing_zone_identifier = {
        argument                       = "\"storage\""
        assignment_type                = "STATIC"
        default_value                  = null
        description                    = "Landing zone identifier for the AKS tenant"
        display_name                   = "Landing Zone Identifier"
        is_environment                 = false
        selectable_values              = null
        sensitive                      = null
        type                           = "STRING"
        updateable_by_consumer         = false
        validation_regex_error_message = null
        value_validation_regex         = null
      }
      namespace_definition_version_uuid = {
        argument                       = null # fill in after applying instance BBD: use meshstack_building_block_definition.az_seaweedfs_instance UUID
        assignment_type                = "STATIC"
        default_value                  = null
        description                    = "UUID of the az-seaweedfs-instance building block definition version"
        display_name                   = "Instance BBD Version UUID"
        is_environment                 = false
        selectable_values              = null
        sensitive                      = null
        type                           = "STRING"
        updateable_by_consumer         = false
        validation_regex_error_message = null
        value_validation_regex         = null
      }
    }
    only_apply_once_per_tenant = false
    outputs = {
      summary = {
        assignment_type = "SUMMARY"
        display_name    = "Summary"
        type            = "STRING"
      }
    }
    permissions = ["BUILDINGBLOCKDEFINITION_LIST", "BUILDINGBLOCKDEFINITION_SAVE", "BUILDINGBLOCK_DELETE", "BUILDINGBLOCK_LIST", "BUILDINGBLOCK_SAVE", "LANDINGZONE_LIST", "PROJECT_LIST", "PROJECT_SAVE", "TENANT_LIST", "TENANT_SAVE", "WORKSPACE_LIST"]
    runner_ref = {
      kind = "meshBuildingBlockRunner"
      uuid = "66ddc814-1e69-4dad-b5f1-3a5bce51c01f"
    }
  }
}
