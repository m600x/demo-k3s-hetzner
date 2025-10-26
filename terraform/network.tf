resource "hcloud_network" "kube_network" {
  name     = "kube_network"
  ip_range = "10.0.0.0/16"
}

resource "hcloud_network_subnet" "kube_subnet_common" {
  type         = "cloud"
  network_id   = hcloud_network.kube_network.id
  network_zone = "eu-central"
  ip_range     = "${var.kube_subnet_prefix_common}.0/24"
}

resource "hcloud_network_subnet" "kube_subnet_servers" {
  type         = "cloud"
  network_id   = hcloud_network.kube_network.id
  network_zone = "eu-central"
  ip_range     = "${var.kube_subnet_prefix_servers}.0/24"
}

resource "hcloud_network_subnet" "kube_subnet_workers" {
  type         = "cloud"
  network_id   = hcloud_network.kube_network.id
  network_zone = "eu-central"
  ip_range     = "${var.kube_subnet_prefix_workers}.0/24"
}

resource "hcloud_firewall" "kube_firewall" {
  name = "kube_firewall"
  rule {
    description = "Allow ICMP"
    direction   = "in"
    protocol    = "icmp"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    description = "Secure web"
    direction   = "in"
    protocol    = "tcp"
    port        = "443"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    description = "Insecure web"
    direction   = "in"
    protocol    = "tcp"
    port        = "80"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    description = "SSH"
    direction   = "in"
    protocol    = "tcp"
    port        = "22"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    description = "Kubernetes cluster internal communication"
    direction   = "in"
    protocol    = "tcp"
    port        = "6443"
    source_ips  = concat(["10.0.0.0/16"], var.allowed_ip)
  }

  rule {
    description = "Kubernetes VXLAN communication"
    direction   = "in"
    protocol    = "udp"
    port        = "8472"
    source_ips  = ["10.0.0.0/16"]
  }

  rule {
    description = "Kubernetes node communication"
    direction   = "in"
    protocol    = "tcp"
    port        = "10250"
    source_ips  = ["10.0.0.0/16"]
  }

  rule {
    description = "Kubernetes etcd server communication"
    direction   = "in"
    protocol    = "udp"
    port        = "2379-2380"
    source_ips  = ["10.0.0.0/16"]
  }

}

resource "hcloud_firewall_attachment" "kube_firewall_attachment" {
  firewall_id = hcloud_firewall.kube_firewall.id
  server_ids = concat(
    [for s in hcloud_server.kube_servers : s.id],
    [for s in hcloud_server.kube_workers : s.id]
  )
}

resource "hcloud_load_balancer" "kube_lb" {
  name               = "kube_lb"
  location           = "fsn1"
  load_balancer_type = "lb11"
}

resource "hcloud_load_balancer_network" "kube_lb_network" {
  load_balancer_id = hcloud_load_balancer.kube_lb.id
  network_id       = hcloud_network.kube_network.id
  ip               = "${var.kube_subnet_prefix_common}.1"
  depends_on       = [hcloud_network_subnet.kube_subnet_common]
}

resource "hcloud_load_balancer_service" "kube_lb_service" {
  load_balancer_id = hcloud_load_balancer.kube_lb.id
  protocol         = "tcp"
  listen_port      = 6443
  destination_port = 6443
  health_check {
    protocol = "tcp"
    port     = 6443
    interval = 10
    timeout  = 5
    retries  = 3
  }
}

resource "hcloud_load_balancer_service" "kube_lb_service_http" {
  load_balancer_id = hcloud_load_balancer.kube_lb.id
  protocol         = "tcp"
  listen_port      = 80
  destination_port = 30080
  proxyprotocol    = false
}

resource "hcloud_load_balancer_target" "kube_lb_target" {
  count = length(hcloud_server.kube_servers)

  type             = "server"
  load_balancer_id = hcloud_load_balancer.kube_lb.id
  server_id        = hcloud_server.kube_servers[count.index].id
  use_private_ip   = true
}