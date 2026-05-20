# __generated__ by OpenTofu
# Please review these resources and move them into your main configuration files.

# __generated__ by OpenTofu
resource "meshstack_building_block_definition" "howto_example" {
  metadata = {
    owned_by_workspace = "meshcloud"
    tags               = {}
  }
  spec = {
    description              = "seaweedfs instance on K8S, part of the Multi-Cloud S3 Storage Service"
    display_name             = "seaweedfs instance on K8S"
    documentation_url        = null
    notification_subscribers = ["user:fnowarre@meshcloud.io"]
    readme                   = "# SeaweedFS S3 Storage Instance\n\n## What is it?\n\nA deployed SeaweedFS instance providing S3-compatible object storage with Keycloak OIDC authentication in your Kubernetes namespace, protected by the existing BunkerWeb WAF infrastructure.\n\n## Resources Deployed\n\n- **Kubernetes Namespace**: Isolated environment for your storage instance\n- **SeaweedFS**: S3-compatible object storage server with persistent volume\n- **Keycloak**: OIDC identity provider with pre-configured realm, clients, and test user\n- **MariaDB**: Database backend for Keycloak\n- **Ingress Rules**: Routes traffic through existing BunkerWeb WAF with Let's Encrypt TLS\n- **Persistent Storage**: PVCs for SeaweedFS data, Keycloak data, and MariaDB data\n\n## Endpoints\n\n- **S3 API**: `https://storage.<subdomain>.<platform>`\n- **Keycloak**: `https://keycloak.<subdomain>.<platform>`\n- **Keycloak Admin**: `https://keycloak.<subdomain>.<platform>/admin`\n\n## Authentication & Access Control\n\n| Keycloak Group | S3 IAM Role       | Permissions                                    |\n| -------------- | ----------------- | ---------------------------------------------- |\n| `admins`       | `S3AdminRole`     | Full S3 access (`s3:*`)                        |\n| `developers`   | `S3WriteRole`     | List, Get, Put, Delete objects and buckets     |\n| _(default)_    | `S3ReadOnlyRole`  | List and Get objects (read-only)               |\n\n**Access Flow**:\n1. User authenticates with Keycloak to obtain JWT token\n2. Token is exchanged for temporary S3 credentials via STS `AssumeRoleWithWebIdentity`\n3. User accesses S3 API with AWS CLI or any S3-compatible client using temporary credentials\n\n## Platform Support\n\n| Platform | Storage Class          | Ingress Class | HTTP→HTTPS Redirect |\n| -------- | ---------------------- | ------------- | ------------------- |\n| Azure    | `default` (azurefile)  | `bunkerweb`   | Enabled             |\n| IONOS    | `ionos-enterprise-hdd` | `bunkerweb`   | Disabled*           |\n\n_*IONOS requires HTTP access initially for Let's Encrypt certificate validation._\n\n## Shared Responsibilities\n\n| Responsibility                                      | Platform Team | Application Team |\n| --------------------------------------------------- | ------------- | ---------------- |\n| Deploy and maintain SeaweedFS, Keycloak, MariaDB   | ✅           | ❌               |\n| Configure Ingress rules and TLS certificates       | ✅           | ❌               |\n| Manage Keycloak realm and OIDC clients             | ✅           | ❌               |\n| Create and manage S3 buckets                       | ❌           | ✅               |\n| Manage object lifecycle (upload/download/delete)   | ❌           | ✅               |\n| Assign users to Keycloak groups (admins/developers) | ❌           | ✅               |\n| Configure AWS CLI or S3 clients                    | ❌           | ✅               |\n| Monitor storage usage and quota management         | ❌           | ✅               |\n\n## Security Features\n\n- **WAF Protection**: Traffic routed through BunkerWeb with ModSecurity OWASP Core Rule Set\n- **TLS Encryption**: Automatic Let's Encrypt certificates via BunkerWeb\n- **Temporary Credentials**: STS tokens expire after 1 hour, reducing credential exposure\n- **OIDC-Only Access**: No static access keys; all authentication via Keycloak JWT tokens\n- **Custom ModSecurity Rules**: Tailored exclusions for SeaweedFS and Keycloak compatibility\n\n## Contact\n\n- **Platform Team**: [platform-team@example.com](mailto:platform-team@example.com)\n- **Documentation**: [Internal Wiki Link]\n- **Support Tickets**: [Support Portal Link]\n"
    run_transparency         = true
    support_url              = null
    supported_platforms = [
      {
        kind = "meshPlatformType"
        name = "STORAGE-SERVICE"
      },
    ]
    symbol                    = "data:image/png;base64,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"
    target_type               = "TENANT_LEVEL"
    use_in_landing_zones_only = false
  }
  version_latest_release = null
  version_spec = {
    deletion_mode = "DELETE"
    dependency_refs = [
    ]
    draft = true
    implementation = {
      azure_devops_pipeline = null
      github_workflows      = null
      gitlab_pipeline       = null
      manual                = null
      terraform = {
        async                          = false
        pre_run_script                 = null
        ref_name                       = "feature/k8s-test"
        repository_path                = "modules/buildingblocks/seaweedfs-instance"
        repository_url                 = "https://github.com/meshcloud/minio_azure_container_app.git"
        ssh_known_host                 = null
        ssh_private_key                = null
        terraform_version              = "1.9.0"
        use_mesh_http_backend_fallback = true
      }
    }
    inputs = {
      allowed_ip_addresses = {
        argument                       = null
        assignment_type                = "USER_INPUT"
        default_value                  = "\"0.0.0.0/0\""
        description                    = "Comma-separated CIDR list for BunkerWeb IP whitelist"
        display_name                   = "Allowed Ip Addresses"
        is_environment                 = false
        selectable_values              = null
        sensitive                      = null
        type                           = "STRING"
        updateable_by_consumer         = true
        validation_regex_error_message = null
        value_validation_regex         = null
      }
      email_lets_encrypt = {
        argument                       = null
        assignment_type                = "USER_INPUT"
        default_value                  = null
        description                    = "Email address used for Let's Encrypt certificate notifications"
        display_name                   = "Email Lets Encrypt"
        is_environment                 = false
        selectable_values              = null
        sensitive                      = null
        type                           = "STRING"
        updateable_by_consumer         = false
        validation_regex_error_message = null
        value_validation_regex         = null
      }
      ionos_config_context = {
        argument                       = "\"cluster-admin@test-k8s\""
        assignment_type                = "STATIC"
        default_value                  = null
        description                    = "Context name for IONOS Kubernetes cluster"
        display_name                   = "Ionos Config Context"
        is_environment                 = false
        selectable_values              = null
        sensitive                      = null
        type                           = "STRING"
        updateable_by_consumer         = false
        validation_regex_error_message = null
        value_validation_regex         = null
      }
      ionos_config_path = {
        argument                       = "\"ionos_kubeconfig.yaml\""
        assignment_type                = "STATIC"
        default_value                  = null
        description                    = "Path to IONOS Kubernetes config file"
        display_name                   = "Ionos Config Path"
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
        description       = null
        display_name      = ""
        is_environment    = false
        selectable_values = null
        sensitive = {
          argument = {
            secret_value   = null # sensitive write-only
            secret_version = "sha256:52b275690795a29c171c925e604c6a2e1e0ca8f0a7c5d750daaa1f25857fb9e8"
          }
          default_value = null
        }
        type                           = "STRING"
        updateable_by_consumer         = false
        validation_regex_error_message = null
        value_validation_regex         = null
      }
      ionos_dns_zone_id = {
        argument                       = "\"a2941365-3902-4e38-b5c0-54a35084c0a3\""
        assignment_type                = "STATIC"
        default_value                  = null
        description                    = null
        display_name                   = "Ionos Dns Zone Id"
        is_environment                 = false
        selectable_values              = null
        sensitive                      = null
        type                           = "STRING"
        updateable_by_consumer         = false
        validation_regex_error_message = null
        value_validation_regex         = null
      }
      ionos_kubeconfig.yaml = {
        argument          = null
        assignment_type   = "STATIC"
        default_value     = null
        description       = null
        display_name      = "Ionos Kubeconfig.yaml"
        is_environment    = false
        selectable_values = null
        sensitive = {
          argument = {
            secret_value   = null # sensitive write-only
            secret_version = "sha256:fb26543645ec3e5d662a68c48b78208eaaaf2dd40be3d31b7d81e3f41afc195e"
          }
          default_value = null
        }
        type                           = "FILE"
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
      lets_encrypt_challenge = {
        argument                       = null
        assignment_type                = "USER_INPUT"
        default_value                  = "\"http\""
        description                    = null
        display_name                   = "Lets Encrypt Challenge"
        is_environment                 = false
        selectable_values              = null
        sensitive                      = null
        type                           = "STRING"
        updateable_by_consumer         = false
        validation_regex_error_message = null
        value_validation_regex         = null
      }
      lets_encrypt_dns_provider = {
        argument                       = null
        assignment_type                = "USER_INPUT"
        default_value                  = null
        description                    = null
        display_name                   = "Lets Encrypt Dns Provider"
        is_environment                 = false
        selectable_values              = null
        sensitive                      = null
        type                           = "STRING"
        updateable_by_consumer         = false
        validation_regex_error_message = null
        value_validation_regex         = null
      }
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
        validation_regex_error_message = "name must be 3-8 lowercase letters only. A random 4-character suffix will be appended to ensure uniqueness."
        value_validation_regex         = "^[a-z]{3,8}$"
      }
      redirect_http_to_https = {
        argument                       = null
        assignment_type                = "USER_INPUT"
        default_value                  = null
        description                    = "Enable HTTP to HTTPS redirect. Set to false for Azure until Let's Encrypt certificates are obtained, then set to true."
        display_name                   = "Redirect Http To Https"
        is_environment                 = false
        selectable_values              = null
        sensitive                      = null
        type                           = "BOOLEAN"
        updateable_by_consumer         = false
        validation_regex_error_message = null
        value_validation_regex         = null
      }
      seaweedfs_domain = {
        argument                       = null
        assignment_type                = "USER_INPUT"
        default_value                  = null
        description                    = "Domain for SeaweedFS S3 API"
        display_name                   = "Seaweedfs Domain"
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
        display_name                   = "Seaweedfs Storage Size"
        is_environment                 = false
        selectable_values              = null
        sensitive                      = null
        type                           = "STRING"
        updateable_by_consumer         = false
        validation_regex_error_message = null
        value_validation_regex         = null
      }
      storage_class_name = {
        argument                       = null
        assignment_type                = "USER_INPUT"
        default_value                  = "\"standard\""
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
      worker_node_ip = {
        argument                       = null
        assignment_type                = "USER_INPUT"
        default_value                  = null
        description                    = null
        display_name                   = "Worker Node Ips"
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
      aws_cli_configure_command = {
        assignment_type = "NONE"
        display_name    = "Aws Cli Configure Command"
        type            = "STRING"
      }
      keycloak_admin_console_url = {
        assignment_type = "NONE"
        display_name    = "Keycloak Admin Console Url"
        type            = "STRING"
      }
      keycloak_admin_password = {
        assignment_type = "NONE"
        display_name    = "Keycloak Admin Password"
        type            = "STRING"
      }
      keycloak_client_secret = {
        assignment_type = "NONE"
        display_name    = "Keycloak Client Secret"
        type            = "STRING"
      }
      keycloak_test_user_password = {
        assignment_type = "NONE"
        display_name    = "Keycloak Test User Password"
        type            = "STRING"
      }
      keycloak_url = {
        assignment_type = "NONE"
        display_name    = "Keycloak Url"
        type            = "STRING"
      }
      mariadb_password = {
        assignment_type = "NONE"
        display_name    = "Mariadb Password"
        type            = "STRING"
      }
      s3_api_url = {
        assignment_type = "NONE"
        display_name    = "S3 Api Url"
        type            = "STRING"
      }
      tenant_id = {
        assignment_type = "PLATFORM_TENANT_ID"
        display_name    = "Tenant Id"
        type            = "STRING"
      }
    }
    permissions = []
    runner_ref = {
      kind = "meshBuildingBlockRunner"
      uuid = "66ddc814-1e69-4dad-b5f1-3a5bce51c01f"
    }
  }
}
