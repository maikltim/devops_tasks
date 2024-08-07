#!/bin/bash 

sudo -i

apt-get update
apt-get install -y curl openssh-server ca-certificates tzdata htop
curl -sS https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | sudo bash
sudo EXTERNAL_URL="http://gitlab.int" apt-get install -y gitlab-ce