provider "ionoscloud" {
  token = var.ionos_token
}

provider "kubernetes" {
  host                   = yamldecode(data.ionoscloud_k8s_cluster.main.kube_config).clusters[0].cluster.server
  cluster_ca_certificate = base64decode(yamldecode(data.ionoscloud_k8s_cluster.main.kube_config).clusters[0].cluster["certificate-authority-data"])
  token                  = yamldecode(data.ionoscloud_k8s_cluster.main.kube_config).users[0].user.token
}

provider "helm" {
  kubernetes {
    host                   = yamldecode(data.ionoscloud_k8s_cluster.main.kube_config).clusters[0].cluster.server
    cluster_ca_certificate = base64decode(yamldecode(data.ionoscloud_k8s_cluster.main.kube_config).clusters[0].cluster["certificate-authority-data"])
    token                  = yamldecode(data.ionoscloud_k8s_cluster.main.kube_config).users[0].user.token
  }
}
