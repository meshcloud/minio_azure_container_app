variable "resource_group_name" {
  type        = string
  description = "Name of the Resource Group where you want to deploy MinIO"
}

variable "location" {
  type        = string
  description = "Azure region for deployment"
}

variable "minio_root_user" {
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

variable "cert_name" {
  type        = string
  description = "Name of the SSL certificate file (e.g., minio-cert.pfx)"
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
  type        = number
  description = "Storage space needed in GBs (minimum 1GB, maximum 5120GB/5TB)"
  validation {
    condition     = var.storage_share_size >= 1 && var.storage_share_size <= 5120
    error_message = "Storage share size must be between 1GB and 5120GB (5TB)."
  }
}

variable "storage_account_name" {
  type        = string
  description = "Storage Account Name (must be globally unique across Azure)"
}

variable "public_url_domain_name" {
  type        = string
  description = "Domain name for the public URL (e.g., 'miniotest' creates 'miniotest.westeurope.azurecontainer.io')"
}

# Container configurations
variable "containers" {
  type = object({
    minio = object({
      image        = string
      cpu          = string
      memory       = string
      cpu_limit    = number
      memory_limit = number
    })
    nginx = object({
      image        = string
      cpu          = string
      memory       = string
      cpu_limit    = number
      memory_limit = number
    })
    coraza_waf = object({
      image        = string
      cpu          = string
      memory       = string
      cpu_limit    = number
      memory_limit = number
    })
  })
  default = {
    minio = {
      image        = "quay.io/minio/minio:RELEASE.2025-09-07T16-13-09Z"
      cpu          = "0.5"
      memory       = "1.5"
      cpu_limit    = 1.0
      memory_limit = 2.0
    }
    nginx = {
      image        = "mcr.microsoft.com/azurelinux/base/nginx:1.25"
      cpu          = "0.5"
      memory       = "1.0"
      cpu_limit    = 1.0
      memory_limit = 2.0
    }
    coraza_waf = {
      image        = "ghcr.io/meshcloud/minio_azure_container_app/coraza-caddy:caddy-2.8-coraza-v2.0.0"
      cpu          = "1.0"
      memory       = "1.0"
      cpu_limit    = 1.0
      memory_limit = 2.0
    }
  }
  description = "Container specifications including images, CPU, and memory limits"
}
