variable "az_kubeconfig_content" {
  type        = string
  sensitive   = true
  description = "Content of the AKS kubeconfig file. Get it with: terraform output -raw kubeconfig (from azure-infrastructure)"
}

variable "ionos_kubeconfig_content" {
  type        = string
  sensitive   = true
  description = "Content of the IONOS kubeconfig file (ionos_kubeconfig.yaml on the runner)"
}
