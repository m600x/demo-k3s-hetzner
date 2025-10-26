#!/bin/bash

echo "-------------------------------"
echo "Cleaning up local files..."
echo "-------------------------------"

if [ -f /.dockerenv ]; then
    rm -rf /root/.kube
fi
rm -rf kubeconfig.yaml
rm -rf ./ansible/ssh_private_key.pem
rm -rf ./ansible/group_vars
rm -rf ./ansible/inventory.ini
rm -rf terraform/.terraform
rm -rf terraform/.terraform.lock.hcl
rm -rf terraform/terraform.tfstate
rm -rf terraform/terraform.tfstate.backup