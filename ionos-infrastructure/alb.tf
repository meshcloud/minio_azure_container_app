resource "ionoscloud_ipblock" "alb" {
  location = var.location
  size     = 1
  name     = "${var.k8s_cluster_name}-alb-ip"
}

resource "ionoscloud_lan" "alb_listener" {
  datacenter_id = data.ionoscloud_datacenter.main.id
  public        = true
  name          = "${var.k8s_cluster_name}-alb-listener"
}

resource "ionoscloud_application_loadbalancer" "main" {
  datacenter_id = data.ionoscloud_datacenter.main.id
  name          = "${var.k8s_cluster_name}-alb"
  listener_lan  = ionoscloud_lan.alb_listener.id
  target_lan    = ionoscloud_lan.nodepool.id
  ips           = [ionoscloud_ipblock.alb.ips[0]]
}

resource "ionoscloud_application_loadbalancer_forwardingrule" "http" {
  datacenter_id               = data.ionoscloud_datacenter.main.id
  application_loadbalancer_id = ionoscloud_application_loadbalancer.main.id
  name                        = "http"
  protocol                    = "HTTP"
  listener_ip                 = ionoscloud_ipblock.alb.ips[0]
  listener_port               = 80
  client_timeout              = 60000

  http_rules {
    name         = "forward-to-bunkerweb"
    type         = "FORWARD"
    target_group = ionoscloud_target_group.bunkerweb_http.id
    conditions {
      type      = "HEADER"
      condition = "EXISTS"
      key       = "Host"
    }
  }
}

resource "ionoscloud_application_loadbalancer_forwardingrule" "https" {
  datacenter_id               = data.ionoscloud_datacenter.main.id
  application_loadbalancer_id = ionoscloud_application_loadbalancer.main.id
  name                        = "https"
  protocol                    = "HTTP"
  listener_ip                 = ionoscloud_ipblock.alb.ips[0]
  listener_port               = 443
  client_timeout              = 60000

  http_rules {
    name         = "forward-to-bunkerweb"
    type         = "FORWARD"
    target_group = ionoscloud_target_group.bunkerweb_https.id
    conditions {
      type      = "HEADER"
      condition = "EXISTS"
      key       = "Host"
    }
  }
}

resource "ionoscloud_target_group" "bunkerweb_http" {
  name             = "${var.k8s_cluster_name}-bunkerweb-http"
  algorithm        = "ROUND_ROBIN"
  protocol         = "HTTP"
  protocol_version = "HTTP1"

  health_check {
    check_timeout  = 5000
    check_interval = var.health_check_interval
    retries        = 3
  }

  http_health_check {
    path       = "/"
    method     = "GET"
    match_type = "STATUS_CODE"
    response   = "200"
  }

  dynamic "targets" {
    for_each = local.node_private_ips
    content {
      ip     = targets.value
      port   = var.nodeport_http
      weight = 1
    }
  }
}

resource "ionoscloud_target_group" "bunkerweb_https" {
  name             = "${var.k8s_cluster_name}-bunkerweb-https"
  algorithm        = "ROUND_ROBIN"
  protocol         = "HTTP"
  protocol_version = "HTTP1"

  health_check {
    check_timeout  = 5000
    check_interval = var.health_check_interval
    retries        = 3
  }

  http_health_check {
    path       = "/"
    method     = "GET"
    match_type = "STATUS_CODE"
    response   = "200"
  }

  dynamic "targets" {
    for_each = local.node_private_ips
    content {
      ip     = targets.value
      port   = var.nodeport_https
      weight = 1
    }
  }
}
