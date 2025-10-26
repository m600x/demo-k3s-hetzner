resource "hcloud_server" "kube_servers" {
  count       = var.kube_servers_count
  name        = "kube-server-${count.index + 1}"
  server_type = var.kube_server_type
  image       = var.kube_os
  location    = var.kube_location
  depends_on = [
    hcloud_ssh_key.terraform-ssh-key,
    hcloud_network_subnet.kube_subnet_servers
  ]
  ssh_keys     = concat([var.terraform_ssh_key_name], var.ssh_keyset)
  firewall_ids = [hcloud_firewall.kube_firewall.id]

  network {
    network_id = hcloud_network.kube_network.id
    ip         = "${var.kube_subnet_prefix_servers}.${count.index + 1}"
  }

  public_net {
    ipv4_enabled = true
    ipv6_enabled = false
  }
}

resource "hcloud_server" "kube_workers" {
  count       = var.kube_workers_count
  name        = "kube-worker-${count.index + 1}"
  server_type = var.kube_server_type
  image       = var.kube_os
  location    = var.kube_location
  depends_on = [
    hcloud_ssh_key.terraform-ssh-key,
    hcloud_network_subnet.kube_subnet_workers
  ]
  ssh_keys     = concat([var.terraform_ssh_key_name], var.ssh_keyset)
  firewall_ids = [hcloud_firewall.kube_firewall.id]

  network {
    network_id = hcloud_network.kube_network.id
    ip         = "${var.kube_subnet_prefix_workers}.${count.index + 1}"
  }

  public_net {
    ipv4_enabled = true
    ipv6_enabled = false
  }
}