provider "kubernetes" {
  config_path    = local.config_path
  config_context = local.config_context
}

provider "ionoscloud" {
  token = var.ionos_dns_token
}
