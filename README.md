# High Availability Kubernetes cluster in Hetzner provider

This will spin up a high availability Kubernetes cluster in Hetzner provider composed of 3 servers (2 doesn't provide quorum) and 3 workers nodes. It will also provision a load balancer in front of the servers.

## Requirement
- Docker on your machine (or terraform and ansible installed locally)
- A Hetzner token with read/write rights

## TL;DR
- Init
  ```
  export TF_VAR_hcloud_token=
  
  ./start_controller.sh
  ```
- Create cluster
  ```
  ./scripts/create_cluster.sh
  ```
- Install kubernetes
  ```
  ./scripts/install_k3s.sh
  ```
- Nuke (destroy the cluster and remove local artifacts)
  ```
  ./scripts/destroy_cluster.sh
  ```
- Clean everything (including tfstate! But does not remove remote resources, be aware)
  ```
  ./scripts/clean.sh
  ```

### Cost
The cost of running the cluster for a full month is **31.60 euros** as of October 2025 if you don't change anything.

Hetzner charge per hour of use, so you can spin up/down as needed. Broken down to (PU for a full month):

|Desc|Unit|PU|Total cost|
|:-:|:-:|:-:|:-:|
|Server cx23|6|3.59|21.53|
|IPv4 lease|6|0.60|3.60|
|Loadbalancer LB11|1|6.47|6.47|

### Variables
| Name                              | Type           | Default             | Description                                      |
| --------------------------------- | :-: | :-: | ------------------------------------------------ |
| `hcloud_token`                    | `string`       | —                   | **REQUIRED**. Hetzner Cloud API token            |
| `allowed_ip`                      | `list(string)` | —                   | List of IPs allowed to access the API serve.   r |
|                                   |                |                     | Add your own public IP so you can have access.   |
| `k3s_version`                     | `string`       | `v1.34.1+k3s1`      | Version of K3s to install                        |
| `kube_servers_count`              | `number`       | `3`                 | Number of Kubernetes server nodes                |
| `kube_workers_count`              | `number`       | `3`                 | Number of Kubernetes workers nodes               |
| `kube_server_type`                | `string`       | `cx23`              | Type of compute instance for all nodes           |
| `kube_location`                   | `string`       | `fsn1`              | Hetzner datacenter location                      |
| `kube_os`                         | `string`       | `debian-13`         | Operating system image used for nodes            |
| `ssh_keyset`                      | `list(string)` | `[]`                | Additional SSH key names to include in nodes     |
|                                   |                |                     | if it already exist in Hetzner                   |


### Manual execution
- Add the token to your env
  ```
  export TF_VAR_hcloud_token=
  ```
- Go to the terraform folder
  ```
  cd terraform
  ```
- Init terraform
  ```
  terraform init
  ```
- Deploy the cluster
  ```
  terraform apply -auto-approve
  ```
- Export ansible inventory from terraform (workaround to be compatible with HCP)
  ```
  terraform output -raw ansible_inventory > inventory.ini
  mkdir -p group_vars
  terraform output -raw ansible_groupvars_all > group_vars/all.yml
  terraform output -raw kube_private_key > ssh_private_key.pem
  chmod 600 ssh_private_key.pem
  ```
- Install K3s on nodes
  ```
  ansible-playbook -i inventory.ini deploy_k3s.yml 
  ```
- Test connection
  ```
  kubectl --kubeconfig kubeconfig.yaml get nodes
  ```
