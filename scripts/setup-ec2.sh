#!/usr/bin/env bash
# ==============================================================================
# Script Name: setup-ec2.sh
# Purpose    : AWS EC2 Ubuntu Bootstrap script for Docker & Swap Space Config
# Usage      : Run via SSH on newly launched AWS EC2 Ubuntu 22.04 LTS instance
# ==============================================================================

set -euo pipefail

echo "=================================================="
echo "🚀 STEP 1: Updating System Packages..."
echo "=================================================="
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install -y curl ca-certificates gnupg lsb-release

echo "=================================================="
echo "🐳 STEP 2: Installing Docker Engine..."
echo "=================================================="
# Add Docker's official GPG key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg --yes

# Set up repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker CE, CLI, and containerd
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Enable and start Docker service
sudo systemctl enable docker
sudo systemctl start docker

# Add ubuntu user to docker group (avoids needing sudo for docker commands)
sudo usermod -aG docker ubuntu

echo "=================================================="
echo "💾 STEP 3: Configuring 2GB Linux Swap Space..."
echo "=================================================="
# Prevent OOM Killer crashes on AWS t2.micro (1GB RAM)
if [ ! -f /swapfile ]; then
    echo "Creating 2GB swap file..."
    sudo fallocate -l 2G /swapfile || sudo dd if=/dev/zero of=/swapfile bs=1M count=2048
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
    echo "Swap space configured successfully!"
else
    echo "Swap file already exists."
fi

echo "=================================================="
echo "✅ STEP 4: System Bootstrap Complete!"
echo "=================================================="
echo "Docker Version:"
sudo docker --version
echo "Memory & Swap Status:"
free -h
echo "NOTE: Please log out and log back in for docker group permissions to take effect."
