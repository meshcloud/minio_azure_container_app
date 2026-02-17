resource "kubernetes_ingress_v1" "seaweedfs" {
  metadata {
    name      = "seaweedfs"
    namespace = var.namespace

    annotations = {
      "bunkerweb.io/USE_MODSECURITY"                = "yes"
      "bunkerweb.io/USE_LIMIT_REQ"                  = "no"
      "bunkerweb.io/USE_BAD_BEHAVIOR"               = "no"
      "bunkerweb.io/REDIRECT_HTTP_TO_HTTPS"         = "no"
      "bunkerweb.io/INTERCEPTED_ERROR_CODES"        = ""
      "bunkerweb.io/REVERSE_PROXY_INTERCEPT_ERRORS" = "no"
      "bunkerweb.io/ALLOWED_METHODS"                = "GET|POST|PUT|DELETE|HEAD|OPTIONS"
    }
  }

  spec {
    ingress_class_name = "bunkerweb"

    rule {
      host = var.seaweedfs_domain

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service.seaweedfs_s3.metadata[0].name

              port {
                number = 8333
              }
            }
          }
        }
      }
    }
  }

  depends_on = [helm_release.bunkerweb]
}

resource "kubernetes_ingress_v1" "keycloak" {
  metadata {
    name      = "keycloak"
    namespace = var.namespace

    annotations = {
      "bunkerweb.io/USE_MODSECURITY"                = "yes"
      "bunkerweb.io/USE_ANTIBOT"                    = "no"
      "bunkerweb.io/USE_BAD_BEHAVIOR"               = "no"
      "bunkerweb.io/REDIRECT_HTTP_TO_HTTPS"         = "no"
      "bunkerweb.io/INTERCEPTED_ERROR_CODES"        = ""
      "bunkerweb.io/REVERSE_PROXY_INTERCEPT_ERRORS" = "no"
    }
  }

  spec {
    ingress_class_name = "bunkerweb"

    rule {
      host = var.keycloak_domain

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service.keycloak.metadata[0].name

              port {
                number = 8080
              }
            }
          }
        }
      }
    }
  }

  depends_on = [helm_release.bunkerweb]
}
