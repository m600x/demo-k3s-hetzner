variable "hcloud_token" {
  description = "Hetzner Cloud API token"
  type        = string
  sensitive   = true
}

variable "allowed_ip" {
  description = "IP address allowed to access the Kubernetes API server"
  type        = list(string)
  sensitive   = true
}

variable "k3s_version" {
  description = "K3s version to install"
  type        = string
  default     = "v1.34.1+k3s1"
}

variable "kube_servers_count" {
  description = "Number of Kubernetes server nodes"
  type        = number
  default     = 3
}

variable "kube_workers_count" {
  description = "Number of Kubernetes worker nodes"
  type        = number
  default     = 3
}

variable "kube_server_type" {
  description = "Compute resource type"
  type        = string
  default     = "cx23"
}

variable "kube_location" {
  description = "Datacenter location"
  type        = string
  default     = "fsn1"
}

variable "kube_os" {
  description = "Operating system image"
  type        = string
  default     = "debian-13"
}

variable "terraform_ssh_key_name" {
  description = "Name of the SSH key to be used for server access"
  type        = string
  default     = "terraform-ssh-key"
}

variable "kube_subnet_prefix_common" {
  description = "Subnet prefix for common network"
  type        = string
  default     = "10.0.1"
}

variable "kube_subnet_prefix_servers" {
  description = "Subnet prefix for servers network"
  type        = string
  default     = "10.0.2"
}

variable "kube_subnet_prefix_workers" {
  description = "Subnet prefix for workers network"
  type        = string
  default     = "10.0.3"
}

variable "ssh_keyset" {
  description = "List of additional SSH key names to be added to servers"
  type        = list(string)
  default     = []
}