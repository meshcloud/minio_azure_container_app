variable "namespace" {
  type        = string
  description = "Kubernetes namespace for all resources"
}

variable "storage_class_name" {
  type        = string
  default     = "standard"
  description = "StorageClass for PVCs"
}

variable "seaweedfs_storage_size" {
  type        = string
  default     = "10Gi"
  description = "PVC size for SeaweedFS data"
}

variable "mariadb_storage_size" {
  type        = string
  default     = "1Gi"
  description = "PVC size for MariaDB data"
}

variable "keycloak_storage_size" {
  type        = string
  default     = "1Gi"
  description = "PVC size for Keycloak data"
}

variable "seaweedfs_domain" {
  type        = string
  description = "Domain for SeaweedFS S3 API"
}

variable "keycloak_domain" {
  type        = string
  description = "Domain for Keycloak"
}

variable "seaweedfs_image" {
  type        = string
  default     = "chrislusf/seaweedfs:latest"
  description = "SeaweedFS container image"
}

variable "keycloak_image" {
  type        = string
  default     = "quay.io/keycloak/keycloak:latest"
  description = "Keycloak container image"
}

variable "mariadb_image" {
  type        = string
  default     = "mariadb:11"
  description = "MariaDB container image"
}

variable "mariadb_database" {
  type        = string
  default     = "keycloakdb"
  description = "MariaDB database name for Keycloak"
}

variable "mariadb_user" {
  type        = string
  default     = "keycloak"
  description = "MariaDB username"
}

variable "keycloak_admin_user" {
  type        = string
  default     = "admin"
  description = "Keycloak admin username"
}

variable "keycloak_test_user_username" {
  type        = string
  default     = "testuser"
  description = "Keycloak test user username"
}

variable "keycloak_test_user_email" {
  type        = string
  default     = "test@test.com"
  description = "Keycloak test user email"
}

variable "opkssh_redirect_uris" {
  type = list(string)
  default = [
    "http://localhost:3000/login-callback",
    "http://localhost:10001/login-callback",
    "http://localhost:11110/login-callback"
  ]
  description = "OpenPubkey SSH client redirect URIs"
}

variable "ingress_class_name" {
  type        = string
  default     = "bunkerweb"
  description = "Ingress class name to use for Ingress resources"
}

variable "bunkerweb_cluster_ip" {
  type        = string
  default     = null
  description = "ClusterIP of the BunkerWeb service (for SeaweedFS host_aliases to resolve domains internally)"
}

variable "email_lets_encrypt" {
  type        = string
  description = "Email address used for Let's Encrypt certificate notifications"
}

variable "allowed_ip_addresses" {
  type        = string
  default     = "0.0.0.0/0"
  description = "Comma-separated CIDR list for BunkerWeb IP whitelist"
}

variable "redirect_http_to_https" {
  type        = bool
  default     = true
  description = "Enable HTTP to HTTPS redirect. Set to false for Azure until Let's Encrypt certificates are obtained, then set to true."
}
