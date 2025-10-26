output "kube_servers" {
  description = "Kubernetes Server IP addresses"
  value       = [for s in hcloud_server.kube_servers : "${s.ipv4_address}"]
}

output "kube_workers" {
  description = "Kubernetes worker IP addresses"
  value       = [for s in hcloud_server.kube_workers : "${s.ipv4_address}"]
}

output "kube_token" {
  description = "K3s cluster token"
  value       = random_string.kube_token.result
  sensitive   = true
}

output "kube_private_key" {
  description = "Private SSH key for accessing Kubernetes servers and workers"
  value       = tls_private_key.terraform-ssh-key.private_key_pem
  sensitive   = true
}

output "kube_lb_ip" {
  description = "Kubernetes Load Balancer IP"
  value       = hcloud_load_balancer.kube_lb.ipv4
}

output "ansible_inventory" {
  description = "Generated Ansible inventory for Kubernetes servers and workers with SSH key and private IPs"
  sensitive   = true
  value = <<EOT
[kube_servers]
${join("\n", [
  for s in hcloud_server.kube_servers :
  "${s.ipv4_address} ansible_host=${s.ipv4_address} private_ip=${tolist(s.network)[0].ip}"
  ])}

[kube_workers]
${join("\n", [
  for s in hcloud_server.kube_workers :
  "${s.ipv4_address} ansible_host=${s.ipv4_address} private_ip=${tolist(s.network)[0].ip}"
])}
EOT
}

output "ansible_groupvars_all" {
  description = "Ansible group_vars/all.yml content with Kubernetes version and token"
  sensitive   = true
  value       = <<EOT
---
k3s_version: "${var.k3s_version}"
k3s_token: "${random_string.kube_token.result}"
k3s_server_url: "https://{{ hostvars[groups['kube_servers'][0]].private_ip }}:6443"
k3s_loadbalancer_ip: "${hcloud_load_balancer.kube_lb.ipv4}"
ansible_ssh_private_key_file: "./ssh_private_key.pem"
ansible_user: "root"
ansible_ssh_common_args: "-o StrictHostKeyChecking=no"
EOT
}