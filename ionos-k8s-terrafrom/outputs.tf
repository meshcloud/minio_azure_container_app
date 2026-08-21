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

# Scoped deployer credentials — pass these to ionos-seaweedfs-instance instead
# of the admin kubeconfig.
output "deployer_token" {
  value       = kubernetes_secret_v1.deployer_token.data["token"]
  sensitive   = true
  description = "Token of the scoped storage-deployer ServiceAccount — pass to ionos-seaweedfs-instance as deployer_token"
}

output "cluster_host" {
  value       = yamldecode(data.ionoscloud_k8s_cluster.main.kube_config).clusters[0].cluster.server
  description = "K8s API server URL — pass to ionos-seaweedfs-instance as cluster_host"
}

output "cluster_ca_certificate" {
  value       = yamldecode(data.ionoscloud_k8s_cluster.main.kube_config).clusters[0].cluster["certificate-authority-data"]
  sensitive   = true
  description = "Base64-encoded cluster CA — pass to ionos-seaweedfs-instance as cluster_ca"
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
