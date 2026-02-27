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
