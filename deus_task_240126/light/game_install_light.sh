#!/bin/bash


# update and upgrade Ubuntu

sudo apt-get update && upgrade -y

# nginx config 
sudo mv /etc/nginx/sites-available/default /etc/nginx/sites-available/default.bak


# Set up new nginx config

sudo bash -c 'cat > /etc/nginx/sites-available/default << EOF
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/html;

    index index.html index.htm index.nginx-debian.html;

    server_name _;

    location / {
        proxy_pass http://localhost:8080;
        proxy_buffering off;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-Host \$host;
        proxy_set_header X-Forwarded-Port \$server_port;
    }
}
EOF'

# Link to /etc/nginx/sites-enabled/
ln -s /etc/nginx/sites-enabled/default 

# Restart nginx
sudo service nginx restart

# Check Nginx service status
sudo service nginx status

# or 

service_name="nginx"

if systemctl is-active --quiet $service_name; then
    echo "$service_name is running"
else
    systemctl start "$service_name"
fi


# add Nodejs 16 PPA source

sudo apt-get install nodejs -y

# check version

node --version

# clone project

git clone https://gitfront.io/r/deusops/JnacRhR4iD8q/2048-game/

# go to project directory 

cd /home/vagrant/2048-game

# Go to project directory

npm install --include=dev
npm run build

# run app

npm start

# create systemd service config file

sudo vim /lib/systemd/system/2048-game.service

# put content
[Unit]
Description=2048-game
After=network.target
After=nginx.service

[Service]
Environment=NODE_PORT=8000
Type=simple
User=vagrant
Group=vagrant
WorkingDirectory=/home/vagrant/2048-game
ExecStart=/usr/bin/npm start
Restart=on-failure

[Install]
WantedBy=multi-user.target

# reload systemd daemon

sudo systemctl daemon-reload

# start and enable service

sudo systemctl enable --now 2048-game

