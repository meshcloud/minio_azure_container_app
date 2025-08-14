variable "azure_subscription_id" {
  type     = string
  nullable = false
  default  = "47e5c076-f337-4f41-8408-d9a3b7cfae69"
}
variable "resource_group_name" {
  type    = string
  default = "minio-rgg"
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
  default  = "usernamepat"
}
variable "minio_root_password" {
  type      = string
  sensitive = true
  nullable  = false
  default   = "passwordpat"
}
variable "ingress_allow_ip_address_range" {
  type        = string
  description = "Range of IP addresses that can access the MinIO Container"
  nullable    = false
  default     = "79.207.212.183"
}
variable "vnet_cidr_range" {
  type        = string
  description = "CIDR Range to use for VNET creation. Example: 10.0.0.0/16"
  default     = "10.0.0.0/16"
}
variable "subnet_cidr_range" {
  type        = string
  description = "Subnet CIDR Range used for Container Application. Must be at minimum /23. Example: 10.0.0.0/23"
  default     = "10.0.0.0/23"
}
variable "ag_subnet_cidr_range" {
  type        = string
  description = "Subnet CIDR Range used for Application Gateway. Must be at minimum /23. Example: 10.0.10.0/23"
  default     = "10.0.10.0/23"
}
variable "container_image" {
  type        = string
  default     = "docker.io/pmooremeshcloud/minio_image:v1"
  # default     = "minioimage.azurecr.io/minioimage:v1"
  description = "Container Image used for building MinIO App. More recent versions have a limited UI."
}
variable "port_ui" {
  type = string
  description = "Port for the UI"
  default = "9001"
}
variable "port_api" {
  type = string
  description = "Port for the API"
  default = "9000"
}