resource "kubernetes_secret" "seaweedfs_identity" {
  metadata {
    name      = "seaweedfs-identity-config"
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  data = {
    "identity.json" = jsonencode({
      identities = [{
        name = "admin"
        credentials = [{
          accessKey = var.seaweedfs_admin_access_key
          secretKey = random_password.seaweedfs_admin_secret.result
        }]
        actions = ["Admin", "Read", "Write", "List", "Tagging"]
      }]
    })
  }
}

resource "kubernetes_secret" "seaweedfs_iam" {
  metadata {
    name      = "seaweedfs-iam-config"
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  data = {
    "oidc.json" = jsonencode({
      sts = {
        enabled          = true
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
          issuer      = "https://${ionoscloud_dns_record.keycloak[0].fqdn}/realms/seaweedfs"
          clientId    = "seaweedfs-s3"
          jwksUri     = "http://keycloak.${var.namespace}.svc.cluster.local:8080/realms/seaweedfs/protocol/openid-connect/certs"
          userInfoUri = "http://keycloak.${var.namespace}.svc.cluster.local:8080/realms/seaweedfs/protocol/openid-connect/userinfo"
          scopes      = ["openid", "profile", "email", "roles", "groups"]
          roleMapping = {
            rules = [
              { claim = "roles", value = "customer-1", role = "arn:aws:iam::role/Airliner1Role" },
              { claim = "roles", value = "customer-2", role = "arn:aws:iam::role/Airliner2Role" }
            ]
          }
        }
      }]
      policies = [
        {
          name = "Airliner1Policy"
          document = {
            Version = "2012-10-17"
            Statement = [{
              Sid      = "AllowBucketRootListing"
              Effect   = "Allow"
              Action   = ["s3:*"]
              Resource = ["arn:aws:s3:::airliner-1", "arn:aws:s3:::airliner-1/*"]
            }]
          }
        },
        {
          name = "Airliner2Policy"
          document = {
            Version = "2012-10-17"
            Statement = [{
              Sid      = "AllowBucketRootListing"
              Effect   = "Allow"
              Action   = ["s3:*"]
              Resource = ["arn:aws:s3:::airliner-2", "arn:aws:s3:::airliner-2/*"]
            }]
          }
        }
      ]
      roles = [
        {
          roleName         = "Airliner1Role"
          roleArn          = "arn:aws:iam::role/Airliner1Role"
          attachedPolicies = ["Airliner1Policy"]
          trustPolicy = {
            Version = "2012-10-17"
            Statement = [{
              Effect    = "Allow"
              Principal = { Federated = "keycloak" }
              Action    = ["sts:AssumeRoleWithWebIdentity"]
              Condition = {
                StringEquals = {
                  "oidc:iss"   = "https://${ionoscloud_dns_record.keycloak[0].fqdn}/realms/seaweedfs"
                  "oidc:roles" = "customer-1"
                  "oidc:aud"   = "seaweedfs-s3"
                }
              }
            }]
          }
        },
        {
          roleName         = "Airliner2Role"
          roleArn          = "arn:aws:iam::role/Airliner2Role"
          attachedPolicies = ["Airliner2Policy"]
          trustPolicy = {
            Version = "2012-10-17"
            Statement = [{
              Effect    = "Allow"
              Principal = { Federated = "keycloak" }
              Action    = ["sts:AssumeRoleWithWebIdentity"]
              Condition = {
                StringEquals = {
                  "oidc:iss"   = "https://${ionoscloud_dns_record.keycloak[0].fqdn}/realms/seaweedfs"
                  "oidc:roles" = "customer-2"
                  "oidc:aud"   = "seaweedfs-s3"
                }
              }
            }]
          }
        },
        {
          roleName = "dummy"
          trustPolicy = {
            Version = "2012-10-17"
            Statement = [{
              Effect    = "Allow"
              Principal = { Federated = "keycloak" }
              Action    = ["sts:AssumeRoleWithWebIdentity"]
              Condition = {
                StringEquals = {
                  "oidc:iss" = "https://${ionoscloud_dns_record.keycloak[0].fqdn}/realms/seaweedfs"
                  "oidc:aud" = "seaweedfs-s3"
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
    namespace = kubernetes_namespace.this.metadata[0].name
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
    namespace = kubernetes_namespace.this.metadata[0].name

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

        dynamic "host_aliases" {
          for_each = var.bunkerweb_cluster_ip != null ? [1] : []
          content {
            ip        = var.bunkerweb_cluster_ip
            hostnames = [ionoscloud_dns_record.keycloak[0].fqdn, ionoscloud_dns_record.seaweedfs[0].fqdn]
          }
        }

        container {
          name  = "seaweedfs"
          image = var.seaweedfs_image

          args = [
            "server",
            "-s3",
            "-s3.port=8333",
            "-dir=/data",
            "-s3.config=/etc/seaweed/identity/identity.json",
            "-s3.iam.config=/etc/seaweed/iam/oidc.json",
            "-volume.max=50",
            "-master.volumeSizeLimitMB=1000"
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
            name       = "identity-config"
            mount_path = "/etc/seaweed/identity"
            read_only  = true
          }

          volume_mount {
            name       = "iam-config"
            mount_path = "/etc/seaweed/iam"
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
          name = "identity-config"

          secret {
            secret_name = kubernetes_secret.seaweedfs_identity.metadata[0].name
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
    namespace = kubernetes_namespace.this.metadata[0].name
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
    namespace = kubernetes_namespace.this.metadata[0].name
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
