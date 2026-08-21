provider "kubernetes" {
  host                   = local.use_token ? var.cluster_host : null
  cluster_ca_certificate = local.use_token ? base64decode(var.cluster_ca) : null
  token                  = local.use_token ? var.deployer_token : null

  config_path    = local.use_token ? null : local.config_path
  config_context = local.use_token ? null : local.config_context
}

provider "ionoscloud" {
  token = var.ionos_dns_token
}
