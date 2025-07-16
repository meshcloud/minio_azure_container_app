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
}
variable "minio_root_user" {
  type    = string
}
variable "minio_root_password" {
  type    = string
}
variable "ingress_allow_ip_address_range" {
  type    = string
}
variable "vnet_cidr_range" {
  type    = string
  default = "10.0.0.0/16"
}
variable "subnet_cidr_range" {
  type    = string
  default = "10.0.0.0/23"
}
variable "ag_subnet_cidr_range" {
  type    = string
  default = "10.0.10.0/23"
}