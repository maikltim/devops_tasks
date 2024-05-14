#!/bin/bash


IP_NFS_SERVER="192.168.50.121"


# update and upgrade Ubuntu
sudo apt-get update
sudo apt-get upgrade -y

# Install python3-venv and pip

sudo apt-get install python3.10-venv -y
sudo apt-get install python3-pip -y

# Install NFS client

sudo apt-get install nfs-common -y

# Install nginx

sudo apt-get install nginx -y

# Make default nginx backup file 

sudo mv /etc/nginx/sites-available/default /etc/nginx/sites-available/default.bak

# Set up new nginx config file

sudo bash -c 'cat > /etc/nginx/sites-available/default << EOF 
server {
    	listen 80 default_server;
    	listen [::]:80 default_server;

	root /var/www/html;

	index index.html index.htm index.nginx-debian.html;
    	server_name _;
    	location / {
            	proxy_pass http://127.0.0.1:8000;
            	}

}
EOF'


# restart Nginx

sudo systemctl restart nginx

# Check nginx service status

service_name="nginx"

if systemctl is-active --quiet "$service_name.service" ; then 
    echo "$service_name running"
else 
    systemctl start "$service_name"
fi     

mkdir /home/vagrant/files
sudo chown vagrant:vagrant /home/vagrant/files

# Clone project
cd /home/vagrant/files
git clone https://gitfront.io/r/deusops/BC6tmrogTrbh/django-filesharing.git


# Copy immage directory

cp -r /home/vagrant/files/django-filesharing/public/static/image /home/vagrant/image

# Mount NFS shared directory 

sudo mount $IP_NFS_SERVER:/nfs/files /home/vagrant/files/django-filesharing/public/static

# Copy image directory

cd /home/vagrant/files/django-filesharing


# Set up and activate virtual environment
python3 -m venv venv
source venv/bin/activate

# Instal requorements
pip3 install -r requirements.txt

python3 manage.py migrate

# Start server

python3 manage.py runserver 












