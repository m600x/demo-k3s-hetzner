#!/bin/bash
set -e

echo "-------------------------------"
echo "Launching Terraform to create Hetzner K3s cluster..."
echo "-------------------------------"

cd terraform
terraform init
terraform apply -auto-approve
terraform output -raw ansible_inventory > ../ansible/inventory.ini
mkdir -p ../ansible/group_vars
terraform output -raw ansible_groupvars_all > ../ansible/group_vars/all.yml
terraform output -raw k3s_private_key > ../ansible/k3s.pem
chmod 600 ../ansible/k3s.pem

echo "-------------------------------"
echo "Terraform applied successfully. Proceeding to Ansible deployment..."
echo "-------------------------------"

cd ../ansible
ansible-playbook -i inventory.ini deploy_k3s.yml
if [ -f /.dockerenv ]; then
    mkdir -p /root/.kube
    cp kubeconfig.yaml /root/.kube/config
fi

echo "-------------------------------"
echo "K3s cluster created successfully. Here are the nodes:"
echo "-------------------------------"

if [ -f /.dockerenv ]; then
    kubectl get nodes
else
    kubectl --kubeconfig=../kubeconfig.yaml get nodes
fi
