resource "hcloud_server" "k3s-servers" {
  count       = var.k3s_servers_count
  name        = "k3s-server-${count.index + 1}"
  server_type = var.k3s_server_type
  image       = var.k3s_os
  location    = var.k3s_location
  depends_on = [
    hcloud_ssh_key.terraform-ssh-key,
    hcloud_network_subnet.k3s-network-subnet-servers
  ]
  ssh_keys     = concat([var.terraform_ssh_key_name], var.ssh_keyset)
  firewall_ids = [hcloud_firewall.k3s-firewall.id]

  network {
    network_id = hcloud_network.k3s-network.id
    ip         = "${var.k3s_network_subnet_part_servers}.${count.index + 1}"
  }

  public_net {
    ipv4_enabled = true
    ipv6_enabled = false
  }
}

resource "hcloud_server" "k3s-agents" {
  count       = var.k3s_agents_count
  name        = "k3s-agent-${count.index + 1}"
  server_type = var.k3s_server_type
  image       = var.k3s_os
  location    = var.k3s_location
  depends_on = [
    hcloud_ssh_key.terraform-ssh-key,
    hcloud_network_subnet.k3s-network-subnet-agents
  ]
  ssh_keys     = concat([var.terraform_ssh_key_name], var.ssh_keyset)
  firewall_ids = [hcloud_firewall.k3s-firewall.id]

  network {
    network_id = hcloud_network.k3s-network.id
    ip         = "${var.k3s_network_subnet_part_agents}.${count.index + 1}"
  }

  public_net {
    ipv4_enabled = true
    ipv6_enabled = false
  }
}