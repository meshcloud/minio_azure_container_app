resource "kubernetes_secret" "seaweedfs_iam" {
  metadata {
    name      = "seaweedfs-iam-config"
    namespace = var.namespace
  }

  data = {
    "iam.json" = jsonencode({
      sts = {
        tokenDuration    = "1h"
        maxSessionLength = "12h"
        issuer           = "seaweedfs-sts"
        signingKey       = base64encode(random_password.seaweedfs_sts_signing_key.result)
      }
      providers = [{
        name    = "keycloak"
        type    = "oidc"
        enabled = true
        config = {
          issuer      = "https://${var.keycloak_domain}/realms/seaweedfs"
          clientId    = "seaweedfs-client"
          jwksUri     = "http://keycloak.${var.namespace}.svc.cluster.local:8080/realms/seaweedfs/protocol/openid-connect/certs"
          userInfoUri = "http://keycloak.${var.namespace}.svc.cluster.local:8080/realms/seaweedfs/protocol/openid-connect/userinfo"
          scopes      = ["openid", "profile", "email"]
          roleMapping = {
            rules = [
              { claim = "groups", value = "admins", role = "arn:aws:iam::role/S3AdminRole" },
              { claim = "groups", value = "developers", role = "arn:aws:iam::role/S3WriteRole" }
            ]
            defaultRole = "arn:aws:iam::role/S3ReadOnlyRole"
          }
        }
      }]
      policies = [
        {
          name = "S3ReadOnlyPolicy"
          document = {
            Version = "2012-10-17"
            Statement = [{
              Effect   = "Allow"
              Action   = ["s3:List*", "s3:Get*"]
              Resource = ["*"]
            }]
          }
        },
        {
          name = "S3WritePolicy"
          document = {
            Version = "2012-10-17"
            Statement = [{
              Effect   = "Allow"
              Action   = ["s3:List*", "s3:Get*", "s3:Put*", "s3:Delete*", "s3:CreateBucket"]
              Resource = ["*"]
            }]
          }
        },
        {
          name = "S3AdminPolicy"
          document = {
            Version = "2012-10-17"
            Statement = [{
              Effect   = "Allow"
              Action   = ["s3:*"]
              Resource = ["*"]
            }]
          }
        }
      ]
      roles = [
        {
          roleName         = "S3ReadOnlyRole"
          roleArn          = "arn:aws:iam::role/S3ReadOnlyRole"
          attachedPolicies = ["S3ReadOnlyPolicy"]
          trustPolicy = {
            Version = "2012-10-17"
            Statement = [{
              Effect    = "Allow"
              Principal = { Federated = "*" }
              Action    = ["sts:AssumeRoleWithWebIdentity"]
              Condition = {
                StringEquals = {
                  "seaweed:Issuer" = "https://${var.keycloak_domain}/realms/seaweedfs"
                }
              }
            }]
          }
        },
        {
          roleName         = "S3WriteRole"
          roleArn          = "arn:aws:iam::role/S3WriteRole"
          attachedPolicies = ["S3WritePolicy"]
          trustPolicy = {
            Version = "2012-10-17"
            Statement = [{
              Effect    = "Allow"
              Principal = { Federated = "*" }
              Action    = ["sts:AssumeRoleWithWebIdentity"]
              Condition = {
                StringEquals = {
                  "seaweed:Issuer" = "https://${var.keycloak_domain}/realms/seaweedfs"
                }
              }
            }]
          }
        },
        {
          roleName         = "S3AdminRole"
          roleArn          = "arn:aws:iam::role/S3AdminRole"
          attachedPolicies = ["S3AdminPolicy"]
          trustPolicy = {
            Version = "2012-10-17"
            Statement = [{
              Effect    = "Allow"
              Principal = { Federated = "*" }
              Action    = ["sts:AssumeRoleWithWebIdentity"]
              Condition = {
                StringEquals = {
                  "seaweed:Issuer" = "https://${var.keycloak_domain}/realms/seaweedfs"
                }
              }
            }]
          }
        }
      ]
    })
  }
}

resource "kubernetes_persistent_volume_claim" "seaweedfs" {
  metadata {
    name      = "seaweedfs-data"
    namespace = var.namespace
  }

  wait_until_bound = false

  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = var.storage_class_name

    resources {
      requests = {
        storage = var.seaweedfs_storage_size
      }
    }
  }
}

resource "kubernetes_deployment" "seaweedfs" {
  metadata {
    name      = "seaweedfs"
    namespace = var.namespace

    labels = {
      app = "seaweedfs"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "seaweedfs"
      }
    }

    strategy {
      type = "Recreate"
    }

    template {
      metadata {
        labels = {
          app = "seaweedfs"
        }
      }

      spec {
        init_container {
          name  = "wait-for-keycloak"
          image = "busybox:1.36"

          command = [
            "/bin/sh", "-c",
            "until nc -z keycloak.${var.namespace}.svc.cluster.local 8080; do echo 'Waiting for Keycloak...'; sleep 2; done"
          ]
        }

        host_aliases {
          ip        = kubernetes_service_v1.bunkerweb_external.spec[0].cluster_ip
          hostnames = [var.keycloak_domain, var.seaweedfs_domain]
        }

        container {
          name  = "seaweedfs"
          image = var.seaweedfs_image

          args = [
            "server",
            "-s3",
            "-s3.port=8333",
            "-dir=/data",
            "-iam.config=/etc/seaweed/iam.json"
          ]

          port {
            name           = "s3"
            container_port = 8333
            protocol       = "TCP"
          }

          port {
            name           = "master"
            container_port = 9333
            protocol       = "TCP"
          }

          port {
            name           = "filer"
            container_port = 8888
            protocol       = "TCP"
          }

          volume_mount {
            name       = "data"
            mount_path = "/data"
          }

          volume_mount {
            name       = "iam-config"
            mount_path = "/etc/seaweed"
            read_only  = true
          }

          liveness_probe {
            http_get {
              path = "/cluster/status"
              port = 9333
            }

            initial_delay_seconds = 30
            period_seconds        = 10
            timeout_seconds       = 5
            failure_threshold     = 3
          }

          readiness_probe {
            tcp_socket {
              port = 8333
            }

            initial_delay_seconds = 15
            period_seconds        = 5
            timeout_seconds       = 3
            failure_threshold     = 3
          }
        }

        volume {
          name = "data"

          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.seaweedfs.metadata[0].name
          }
        }

        volume {
          name = "iam-config"

          secret {
            secret_name = kubernetes_secret.seaweedfs_iam.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "seaweedfs_s3" {
  metadata {
    name      = "seaweedfs-s3"
    namespace = var.namespace
  }

  spec {
    selector = {
      app = "seaweedfs"
    }

    port {
      name        = "s3"
      port        = 8333
      target_port = 8333
      protocol    = "TCP"
    }
  }
}

resource "kubernetes_service" "seaweedfs_master" {
  metadata {
    name      = "seaweedfs-master"
    namespace = var.namespace
  }

  spec {
    selector = {
      app = "seaweedfs"
    }

    port {
      name        = "master"
      port        = 9333
      target_port = 9333
      protocol    = "TCP"
    }
  }
}
