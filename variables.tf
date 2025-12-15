variable "resource_group_name" {
  type        = string
  description = "Name of the Resource Group where you want to deploy MinIO"
}

variable "location" {
  default     = "germanywestcentral"
  type        = string
  description = "Azure region for deployment"
}

variable "minio_root_user" {
  default     = "minioadmin"
  type        = string
  nullable    = false
  description = "MinIO root username for admin access"
  validation {
    condition     = length(var.minio_root_user) > 0
    error_message = "MinIO root user cannot be empty."
  }
}

variable "minio_root_password" {
  type        = string
  sensitive   = true
  nullable    = false
  description = "MinIO root password for admin access"
  validation {
    condition     = length(var.minio_root_password) > 0
    error_message = "MinIO root password cannot be empty."
  }
}

variable "storage_share_size" {
  default     = 100
  type        = number
  description = "Storage space needed in GBs (minimum 1GB, maximum 5120GB/5TB)"
  validation {
    condition     = var.storage_share_size >= 1 && var.storage_share_size <= 5120
    error_message = "Storage share size must be between 1GB and 5120GB (5TB)."
  }
}

variable "storage_account_name" {
  type        = string
  default     = "miniostorage"
  description = "Storage Account Name prefix (random suffix will be added for global uniqueness)"
  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.storage_account_name))
    error_message = "Storage account name prefix must be 3-24 characters, lowercase letters and numbers only. No special characters or uppercase letters allowed."
  }
}

variable "public_url_domain_name" {
  type        = string
  description = "Domain name for the public URL (e.g., 'miniotest' creates 'miniotest.westeurope.azurecontainer.io')"
}

variable "minio_image" {
  type        = string
  default     = "quay.io/minio/minio:RELEASE.2025-04-22T22-12-26Z"
  description = "MinIO container image"
}

variable "nginx_image" {
  type        = string
  default     = "mcr.microsoft.com/azurelinux/base/nginx:1.25"
  description = "Nginx container image"
}

variable "coraza_waf_image" {
  type        = string
  default     = "ghcr.io/meshcloud/minio_azure_container_app/coraza-caddy:caddy-2.9.1-coraza-v2.0.0"
  description = "Coraza WAF container image"
}

variable "allowed_ip_addresses" {
  type        = string
  description = "Comma-separated list of IP addresses that will be allowed to access the MinIO service in CIDR format. Example: '203.0.113.0/32' for a single IP or '10.10.10.2/32,192.168.1.0/24' for multiple IPs."
  default     = "10.10.10.2/32"
  validation {
    condition = alltrue([
      for ip in split(",", var.allowed_ip_addresses) : can(cidrhost(trimspace(ip), 0))
    ])
    error_message = "All IP addresses must be in valid CIDR format (e.g., '10.10.10.2/32' for a single IP or '192.168.1.0/24' for a subnet)."
  }
}

variable "mariadb_database" {
  type        = string
  default     = "mariadb"
  description = "MariaDB database name for Keycloak"
}

variable "mariadb_user" {
  type        = string
  default     = "keycloak"
  description = "MariaDB username"
}

variable "keycloak_admin_user" {
  type        = string
  default     = "admin"
  description = "Keycloak admin username"
}

variable "keycloak_admin_password" {
  type        = string
  sensitive   = true
  nullable    = false
  description = "Keycloak admin password"
  validation {
    condition     = length(var.keycloak_admin_password) > 0
    error_message = "Keycloak admin password cannot be empty."
  }
}

variable "keycloak_test_user_username" {
  type        = string
  default     = "testuser"
  description = "Keycloak test user username"
}

variable "keycloak_test_user_email" {
  type        = string
  default     = "test@test.com"
  description = "Keycloak test user email"
}

variable "keycloak_test_user_password" {
  type        = string
  sensitive   = true
  default     = "password"
  description = "Keycloak test user password"
}

variable "opkssh_redirect_uris" {
  type = list(string)
  default = [
    "http://localhost:3000/login-callback",
    "http://localhost:10001/login-callback",
    "http://localhost:11110/login-callback"
  ]
  description = "OpenPubkey SSH client redirect URIs for local development"
}
