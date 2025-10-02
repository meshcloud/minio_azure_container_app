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
}

variable "minio_root_password" {
  type        = string
  sensitive   = true
  nullable    = false
  description = "MinIO root password for admin access"
}

variable "container_image" {
  type        = string
  default     = "quay.io/minio/minio:RELEASE.2025-09-07T16-13-09Z"
  description = "MinIO container image. More recent versions have a limited UI."
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

# Resource governance variables
variable "minio_cpu_limit" {
  type        = number
  default     = 1.0
  description = "Maximum CPU cores for MinIO container (prevents runaway consumption)"
  validation {
    condition     = var.minio_cpu_limit >= 0.1 && var.minio_cpu_limit <= 4.0
    error_message = "MinIO CPU limit must be between 0.1 and 4.0 cores."
  }
}

variable "minio_memory_limit" {
  type        = number
  default     = 2.0
  description = "Maximum memory in GB for MinIO container"
  validation {
    condition     = var.minio_memory_limit >= 0.5 && var.minio_memory_limit <= 8.0
    error_message = "MinIO memory limit must be between 0.5GB and 8.0GB."
  }
}

variable "waf_cpu_limit" {
  type        = number
  default     = 1.0
  description = "Maximum CPU cores for WAF container"
  validation {
    condition     = var.waf_cpu_limit >= 0.1 && var.waf_cpu_limit <= 2.0
    error_message = "WAF CPU limit must be between 0.1 and 2.0 cores."
  }
}

variable "waf_memory_limit" {
  type        = number
  default     = 2.0
  description = "Maximum memory in GB for WAF container"
  validation {
    condition     = var.waf_memory_limit >= 0.5 && var.waf_memory_limit <= 4.0
    error_message = "WAF memory limit must be between 0.5GB and 4.0GB."
  }
}



