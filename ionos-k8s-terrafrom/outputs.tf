# Worker node IPs - point DNS A records to these
# With hostNetwork mode, BunkerWeb binds directly to ports 80/443 on these IPs
output "worker_node_ips" {
  value       = data.ionoscloud_k8s_node_pool_nodes.main.nodes[*].public_ip
  description = "Public IPs of worker nodes (point DNS A records to one or all of these)"
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

output "bunkerweb_ingress_class_name" {
  value       = "bunkerweb"
  description = "Ingress class name for the shared BunkerWeb deployment"
}
