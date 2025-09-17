variable "resource_group_name" {
  type    = string
  description = "Name of the existing Resource Group where you want to deploy the MinIO Storage Bucket"
}
variable "location" {
  type    = string
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
  description = "Provide a list of IP CIDR ranges allowed to access the MinIO service. Use a semicolon (;) to separate multiple entries. Ex. 10.0.0.0/24;10.0.10.0/24;10.0.20.0/24"
  nullable    = false
  validation {
    condition = can(regex("^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\/(3[0-2]|[12]?[0-9])(;((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\/(3[0-2]|[12]?[0-9]))*$", var.ingress_allow_ip_address_range))
    error_message = "Incorrect format. Correct example: 10.0.0.0/24;10.0.10.0/24"
  }
}
variable "vnet_name" {
  type        = string
  description = "Name of the existing VNET where the application will run"
}
variable "subnet_cidr_range" {
  type        = string
  description = "Subnet CIDR Range that will be created for the Container Application"
}
variable "ag_subnet_cidr_range" {
  type        = string
  description = "Subnet CIDR Range that will be created for the Application Gateway"
}
variable "container_image" {
  type = string
  default     = "quay.io/minio/minio:RELEASE.2025-09-07T16-13-09Z"
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
  description = "MUST BE GLOBALLY UNIQUE ACROSS AZURE REGION. Suggest using Project Name"
}
variable "public_url_domain_name" {
  type = string
  description = "Domain Name to use for the public URL. Example: 'miniotest' would allow you to access MinIO from the URL 'https://miniotest.westeurope.cloudapp.azure.com'"
}