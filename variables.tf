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
  description = "CIDR Range to use for VNET creation. Example: 10.1.10.0/24"
}
variable "subnet_cidr_range" {
  type        = string
  description = "Subnet CIDR Range used for Container Application. Example: 10.1.10.64/27"
}
variable "ag_subnet_cidr_range" {
  type        = string
  description = "Subnet CIDR Range used for Application Gateway. Example: 10.1.10.0/26"
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
variable "cert_name" {
  type    = string
}
variable "cert_password" {
  type      = string
  sensitive = true
  nullable  = false
}
variable "storage_share_size" {
  type = number
  description = "How much storage space do you need in GBs? Minimun size is 1GB and Maximum is 5120GB (5TB)"
}
variable "storage_account_name" {
  type = string
  description = "Storage Account Name. Must be globally unique across Azure Region. Suggest using Project Name"
}
variable "public_url_domain_name" {
  type = string
  description = "Domain Name to use for the public URL. Example: 'miniotest' would allow you to access MinIO from the URL 'https://miniotest.westeurope.cloudapp.azure.com'"
}