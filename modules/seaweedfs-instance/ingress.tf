resource "kubernetes_ingress_v1" "seaweedfs" {
  metadata {
    name      = "seaweedfs"
    namespace = var.namespace

    annotations = {
      "bunkerweb.io/USE_MODSECURITY"                = "yes"
      "bunkerweb.io/USE_LIMIT_REQ"                  = "no"
      "bunkerweb.io/USE_BAD_BEHAVIOR"               = "no"
      "bunkerweb.io/AUTO_LETS_ENCRYPT"              = "yes"
      "bunkerweb.io/EMAIL_LETS_ENCRYPT"             = var.email_lets_encrypt
      "bunkerweb.io/REDIRECT_HTTP_TO_HTTPS"         = "yes"
      "bunkerweb.io/INTERCEPTED_ERROR_CODES"        = ""
      "bunkerweb.io/REVERSE_PROXY_INTERCEPT_ERRORS" = "no"
      "bunkerweb.io/ALLOWED_METHODS"                = "GET|POST|PUT|DELETE|HEAD|OPTIONS"
    }
  }

  spec {
    ingress_class_name = var.ingress_class_name

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
}

resource "kubernetes_ingress_v1" "keycloak" {
  metadata {
    name      = "keycloak"
    namespace = var.namespace

    annotations = {
      "bunkerweb.io/USE_MODSECURITY"                = "yes"
      "bunkerweb.io/USE_ANTIBOT"                    = "no"
      "bunkerweb.io/USE_LIMIT_REQ"                  = "no"
      "bunkerweb.io/USE_BAD_BEHAVIOR"               = "no"
      "bunkerweb.io/AUTO_LETS_ENCRYPT"              = "yes"
      "bunkerweb.io/EMAIL_LETS_ENCRYPT"             = var.email_lets_encrypt
      "bunkerweb.io/REDIRECT_HTTP_TO_HTTPS"         = "yes"
      "bunkerweb.io/INTERCEPTED_ERROR_CODES"        = ""
      "bunkerweb.io/REVERSE_PROXY_INTERCEPT_ERRORS" = "no"
      "bunkerweb.io/COOKIE_AUTO_SECURE_FLAG"        = "no"
      "bunkerweb.io/COOKIE_FLAGS"                   = ""
      "bunkerweb.io/STRICT_TRANSPORT_SECURITY"      = "max-age=31536000"
      "bunkerweb.io/CONTENT_SECURITY_POLICY"        = ""
    }
  }

  spec {
    ingress_class_name = var.ingress_class_name

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
}

resource "kubernetes_config_map" "seaweedfs_modsec" {
  metadata {
    name      = "seaweedfs-modsec-crs"
    namespace = var.namespace

    annotations = {
      "bunkerweb.io/CONFIG_TYPE" = "modsec-crs"
      "bunkerweb.io/CONFIG_SITE" = var.seaweedfs_domain
    }
  }

  data = {
    "seaweedfs-exclusions.conf" = "SecRuleRemoveById 920340\nSecRuleRemoveById 920420\nSecRuleRemoveById 920450\nSecRuleRemoveById 920640"
  }
}

resource "kubernetes_config_map" "keycloak_modsec" {
  metadata {
    name      = "keycloak-modsec-crs"
    namespace = var.namespace

    annotations = {
      "bunkerweb.io/CONFIG_TYPE" = "modsec-crs"
      "bunkerweb.io/CONFIG_SITE" = var.keycloak_domain
    }
  }

  data = {
    "keycloak-exclusions.conf" = "SecRuleRemoveById 934100-934199\nSecRuleRemoveById 953100\nSecRuleRemoveById 959100"
  }
}
