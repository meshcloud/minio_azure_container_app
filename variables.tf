variable "kubeconfig_path" {
  type        = string
  default     = "~/.kube/config"
  description = "Path to kubeconfig file"
}

variable "kubeconfig_context" {
  type        = string
  default     = "kind-seaweedfs"
  description = "Kubeconfig context to use"
}

variable "namespace" {
  type        = string
  default     = "default"
  description = "Kubernetes namespace for all resources"
}

variable "storage_class_name" {
  type        = string
  default     = "standard"
  description = "StorageClass for PVCs (kind uses 'standard' by default)"
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
  default     = "s3.localhost"
  description = "Domain for SeaweedFS S3 API"
}

variable "keycloak_domain" {
  type        = string
  default     = "auth.localhost"
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

variable "keycloak_admin_password" {
  type        = string
  sensitive   = true
  default     = "admin"
  description = "Keycloak admin password"
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

variable "keycloak_test_user_password" {
  type        = string
  sensitive   = true
  default     = "password"
  description = "Keycloak test user password"
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

variable "allowed_ip_addresses" {
  type        = string
  default     = "0.0.0.0/0"
  description = "Comma-separated CIDR list for BunkerWeb IP whitelist"
}

variable "bunkerweb_version" {
  type        = string
  default     = "1.0.13"
  description = "BunkerWeb Helm chart version"
}
