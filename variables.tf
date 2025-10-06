variable "resource_group_name" {
  type        = string
  description = "Name of the Resource Group where you want to deploy MinIO"
}

variable "location" {
  default     = "West Europe"
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

variable "cert_password" {
  type        = string
  sensitive   = true
  nullable    = false
  description = "Password for the SSL certificate"
  validation {
    condition     = length(var.cert_password) > 0
    error_message = "Certificate password cannot be empty."
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

# Container configurations
variable "ssl_cert_file" {
  type        = string
  default     = "server.crt"
  description = "Name of the SSL certificate file"
}

variable "ssl_key_file" {
  type        = string
  default     = "server.key"
  description = "Name of the SSL private key file"
}

variable "minio_image" {
  type        = string
  default     = "quay.io/minio/minio:RELEASE.2025-09-07T16-13-09Z"
  description = "MinIO container image"
}

variable "nginx_image" {
  type        = string
  default     = "mcr.microsoft.com/azurelinux/base/nginx:1.25"
  description = "Nginx container image"
}

variable "coraza_waf_image" {
  type        = string
  default     = "ghcr.io/meshcloud/minio_azure_container_app/coraza-caddy:caddy-2.8-coraza-v2.0.0"
  description = "Coraza WAF container image"
}
