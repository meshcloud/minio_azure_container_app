variable "azure_subscription_id" {
  type = string
  nullable = false
}
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
variable "container_image" {
  type    = string
  default = "quay.io/minio/minio:RELEASE.2025-04-22T22-12-26Z"
  description = "Container Image used for building MinIO App. More recent versions have a limited UI."
}
variable "minio_root_user" {
  type    = string
  nullable = false
}
variable "minio_root_password" {
  type    = string
  # sensitive = true
  nullable = false
}
variable "ingress_allow_ip_address_range" {
  type    = string
  description = "Range of IP addresses that can access the MinIO Container"
  nullable = false
}
variable "vnet_cidr_range" {
  type    = string
  description = "CIDR Range to use for VNET creation. Example: 10.0.0.0/16"
  default = "10.0.0.0/16"
}
variable "subnet_cidr_range" {
  type    = string
  description = "Subnet CIDR Range used for Container Application. Must be at minimum /23. Example: 10.0.0.0/23"
  default = "10.0.0.0/23"
}
variable "ag_subnet_cidr_range" {
  type    = string
  description = "Subnet CIDR Range used for Application Gateway. Must be at minimum /23. Example: 10.0.10.0/23"
  default = "10.0.10.0/23"
}