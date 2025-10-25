variable "hcloud_token" {
  description = "Hetzner Cloud API token"
  type        = string
  sensitive   = true
}

variable "allowed_ip" {
  description = "IP address allowed to access the K3s API server"
  type        = list(string)
  sensitive   = true
}

variable "k3s_version" {
  description = "K3s version to install"
  type        = string
  default     = "v1.34.1+k3s1"
}

variable "k3s_servers_count" {
  description = "Number of K3s server nodes"
  type        = number
  default     = 3
}

variable "k3s_agents_count" {
  description = "Number of K3s agent nodes"
  type        = number
  default     = 3
}

variable "k3s_server_type" {
  description = "Compute resource type"
  type        = string
  default     = "cx23"
}

variable "k3s_location" {
  description = "Datacenter location"
  type        = string
  default     = "fsn1"
}

variable "k3s_os" {
  description = "Operating system image"
  type        = string
  default     = "debian-13"
}

variable "terraform_ssh_key_name" {
  description = "Name of the SSH key to be used for server access"
  type        = string
  default     = "terraform-ssh-key"
}

variable "k3s_network_subnet_part_common" {
  description = "Subnet part for common network"
  type        = string
  default     = "10.0.1"
}

variable "k3s_network_subnet_part_servers" {
  description = "Subnet part for servers network"
  type        = string
  default     = "10.0.2"
}

variable "k3s_network_subnet_part_agents" {
  description = "Subnet part for agents network"
  type        = string
  default     = "10.0.3"
}

variable "ssh_keyset" {
  description = "List of additional SSH key names to be added to servers"
  type        = list(string)
  default     = []
}