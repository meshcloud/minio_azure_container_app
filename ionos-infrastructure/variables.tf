variable "ionos_token" {
  type        = string
  sensitive   = true
  description = "IONOS Cloud API token (can also be set via IONOS_TOKEN env var)"
  default     = null
}

variable "location" {
  type        = string
  default     = "de/fra"
  description = "IONOS datacenter location"
}

variable "datacenter_name" {
  type        = string
  default     = "k8s-datacenter"
  description = "Name of the IONOS datacenter"
}

variable "k8s_cluster_name" {
  type        = string
  default     = "k8s-cluster"
  description = "Name of the K8s cluster"
}

variable "k8s_version" {
  type        = string
  default     = "1.31.2"
  description = "Kubernetes version"
}

variable "node_pool_name" {
  type        = string
  default     = "default-pool"
  description = "Name of the K8s node pool"
}

variable "node_count" {
  type        = number
  default     = 3
  description = "Number of worker nodes"
}

variable "cores_count" {
  type        = number
  default     = 2
  description = "CPU cores per node"
}

variable "ram_size" {
  type        = number
  default     = 8192
  description = "RAM per node in MB"
}

variable "storage_size" {
  type        = number
  default     = 50
  description = "Storage per node in GB"
}

variable "storage_type" {
  type        = string
  default     = "SSD"
  description = "Storage type (SSD or HDD)"
}

variable "cpu_family" {
  type        = string
  default     = "INTEL_SKYLAKE"
  description = "CPU family (INTEL_SKYLAKE, AMD_EPYC)"
}

variable "nodeport_http" {
  type        = number
  default     = 31063
  description = "NodePort for HTTP traffic (BunkerWeb)"
}

variable "nodeport_https" {
  type        = number
  default     = 31925
  description = "NodePort for HTTPS traffic (BunkerWeb)"
}

variable "health_check_interval" {
  type        = number
  default     = 2000
  description = "NLB health check interval in milliseconds"
}

variable "bunkerweb_version" {
  type        = string
  default     = "1.0.13"
  description = "BunkerWeb Helm chart version"
}

variable "bunkerweb_namespace" {
  type        = string
  default     = "bunkerweb"
  description = "Kubernetes namespace for the shared BunkerWeb deployment"
}

variable "bunkerweb_dns_resolvers" {
  type        = string
  default     = "coredns.kube-system.svc.cluster.local"
  description = "DNS resolver for BunkerWeb nginx"
}

variable "bunkerweb_storage_class_name" {
  type        = string
  default     = "ionos-enterprise-ssd"
  description = "StorageClass for BunkerWeb MariaDB and Redis PVCs"
}
