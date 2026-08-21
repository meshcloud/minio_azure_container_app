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

variable "kubeconfig_path" {
  type        = string
  default     = ""
  description = "Path to AKS kubeconfig file. Fallback auth used only when deployer_token is not set."
}

variable "kubeconfig_context" {
  type        = string
  default     = ""
  description = "Context name in the kubeconfig for the AKS cluster. Fallback auth used only when deployer_token is not set."
}

# Preferred, scoped auth: token of the storage-deployer ServiceAccount from the
# azure-k8s-terrafrom cluster bootstrap. When set, it takes precedence over the
# kubeconfig above.
variable "cluster_host" {
  type        = string
  default     = ""
  description = "AKS API server URL (from azure-k8s-terrafrom output cluster_host)."
}

variable "cluster_ca" {
  type        = string
  default     = ""
  description = "Base64-encoded cluster CA (from azure-k8s-terrafrom output cluster_ca_certificate)."
}

variable "deployer_token" {
  type        = string
  default     = ""
  sensitive   = true
  description = "Scoped storage-deployer ServiceAccount token (from azure-k8s-terrafrom output deployer_token)."
}

variable "seaweedfs_admin_access_key" {
  type        = string
  default     = "admin"
  description = "SeaweedFS admin access key for S3 API"
}

variable "lets_encrypt_challenge" {
  type        = string
  default     = "http"
  description = "Let's Encrypt challenge type: 'http' or 'dns'. Use 'dns' for IONOS ALB which doesn't support TLS passthrough."

  validation {
    condition     = contains(["http", "dns"], var.lets_encrypt_challenge)
    error_message = "lets_encrypt_challenge must be either 'http' or 'dns'."
  }
}

variable "lets_encrypt_dns_provider" {
  type        = string
  default     = ""
  description = "DNS provider for Let's Encrypt DNS-01 challenge (e.g., 'route53', 'azure', 'cloudflare'). Required when lets_encrypt_challenge is 'dns'."
}

variable "lets_encrypt_dns_credential_item" {
  type        = string
  default     = ""
  sensitive   = true
  description = "Credential item string passed to BunkerWeb for DNS-01 challenge (e.g. Route53 key/secret). Required when lets_encrypt_challenge is 'dns'."
}

variable "dns_zone_name" {
  type        = string
  description = "Azure DNS zone name (subdomain to delegate from Route53, e.g. 'azure.example.com')."
}

variable "dns_zone_resource_group" {
  type        = string
  description = "Resource group where the Azure DNS zone will be created."
}

variable "worker_node_ip" {
  type        = string
  default     = ""
  description = "AKS LoadBalancer public IP for DNS A records. Leave empty to skip A record creation."
}
