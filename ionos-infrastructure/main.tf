data "ionoscloud_datacenter" "main" {
  id = "2dbe0403-732e-4fcb-98d1-9df607f4ce78"
}

resource "ionoscloud_lan" "nodepool" {
  datacenter_id = data.ionoscloud_datacenter.main.id
  public        = false
  name          = "${var.k8s_cluster_name}-nodepool"

  lifecycle {
    create_before_destroy = true
  }
}

resource "ionoscloud_k8s_cluster" "main" {
  name        = var.k8s_cluster_name
  k8s_version = var.k8s_version

  maintenance_window {
    day_of_the_week = "Sunday"
    time            = "03:00:00Z"
  }
}

resource "ionoscloud_k8s_node_pool" "main" {
  datacenter_id     = data.ionoscloud_datacenter.main.id
  k8s_cluster_id    = ionoscloud_k8s_cluster.main.id
  name              = var.node_pool_name
  k8s_version       = ionoscloud_k8s_cluster.main.k8s_version
  node_count        = var.node_count
  cpu_family        = var.cpu_family
  availability_zone = "AUTO"
  cores_count       = var.cores_count
  ram_size          = var.ram_size
  storage_size      = var.storage_size
  storage_type      = var.storage_type

  lans {
    id   = ionoscloud_lan.nodepool.id
    dhcp = true
  }

  maintenance_window {
    day_of_the_week = "Monday"
    time            = "03:00:00Z"
  }
}

data "ionoscloud_k8s_cluster" "main" {
  id = ionoscloud_k8s_cluster.main.id

  depends_on = [ionoscloud_k8s_node_pool.main]
}

data "ionoscloud_k8s_node_pool_nodes" "main" {
  k8s_cluster_id = ionoscloud_k8s_cluster.main.id
  node_pool_id   = ionoscloud_k8s_node_pool.main.id
}

data "ionoscloud_server" "nodes" {
  for_each      = { for node in data.ionoscloud_k8s_node_pool_nodes.main.nodes : node.id => node }
  datacenter_id = data.ionoscloud_datacenter.main.id
  id            = each.key
}

locals {
  node_private_ips = flatten([
    for server in data.ionoscloud_server.nodes : [
      for nic in tolist(server.nics) : nic.ips
      if nic.lan == tonumber(ionoscloud_lan.nodepool.id)
    ]
  ])
}
