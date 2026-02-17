resource "helm_release" "bunkerweb" {
  name             = "bunkerweb"
  repository       = "https://repo.bunkerweb.io/charts"
  chart            = "bunkerweb"
  version          = var.bunkerweb_version
  namespace        = var.namespace
  create_namespace = false
  wait             = true
  timeout          = 600

  values = [yamlencode({
    service = {
      type = "ClusterIP"
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
        dnsResolvers = "kube-dns.kube-system.svc.cluster.local"
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
