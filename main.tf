module "team_alpha" {
  source = "./modules/seaweedfs-instance"

  namespace            = "seaweedfs"
  storage_class_name   = "ionos-enterprise-hdd"
  seaweedfs_domain     = "seaweedfs.ionos.meshcloud.io"
  keycloak_domain      = "keycloak.ionos.meshcloud.io"
  email_lets_encrypt   = "fnowarre@meshcloud.io"
  ingress_class_name   = "bunkerweb"
  bunkerweb_cluster_ip = "100.64.23.143"
}

module "team_beta" {
  source = "./modules/seaweedfs-instance"

  namespace            = "seaweedfs2"
  storage_class_name   = "ionos-enterprise-hdd"
  seaweedfs_domain     = "seaweedfs2.ionos.meshcloud.io"
  keycloak_domain      = "keycloak2.ionos.meshcloud.io"
  email_lets_encrypt   = "fnowarre@meshcloud.io"
  ingress_class_name   = "bunkerweb"
  bunkerweb_cluster_ip = "100.64.23.143"
}
