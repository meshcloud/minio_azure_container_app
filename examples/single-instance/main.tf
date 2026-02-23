terraform {
  required_version = ">= 1.6.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.35"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.17"
    }
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "kind-seaweedfs"
}

provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
    config_context = "kind-seaweedfs"
  }
}

resource "helm_release" "bunkerweb" {
  name             = "bunkerweb"
  repository       = "https://repo.bunkerweb.io/charts"
  chart            = "bunkerweb"
  version          = "1.0.13"
  namespace        = "seaweedfs"
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
        dnsResolvers   = "kube-dns.kube-system.svc.cluster.local"
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

    ui  = { enabled = false }
    api = { enabled = false }
    mariadb = {
      enabled     = true
      persistence = { storageClass = "standard" }
    }
    redis = {
      enabled     = true
      persistence = { storageClass = "standard" }
    }
    prometheus = { enabled = false }
    grafana    = { enabled = false }
  })]
}

resource "kubernetes_service_v1" "bunkerweb_external" {
  metadata {
    name      = "bunkerweb"
    namespace = "seaweedfs"
    labels = {
      "app.kubernetes.io/name"     = "bunkerweb"
      "app.kubernetes.io/instance" = "bunkerweb"
    }
  }

  spec {
    type = "ClusterIP"
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

  depends_on = [helm_release.bunkerweb]
}

module "seaweedfs" {
  source = "../../modules/seaweedfs-instance"

  namespace            = "seaweedfs"
  storage_class_name   = "standard"
  seaweedfs_domain     = "s3.localhost"
  keycloak_domain      = "auth.localhost"
  email_lets_encrypt   = "admin@example.com"
  ingress_class_name   = "bunkerweb"
  bunkerweb_cluster_ip = kubernetes_service_v1.bunkerweb_external.spec[0].cluster_ip
}

output "s3_api_url" {
  value = module.seaweedfs.s3_api_url
}

output "keycloak_url" {
  value = module.seaweedfs.keycloak_url
}

output "keycloak_admin_password" {
  value     = module.seaweedfs.keycloak_admin_password
  sensitive = true
}
