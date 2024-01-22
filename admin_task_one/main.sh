#!/bin/bash

sudo -i

apt install curl
curl -fsSL https://get.docker.com -o get-docker.sh

chmod +x get-docker.sh

bash ./get-docker.sh