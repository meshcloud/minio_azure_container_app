# Scoped ServiceAccount used by the per-tenant seaweedfs-instance deployments
# instead of the cluster-admin kubeconfig. Created once with the cluster; the
# token is reused by every tenant deployment (nothing is created per tenant).
resource "kubernetes_service_account_v1" "deployer" {
  metadata {
    name      = "storage-deployer"
    namespace = "kube-system"
  }
}

# Cluster-scoped bits the built-in "edit" role does NOT cover: namespace
# lifecycle (a namespace is created per tenant) + reading storageclasses.
resource "kubernetes_cluster_role_v1" "deployer_namespaces" {
  metadata {
    name = "storage-deployer-namespaces"
  }
  rule {
    api_groups = [""]
    resources  = ["namespaces"]
    verbs      = ["get", "list", "create", "delete"]
  }
  rule {
    api_groups = ["storage.k8s.io"]
    resources  = ["storageclasses"]
    verbs      = ["get", "list"]
  }
}

resource "kubernetes_cluster_role_binding_v1" "deployer_namespaces" {
  metadata {
    name = "storage-deployer-namespaces"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.deployer_namespaces.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.deployer.metadata[0].name
    namespace = "kube-system"
  }
}

# Full management of namespaced app resources (deployments, services, secrets,
# configmaps, pvc, …) via the built-in "edit" ClusterRole, bound cluster-wide
# so it also applies to future tenant namespaces without per-namespace binding.
resource "kubernetes_cluster_role_binding_v1" "deployer_edit" {
  metadata {
    name = "storage-deployer-edit"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "edit"
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.deployer.metadata[0].name
    namespace = "kube-system"
  }
}

# Long-lived token for the deployer SA (K8s >= 1.24 no longer auto-creates one).
resource "kubernetes_secret_v1" "deployer_token" {
  metadata {
    name      = "storage-deployer-token"
    namespace = "kube-system"
    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account_v1.deployer.metadata[0].name
    }
  }
  type                           = "kubernetes.io/service-account-token"
  wait_for_service_account_token = true
}
