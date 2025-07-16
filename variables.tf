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
  default = "usernamepat"
}
variable "minio_root_password" {
  type    = string
  default = "passwordpat"
}
variable "ingress_allow_ip_address_range" { # TODO: remove default value
  type    = string
  default = "79.207.219.193"
}
variable "blocked_ip_address" {
  type        = string
  default     = ""
  description = "The IP address to be blocked by the WAF custom rule."
}