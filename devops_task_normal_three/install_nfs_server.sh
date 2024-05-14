#!/bin/bash

IP="192.168.50.122"


# update and upgrade Ubuntu
sudo apt-get update
sudo apt-get upgrade -y


# Install NFS Server

sudo apt-get -y install nfs-kernel-server


# Create NFS shared directory

sudo mkdir -p /nfs/files

# Change owner ~/files directory
sudo chown -R nobody:nogroup /nfs/files

# Change permission ~/files directory
sudo chmod 777 /nfs/files

# Grant NFS Share Access to Client Systems
echo "/nfs/files *(rw,sync,no_subtree_check,no_root_squash)" > /etc/exports

# Start nfs-server service
sudo systemctl restart nfs-kernel-server

# Check NFS service status
service_name="nfs-kernel-server"

if systemctl is-active --quiet "$service_name.service" ; then
  echo "$service_name successfully installed and running"
else
  systemctl start "$service_name"
fi
