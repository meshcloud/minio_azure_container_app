module "seaweedfs" {
  source = "./modules/seaweedfs-instance"

  namespace              = var.namespace
  storage_class_name     = var.storage_class_name
  seaweedfs_storage_size = var.seaweedfs_storage_size
  mariadb_storage_size   = var.mariadb_storage_size
  keycloak_storage_size  = var.keycloak_storage_size
  seaweedfs_domain       = var.seaweedfs_domain
  keycloak_domain        = var.keycloak_domain
  seaweedfs_image        = var.seaweedfs_image
  keycloak_image         = var.keycloak_image
  mariadb_image          = var.mariadb_image
  mariadb_database       = var.mariadb_database
  mariadb_user           = var.mariadb_user
  keycloak_admin_user    = var.keycloak_admin_user
  email_lets_encrypt     = var.email_lets_encrypt
  allowed_ip_addresses   = var.allowed_ip_addresses
  ingress_class_name     = "bunkerweb-${var.namespace}"
  bunkerweb_cluster_ip   = kubernetes_service_v1.bunkerweb_external.spec[0].cluster_ip

  keycloak_test_user_username = var.keycloak_test_user_username
  keycloak_test_user_email    = var.keycloak_test_user_email
  opkssh_redirect_uris        = var.opkssh_redirect_uris
}
