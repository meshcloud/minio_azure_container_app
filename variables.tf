variable "resource_group_name" {
  type    = string
  nullable = false
}
variable "location" {
  type    = list(string)
  default = ["West Europe", "North Europe", "Germany West Central", "Germany North"]
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
  sensitive = true
  nullable = false
}
variable "ingress_allow_ip_address_range" {
  type    = string
  description = "Range of IP addresses that can access the MinIO Container"
  nullable = false
}
variable "vnet_name" {
  type    = string
  description = "Name of the existing VNET to be used"
}
variable "subnet_name" {
  type    = string
  description = "Name of the existing Subnet to be used for the Azure Container App"
}
variable "ag_subnet_name" {
  type    = string
  description = "Name of the existing Subnet to be used for the Application Gateway"
}