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
