run "plan_local_deployment" {
  command = plan

  variables {
    kubeconfig_path    = "~/.kube/config"
    kubeconfig_context = "kind-seaweedfs"
  }

  assert {
    condition     = kubernetes_deployment.mariadb.metadata[0].name == "mariadb"
    error_message = "MariaDB deployment should be named 'mariadb'"
  }

  assert {
    condition     = kubernetes_deployment.keycloak.metadata[0].name == "keycloak"
    error_message = "Keycloak deployment should be named 'keycloak'"
  }

  assert {
    condition     = kubernetes_deployment.seaweedfs.metadata[0].name == "seaweedfs"
    error_message = "SeaweedFS deployment should be named 'seaweedfs'"
  }

  assert {
    condition     = kubernetes_service.mariadb.spec[0].port[0].port == 3306
    error_message = "MariaDB service should expose port 3306"
  }

  assert {
    condition     = kubernetes_service.seaweedfs_s3.spec[0].port[0].port == 8333
    error_message = "SeaweedFS S3 service should expose port 8333"
  }

  assert {
    condition     = kubernetes_service.keycloak.spec[0].port[0].port == 8080
    error_message = "Keycloak service should expose port 8080"
  }

  assert {
    condition     = kubernetes_ingress_v1.seaweedfs.spec[0].ingress_class_name == "bunkerweb"
    error_message = "SeaweedFS ingress should use bunkerweb ingress class"
  }

  assert {
    condition     = kubernetes_ingress_v1.keycloak.spec[0].ingress_class_name == "bunkerweb"
    error_message = "Keycloak ingress should use bunkerweb ingress class"
  }

  assert {
    condition     = output.s3_api_url == "http://s3.localhost"
    error_message = "S3 API URL should default to http://s3.localhost"
  }

  assert {
    condition     = output.keycloak_url == "http://auth.localhost"
    error_message = "Keycloak URL should default to http://auth.localhost"
  }
}
