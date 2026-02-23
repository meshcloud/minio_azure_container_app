resource "helm_release" "bunkerweb" {
  name             = "bunkerweb-${var.namespace}"
  repository       = "https://repo.bunkerweb.io/charts"
  chart            = "bunkerweb"
  version          = var.bunkerweb_version
  namespace        = var.namespace
  create_namespace = false
  wait             = true
  timeout          = 600

  values = [yamlencode({
    service = {
      enabled = false
    }

    bunkerweb = {
      kind     = "Deployment"
      replicas = 1

      pdb = {
        create = false
      }
    }

    settings = {
      kubernetes = {
        ingressClass = "bunkerweb"
      }

      misc = {
        dnsResolvers   = var.bunkerweb_dns_resolvers
        apiWhitelistIp = "127.0.0.0/8 10.0.0.0/8 172.16.0.0/12 192.168.0.0/16 100.64.0.0/10"
      }

      ui = {
        wizard = false
      }
    }

    ingressClass = {
      enabled    = true
      name       = "bunkerweb-${var.namespace}"
      controller = "bunkerweb.io/ingress-controller"
    }

    controller = {
      enabled = true
    }

    ui = {
      enabled = false
    }

    api = {
      enabled = false
    }

    mariadb = {
      enabled = true

      persistence = {
        storageClass = var.storage_class_name
      }
    }

    redis = {
      enabled = true

      persistence = {
        storageClass = var.storage_class_name
      }
    }

    prometheus = {
      enabled = false
    }

    grafana = {
      enabled = false
    }
  })]
}

resource "kubernetes_service_v1" "bunkerweb_external" {
  metadata {
    name      = "bunkerweb-${var.namespace}"
    namespace = var.namespace

    labels = {
      "app.kubernetes.io/name"     = "bunkerweb"
      "app.kubernetes.io/instance" = "bunkerweb"
    }
  }

  spec {
    type                    = var.bunkerweb_service_type
    external_traffic_policy = var.bunkerweb_service_type == "ClusterIP" ? null : "Local"

    selector = {
      "bunkerweb.io/component" = "bunkerweb"
    }

    port {
      name        = "http"
      port        = 80
      target_port = 8080
      protocol    = "TCP"
      node_port   = var.bunkerweb_nodeport_http
    }

    port {
      name        = "https"
      port        = 443
      target_port = 8443
      protocol    = "TCP"
      node_port   = var.bunkerweb_nodeport_https
    }
  }

  depends_on = [helm_release.bunkerweb]
}
