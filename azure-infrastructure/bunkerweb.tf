resource "helm_release" "bunkerweb" {
  name             = "bunkerweb"
  repository       = "https://repo.bunkerweb.io/charts"
  chart            = "bunkerweb"
  version          = var.bunkerweb_version
  namespace        = var.bunkerweb_namespace
  create_namespace = true
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
      name       = "bunkerweb"
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
        storageClass = var.bunkerweb_storage_class_name
      }
    }

    redis = {
      enabled = true

      persistence = {
        storageClass = var.bunkerweb_storage_class_name
      }
    }

    prometheus = {
      enabled = false
    }

    grafana = {
      enabled = false
    }
  })]

  depends_on = [azurerm_kubernetes_cluster.main]
}

resource "kubernetes_service_v1" "bunkerweb_external" {
  metadata {
    name      = "bunkerweb-external"
    namespace = var.bunkerweb_namespace

    labels = {
      "app.kubernetes.io/name"     = "bunkerweb"
      "app.kubernetes.io/instance" = "bunkerweb"
    }

    annotations = {
      "service.beta.kubernetes.io/azure-load-balancer-resource-group" = azurerm_resource_group.main.name
      "service.beta.kubernetes.io/azure-pip-name"                     = azurerm_public_ip.lb.name
    }
  }

  spec {
    type                    = "LoadBalancer"
    external_traffic_policy = "Local"
    load_balancer_ip        = azurerm_public_ip.lb.ip_address

    selector = {
      "bunkerweb.io/component" = "bunkerweb"
    }

    port {
      name        = "http"
      port        = 80
      target_port = 8080
      protocol    = "TCP"
    }

    port {
      name        = "https"
      port        = 443
      target_port = 8443
      protocol    = "TCP"
    }
  }

  depends_on = [helm_release.bunkerweb, azurerm_public_ip.lb]
}
