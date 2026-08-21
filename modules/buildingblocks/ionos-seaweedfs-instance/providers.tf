provider "kubernetes" {
  host                   = var.cluster_host
  cluster_ca_certificate = base64decode(var.cluster_ca)
  token                  = var.deployer_token
}

provider "ionoscloud" {
  token = var.ionos_dns_token
}
