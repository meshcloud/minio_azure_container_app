run "plan_deployment" {
  command = plan

  variables {
    kubeconfig_path    = "~/.kube/config"
    kubeconfig_context = "kind-seaweedfs"
  }

  assert {
    condition     = module.team_alpha.kubernetes_deployment.mariadb.metadata[0].name == "mariadb"
    error_message = "Team Alpha: MariaDB deployment should be named 'mariadb'"
  }

  assert {
    condition     = module.team_alpha.kubernetes_deployment.keycloak.metadata[0].name == "keycloak"
    error_message = "Team Alpha: Keycloak deployment should be named 'keycloak'"
  }

  assert {
    condition     = module.team_alpha.kubernetes_deployment.seaweedfs.metadata[0].name == "seaweedfs"
    error_message = "Team Alpha: SeaweedFS deployment should be named 'seaweedfs'"
  }

  assert {
    condition     = module.team_alpha.kubernetes_service.mariadb.spec[0].port[0].port == 3306
    error_message = "Team Alpha: MariaDB service should expose port 3306"
  }

  assert {
    condition     = module.team_alpha.kubernetes_service.seaweedfs_s3.spec[0].port[0].port == 8333
    error_message = "Team Alpha: SeaweedFS S3 service should expose port 8333"
  }

  assert {
    condition     = module.team_alpha.kubernetes_service.keycloak.spec[0].port[0].port == 8080
    error_message = "Team Alpha: Keycloak service should expose port 8080"
  }

  assert {
    condition     = module.team_alpha.kubernetes_ingress_v1.seaweedfs.spec[0].ingress_class_name == "bunkerweb"
    error_message = "Team Alpha: SeaweedFS ingress should use bunkerweb ingress class"
  }

  assert {
    condition     = module.team_alpha.kubernetes_ingress_v1.keycloak.spec[0].ingress_class_name == "bunkerweb"
    error_message = "Team Alpha: Keycloak ingress should use bunkerweb ingress class"
  }

  assert {
    condition     = output.team_alpha_s3_api_url == "https://seaweedfs.ionos.meshcloud.io"
    error_message = "Team Alpha: S3 API URL should be https://seaweedfs.ionos.meshcloud.io"
  }

  assert {
    condition     = output.team_alpha_keycloak_url == "https://keycloak.ionos.meshcloud.io"
    error_message = "Team Alpha: Keycloak URL should be https://keycloak.ionos.meshcloud.io"
  }

  assert {
    condition     = output.team_beta_s3_api_url == "https://seaweedfs2.ionos.meshcloud.io"
    error_message = "Team Beta: S3 API URL should be https://seaweedfs2.ionos.meshcloud.io"
  }

  assert {
    condition     = output.team_beta_keycloak_url == "https://keycloak2.ionos.meshcloud.io"
    error_message = "Team Beta: Keycloak URL should be https://keycloak2.ionos.meshcloud.io"
  }
}
