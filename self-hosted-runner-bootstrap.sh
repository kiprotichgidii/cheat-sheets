#!/usr/bin/env bash
set -euo pipefail

echo ">>> Updating system..."
sudo apt-get update -y && sudo apt-get upgrade -y

echo ">>> Installing essential packages..."
sudo apt-get install -y \
    build-essential \
    curl \
    wget \
    unzip \
    git \
    gnupg \
    ca-certificates \
    software-properties-common \
    apt-transport-https \
    lsb-release

echo ">>> Installing Docker..."
curl -fsSL https://get.docker.com | sh
sudo systemctl enable --now docker
sudo usermod -aG docker $USER
newgrp docker

echo ">>> Installing Docker Compose (v2)..."
DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep tag_name | cut -d '"' -f 4)
sudo curl -SL "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" \
  -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

echo ">>> Installing Node.js (LTS) and npm..."
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs

echo ">>> Installing Python and pip..."
sudo apt-get install -y python3 python3-pip python3-venv

echo ">>> Installing Go..."
GO_VERSION=$(curl -s https://go.dev/VERSION?m=text | head -n 1)
wget https://go.dev/dl/${GO_VERSION}.linux-amd64.tar.gz
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf ${GO_VERSION}.linux-amd64.tar.gz
echo "export PATH=\$PATH:/usr/local/go/bin" >> ~/.bashrc

echo ">>> Installing Java (OpenJDK 17)..."
sudo apt-get install -y openjdk-17-jdk maven gradle

echo ">>> Installing .NET SDK..."
wget https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo apt-get update -y
sudo apt-get install -y dotnet-sdk-8.0

echo ">>> Installing PHP..."
sudo apt-get install -y php-cli php-mbstring php-xml composer

echo ">>> Installing Terraform..."
TERRAFORM_VERSION=$(curl -s https://api.github.com/repos/hashicorp/terraform/releases/latest | grep tag_name | cut -d '"' -f 4)
wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION#v}/terraform_${TERRAFORM_VERSION#v}_linux_amd64.zip
unzip terraform_${TERRAFORM_VERSION#v}_linux_amd64.zip
sudo mv terraform /usr/local/bin/

echo ">>> Installing kubectl..."
KUBECTL_VERSION=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)
curl -LO "https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

echo ">>> Installing Helm..."
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

echo ">>> Cleanup..."
rm -f *.zip *.tar.gz packages-microsoft-prod.deb

echo ">>> Done! GitHub Actions Runner Bootstrapping was successful!"

