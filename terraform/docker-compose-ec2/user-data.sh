#!/bin/bash
set -e

PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
APP_URL="http://$${PUBLIC_IP}:3000"

echo "export APP_URL='$${APP_URL}'" >> /etc/environment

# -------- UPDATE SYSTEM --------
echo "Updating system packages..."
sudo apt-get update -y
sudo apt-get upgrade -y

# -------- INSTALL DEPENDENCIES --------
echo "Installing dependencies..."
sudo apt-get install -y ca-certificates curl gnupg lsb-release

# -------- ADD DOCKER REPO --------
echo "Adding Docker official repository..."
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# -------- INSTALL DOCKER & COMPOSE PLUGIN --------
echo "Installing Docker Engine and Compose plugin..."
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# -------- POST-INSTALL: ADD USER TO DOCKER GROUP --------
DEFAULT_USER=$(getent passwd 1000 | cut -d: -f1)
echo "Adding $${DEFAULT_USER} to docker group..."
usermod -aG docker "$${DEFAULT_USER}"

# -------- CHECK INSTALLATION --------
echo "Checking Docker and Docker Compose versions..."
docker --version
docker compose version

# Create app directory
sudo mkdir -p /opt/devops-blog
cd /opt/devops-blog

echo "Docker Setup Completed"

# Uncomment below if you are using Terraform locally

# sudo git clone https://github.com/PriyanSappal/nodejs-ai-mini-blog.git .
# cd app/

# sudo cat <<EOF > .env
# PORT=${PORT}
# MONGO_URI=${MONGO_URI}
# OPENAI_API_KEY=${OPENAI_API_KEY}
# APP_URL=$${APP_URL}
# EOF

# sudo docker compose up --build -d
# sudo docker compose up -d
