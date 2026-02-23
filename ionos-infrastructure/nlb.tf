resource "ionoscloud_ipblock" "nlb" {
  location = var.location
  size     = 1
  name     = "${var.k8s_cluster_name}-nlb-ip"
}

resource "ionoscloud_lan" "nlb_listener" {
  datacenter_id = data.ionoscloud_datacenter.main.id
  public        = true
  name          = "${var.k8s_cluster_name}-nlb-listener"
}

resource "ionoscloud_networkloadbalancer" "main" {
  datacenter_id = data.ionoscloud_datacenter.main.id
  name          = "${var.k8s_cluster_name}-nlb"
  listener_lan  = ionoscloud_lan.nlb_listener.id
  target_lan    = ionoscloud_lan.nodepool.id
  ips           = [ionoscloud_ipblock.nlb.ips[0]]
}

resource "ionoscloud_networkloadbalancer_forwardingrule" "http" {
  datacenter_id          = data.ionoscloud_datacenter.main.id
  networkloadbalancer_id = ionoscloud_networkloadbalancer.main.id
  name                   = "http"
  algorithm              = "ROUND_ROBIN"
  protocol               = "TCP"
  listener_ip            = ionoscloud_ipblock.nlb.ips[0]
  listener_port          = 80

  health_check {
    retries         = 3
    connect_timeout = 5000
    target_timeout  = 30000
  }

  dynamic "targets" {
    for_each = local.node_private_ips
    content {
      ip     = targets.value
      port   = var.nodeport_http
      weight = 1
      health_check {
        check          = true
        check_interval = var.health_check_interval
      }
    }
  }
}

resource "ionoscloud_networkloadbalancer_forwardingrule" "https" {
  datacenter_id          = data.ionoscloud_datacenter.main.id
  networkloadbalancer_id = ionoscloud_networkloadbalancer.main.id
  name                   = "https"
  algorithm              = "ROUND_ROBIN"
  protocol               = "TCP"
  listener_ip            = ionoscloud_ipblock.nlb.ips[0]
  listener_port          = 443

  health_check {
    retries         = 3
    connect_timeout = 5000
    target_timeout  = 30000
  }

  dynamic "targets" {
    for_each = local.node_private_ips
    content {
      ip     = targets.value
      port   = var.nodeport_https
      weight = 1
      health_check {
        check          = true
        check_interval = var.health_check_interval
      }
    }
  }
}
