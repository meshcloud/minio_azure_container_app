variable "meshstack" {
  type = object({
    owning_workspace_identifier = string
    platform_type_name          = optional(string, "STORAGE-SERVICE")
    platform_name               = optional(string, "storage-service")
    location_name               = optional(string, "storage")
    tags                        = optional(map(list(string)), {})
    notification_subscribers    = optional(list(string), [])
  })
}

resource "meshstack_platform_type" "storage_service_platfrom_type" {
  provider = meshstack.admin
  metadata = {
    name               = var.meshstack.platform_type_name
    owned_by_workspace = var.meshstack.owning_workspace_identifier
  }
  spec = {
    default_endpoint = null
    display_name     = var.meshstack.platform_name
    icon             = "data:image/png;base64,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"
  }
}

resource "meshstack_platform" "storage_platform" {
  metadata = {
    name               = var.meshstack.platform_name
    owned_by_workspace = var.meshstack.owning_workspace_identifier
  }
  spec = {
    access_information = null
    availability = {
      publication_state        = "UNPUBLISHED"
      restricted_to_workspaces = [var.meshstack.owning_workspace_identifier]
      restriction              = "PRIVATE"
    }
    config = {
      aks     = null
      aws     = null
      azure   = null
      azurerg = null
      custom = {
        metering = {
          processing = {
            compact_timelines_after_days = 30
            delete_raw_data_after_days   = 65
          }
        }
        platform_type_ref = {
          kind = "meshPlatformType"
          name = meshstack_platform_type.storage_service_platfrom_type.metadata.name
        }
      }
      gcp        = null
      kubernetes = null
      openshift  = null
    }
    contributing_workspaces = []
    description             = ""
    display_name            = var.meshstack.platform_name
    documentation_url       = ""
    endpoint                = var.meshstack.platform_name
    location_ref = {
      kind = "meshLocation"
      name = var.meshstack.location_name
    }
    quota_definitions = []
    support_url       = ""
  }
}
resource "meshstack_landingzone" "example" {
  metadata = {
    name               = "storage-lz"
    owned_by_workspace = var.meshstack.owning_workspace_identifier
    tags               = var.meshstack.tags
  }
  spec = {
    automate_deletion_approval    = false
    automate_deletion_replication = false
    description                   = var.meshstack.location_name
    display_name                  = var.meshstack.location_name
    info_link                     = ""
    mandatory_building_block_refs = [
    ]
    platform_properties = {
      aks     = null
      aws     = null
      azure   = null
      azurerg = null
      custom = {
      }
      gcp        = null
      kubernetes = null
      openshift  = null
    }
    platform_ref = {
      kind = "meshPlatform"
      uuid = meshstack_platform.storage_platform.metadata.uuid
    }
    quotas = [
    ]
    recommended_building_block_refs = [
    ]
  }
}

# ---------------------------------------------------------------------------
# Variables for building block definitions
# ---------------------------------------------------------------------------

variable "ionos_dns_token" {
  type        = string
  sensitive   = true
  description = "IONOS Cloud DNS API token for DNS-01 Let's Encrypt challenge."
  default     = "null"
}

variable "ionos" {
  type = object({
    worker_node_ip            = optional(string, "217.160.202.141")
    dns_zone_id               = optional(string, "")
    instance_bbd_version_uuid = optional(string, "")
    # Non-secret scoped-auth config (from ionos-k8s-terrafrom outputs).
    # The deployer token is a secret and lives in var.ionos_deployer_token.
    cluster_host = optional(string, "")
    cluster_ca   = optional(string, "")
  })
  description = "IONOS Kubernetes configuration for the SeaweedFS building block definitions."
  default     = {}
}

variable "azure" {
  type = object({
    worker_node_ip            = string
    dns_zone_name             = optional(string, "")
    dns_zone_resource_group   = optional(string, "")
    instance_bbd_version_uuid = optional(string, "")
    # Non-secret scoped-auth config (from azure-k8s-terrafrom outputs).
    # The deployer token is a secret and lives in var.az_deployer_token.
    cluster_host = optional(string, "")
    cluster_ca   = optional(string, "")
    # Scoped DNS Service Principal (from azure-k8s-terrafrom outputs). The client
    # secret is sensitive and lives in var.az_dns_client_secret.
    tenant_id       = optional(string, "")
    subscription_id = optional(string, "")
    client_id       = optional(string, "")
  })
  description = "Azure AKS configuration for the SeaweedFS building block definitions."
}

variable "az_deployer_token" {
  type        = string
  sensitive   = true
  default     = ""
  description = "Scoped storage-deployer ServiceAccount token for AKS (from azure-k8s-terrafrom output deployer_token)."
}

variable "az_dns_client_secret" {
  type        = string
  sensitive   = true
  default     = ""
  description = "DNS Service Principal client secret for AKS (from azure-k8s-terrafrom output dns_sp_client_secret)."
}

variable "ionos_deployer_token" {
  type        = string
  sensitive   = true
  default     = ""
  description = "Scoped storage-deployer ServiceAccount token for IONOS K8s (from ionos-k8s-terrafrom output deployer_token)."
}

locals {
  # The provider rejects empty secrets. The building block definitions are always
  # created, so until a real token is supplied we fall back to a non-empty
  # placeholder; the real value rotates in automatically once provided
  # (secret_version is a hash of the value).
  az_deployer_token    = var.az_deployer_token != "" ? var.az_deployer_token : "PLACEHOLDER-az-deployer-token"
  ionos_deployer_token = var.ionos_deployer_token != "" ? var.ionos_deployer_token : "PLACEHOLDER-ionos-deployer-token"
  az_dns_client_secret = var.az_dns_client_secret != "" ? var.az_dns_client_secret : "PLACEHOLDER-az-dns-client-secret"
}

# ---------------------------------------------------------------------------
# Azure Instance Building Block Definition
# ---------------------------------------------------------------------------

resource "meshstack_building_block_definition" "az_seaweedfs_instance" {
  metadata = {
    owned_by_workspace = var.meshstack.owning_workspace_identifier
    tags               = {}
  }
  spec = {
    description              = "SeaweedFS instance on AKS (Azure), part of the Multi-Cloud S3 Storage Service"
    display_name             = "SeaweedFS instance on AKS"
    documentation_url        = null
    notification_subscribers = var.meshstack.notification_subscribers
    readme                   = file("${path.module}/../modules/buildingblocks/az-seaweedfs-instance/APP_TEAM_README.md")
    run_transparency         = true
    support_url              = null
    supported_platforms = [
      {
        kind = "meshPlatformType"
        name = var.meshstack.platform_type_name
      },
    ]
    symbol                    = "data:image/png;base64,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"
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
      cluster_host = {
        argument                       = "\"${var.azure.cluster_host}\""
        assignment_type                = "STATIC"
        default_value                  = null
        description                    = "AKS API server URL for scoped (token) auth"
        display_name                   = "Cluster Host"
        is_environment                 = false
        selectable_values              = null
        sensitive                      = null
        type                           = "STRING"
        updateable_by_consumer         = false
        validation_regex_error_message = null
        value_validation_regex         = null
      }
      cluster_ca = {
        argument                       = "\"${var.azure.cluster_ca}\""
        assignment_type                = "STATIC"
        default_value                  = null
        description                    = "Base64-encoded cluster CA for scoped (token) auth"
        display_name                   = "Cluster CA"
        is_environment                 = false
        selectable_values              = null
        sensitive                      = null
        type                           = "STRING"
        updateable_by_consumer         = false
        validation_regex_error_message = null
        value_validation_regex         = null
      }
      deployer_token = {
        argument          = null
        assignment_type   = "STATIC"
        default_value     = null
        description       = "Scoped storage-deployer ServiceAccount token"
        display_name      = "Deployer Token"
        is_environment    = false
        selectable_values = null
        sensitive = {
          argument = {
            secret_value   = local.az_deployer_token
            secret_version = nonsensitive(sha256(local.az_deployer_token))
          }
          default_value = null
        }
        type                           = "STRING"
        updateable_by_consumer         = false
        validation_regex_error_message = null
        value_validation_regex         = null
      }
      ARM_TENANT_ID = {
        argument                       = "\"${var.azure.tenant_id}\""
        assignment_type                = "STATIC"
        default_value                  = null
        description                    = "Azure AD tenant ID for the DNS Service Principal"
        display_name                   = "ARM Tenant ID"
        is_environment                 = true
        selectable_values              = null
        sensitive                      = null
        type                           = "STRING"
        updateable_by_consumer         = false
        validation_regex_error_message = null
        value_validation_regex         = null
      }
      ARM_SUBSCRIPTION_ID = {
        argument                       = "\"${var.azure.subscription_id}\""
        assignment_type                = "STATIC"
        default_value                  = null
        description                    = "Azure subscription ID of the cluster"
        display_name                   = "ARM Subscription ID"
        is_environment                 = true
        selectable_values              = null
        sensitive                      = null
        type                           = "STRING"
        updateable_by_consumer         = false
        validation_regex_error_message = null
        value_validation_regex         = null
      }
      ARM_CLIENT_ID = {
        argument                       = "\"${var.azure.client_id}\""
        assignment_type                = "STATIC"
        default_value                  = null
        description                    = "DNS Service Principal client ID"
        display_name                   = "ARM Client ID"
        is_environment                 = true
        selectable_values              = null
        sensitive                      = null
        type                           = "STRING"
        updateable_by_consumer         = false
        validation_regex_error_message = null
        value_validation_regex         = null
      }
      ARM_CLIENT_SECRET = {
        argument          = null
        assignment_type   = "STATIC"
        default_value     = null
        description       = "DNS Service Principal client secret"
        display_name      = "ARM Client Secret"
        is_environment    = true
        selectable_values = null
        sensitive = {
          argument = {
            secret_value   = local.az_dns_client_secret
            secret_version = nonsensitive(sha256(local.az_dns_client_secret))
          }
          default_value = null
        }
        type                           = "STRING"
        updateable_by_consumer         = false
        validation_regex_error_message = null
        value_validation_regex         = null
      }
      dns_zone_name = {
        argument                       = "\"${var.azure.dns_zone_name}\""
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
        argument                       = "\"${var.azure.dns_zone_resource_group}\""
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
        argument                       = "\"${var.azure.worker_node_ip}\""
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
        description                    = "Let's Encrypt challenge type"
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
  }
}

# ---------------------------------------------------------------------------
# IONOS Instance Building Block Definition
# ---------------------------------------------------------------------------

resource "meshstack_building_block_definition" "ionos_seaweedfs_instance" {
  metadata = {
    owned_by_workspace = var.meshstack.owning_workspace_identifier
    tags               = {}
  }
  spec = {
    description              = "SeaweedFS instance on IONOS Kubernetes, part of the Multi-Cloud S3 Storage Service"
    display_name             = "SeaweedFS instance on IONOS"
    documentation_url        = null
    notification_subscribers = var.meshstack.notification_subscribers
    readme                   = file("${path.module}/../modules/buildingblocks/ionos-seaweedfs-instance/APP_TEAM_README.md")
    run_transparency         = true
    support_url              = null
    supported_platforms = [
      {
        kind = "meshPlatformType"
        name = var.meshstack.platform_type_name
      },
    ]
    symbol                    = "data:image/png;base64,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"
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
        repository_path                = "modules/buildingblocks/ionos-seaweedfs-instance"
        repository_url                 = "https://github.com/meshcloud/minio_azure_container_app.git"
        ssh_known_host                 = null
        ssh_private_key                = null
        terraform_version              = "1.9.0"
        use_mesh_http_backend_fallback = true
      }
    }
    inputs = {
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
        description                    = "Domain for SeaweedFS S3 API"
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
        description                    = "Domain for Keycloak"
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
      cluster_host = {
        argument                       = "\"${var.ionos.cluster_host}\""
        assignment_type                = "STATIC"
        default_value                  = null
        description                    = "K8s API server URL for scoped (token) auth"
        display_name                   = "Cluster Host"
        is_environment                 = false
        selectable_values              = null
        sensitive                      = null
        type                           = "STRING"
        updateable_by_consumer         = false
        validation_regex_error_message = null
        value_validation_regex         = null
      }
      cluster_ca = {
        argument                       = "\"${var.ionos.cluster_ca}\""
        assignment_type                = "STATIC"
        default_value                  = null
        description                    = "Base64-encoded cluster CA for scoped (token) auth"
        display_name                   = "Cluster CA"
        is_environment                 = false
        selectable_values              = null
        sensitive                      = null
        type                           = "STRING"
        updateable_by_consumer         = false
        validation_regex_error_message = null
        value_validation_regex         = null
      }
      deployer_token = {
        argument          = null
        assignment_type   = "STATIC"
        default_value     = null
        description       = "Scoped storage-deployer ServiceAccount token"
        display_name      = "Deployer Token"
        is_environment    = false
        selectable_values = null
        sensitive = {
          argument = {
            secret_value   = local.ionos_deployer_token
            secret_version = nonsensitive(sha256(local.ionos_deployer_token))
          }
          default_value = null
        }
        type                           = "STRING"
        updateable_by_consumer         = false
        validation_regex_error_message = null
        value_validation_regex         = null
      }
      storage_class_name = {
        argument                       = "\"ionos-enterprise-hdd\""
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
      lets_encrypt_challenge = {
        argument                       = "\"dns\""
        assignment_type                = "STATIC"
        default_value                  = null
        description                    = "Let's Encrypt challenge type"
        display_name                   = "Let's Encrypt Challenge"
        is_environment                 = false
        selectable_values              = null
        sensitive                      = null
        type                           = "STRING"
        updateable_by_consumer         = false
        validation_regex_error_message = null
        value_validation_regex         = null
      }
      lets_encrypt_dns_provider = {
        argument                       = "\"ionoscloud\""
        assignment_type                = "STATIC"
        default_value                  = null
        description                    = "DNS provider for Let's Encrypt DNS-01 challenge"
        display_name                   = "Let's Encrypt DNS Provider"
        is_environment                 = false
        selectable_values              = null
        sensitive                      = null
        type                           = "STRING"
        updateable_by_consumer         = false
        validation_regex_error_message = null
        value_validation_regex         = null
      }
      redirect_http_to_https = {
        argument                       = "false"
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
      worker_node_ip = {
        argument                       = "\"${var.ionos.worker_node_ip}\""
        assignment_type                = "STATIC"
        default_value                  = null
        description                    = "Worker node public IP for DNS A records"
        display_name                   = "Worker Node IP"
        is_environment                 = false
        selectable_values              = null
        sensitive                      = null
        type                           = "STRING"
        updateable_by_consumer         = false
        validation_regex_error_message = null
        value_validation_regex         = null
      }
      ionos_dns_zone_id = {
        argument                       = "\"${var.ionos.dns_zone_id}\""
        assignment_type                = "STATIC"
        default_value                  = null
        description                    = "IONOS Cloud DNS Zone ID for DNS-01 challenge"
        display_name                   = "DNS Zone ID"
        is_environment                 = false
        selectable_values              = null
        sensitive                      = null
        type                           = "STRING"
        updateable_by_consumer         = false
        validation_regex_error_message = null
        value_validation_regex         = null
      }
      ionos_dns_token = {
        argument          = null
        assignment_type   = "STATIC"
        default_value     = null
        description       = "IONOS Cloud DNS API token for DNS-01 challenge"
        display_name      = "IONOS DNS Token"
        is_environment    = false
        selectable_values = null
        sensitive = {
          argument = {
            secret_value   = var.ionos_dns_token
            secret_version = nonsensitive(sha256(var.ionos_dns_token))
          }
          default_value = null
        }
        type                           = "STRING"
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
  }
}

# ---------------------------------------------------------------------------
# SeaweedFS Composition Building Block Definition (unified — IONOS + Azure)
# ---------------------------------------------------------------------------

resource "meshstack_building_block_definition" "seaweedfs_composition" {
  metadata = {
    owned_by_workspace = var.meshstack.owning_workspace_identifier
    tags               = {}
  }
  spec = {
    description               = "The S3 Storage Service — SeaweedFS with Keycloak OIDC and BunkerWeb WAF. Works on IONOS and Azure."
    display_name              = "S3 Storage Service"
    documentation_url         = null
    notification_subscribers  = var.meshstack.notification_subscribers
    readme                    = file("${path.module}/../modules/buildingblocks/seaweedfs-composition/APP_TEAM_README.md")
    run_transparency          = false
    support_url               = null
    supported_platforms       = null
    symbol                    = "data:image/png;base64,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"
    target_type               = "WORKSPACE_LEVEL"
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
        repository_path                = "modules/buildingblocks/seaweedfs-composition"
        repository_url                 = "https://github.com/meshcloud/minio_azure_container_app.git"
        ssh_known_host                 = null
        ssh_private_key                = null
        terraform_version              = "1.9.0"
        use_mesh_http_backend_fallback = true
      }
    }
    inputs = {
      name = {
        argument                       = null
        assignment_type                = "USER_INPUT"
        default_value                  = null
        description                    = "Base name used for generating resource names. A random 4-character suffix will be appended to ensure uniqueness."
        display_name                   = "Name your Storage"
        is_environment                 = false
        selectable_values              = null
        sensitive                      = null
        type                           = "STRING"
        updateable_by_consumer         = false
        validation_regex_error_message = "name must be 3-8 lowercase letters only."
        value_validation_regex         = "^[a-z]{3,8}$"
      }
      cloud_provider = {
        argument                       = null
        assignment_type                = "USER_INPUT"
        default_value                  = null
        description                    = "Target cloud provider for your storage environment."
        display_name                   = "Cloud Provider"
        is_environment                 = false
        selectable_values              = ["ionos", "azure"]
        sensitive                      = null
        type                           = "SINGLE_SELECT"
        updateable_by_consumer         = false
        validation_regex_error_message = null
        value_validation_regex         = null
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
        argument                       = jsonencode(jsonencode(var.meshstack.tags))
        assignment_type                = "STATIC"
        default_value                  = null
        description                    = "YAML map of project tags."
        display_name                   = "Project Tags"
        is_environment                 = false
        selectable_values              = null
        sensitive                      = null
        type                           = "CODE"
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
      ionos_instance_version_uuid = {
        argument                       = "\"${meshstack_building_block_definition.ionos_seaweedfs_instance.version_latest.uuid}\""
        assignment_type                = "STATIC"
        default_value                  = null
        description                    = "UUID of the IONOS instance building block definition version."
        display_name                   = "IONOS Instance Version UUID"
        is_environment                 = false
        selectable_values              = null
        sensitive                      = null
        type                           = "STRING"
        updateable_by_consumer         = false
        validation_regex_error_message = null
        value_validation_regex         = null
      }
      azure_instance_version_uuid = {
        argument                       = "\"${meshstack_building_block_definition.az_seaweedfs_instance.version_latest.uuid}\""
        assignment_type                = "STATIC"
        default_value                  = null
        description                    = "UUID of the Azure instance building block definition version."
        display_name                   = "Azure Instance Version UUID"
        is_environment                 = false
        selectable_values              = null
        sensitive                      = null
        type                           = "STRING"
        updateable_by_consumer         = false
        validation_regex_error_message = null
        value_validation_regex         = null
      }
      dns_zone_name = {
        argument                       = "\"${var.azure.dns_zone_name}\""
        assignment_type                = "STATIC"
        default_value                  = null
        description                    = "Azure DNS zone name (ignored for IONOS)."
        display_name                   = "Azure DNS Zone Name"
        is_environment                 = false
        selectable_values              = null
        sensitive                      = null
        type                           = "STRING"
        updateable_by_consumer         = false
        validation_regex_error_message = null
        value_validation_regex         = null
      }
      dns_zone_resource_group = {
        argument                       = "\"${var.azure.dns_zone_resource_group}\""
        assignment_type                = "STATIC"
        default_value                  = null
        description                    = "Resource group of the Azure DNS zone (ignored for IONOS)."
        display_name                   = "Azure DNS Zone Resource Group"
        is_environment                 = false
        selectable_values              = null
        sensitive                      = null
        type                           = "STRING"
        updateable_by_consumer         = false
        validation_regex_error_message = null
        value_validation_regex         = null
      }
      owned_by_workspace = {
        argument                       = "\"${var.meshstack.owning_workspace_identifier}\""
        assignment_type                = "STATIC"
        default_value                  = null
        description                    = "Workspace that owns the created resources."
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
        argument                       = "\"${var.meshstack.platform_name}.${var.meshstack.location_name}\""
        assignment_type                = "STATIC"
        default_value                  = null
        description                    = "Identifier of the platform where the tenant will be created."
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
        argument                       = "\"storage-lz\""
        assignment_type                = "STATIC"
        default_value                  = null
        description                    = "Identifier of the landing zone to use for the tenant."
        display_name                   = "Landing Zone Identifier"
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
    permissions = ["BUILDINGBLOCKDEFINITION_LIST", "BUILDINGBLOCKDEFINITION_SAVE", "BUILDINGBLOCK_DELETE", "BUILDINGBLOCK_LIST", "BUILDINGBLOCK_SAVE", "LANDINGZONE_LIST", "PROJECT_DELETE", "PROJECT_LIST", "PROJECT_SAVE", "TENANT_DELETE", "TENANT_LIST", "TENANT_SAVE", "WORKSPACE_LIST", "PLATFORMINSTANCE_LIST"]
  }
}

terraform {
  required_providers {
    meshstack = {
      source                = "meshcloud/meshstack"
      version               = ">= 0.22.0"
      configuration_aliases = [meshstack.admin]
    }
  }
}
