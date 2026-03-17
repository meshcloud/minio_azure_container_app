output "nlb_public_ip" {
  value       = ionoscloud_ipblock.nlb.ips[0]
  description = "Public IP of the NLB — point DNS records here"
}

output "kubeconfig" {
  value       = data.ionoscloud_k8s_cluster.main.kube_config
  sensitive   = true
  description = "Kubeconfig for the K8s cluster (use: tofu output -raw kubeconfig > kubeconfig.yaml)"
}

output "k8s_cluster_id" {
  value       = ionoscloud_k8s_cluster.main.id
  description = "K8s cluster ID"
}

output "datacenter_id" {
  value       = data.ionoscloud_datacenter.main.id
  description = "Datacenter ID"
}

output "bunkerweb_cluster_ip" {
  value       = kubernetes_service_v1.bunkerweb_external.spec[0].cluster_ip
  description = "ClusterIP of the BunkerWeb external service (pass to seaweedfs-instance module)"
}

output "bunkerweb_ingress_class_name" {
  value       = "bunkerweb"
  description = "Ingress class name for the shared BunkerWeb deployment"
}

output "nlb_listener_lan_id" {
  value       = ionoscloud_lan.nlb_listener.id
  description = "NLB listener LAN ID (for firewall rules)"
}

output "nlb_name" {
  value       = ionoscloud_networkloadbalancer.main.name
  description = "NLB name"
}
