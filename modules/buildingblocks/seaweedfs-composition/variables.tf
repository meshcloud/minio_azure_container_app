variable "cloud_provider" {
  type        = string
  description = "Target cloud provider: 'ionos' or 'azure'."

  validation {
    condition     = contains(["ionos", "azure"], var.cloud_provider)
    error_message = "cloud_provider must be 'ionos' or 'azure'."
  }
}

variable "name" {
  type        = string
  description = "Base name used for generating resource names."

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-_]{0,61}[a-zA-Z0-9]$", var.name))
    error_message = "name must be 2-63 characters, start and end with alphanumeric, and contain only alphanumeric, hyphens, or underscores."
  }
}

variable "project_tags_yaml" {
  type        = string
  description = <<EOF
YAML configuration for project tags. Expected structure:

```yaml
 key1:
  - "value1"
 key2:
  - "value2"
```
EOF
}

variable "creator" {
  type        = string
  description = "Creator JSON (must contain an 'email' field for Let's Encrypt notifications)."
}

variable "allowed_ip_addresses" {
  type        = string
  description = "Comma-separated CIDR list for BunkerWeb IP whitelist."
  default     = "0.0.0.0/0"

  validation {
    condition     = can(regex("^(((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)/(3[0-2]|[12]?[0-9]))(,((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)/(3[0-2]|[12]?[0-9]))*$", var.allowed_ip_addresses))
    error_message = "allowed_ip_addresses must be a comma-separated list of valid CIDR blocks (e.g., '10.0.0.0/8,192.168.1.0/24')."
  }
}

variable "owned_by_workspace" {
  type        = string
  description = "Name of the workspace that owns the created resources."
}

variable "platform_identifier" {
  type        = string
  description = "Identifier of the platform where the tenant will be created."
}

variable "landing_zone_identifier" {
  type        = string
  description = "Identifier of the landing zone to use for the tenant."
}

variable "namespace_definition_version_uuid" {
  type        = string
  description = "UUID of the instance building block definition version (IONOS or Azure depending on cloud_provider)."
}

variable "worker_node_ip" {
  type        = string
  description = "Public IP of the load balancer in front of BunkerWeb (IONOS NLB or AKS LoadBalancer)."
  default     = ""
}

variable "dns_zone_name" {
  type        = string
  description = "Azure DNS zone name. Required when cloud_provider = 'azure'."
  default     = ""
}

variable "dns_zone_resource_group" {
  type        = string
  description = "Resource group of the Azure DNS zone. Required when cloud_provider = 'azure'."
  default     = ""
}
