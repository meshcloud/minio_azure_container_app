output "lb_public_ip" {
  value       = azurerm_public_ip.lb.ip_address
  description = "Public IP of the Load Balancer — point DNS records here"
}

output "kubeconfig" {
  value       = azurerm_kubernetes_cluster.main.kube_config_raw
  sensitive   = true
  description = "Kubeconfig for the AKS cluster (use: terraform output -raw kubeconfig > kubeconfig.yaml)"
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
