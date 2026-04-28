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
      kind     = "DaemonSet" # Run on all nodes for HA with hostNetwork
      replicas = 1           # Ignored for DaemonSet, but kept for reference

      # Use custom image with IONOS Cloud DNS support
      repository = "ghcr.io/florianow/bunkerweb-ionoscloud"
      tag        = "1.6.9"
      pullPolicy = "IfNotPresent"

      pdb = {
        create = false
      }

      # Use host network to bind directly to node IPs on ports 80/443
      hostNetwork = true
      dnsPolicy   = "ClusterFirstWithHostNet" # Required when using hostNetwork

      # Override default ports to use 80/443 directly
      http = {
        port = 80
      }
      https = {
        port = 443
      }
    }

    # Use custom scheduler image with IONOS Cloud DNS support
    scheduler = {
      repository = "ghcr.io/florianow/bunkerweb-scheduler-ionoscloud"
      tag        = "1.6.9-v2"
      pullPolicy = "Always"
    }

    settings = {
      kubernetes = {
        ingressClass = "bunkerweb"
      }

      misc = {
        dnsResolvers   = var.bunkerweb_dns_resolvers
        apiWhitelistIp = "127.0.0.0/8 10.0.0.0/8 172.16.0.0/12 192.168.0.0/16 100.64.0.0/10"
        # Use real client IP (preserved with hostNetwork)
        useRealIp    = "yes"
        realIpFrom   = "0.0.0.0/0"
        realIpHeader = "X-Forwarded-For"
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
      enabled    = true
      repository = "docker.io/bunkerity/bunkerweb-autoconf"
      tag        = "1.6.9"
      pullPolicy = "IfNotPresent"
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
}
