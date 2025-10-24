output "k3s-servers" {
  description = "K3s Server IP addresses"
  value = [for s in hcloud_server.k3s-servers : "${s.ipv4_address}"]
}

output "k3s-agents" {
  description = "K3s Agent IP addresses"
  value = [for s in hcloud_server.k3s-agents : "${s.ipv4_address}"]
}

output "k3s_token" {
  description = "K3s cluster token"
  value     = random_string.k3s_token.result
  sensitive = true
}

output "k3s_private_key" {
  description = "Private SSH key for accessing K3s servers and agents"
  value     = tls_private_key.terraform-ssh-key.private_key_pem
  sensitive = true
}

output "k3s_lb_ip" {
  description = "K3s Load Balancer IP"
  value = hcloud_load_balancer.k3s_lb.ipv4
}

output "ansible_inventory" {
  description = "Generated Ansible inventory for K3s servers and agents with SSH key and private IPs"
  sensitive   = true
  value = <<EOT
[k3s_servers]
${join("\n", [
  for s in hcloud_server.k3s-servers :
  "${s.ipv4_address} ansible_host=${s.ipv4_address} private_ip=${tolist(s.network)[0].ip}"
  ])}

[k3s_agents]
${join("\n", [
  for s in hcloud_server.k3s-agents :
  "${s.ipv4_address} ansible_host=${s.ipv4_address} private_ip=${tolist(s.network)[0].ip}"
])}
EOT
}

output "ansible_groupvars_all" {
  description = "Ansible group_vars/all.yml content with K3s version and token"
  sensitive   = true
  value       = <<EOT
---
k3s_version: "${var.k3s_version}"
k3s_token: "${random_string.k3s_token.result}"
k3s_server_url: "https://{{ hostvars[groups['k3s_servers'][0]].private_ip }}:6443"
k3s_loadbalancer_ip: "${hcloud_load_balancer.k3s_lb.ipv4}"
ansible_ssh_private_key_file: "./k3s.pem"
ansible_user: "root"
ansible_ssh_common_args: "-o StrictHostKeyChecking=no"
EOT
}