#!/bin/bash
set -e

echo "-------------------------------"
echo "Launching Terraform to create the cluster..."
echo "-------------------------------"

cd terraform
terraform init
terraform apply -auto-approve

echo "-------------------------------"
echo "Terraform applied successfully. Exporting Ansible artifacts."
echo "-------------------------------"

terraform output -raw ansible_inventory > ../ansible/inventory.ini
mkdir -p ../ansible/group_vars
terraform output -raw ansible_groupvars_all > ../ansible/group_vars/all.yml
terraform output -raw k3s_private_key > ../ansible/ssh_private_key.pem
chmod 600 ../ansible/ssh_private_key.pem

echo "-------------------------------"
echo "Terraform applied successfully."
echo "-------------------------------"
