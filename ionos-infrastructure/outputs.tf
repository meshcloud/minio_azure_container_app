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
  value       = ionoscloud_datacenter.main.id
  description = "Datacenter ID"
}


