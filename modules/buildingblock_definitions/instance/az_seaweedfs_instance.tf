resource "meshstack_building_block_definition" "az_seaweedfs_instance" {
  metadata = {
    owned_by_workspace = "meshcloud"
    tags               = {}
  }
  spec = {
    description              = "SeaweedFS instance on AKS (Azure), part of the Multi-Cloud S3 Storage Service"
    display_name             = "SeaweedFS instance on AKS"
    documentation_url        = null
    notification_subscribers = ["user:fnowarre@meshcloud.io"]
    readme                   = "# SeaweedFS S3 Storage Instance (Azure AKS)\n\nDeploys SeaweedFS with Keycloak OIDC authentication into an AKS namespace, protected by the shared BunkerWeb WAF.\n\n## Endpoints\n\n- **S3 API**: `https://storage.<subdomain>.az-flo.msh.host`\n- **Keycloak**: `https://keycloak.<subdomain>.az-flo.msh.host`\n"
    run_transparency         = true
    support_url              = null
    supported_platforms = [
      {
        kind = "meshPlatformType"
        name = "STORAGE-SERVICE"
      },
    ]
    symbol                    = null
    target_type               = "TENANT_LEVEL"
    use_in_landing_zones_only = false
  }
  version_latest_release = null
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
        repository_path                = "modules/buildingblocks/az-seaweedfs-instance"
        repository_url                 = "https://github.com/meshcloud/minio_azure_container_app.git"
        ssh_known_host                 = null
        ssh_private_key                = null
        terraform_version              = "1.9.0"
        use_mesh_http_backend_fallback = true
      }
    }
    inputs = {
      # --- User provides ---
      namespace = {
        argument                       = null
        assignment_type                = "USER_INPUT"
        default_value                  = null
        description                    = "Kubernetes namespace for all resources"
        display_name                   = "Namespace"
        is_environment                 = false
        selectable_values              = null
        sensitive                      = null
        type                           = "STRING"
        updateable_by_consumer         = false
        validation_regex_error_message = "name must be 3-8 lowercase letters only."
        value_validation_regex         = "^[a-z]{3,8}$"
      }
      seaweedfs_domain = {
        argument                       = null
        assignment_type                = "USER_INPUT"
        default_value                  = null
        description                    = "Subdomain for SeaweedFS S3 API (without zone suffix)"
        display_name                   = "SeaweedFS Domain"
        is_environment                 = false
        selectable_values              = null
        sensitive                      = null
        type                           = "STRING"
        updateable_by_consumer         = false
        validation_regex_error_message = null
        value_validation_regex         = null
      }
      keycloak_domain = {
        argument                       = null
        assignment_type                = "USER_INPUT"
        default_value                  = null
        description                    = "Subdomain for Keycloak (without zone suffix)"
        display_name                   = "Keycloak Domain"
        is_environment                 = false
        selectable_values              = null
        sensitive                      = null
        type                           = "STRING"
        updateable_by_consumer         = false
        validation_regex_error_message = null
        value_validation_regex         = null
      }
      email_lets_encrypt = {
        argument                       = null
        assignment_type                = "USER_INPUT"
        default_value                  = null
        description                    = "Email address for Let's Encrypt certificate notifications"
        display_name                   = "Let's Encrypt Email"
        is_environment                 = false
        selectable_values              = null
        sensitive                      = null
        type                           = "STRING"
        updateable_by_consumer         = false
        validation_regex_error_message = null
        value_validation_regex         = null
      }
      allowed_ip_addresses = {
        argument                       = null
        assignment_type                = "USER_INPUT"
        default_value                  = "\"0.0.0.0/0\""
        description                    = "Comma-separated CIDR list for BunkerWeb IP whitelist"
        display_name                   = "Allowed IP Addresses"
        is_environment                 = false
        selectable_values              = null
        sensitive                      = null
        type                           = "STRING"
        updateable_by_consumer         = true
        validation_regex_error_message = null
        value_validation_regex         = null
      }

      # --- Static platform values ---
      kubeconfig_path = {
        argument                       = "\"az_kubeconfig.yaml\""
        assignment_type                = "STATIC"
        default_value                  = null
        description                    = "Path to AKS kubeconfig file (uploaded as FILE input below)"
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
        description                    = "AKS cluster context name in the kubeconfig"
        display_name                   = "Kubeconfig Context"
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
        description                    = "Azure DNS zone name"
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
      worker_node_ip = {
        argument                       = null # fill in after: terraform output -raw lb_public_ip (from azure-infrastructure)
        assignment_type                = "STATIC"
        default_value                  = null
        description                    = "AKS LoadBalancer public IP"
        display_name                   = "Worker Node IP"
        is_environment                 = false
        selectable_values              = null
        sensitive                      = null
        type                           = "STRING"
        updateable_by_consumer         = false
        validation_regex_error_message = null
        value_validation_regex         = null
      }
      storage_class_name = {
        argument                       = "\"default\""
        assignment_type                = "STATIC"
        default_value                  = null
        description                    = "StorageClass for PVCs"
        display_name                   = "Storage Class Name"
        is_environment                 = false
        selectable_values              = null
        sensitive                      = null
        type                           = "STRING"
        updateable_by_consumer         = false
        validation_regex_error_message = null
        value_validation_regex         = null
      }
      seaweedfs_storage_size = {
        argument                       = "\"10Gi\""
        assignment_type                = "STATIC"
        default_value                  = null
        description                    = "PVC size for SeaweedFS data"
        display_name                   = "SeaweedFS Storage Size"
        is_environment                 = false
        selectable_values              = null
        sensitive                      = null
        type                           = "STRING"
        updateable_by_consumer         = false
        validation_regex_error_message = null
        value_validation_regex         = null
      }
      lets_encrypt_challenge = {
        argument                       = "\"http\""
        assignment_type                = "STATIC"
        default_value                  = null
        description                    = "Let's Encrypt challenge type (http for Azure NLB)"
        display_name                   = "Let's Encrypt Challenge"
        is_environment                 = false
        selectable_values              = null
        sensitive                      = null
        type                           = "STRING"
        updateable_by_consumer         = false
        validation_regex_error_message = null
        value_validation_regex         = null
      }
      redirect_http_to_https = {
        argument                       = "true"
        assignment_type                = "STATIC"
        default_value                  = null
        description                    = "Enable HTTP to HTTPS redirect"
        display_name                   = "Redirect HTTP to HTTPS"
        is_environment                 = false
        selectable_values              = null
        sensitive                      = null
        type                           = "BOOLEAN"
        updateable_by_consumer         = false
        validation_regex_error_message = null
        value_validation_regex         = null
      }

      # --- Sensitive file ---
      "az_kubeconfig.yaml" = {
        argument          = null
        assignment_type   = "STATIC"
        default_value     = null
        description       = "AKS kubeconfig file (from: terraform output -raw kubeconfig > az_kubeconfig.yaml)"
        display_name      = "AKS Kubeconfig"
        is_environment    = false
        selectable_values = null
        sensitive = {
          argument = {
            secret_value   = var.az_kubeconfig_content
            secret_version = null
          }
          default_value = null
        }
        type                           = "FILE"
        updateable_by_consumer         = false
        validation_regex_error_message = null
        value_validation_regex         = null
      }
    }
    only_apply_once_per_tenant = false
    outputs = {
      s3_api_url = {
        assignment_type = "NONE"
        display_name    = "S3 API URL"
        type            = "STRING"
      }
      keycloak_url = {
        assignment_type = "NONE"
        display_name    = "Keycloak URL"
        type            = "STRING"
      }
      keycloak_admin_console_url = {
        assignment_type = "NONE"
        display_name    = "Keycloak Admin Console URL"
        type            = "STRING"
      }
      keycloak_admin_password = {
        assignment_type = "NONE"
        display_name    = "Keycloak Admin Password"
        type            = "STRING"
      }
      keycloak_test_user_password = {
        assignment_type = "NONE"
        display_name    = "Keycloak Test User Password"
        type            = "STRING"
      }
      keycloak_client_secret = {
        assignment_type = "NONE"
        display_name    = "Keycloak Client Secret"
        type            = "STRING"
      }
      mariadb_password = {
        assignment_type = "NONE"
        display_name    = "MariaDB Password"
        type            = "STRING"
      }
      seaweedfs_admin_access_key = {
        assignment_type = "NONE"
        display_name    = "SeaweedFS Admin Access Key"
        type            = "STRING"
      }
      seaweedfs_admin_secret_key = {
        assignment_type = "NONE"
        display_name    = "SeaweedFS Admin Secret Key"
        type            = "STRING"
      }
      client_app_1_secret = {
        assignment_type = "NONE"
        display_name    = "Client App 1 Secret"
        type            = "STRING"
      }
      client_app_2_secret = {
        assignment_type = "NONE"
        display_name    = "Client App 2 Secret"
        type            = "STRING"
      }
      aws_cli_configure_command = {
        assignment_type = "NONE"
        display_name    = "AWS CLI Configure Command"
        type            = "STRING"
      }
      tenant_id = {
        assignment_type = "PLATFORM_TENANT_ID"
        display_name    = "Tenant ID"
        type            = "STRING"
      }
    }
    permissions = []
    runner_ref = {
      kind = "meshBuildingBlockRunner"
      uuid = "98520496-627d-43e6-82da-ce499179ff3f"
    }
  }
}
