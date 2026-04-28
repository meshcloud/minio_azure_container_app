variable "dns_definition_version_uuid" {
  type        = string
  description = "UUID of the DNS building block definition version."
}

variable "name" {
  type        = string
  description = "Base name used for generating resource names."

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-_]{0,61}[a-zA-Z0-9]$", var.name))
    error_message = "name must be 2-63 characters, start and end with alphanumeric, and contain only alphanumeric, hyphens, or underscores."
  }
}

variable "zone_name" {
  type        = string
  description = "DNS zone name. Use 'meshcloud.io' for Azure, 'ionos.msh.host' for IONOS."
  default     = "meshcloud.io"
}

variable "dns_record_type" {
  type        = string
  description = "DNS record type (A, CNAME, TXT)."
  default     = "A"
}

variable "ttl" {
  type        = string
  description = "DNS record TTL in seconds."
  default     = "300"
}

variable "k8s_platform" {
  type        = string
  description = "Target platform type: 'azure' or 'ionos'. Determines redirect behavior for Let's Encrypt compatibility."
  default     = "ionos"

  validation {
    condition     = contains(["azure", "ionos"], var.k8s_platform)
    error_message = "platform_type must be either 'azure' or 'ionos'."
  }
}

variable "creator" {
  type        = string
  description = "creator of the resources"
}

variable "aks_public_ip" {
  type        = string
  description = "Public IP address of the Azure Load Balancer. Used for creating DNS A records that point to the Azure cluster."
}

variable "ionos_public_ip" {
  type        = string
  description = "Public IP address of the IONOS Network Load Balancer. Used for creating DNS A records that point to the IONOS cluster."
}

variable "az_cluster_ip" {
  type        = string
  description = "Private ClusterIP of the BunkerWeb service in Azure Kubernetes Service. Used for internal DNS resolution within the cluster."
}

variable "ionos_cluster_ip" {
  type        = string
  description = "Private ClusterIP of the BunkerWeb service in IONOS Kubernetes cluster. Used for internal DNS resolution within the cluster."
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
  description = "UUID of the namespace building block definition version."
}

variable "lets_encrypt_challenge" {
  type        = string
  default     = "http"
  description = "Let's Encrypt challenge type: 'http' for Azure (NLB with TLS passthrough), 'dns' for IONOS (ALB without TLS passthrough)."

  validation {
    condition     = contains(["http", "dns"], var.lets_encrypt_challenge)
    error_message = "lets_encrypt_challenge must be either 'http' or 'dns'."
  }
}

variable "lets_encrypt_dns_provider" {
  type        = string
  default     = "ionoscloud"
  description = "DNS provider for Let's Encrypt DNS-01 challenge. Use 'ionoscloud' for IONOS Cloud DNS."
}
