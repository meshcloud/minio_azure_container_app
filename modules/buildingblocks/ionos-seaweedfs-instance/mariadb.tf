resource "kubernetes_persistent_volume_claim" "mariadb" {
  metadata {
    name      = "mariadb-data"
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  wait_until_bound = false

  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = var.storage_class_name

    resources {
      requests = {
        storage = var.mariadb_storage_size
      }
    }
  }
}

resource "kubernetes_deployment" "mariadb" {
  metadata {
    name      = "mariadb"
    namespace = kubernetes_namespace.this.metadata[0].name

    labels = {
      app = "mariadb"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "mariadb"
      }
    }

    strategy {
      type = "Recreate"
    }

    template {
      metadata {
        labels = {
          app = "mariadb"
        }
      }

      spec {
        container {
          name  = "mariadb"
          image = var.mariadb_image

          port {
            container_port = 3306
            protocol       = "TCP"
          }

          env {
            name  = "MARIADB_DATABASE"
            value = var.mariadb_database
          }

          env {
            name  = "MARIADB_USER"
            value = var.mariadb_user
          }

          env {
            name = "MARIADB_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.mariadb.metadata[0].name
                key  = "password"
              }
            }
          }

          env {
            name = "MARIADB_ROOT_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.mariadb.metadata[0].name
                key  = "root-password"
              }
            }
          }

          volume_mount {
            name       = "data"
            mount_path = "/var/lib/mysql"
          }

          liveness_probe {
            exec {
              command = ["/bin/sh", "-c", "mariadb -u root -p$MARIADB_ROOT_PASSWORD -e 'SELECT 1'"]
            }

            initial_delay_seconds = 30
            period_seconds        = 10
            timeout_seconds       = 5
            failure_threshold     = 3
          }

          readiness_probe {
            exec {
              command = ["/bin/sh", "-c", "mariadb -u root -p$MARIADB_ROOT_PASSWORD -e 'SELECT 1'"]
            }

            initial_delay_seconds = 10
            period_seconds        = 5
            timeout_seconds       = 3
            failure_threshold     = 3
          }
        }

        volume {
          name = "data"

          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.mariadb.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_secret" "mariadb" {
  metadata {
    name      = "mariadb-credentials"
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  data = {
    "password"      = random_password.mariadb_password.result
    "root-password" = random_password.mariadb_password.result
  }
}

resource "kubernetes_service" "mariadb" {
  metadata {
    name      = "mariadb"
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  spec {
    selector = {
      app = "mariadb"
    }

    port {
      port        = 3306
      target_port = 3306
      protocol    = "TCP"
    }
  }
}
