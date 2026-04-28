module "team_alpha" {
  source = "./modules/buildingblocks/seaweedfs-instance"

  namespace            = "seaweedfs"
  storage_class_name   = "ionos-enterprise-hdd"
  seaweedfs_domain     = "storage.flotest.ionos.msh.host"
  keycloak_domain      = "keycloak.flotest.ionos.msh.host"
  email_lets_encrypt   = "fnowarre@meshcloud.io"
  ingress_class_name   = "bunkerweb"
  bunkerweb_cluster_ip = "100.64.23.143"

  # DNS-01 challenge for IONOS ALB (no TLS passthrough)
  lets_encrypt_challenge    = "dns"
  lets_encrypt_dns_provider = "ionos"
  ionos_dns_api_prefix      = var.ionos_dns_api_prefix
  ionos_dns_api_secret      = var.ionos_dns_api_secret

  # Required but not used for single-platform deployment
  azure_config_path    = ""
  ionos_config_path    = ""
  azure_config_context = ""
  ionos_config_context = ""
  k8s_platform         = "ionos"
}

module "team_beta" {
  source = "./modules/buildingblocks/seaweedfs-instance"

  namespace            = "seaweedfs2"
  storage_class_name   = "ionos-enterprise-hdd"
  seaweedfs_domain     = "storage.flotest2.ionos.msh.host"
  keycloak_domain      = "keycloak.flotest2.ionos.msh.host"
  email_lets_encrypt   = "fnowarre@meshcloud.io"
  ingress_class_name   = "bunkerweb"
  bunkerweb_cluster_ip = "100.64.23.143"

  # DNS-01 challenge for IONOS ALB (no TLS passthrough)
  lets_encrypt_challenge    = "dns"
  lets_encrypt_dns_provider = "ionos"
  ionos_dns_api_prefix      = var.ionos_dns_api_prefix
  ionos_dns_api_secret      = var.ionos_dns_api_secret

  # Required but not used for single-platform deployment
  azure_config_path    = ""
  ionos_config_path    = ""
  azure_config_context = ""
  ionos_config_context = ""
  k8s_platform         = "ionos"
}
