FROM debian:12.11-slim

# Ops container

# Dependencies
RUN set -eux && \
    apt-get update && \
    apt-get install -y --no-install-recommends wget gnupg software-properties-common unzip vim mandoc ssh curl && \
    rm -rf /var/lib/apt/lists/*

# Terraform
RUN set -eux && \
    wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmour -o /usr/share/keyrings/hashicorp.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" > /etc/apt/sources.list.d/hashicorp.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends terraform && \
    rm -rf /var/lib/apt/lists/*

# Vault
RUN set -eux && \
    if [ ! -f /usr/share/keyrings/hashicorp.gpg ]; then \
        wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmour -o /usr/share/keyrings/hashicorp.gpg ; \
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" > /etc/apt/sources.list.d/hashicorp.list ; \
    fi ; \
    apt-get update && \
    apt-get install -y --no-install-recommends vault && \
    rm -rf /var/lib/apt/lists/*

# Ansible
RUN set -eux && \
    wget -O- "https://keyserver.ubuntu.com/pks/lookup?fingerprint=on&op=get&search=0x6125E2A8C77F2818FB7BD15B93C4A3FD7BB9C367" | gpg --dearmour -o /usr/share/keyrings/ansible.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ansible.gpg] http://ppa.launchpad.net/ansible/ansible/ubuntu jammy main" > /etc/apt/sources.list.d/ansible.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends ansible && \
    rm -rf /var/lib/apt/lists/*

# Kubectl
RUN set -eux && \
    wget -q -P /usr/local/bin https://dl.k8s.io/release/$(wget -qO- https://cdn.dl.k8s.io/release/stable.txt)/bin/linux/$(dpkg --print-architecture)/kubectl && \
    chmod 0755 /usr/local/bin/kubectl

# AWS CLI
RUN set -eux && \
    wget -q -P /tmp https://awscli.amazonaws.com/awscli-exe-linux-$(uname -m).zip && \
    unzip /tmp/awscli-exe-linux-$(uname -m).zip -d /tmp && \
    /tmp/aws/install && \
    rm -rf /tmp/aws

# Azure CLI
RUN set -eux && \
    wget -O- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft.gpg && \
    printf "Types: deb\nURIs: https://packages.microsoft.com/repos/azure-cli/\nSuites: $(lsb_release -cs)\nComponents: main\nArchitectures: $(dpkg --print-architecture)\nSigned-by: /usr/share/keyrings/microsoft.gpg\n" > /etc/apt/sources.list.d/azure.sources && \
    apt-get update && \
    apt-get install -y --no-install-recommends azure-cli && \
    rm -rf /var/lib/apt/lists/*

# GCP CLI
RUN set -eux && \
    wget -O- https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/google.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" > /etc/apt/sources.list.d/google.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends google-cloud-cli && \
    rm -rf /var/lib/apt/lists/*

RUN echo "echo '********************************'" >> /etc/bash.bashrc && \
    echo "echo '* Installed app:'" >> /etc/bash.bashrc && \
    echo "echo '*'" >> /etc/bash.bashrc && \
    echo "echo '* - Ansible   : $(ansible --version | head -1 | grep -oP '\d+\.\d+\.\d+')'" >> /etc/bash.bashrc && \
    echo "echo '* - Terraform : $(terraform -v | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')'" >> /etc/bash.bashrc && \
    echo "echo '* - Kubectl   : $(kubectl version --client | grep 'Client Version' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')'" >> /etc/bash.bashrc && \
    echo "echo '*'" >> /etc/bash.bashrc && \
    echo "echo '* - AWS CLI   : $(aws --version | grep -oP 'aws-cli/\K[0-9]+\.[0-9]+\.[0-9]+')'" >> /etc/bash.bashrc && \
    echo "echo '* - Azure CLI : $(az version | grep '"azure-cli":' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')'" >> /etc/bash.bashrc && \
    echo "echo '* - GCP CLI   : $(gcloud --version | grep -oP '^Google Cloud SDK \K[0-9]+\.[0-9]+\.[0-9]+')'" >> /etc/bash.bashrc && \
    echo "echo '********************************'" >> /etc/bash.bashrc

WORKDIR /app

CMD ["bash"]