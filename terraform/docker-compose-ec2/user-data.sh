#!/bin/bash
set -e

PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
APP_URL="http://${PUBLIC_IP}:3000"

echo "export APP_URL='${APP_URL}'" >> /etc/environment

# -------- UPDATE SYSTEM --------
echo_info "Updating system packages..."
sudo apt-get update -y
sudo apt-get upgrade -y

# -------- INSTALL DEPENDENCIES --------
echo_info "Installing dependencies..."
sudo apt-get install -y ca-certificates curl gnupg lsb-release

# -------- ADD DOCKER REPO --------
echo_info "Adding Docker official repository..."
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# -------- INSTALL DOCKER & COMPOSE PLUGIN --------
echo_info "Installing Docker Engine and Compose plugin..."
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# -------- POST-INSTALL: ADD USER TO DOCKER GROUP --------
echo_info "Adding $USER_NAME to docker group..."
sudo usermod -aG docker $USER_NAME

# -------- CHECK INSTALLATION --------
echo_info "Checking Docker and Docker Compose versions..."
docker --version
docker compose version

# Create app directory
mkdir -p /opt/devops-blog
cd /opt/devops-blog

scp -i "~/.ssh/devops-key" -r nodejs-mini-blog ubuntu@ec2-52-56-42-119.eu-west-2.compute.amazonaws.com:~

# Copy the docker-compose file from Terraform
cat <<EOF > version: '3.9'

services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=development
      - PORT=${PORT}
      - MONGO_URI=${MONGO_URI}
      - OPENAI_API_KEY=${OPENAI_API_KEY} # optional
      - APP_URL=${APP_URL}
    depends_on:
      - mongo
    volumes:
      - .:/usr/src/app
      - /usr/src/app/node_modules
    networks:
      - app_net

  mongo:
    image: mongo:6
    container_name: mongo-db-new
    restart: always
    environment:
      MONGO_INITDB_DATABASE: devops_blog
    volumes:
      - mongo_data:/data/db
    networks:
      - app_net

volumes:
  mongo_data:

networks:
  app_net:
    driver: bridge
EOF

# Run the stack
suod docker compose up -d
