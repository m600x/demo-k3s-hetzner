#!/bin/bash
set -e

echo "-------------------------------"
echo "Launching Ansible to create the K3s cluster..."
echo "-------------------------------"

cd ansible
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
