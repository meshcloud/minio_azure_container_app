run "plan_local_deployment" {
  command = plan

  variables {
    kubeconfig_path    = "~/.kube/config"
    kubeconfig_context = "kind-seaweedfs"
    email_lets_encrypt = "test@example.com"
  }

  assert {
    condition     = module.seaweedfs.kubernetes_deployment.mariadb.metadata[0].name == "mariadb"
    error_message = "MariaDB deployment should be named 'mariadb'"
  }

  assert {
    condition     = module.seaweedfs.kubernetes_deployment.keycloak.metadata[0].name == "keycloak"
    error_message = "Keycloak deployment should be named 'keycloak'"
  }

  assert {
    condition     = module.seaweedfs.kubernetes_deployment.seaweedfs.metadata[0].name == "seaweedfs"
    error_message = "SeaweedFS deployment should be named 'seaweedfs'"
  }

  assert {
    condition     = module.seaweedfs.kubernetes_service.mariadb.spec[0].port[0].port == 3306
    error_message = "MariaDB service should expose port 3306"
  }

  assert {
    condition     = module.seaweedfs.kubernetes_service.seaweedfs_s3.spec[0].port[0].port == 8333
    error_message = "SeaweedFS S3 service should expose port 8333"
  }

  assert {
    condition     = module.seaweedfs.kubernetes_service.keycloak.spec[0].port[0].port == 8080
    error_message = "Keycloak service should expose port 8080"
  }

  assert {
    condition     = module.seaweedfs.kubernetes_ingress_v1.seaweedfs.spec[0].ingress_class_name == "bunkerweb-default"
    error_message = "SeaweedFS ingress should use bunkerweb-default ingress class"
  }

  assert {
    condition     = module.seaweedfs.kubernetes_ingress_v1.keycloak.spec[0].ingress_class_name == "bunkerweb-default"
    error_message = "Keycloak ingress should use bunkerweb-default ingress class"
  }

  assert {
    condition     = output.s3_api_url == "https://s3.localhost"
    error_message = "S3 API URL should default to https://s3.localhost"
  }

  assert {
    condition     = output.keycloak_url == "https://auth.localhost"
    error_message = "Keycloak URL should default to https://auth.localhost"
  }
}
