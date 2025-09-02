variable "resource_group_name" {
  type    = string
  default = "minio-rg"
}
variable "location" {
  type    = string
  default = "West Europe"
}
variable "container_app_name" {
  type    = string
  default = "minio-container-app"
}
variable "minio_root_user" {
  type     = string
  nullable = false
}
variable "minio_root_password" {
  type      = string
  sensitive = true
  nullable  = false
}
variable "ingress_allow_ip_address_range" {
  type        = string
  description = "Range of IP addresses that can access the MinIO Container"
  nullable    = false
}
variable "vnet_cidr_range" {
  type        = string
  description = "CIDR Range to use for VNET creation. Example: 10.0.0.0/16"
  default     = "10.1.10.0/24"
}
variable "subnet_cidr_range" {
  type        = string
  description = "Subnet CIDR Range used for Container Application. Must be at minimum /23. Example: 10.0.0.0/23"
  default     = "10.1.10.64/27"
}
variable "ag_subnet_cidr_range" {
  type        = string
  description = "Subnet CIDR Range used for Application Gateway. Must be at minimum /23. Example: 10.0.10.0/23"
  default     = "10.1.10.0/26"
}
variable "storage_account_subnet_cidr_range" {
  type        = string
  description = "Subnet CIDR Range used for Application Gateway. Must be at minimum /23. Example: 10.0.10.0/23"
  default     = "10.1.10.96/27" # 10.1.10.96 - 10.1.10.127
}
variable "container_image" {
  type = string
  default     = "quay.io/minio/minio:RELEASE.2025-04-22T22-12-26Z"
  description = "Container Image used for building MinIO App. More recent versions have a limited UI."
}
variable "port_ui" {
  type        = string
  description = "Port for the UI"
  default     = "9001"
}
variable "port_api" {
  type        = string
  description = "Port for the API"
  default     = "9000"
}
variable "keyvault_name" {
  type    = string
  default = "miniokeyvault"
}
variable "kv_cert_name" {
  type    = string
  default = "minioapp.pfx"
}
variable "kv_cert_password" {
  type      = string
  sensitive = true
  nullable  = false
}