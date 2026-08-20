# __generated__ by OpenTofu
# Please review these resources and move them into your main configuration files.

# __generated__ by OpenTofu from "6dfc94ef-8d7c-48f9-8990-b455f9979354"
resource "meshstack_building_block_definition" "howto_example" {
  metadata = {
    owned_by_workspace = "meshcloud"
    tags               = {}
  }
  spec = {
    description               = "The S3 Storage Service provides application teams with a secure, self-hosted, S3-compatible object storage platform with enterprise-grade authentication and WAF protection."
    display_name              = "Multi-Cloud S3 Storage Service"
    documentation_url         = null
    notification_subscribers  = ["user:fnowarre@meshcloud.io"]
    readme                    = "# Multi-Cloud S3 Storage Service\n\n## What is it?\n\nThe **S3 Storage Service** provides application teams with a secure, self-hosted, S3-compatible object storage platform with enterprise-grade authentication and WAF protection. It automates the deployment of SeaweedFS storage, Keycloak OIDC authentication, and BunkerWeb WAF on Kubernetes (Azure AKS or IONOS).\n\n## When to use it?\n\nThis building block is ideal for teams that:\n\n- Need S3-compatible object storage without vendor lock-in to AWS or cloud-specific services.\n- Require OIDC-based authentication with group-based access control for storage buckets.\n- Want portable storage infrastructure that works across multiple cloud providers (Azure, IONOS, etc.).\n- Need enterprise security (WAF, rate limiting, IP whitelisting) for their storage endpoints.\n\n## Usage Examples\n\n1. **Application artifact storage**: Teams can store container images, build artifacts, or backups in S3 buckets with role-based access control (admins have full access, developers can read/write, others read-only).\n2. **Data lake for analytics**: Store datasets in S3 buckets accessible via standard AWS CLI tools, with authentication enforced via Keycloak groups.\n3. **Multi-tenant storage**: Deploy separate instances per team/project with isolated namespaces and DNS subdomains (e.g., `storage.team-a.azure`, `storage.team-b.ionos`).\n\n## Resources Created\n\nThis building block automates the creation of the following resources:\n\n- **DNS Records**: Subdomain entries for SeaweedFS S3 API (`storage.<sub>.<platform>`) and Keycloak (`keycloak.<sub>.<platform>`).\n- **Kubernetes Namespace**: Isolated environment for the storage instance.\n  - **SeaweedFS Deployment**: S3-compatible object storage server with persistent volume.\n  - **Keycloak Deployment**: OIDC identity provider with pre-configured realm and clients.\n  - **MariaDB Deployment**: Database backend for Keycloak.\n  - **BunkerWeb Ingress**: WAF-protected ingress with Let's Encrypt TLS, ModSecurity rules, rate limiting, and IP whitelisting.\n  - **Persistent Storage**: PVCs for SeaweedFS data, Keycloak data, and MariaDB data (platform-specific storage classes).\n\n## Authentication & Access Control\n\n| Keycloak Group | S3 IAM Role       | Permissions                                    |\n| -------------- | ----------------- | ---------------------------------------------- |\n| `admins`       | `S3AdminRole`     | Full S3 access (`s3:*`)                        |\n| `developers`   | `S3WriteRole`     | List, Get, Put, Delete objects and buckets     |\n| _(default)_    | `S3ReadOnlyRole`  | List and Get objects (read-only)               |\n\n**Access Flow**:\n1. User authenticates with Keycloak to obtain JWT token.\n2. Token is exchanged for temporary S3 credentials via STS `AssumeRoleWithWebIdentity`.\n3. User accesses S3 API with AWS CLI or any S3-compatible client using temporary credentials.\n\n## Platform Support\n\n| Platform | Storage Class          | Ingress Class | HTTP→HTTPS Redirect | Kubernetes Config          |\n| -------- | ---------------------- | ------------- | ------------------- | -------------------------- |\n| Azure    | `azurefile` (default)  | `bunkerweb`   | Enabled             | `~/.kube/config-azure`     |\n| IONOS    | `ionos-enterprise-hdd` | `bunkerweb`   | Disabled*           | `~/.kube/config-ionos`     |\n\n_*IONOS requires HTTP access initially for Let's Encrypt certificate validation._\n\n## Shared Responsibilities\n\n| Responsibility                                     | Platform Team | Application Team |\n| -------------------------------------------------- | ------------- | ---------------- |\n| Provision and manage Kubernetes cluster (AKS/IONOS) | ✅           | ❌               |\n| Deploy and maintain SeaweedFS, Keycloak, MariaDB  | ✅           | ❌               |\n| Configure BunkerWeb WAF, TLS, and ingress rules   | ✅           | ❌               |\n| Manage DNS records for storage and auth endpoints | ✅           | ❌               |\n| Manage Keycloak realm and OIDC clients            | ✅           | ❌               |\n| Create and manage S3 buckets                      | ❌           | ✅               |\n| Manage object lifecycle (upload/download/delete)  | ❌           | ✅               |\n| Assign users to Keycloak groups (admins/developers) | ❌           | ✅               |\n| Configure AWS CLI or S3 clients                   | ❌           | ✅               |\n| Monitor storage usage and quota management        | ❌           | ✅               |\n\n## Security Features\n\n- **WAF Protection**: ModSecurity with OWASP Core Rule Set blocks common attacks (SQL injection, XSS, etc.).\n- **Rate Limiting**: Configurable request rate limits per service (default: 30 req/s).\n- **IP Whitelisting**: Restrict access to specific CIDR ranges.\n- **TLS Encryption**: Automatic Let's Encrypt certificates via BunkerWeb.\n- **Temporary Credentials**: STS tokens expire after 1 hour, reducing credential exposure.\n- **OIDC-Only Access**: No static access keys; all authentication via Keycloak JWT tokens.\n\n### Contact\n\n- **Platform Team**: [platform-team@example.com](mailto:platform-team@example.com)\n- **Documentation**: [Internal Wiki Link]\n- **Support Tickets**: [Support Portal Link]\n"
    run_transparency          = false
    support_url               = null
    supported_platforms       = null
    symbol                    = "data:image/png;base64,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"
    target_type               = "WORKSPACE_LEVEL"
    use_in_landing_zones_only = false
  }
  # version_latest_release = {}
  version_spec = {
    deletion_mode = "DELETE"
    dependency_refs = [
    ]
    draft = false
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
      allowed_ip_addresses = {
        argument                       = null
        assignment_type                = "USER_INPUT"
        default_value                  = "\"0.0.0.0/0\""
        description                    = "Comma-separated CIDR list for BunkerWeb IP whitelist."
        display_name                   = "Allowed Ip Addresses"
        is_environment                 = false
        selectable_values              = null
        sensitive                      = null
        type                           = "STRING"
        updateable_by_consumer         = true
        validation_regex_error_message = "allowed_ip_addresses must be a comma-separated list of valid CIDR blocks (e.g., '10.0.0.0/8,192.168.1.0/24')."
        value_validation_regex         = "^((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\\.){3}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])/(3[0-2]|[1-2]?[0-9])(,((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\\.){3}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])/(3[0-2]|[1-2]?[0-9]))*$"
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
      dns_record_type = {
        argument                       = "\"A\""
        assignment_type                = "STATIC"
        default_value                  = null
        description                    = "DNS record type (A, CNAME, TXT)."
        display_name                   = "Dns Record Type"
        is_environment                 = false
        selectable_values              = null
        sensitive                      = null
        type                           = "STRING"
        updateable_by_consumer         = false
        validation_regex_error_message = null
        value_validation_regex         = null
      }
      ionos_public_ip = {
        argument                       = "\"217.160.202.141\""
        assignment_type                = "STATIC"
        default_value                  = null
        description                    = "Public IP address of the IONOS Network Load Balancer. Used for creating DNS A records that point to the IONOS cluster."
        display_name                   = "Ionos Public Ip"
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
        validation_regex_error_message = "name must be 3-8 lowercase letters only. A random 4-character suffix will be appended to ensure uniqueness."
        value_validation_regex         = "^[a-z]{3,8}$"
      }
      namespace_definition_version_uuid = {
        argument                       = "\"e8a15876-ddfb-4a1a-8559-af8c69a9fea5\""
        assignment_type                = "STATIC"
        default_value                  = null
        description                    = "UUID of the namespace building block definition version."
        display_name                   = "Namespace Definition Version Uuid"
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
        description                    = "Name of the workspace that owns the created resources."
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
      ttl = {
        argument                       = "\"300\""
        assignment_type                = "STATIC"
        default_value                  = null
        description                    = "DNS record TTL in seconds."
        display_name                   = "Ttl"
        is_environment                 = false
        selectable_values              = null
        sensitive                      = null
        type                           = "STRING"
        updateable_by_consumer         = false
        validation_regex_error_message = null
        value_validation_regex         = null
      }
      zone_name = {
        argument                       = "\"meshcloud.io\""
        assignment_type                = "STATIC"
        default_value                  = null
        description                    = "DNS zone name."
        display_name                   = "Zone Name"
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
