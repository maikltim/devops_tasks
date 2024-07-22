#!/bin/bash

# download
cd /tmp 

curl -LO https://github.com/prometheus/node_exporter/releases/download/v1.4.0/node_exporter-1.4.0.linux-amd64.tar.gz
tar -xvf node_exporter-1.4.0.linux-amd64.tar.gz


# start as service
sudo mv node_exporter-1.4.0.linux-amd64/node_exporter /usr/local/bin/
cd /etc/systemd/system/
sudo touch node_exporter.service

sudo cat > node_exporter.service <<EOF
[Unit]
Description=Node Exporter
After=network-online.target

[Service]
User=vagarnt
Group=vagrant 
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter