variable "location" {
  type        = string
  default     = "westeurope"
  description = "Azure region"
}

variable "resource_group_name" {
  type        = string
  default     = "aks-cluster-rg"
  description = "Name of the Azure resource group"
}

variable "aks_cluster_name" {
  type        = string
  default     = "aks-cluster"
  description = "Name of the AKS cluster"
}

variable "k8s_version" {
  type        = string
  default     = "1.35.6"
  description = "Kubernetes version"
}

variable "node_pool_name" {
  type        = string
  default     = "default"
  description = "Name of the AKS node pool"
}

variable "node_count" {
  type        = number
  default     = 3
  description = "Number of worker nodes"
}

variable "vm_size" {
  type        = string
  default     = "Standard_D2s_v3"
  description = "Azure VM size for nodes (Standard_D2s_v3, Standard_D2s_v4, etc.)"
}

variable "storage_size" {
  type        = number
  default     = 50
  description = "OS disk size per node in GB"
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
  default     = "10.1.0.10"
  description = "DNS resolver for BunkerWeb nginx (CoreDNS service IP from service_cidr)"
}

variable "bunkerweb_storage_class_name" {
  type        = string
  default     = "managed-csi"
  description = "StorageClass for BunkerWeb MariaDB and Redis PVCs (managed-csi = Azure Disk)"
}

variable "dns_zone_name" {
  type        = string
  description = "Azure DNS zone name for the subdomain delegated from Route53 (e.g. 'azure.msh.host')"
}
