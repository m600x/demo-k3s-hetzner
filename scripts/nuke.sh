#!/bin/bash

echo "-------------------------------"
echo "Launching Terraform to destroy Hetzner K3s cluster..."
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
rm -rf ./ansible/k3s.pem
rm -rf ./ansible/group_vars
rm -rf ./ansible/inventory.ini