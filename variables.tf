variable "kubeconfig_path" {
  type        = string
  default     = "~/.kube/config"
  description = "Path to kubeconfig file"
}

variable "kubeconfig_context" {
  type        = string
  default     = "test-aks"
  description = "Kubeconfig context to use"
}

variable "ionos_dns_api_prefix" {
  type        = string
  sensitive   = true
  description = "IONOS DNS API prefix for Let's Encrypt DNS-01 challenge"
}

variable "ionos_dns_api_secret" {
  type        = string
  sensitive   = true
  description = "IONOS DNS API secret for Let's Encrypt DNS-01 challenge"
}
