variable "dns_definition_version_uuid" {
  type        = string
  description = "UUID of the DNS building block definition version."
}

variable "dev_tenant_uuid" {
  type        = string
  description = "UUID of the dev meshTenant."
}

variable "prod_tenant_uuid" {
  type        = string
  description = "UUID of the prod meshTenant."
}

variable "name" {
  type        = string
  description = "Base name used for generating resource names."
}

variable "zone_name" {
  type        = string
  description = "DNS zone name."
  default     = "meshcloud.io"
}

variable "sub" {
  type        = string
  description = "DNS record subdomain."
}

variable "dns_record_type" {
  type        = string
  description = "DNS record type (A, CNAME, TXT)."
  default     = "A"
}

variable "ttl" {
  type        = string
  description = "DNS record TTL in seconds."
  default     = "300"
}
