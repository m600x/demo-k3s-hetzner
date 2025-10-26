terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.45"
    }
    ansible = {
      version = "~> 1.3.0"
      source  = "ansible/ansible"
    }
  }
}

provider "hcloud" {
  token = var.hcloud_token
}

resource "tls_private_key" "terraform-ssh-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "hcloud_ssh_key" "terraform-ssh-key" {
  name       = var.terraform_ssh_key_name
  public_key = tls_private_key.terraform-ssh-key.public_key_openssh
}

resource "random_string" "kube_token" {
  length  = 64
  special = false
}