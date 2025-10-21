#!/bin/bash

# Update the system package list
echo Updating package list...
sudo apt-get update -y
echo Done!

# Upgrade all installed packages to their latest versions
echo Upgrading installed packages...
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
echo Done!

# Install necessary dependencies
echo "Installing dependencies..."
sudo apt-get install -y gnupg curl
echo "Done!"

# Download and add MongoDB GPG key for package verification
echo "Adding MongoDB GPG key..."
curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | sudo gpg --yes -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor
echo "Done!"

# Add MongoDB repository to the sources list
echo "Adding MongoDB repository to sources list..."
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
echo "Done!"

# Update package list again to include the newly added MongoDB repository
echo "Updating package list with MongoDB repository..."
sudo DEBIAN_FRONTEND=noninteractive apt-get update -y
echo "Done!"

# Install MongoDB version 7.0.6 and specific associated packages non-interactively
echo "Installing MongoDB and related packages..."
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y mongodb-org=7.0.6 mongodb-org-database=7.0.6 mongodb-org-server=7.0.6 mongodb-mongosh=2.1.5 mongodb-org-mongos=7.0.6
echo "Done!"

# Start MongoDB service immediately
echo "Starting MongoDB service..."
sudo systemctl start mongod
echo "Done!"
# Modify MongoDB configuration to allow remote connections
echo "Configuring MongoDB to allow remote connections..."
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
echo "Done!"

echo "Restarting MongoDB service..."
sudo systemctl restart mongod
echo "Done!"

# Enable MongoDB service to start on boot
echo "Enabling MongoDB service to start on boot..."
sudo systemctl enable mongod
echo "Done!"