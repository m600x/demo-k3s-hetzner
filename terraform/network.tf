resource "hcloud_network" "k3s-network" {
  name     = "k3s-network"
  ip_range = "10.0.0.0/16"
}

resource "hcloud_network_subnet" "k3s-network-subnet-common" {
  type         = "cloud"
  network_id   = hcloud_network.k3s-network.id
  network_zone = "eu-central"
  ip_range     = "${var.k3s_network_subnet_part_common}.0/24"
}

resource "hcloud_network_subnet" "k3s-network-subnet-servers" {
  type         = "cloud"
  network_id   = hcloud_network.k3s-network.id
  network_zone = "eu-central"
  ip_range     = "${var.k3s_network_subnet_part_servers}.0/24"
}

resource "hcloud_network_subnet" "k3s-network-subnet-workers" {
  type         = "cloud"
  network_id   = hcloud_network.k3s-network.id
  network_zone = "eu-central"
  ip_range     = "${var.k3s_network_subnet_part_workers}.0/24"
}

resource "hcloud_firewall" "k3s-firewall" {
  name = "k3s-firewall"
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
    description = "K3s cluster internal communication"
    direction   = "in"
    protocol    = "tcp"
    port        = "6443"
    source_ips  = concat(["10.0.0.0/16"], var.allowed_ip)
  }

  rule {
    description = "K3s VXLAN communication"
    direction   = "in"
    protocol    = "udp"
    port        = "8472"
    source_ips  = ["10.0.0.0/16"]
  }

  rule {
    description = "K3s node communication"
    direction   = "in"
    protocol    = "tcp"
    port        = "10250"
    source_ips  = ["10.0.0.0/16"]
  }

  rule {
    description = "K3s etcd server communication"
    direction   = "in"
    protocol    = "udp"
    port        = "2379-2380"
    source_ips  = ["10.0.0.0/16"]
  }

}

resource "hcloud_firewall_attachment" "k3s-firewall-attachment" {
  firewall_id = hcloud_firewall.k3s-firewall.id
  server_ids = concat(
    [for s in hcloud_server.k3s-servers : s.id],
    [for s in hcloud_server.k3s-workers : s.id]
  )
}

resource "hcloud_load_balancer" "k3s_lb" {
  name               = "k3s-lb"
  location           = "fsn1"
  load_balancer_type = "lb11"
}

resource "hcloud_load_balancer_network" "k3s_lb_network" {
  load_balancer_id = hcloud_load_balancer.k3s_lb.id
  network_id       = hcloud_network.k3s-network.id
  ip               = "${var.k3s_network_subnet_part_common}.1"
  depends_on       = [hcloud_network_subnet.k3s-network-subnet-common]
}

resource "hcloud_load_balancer_service" "k3s_lb_service" {
  load_balancer_id = hcloud_load_balancer.k3s_lb.id
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

resource "hcloud_load_balancer_service" "k3s_lb_service_http" {
  load_balancer_id = hcloud_load_balancer.k3s_lb.id
  protocol         = "tcp"
  listen_port      = 80
  destination_port = 30080
  proxyprotocol    = false
}

resource "hcloud_load_balancer_target" "k3s_lb_target" {
  count = length(hcloud_server.k3s-servers)

  type             = "server"
  load_balancer_id = hcloud_load_balancer.k3s_lb.id
  server_id        = hcloud_server.k3s-servers[count.index].id
  use_private_ip   = true
}