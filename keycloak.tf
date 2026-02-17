resource "kubernetes_config_map" "keycloak_realm" {
  metadata {
    name      = "keycloak-realm-config"
    namespace = var.namespace
  }

  data = {
    "realm-config.json" = templatefile("${path.module}/realm-config.json.tpl", {
      fqdn                 = var.keycloak_domain
      client_secret        = random_password.keycloak_client_secret.result
      test_user_username   = var.keycloak_test_user_username
      test_user_email      = var.keycloak_test_user_email
      test_user_password   = random_password.keycloak_test_user_password.result
      opkssh_redirect_uris = jsonencode(var.opkssh_redirect_uris)
    })
  }
}

resource "kubernetes_persistent_volume_claim" "keycloak" {
  metadata {
    name      = "keycloak-data"
    namespace = var.namespace
  }

  wait_until_bound = false

  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = var.storage_class_name

    resources {
      requests = {
        storage = var.keycloak_storage_size
      }
    }
  }
}

resource "kubernetes_deployment" "keycloak" {
  metadata {
    name      = "keycloak"
    namespace = var.namespace

    labels = {
      app = "keycloak"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "keycloak"
      }
    }

    strategy {
      type = "Recreate"
    }

    template {
      metadata {
        labels = {
          app = "keycloak"
        }
      }

      spec {
        init_container {
          name  = "wait-for-mariadb"
          image = "busybox:1.36"

          command = [
            "/bin/sh", "-c",
            "until nc -z mariadb.${var.namespace}.svc.cluster.local 3306; do echo 'Waiting for MariaDB...'; sleep 2; done"
          ]
        }

        init_container {
          name  = "copy-realm-config"
          image = "busybox:1.36"

          command = [
            "/bin/sh", "-c",
            "mkdir -p /data/import && cp /realm-config/*.json /data/import/"
          ]

          volume_mount {
            name       = "realm-config"
            mount_path = "/realm-config"
            read_only  = true
          }

          volume_mount {
            name       = "data"
            mount_path = "/data"
          }
        }

        container {
          name  = "keycloak"
          image = var.keycloak_image

          args = ["start", "--import-realm"]

          port {
            name           = "http"
            container_port = 8080
            protocol       = "TCP"
          }

          port {
            name           = "management"
            container_port = 9090
            protocol       = "TCP"
          }

          env {
            name  = "KC_BOOTSTRAP_ADMIN_USERNAME"
            value = var.keycloak_admin_user
          }

          env {
            name = "KC_BOOTSTRAP_ADMIN_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.keycloak.metadata[0].name
                key  = "admin-password"
              }
            }
          }

          env {
            name  = "KC_HTTP_ENABLED"
            value = "true"
          }

          env {
            name  = "KC_HOSTNAME"
            value = "http://${var.keycloak_domain}"
          }

          env {
            name  = "KC_HOSTNAME_BACKCHANNEL_DYNAMIC"
            value = "true"
          }

          env {
            name  = "KC_PROXY_HEADERS"
            value = "xforwarded"
          }

          env {
            name  = "KC_DB"
            value = "mariadb"
          }

          env {
            name  = "KC_DB_URL"
            value = "jdbc:mariadb://mariadb.${var.namespace}.svc.cluster.local:3306/${var.mariadb_database}"
          }

          env {
            name  = "KC_DB_USERNAME"
            value = var.mariadb_user
          }

          env {
            name = "KC_DB_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.mariadb.metadata[0].name
                key  = "password"
              }
            }
          }

          env {
            name  = "KC_HEALTH_ENABLED"
            value = "true"
          }

          env {
            name  = "KC_METRICS_ENABLED"
            value = "true"
          }

          env {
            name  = "KC_HTTP_MANAGEMENT_ENABLED"
            value = "true"
          }

          env {
            name  = "KC_HTTP_MANAGEMENT_PORT"
            value = "9090"
          }

          volume_mount {
            name       = "data"
            mount_path = "/opt/keycloak/data"
          }

          liveness_probe {
            http_get {
              path = "/health/live"
              port = 9090
            }

            initial_delay_seconds = 120
            period_seconds        = 30
            timeout_seconds       = 10
            failure_threshold     = 3
          }

          readiness_probe {
            http_get {
              path = "/health/ready"
              port = 9090
            }

            initial_delay_seconds = 60
            period_seconds        = 10
            timeout_seconds       = 5
            failure_threshold     = 3
          }
        }

        volume {
          name = "realm-config"

          config_map {
            name = kubernetes_config_map.keycloak_realm.metadata[0].name
          }
        }

        volume {
          name = "data"

          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.keycloak.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_secret" "keycloak" {
  metadata {
    name      = "keycloak-credentials"
    namespace = var.namespace
  }

  data = {
    "admin-password" = random_password.keycloak_admin_password.result
    "client-secret"  = random_password.keycloak_client_secret.result
  }
}

resource "kubernetes_service" "keycloak" {
  metadata {
    name      = "keycloak"
    namespace = var.namespace
  }

  spec {
    selector = {
      app = "keycloak"
    }

    port {
      name        = "http"
      port        = 8080
      target_port = 8080
      protocol    = "TCP"
    }

    port {
      name        = "management"
      port        = 9090
      target_port = 9090
      protocol    = "TCP"
    }
  }
}
