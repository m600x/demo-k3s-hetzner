#!/bin/bash

echo "-------------------------------"
echo "Launching Terraform to destroy the cluster..."
echo "-------------------------------"

cd terraform
terraform destroy -auto-approve

echo "-------------------------------"
echo "Terraform destroyed the cluster successfully. Cleaning up local files..."
echo "-------------------------------"

if [ -f /.dockerenv ]; then
    rm -rf /root/.kube
fi
rm -rf kubeconfig.yaml
rm -rf ./ansible/ssh_private_key.pem
rm -rf ./ansible/group_vars
rm -rf ./ansible/inventory.ini