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
  description = "UUID of the az-seaweedfs-instance building block definition version."
}

variable "worker_node_ip" {
  type        = string
  description = "AKS LoadBalancer public IP (output 'lb_public_ip' from azure-infrastructure)."
}

variable "dns_zone_name" {
  type        = string
  description = "Azure DNS zone name (output 'dns_zone_name' from azure-infrastructure)."
}

variable "dns_zone_resource_group" {
  type        = string
  description = "Resource group of the Azure DNS zone (output 'dns_zone_resource_group' from azure-infrastructure)."
}

variable "kubeconfig_path" {
  type        = string
  description = "Path to the AKS kubeconfig file on the building block runner."
}

variable "kubeconfig_context" {
  type        = string
  description = "Context name in the kubeconfig for the AKS cluster."
}
