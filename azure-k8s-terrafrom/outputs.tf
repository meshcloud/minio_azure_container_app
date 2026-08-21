output "lb_public_ip" {
  value       = azurerm_public_ip.lb.ip_address
  description = "Public IP of the Load Balancer — point DNS records here"
}

# Scoped DNS Service Principal — pass to az-seaweedfs-instance for DNS management.
output "dns_sp_tenant_id" {
  value       = data.azurerm_client_config.current.tenant_id
  description = "Azure AD tenant ID — pass as azure_tenant_id"
}

output "dns_sp_subscription_id" {
  value       = data.azurerm_client_config.current.subscription_id
  description = "Subscription ID of the cluster — pass as azure_subscription_id"
}

output "dns_sp_client_id" {
  value       = azuread_application.dns.client_id
  description = "DNS Service Principal client ID — pass as azure_client_id"
}

output "dns_sp_client_secret" {
  value       = azuread_service_principal_password.dns.value
  sensitive   = true
  description = "DNS Service Principal client secret — pass as azure_client_secret"
}

output "kubeconfig" {
  value       = azurerm_kubernetes_cluster.main.kube_config_raw
  sensitive   = true
  description = "Kubeconfig for the AKS cluster (use: terraform output -raw kubeconfig > kubeconfig.yaml)"
}

# Scoped deployer credentials — pass these to az-seaweedfs-instance instead of
# the admin kubeconfig.
output "deployer_token" {
  value       = kubernetes_secret_v1.deployer_token.data["token"]
  sensitive   = true
  description = "Token of the scoped storage-deployer ServiceAccount — pass to az-seaweedfs-instance as deployer_token"
}

output "cluster_host" {
  value       = nonsensitive(azurerm_kubernetes_cluster.main.kube_config[0].host)
  description = "AKS API server URL — pass to az-seaweedfs-instance as cluster_host"
}

output "cluster_ca_certificate" {
  value       = azurerm_kubernetes_cluster.main.kube_config[0].cluster_ca_certificate
  sensitive   = true
  description = "Base64-encoded cluster CA — pass to az-seaweedfs-instance as cluster_ca"
}

output "aks_cluster_id" {
  value       = azurerm_kubernetes_cluster.main.id
  description = "AKS cluster ID"
}

output "resource_group_name" {
  value       = azurerm_resource_group.main.name
  description = "Resource group name"
}

output "bunkerweb_cluster_ip" {
  value       = kubernetes_service_v1.bunkerweb_external.spec[0].cluster_ip
  description = "ClusterIP of the BunkerWeb external service (pass to seaweedfs-instance module)"
}

output "bunkerweb_ingress_class_name" {
  value       = "bunkerweb"
  description = "Ingress class name for the shared BunkerWeb deployment"
}

output "dns_zone_name" {
  value       = azurerm_dns_zone.main.name
  description = "Azure DNS zone name — pass to az-seaweedfs-instance as dns_zone_name"
}

output "dns_zone_resource_group" {
  value       = azurerm_resource_group.main.name
  description = "Resource group of the Azure DNS zone — pass to az-seaweedfs-instance as dns_zone_resource_group"
}

output "azure_dns_nameservers" {
  value       = azurerm_dns_zone.main.name_servers
  description = "Add these as NS record values in Route53 for the delegated subdomain"
}
