# Admin tasks 

## Create 3 station wit linux: web01, db01, mon01 

> For this task we use Vagrant for test stand

## Install Mysql-server to the station db01

```
sudo apt update
sudo apt install mysql-server

For new  install of Mysql we have to start security script
user root:
password: 123password

new user mysql> CREATE USER 'sammy'@'localhost' IDENTIFIED BY '1234password';
Query OK, 0 rows affected (0.02 sec)
```
> Use material: https://www.digitalocean.com/community/tutorials/how-to-install-mysql-on-ubuntu-20-04-ru


## Install and setup nginx on station web01

```
sudo apt update
sudo apt install nginx -y
sudo ufw app list
sudo ufw allow 'Nginx HTTP'
sudo ufw status
if Status: inactive
use: sudo ufw enable

check status 
systemctl status nginx
```
> Usefull material: https://www.digitalocean.com/community/tutorials/how-to-install-nginx-on-ubuntu-20-04


## Install and setup PhpmyAdmin

```
sudo apt install phpmyadmin

```
> Usefull material: https://selectel.ru/blog/tutorials/how-to-install-and-configure-phpmyadmin-on-ubuntu-20-04/

## Configure phpMyAdmin with Nginx

```
sudo apt -y install php7.4 php7.4-cli php7.4-fpm php7.4-json php7.4-pdo php7.4-mysql php7.4-zip php7.4-gd php7.4-mbstring php7.4-curl php7.4-xml php-pear php7.4-bcmath

sudo nano /etc/php/7.4/fpm/php.ini
Найдите пункт cgi.fix_pathinfo = 1 и измените его значение на 0 чтобы получилось cgi.fix_pathinfo = 0:

sudo ln -s /usr/share/phpmyadmin /var/www/html/phpmyadmin

sudo nano /etc/nginx/sites-available/default
Найдите строку, содержащую комментарий # Add index.php to the list if you are using PHP и добавьте index.php в строку ниже:
sudo systemctl restart nginx
```


> https://losst.pro/ustanovka-phpmyadmin-s-nginx-v-ubuntu-20-04?ysclid=lui3o8n3vc227840856

> https://www.digitalocean.com/community/tutorials/how-to-install-and-secure-phpmyadmin-with-nginx-on-an-ubuntu-20-04-server 


## To mon01 Install monitoring system Promettheus & Grafana

```
apt update

apt install wget tar
then install chrony
apt install chrony

systemctl enable chrony

systemctl start chrony

then Iptables rules
iptables -I INPUT -p tcp --match multiport --dports 9090,9093,9094,9100 -j ACCEPT

iptables -I INPUT -p udp --dport 9094 -j ACCEPT

apt install iptables-persistent

netfilter-persistent save
then check SELinux
getenforce
```

### Install Prometeus 

```
wget https://github.com/prometheus/prometheus/releases/download/v2.45.0/prometheus-2.45.0.linux-amd64.tar.gz
then 

mkdir /etc/prometheus /var/lib/prometheus

tar -zxf prometheus-*.linux-amd64.tar.gz

cd prometheus-*.linux-amd64

cp prometheus promtool /usr/local/bin/

cp -r console_libraries consoles prometheus.yml /etc/prometheus

cd .. && rm -rf prometheus-*.linux-amd64/ && rm -f prometheus-*.linux-amd64.tar.gz
Create User 
useradd --no-create-home --shell /bin/false prometheus

chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus
chown prometheus:prometheus /usr/local/bin/{prometheus,promtool}
Start Prometeus from user 
sudo -u prometheus /usr/local/bin/prometheus --config.file /etc/prometheus/prometheus.yml --storage.tsdb.path /var/lib/prometheus/ --web.console.templates=/etc/prometheus/consoles --web.console.libraries=/etc/prometheus/console_libraries

then we see in console 

msg="Server is ready to receive web requests."
check in browser
http://<IP-адрес сервера>:9090

```
## Authostart

> Create prometeus.service
```
vi /etc/systemd/system/prometheus.service

[Unit]
Description=Prometheus Service
Documentation=https://prometheus.io/docs/introduction/overview/
After=network.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
 --config.file /etc/prometheus/prometheus.yml \
 --storage.tsdb.path /var/lib/prometheus/ \
 --web.console.templates=/etc/prometheus/consoles \
 --web.console.libraries=/etc/prometheus/console_libraries
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure

[Install]
WantedBy=multi-user.target

then 

systemctl enable prometheus
systemctl start prometheus
systemctl status prometheus
```
> https://www.dmosk.ru/instruktions.php?object=prometheus-linux


## Insrtall Grafana

```
add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"

wget -q -O - https://packages.grafana.com/gpg.key | apt-key add -

apt update
apt install grafana

iptables -A INPUT -p tcp --dport 3000 -j ACCEPT

netfilter-persistent save

systemctl enable grafana-server

systemctl start grafana-server

http://<IP-адрес сервера>:3000. 

login/passwored admin / admin
```

> https://www.dmosk.ru/miniinstruktions.php?mini=grafana-install#ubuntu

## Instal node_exporter to web01 and db01 

```
wget https://github.com/prometheus/node_exporter/releases/download/v1.0.1/node_exporter-1.0.1.linux-amd64.tar.gz

tar -zxf node_exporter-*.linux-amd64.tar.gz

cd node_exporter-*.linux-amd64
cp node_exporter /usr/local/bin/

useradd --no-create-home --shell /bin/false nodeusr

chown -R nodeusr:nodeusr /usr/local/bin/node_exporter

cat > /etc/systemd/system/node_exporter.service <<EOF
[Unit]
Description=Node Exporter Service
After=network.target

[Service]
User=nodeusr
Group=nodeusr
Type=simple
ExecStart=/usr/local/bin/node_exporter
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure

[Install]
WantedBy=multi-user.target

EOF

systemctl daemon-reload
systemctl enable node_exporter
systemctl start node_exporter
```

## Add to prometeus config web01 & db01
```
cd /etc/prometheus/
sudo vi prometheus.yml
global:
  scrape_interval: 10s
scrape_configs:
- job_name: 'prometheus_master'
  scrape_interval: 5s
  static_configs:
   - targets: ['localhost:9090']

- job_name: 'node_exporter_web01'
  scrape_interval: 5s
  static_configs:
    - targets: ['192.168.11.150:9100']

- job_name: 'node_exporter_db01'
  scrape_interval: 5s
  static_configs:
    - targets: ['192.168.11.160:9100']

```