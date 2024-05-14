#!/bin/bash

# Update and upgrade Ubuntu
sudo apt-get update
sudo apt-get upgrade -y

# uninstall all conflicting packages
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podamn-docker containerd runc; do sudo apt-get remove $pkg; done


# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certicates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update OS
sudo apt-get update

# Install the lates version 
sudo apt-get -y install docker-ce docker-compose docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Check Nginx service status
service_name="docker"

if systemctl is-active --quiet "$service_name.service" ; then
  echo "$service_name running"
else
  systemctl start "$service_name"
fi

# Add your user to the docker group
sudo usermod -aG docker $USER

# activate the changes to groups
newgrp docker


