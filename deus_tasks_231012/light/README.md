# Light

1. Развернуть 3 виртуальные машины Vagrant (web01, db01, mon01) 

> Развернем три виртуальные машины на Ubuntu 22.04 с IP 
- web01 192.168.50.110
- db01 192.168.50.120
- mon01 192.168.50.130

2. Установить сервер баз данных MySQL на виртуальную машину web01 

```
sudo apt update && sudo apt upgrade -y

sudo apt install mysql-server -y

sudo systemctl status mysql
```

> Настройте MySQL (рекомендуется для безопасности): Запустите скрипт настройки:

```
sudo mysql_secure_installation
```

> Проверьте вход в MySQL

```
sudo mysql -u root -p

sudo mysql
```

```
CREATE USER 'username'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON *.* TO 'username'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

3. Установить и настроить nginx на машину web01

```
sudo apt update && sudo apt upgrade -y

sudo apt install nginx -y
sudo systemctl status nginx

(active (running))

curl http://localhost
```

> Создадим файл конфигурации в /etc/nginx/sites-available/

```
sudo nano /etc/nginx/sites-available/example.com

server {
    listen 80;
    server_name example.com www.example.com;

    root /var/www/example.com/html;
    index index.html index.htm;

    location / {
        try_files $uri $uri/ /index.html;
    }

    error_page 500 502 503 504 /50x.html;
    location = /50x.html {
        root /usr/share/nginx/html;
    }
}
```

> Создадим директорию для сайта

```
sudo mkdir -p /var/www/example.com/html
```

> Активируем конфигурацию: Создадим символическую ссылку в sites-enabled:

```
sudo ln -s /etc/nginx/sites-available/example.com /etc/nginx/sites-enabled/
```

4. Установить приложение phpmyadmin на машине web01 и настроить его для работы с mysql на другом серевере

```
sudo apt update && sudo apt upgrade -y

sudo apt install php-fpm php-mysql php-cli php-mbstring php-zip php-gd unzip -y
```

> Установить phpMyAdmin

```
sudo apt install phpmyadmin -y
```

> Во время установки:
-   Выберить не настраивать веб-сервер автоматически (так как используем NGINX, а не Apache).
-   Выберить No для настройки базы данных с помощью dbconfig-common, так как MySQL находится на другом сервере.

> Создадим символическую ссылку для phpMyAdmin: Чтобы phpMyAdmin был доступен по адресу, например, http://your_server_ip/phpmyadmin

```
sudo ln -s /usr/share/phpmyadmin /var/www/html/phpmyadmin
```

> Настроим NGINX для phpMyAdmin: Отредактируем конфигурацию NGINX (например, /etc/nginx/sites-available/default):

```
sudo nano /etc/nginx/sites-available/default
```

> Добавим блок location для PHP:

```
server {
    listen 80;
    server_name your_server_ip;

    root /var/www/html;
    index index.php index.html index.htm;

    location / {
        try_files $uri $uri/ /index.php?$args;
    }

    location /phpmyadmin {
        alias /usr/share/phpmyadmin;
        index index.php;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.1-fpm.sock; # Проверьте версию PHP (php -v)
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
}
```

> Перезагрузим nginx 

```
sudo systemctl reload nginx
```

> Настроим права доступа: Убедимся, что папка phpMyAdmin доступна:

```
sudo chown -R www-data:www-data /usr/share/phpmyadmin
sudo chmod -R 755 /usr/share/phpmyadmin
```

> Настройка MySQL

> Разрешим удалённые подключения: Отредактируем конфигурацию MySQL (/etc/mysql/my.cnf или /etc/mysql/mysql.conf.d/mysqld.cnf):

```
sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf
```

> Найдидем строку bind-address и измените её:

```
bind-address = 0.0.0.0
```

> Создадим пользователя для phpMyAdmin

```
mysql -u root -p
```

> Создадим пользователя, который сможет подключаться к web01

```
CREATE USER 'phpmyadmin'@'192.168.1.200' IDENTIFIED BY 'your_secure_password';
GRANT ALL PRIVILEGES ON *.* TO 'phpmyadmin'@'192.168.1.200';
FLUSH PRIVILEGES;
EXIT;

mysql -u phpmyadmin -h 192.168.1.100 -p
```

> Настройка phpMyAdmin для работы с удалённым MySQL

```
sudo nano /etc/phpmyadmin/config.inc.php

$cfg['Servers'][$i]['verbose'] = 'Remote MySQL Server';
$cfg['Servers'][$i]['host'] = '192.168.1.100'; // IP сервера B
$cfg['Servers'][$i]['port'] = '3306';
$cfg['Servers'][$i]['connect_type'] = 'tcp';
$cfg['Servers'][$i]['extension'] = 'mysqli';
$cfg['Servers'][$i]['auth_type'] = 'cookie';
$cfg['Servers'][$i]['AllowNoPassword'] = false;

verbose: Имя сервера, отображаемое в интерфейсе.
host: IP-адрес или имя хоста сервера B.
auth_type: Рекомендуется cookie для безопасного ввода логина и пароля через интерфейс.
```

> Откроем phpmyadmin в браузере

```
http://your_server_a_ip/phpmyadmin
```

5. На виртуальной машине mon01 устагновим Prometheus и Grafana

> Установка Prometheus

```
sudo apt update && sudo apt upgrade -y

sudo groupadd --system prometheus
sudo useradd -s /sbin/nologin --system -g prometheus prometheus
sudo mkdir /var/lib/prometheus
for i in rules rules.d files_sd; do sudo mkdir -p /etc/prometheus/${i}; done

wget https://github.com/prometheus/prometheus/releases/download/v2.54.1/prometheus-2.54.1.linux-amd64.tar.gz
tar xvf prometheus-2.54.1.linux-amd64.tar.gz
cd prometheus-2.54.1.linux-amd64
sudo mv prometheus promtool /usr/local/bin/
sudo mv prometheus.yml /etc/prometheus/
sudo mv consoles console_libraries /etc/prometheus/

sudo chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus
sudo chmod -R 775 /etc/prometheus /var/lib/prometheus
```
> Создадим systemd-сервис для Prometheus

```
sudo nano /etc/systemd/system/prometheus.service
```
> И добавим следующее

```
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file=/etc/prometheus/prometheus.yml \
    --storage.tsdb.path=/var/lib/prometheus \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries
Restart=always

[Install]
WantedBy=multi-user.target
```

> Запустить и включить Prometheus

```
sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl enable prometheus

sudo systemctl status prometheus
```


> Проверим веб-интерфейс Prometheus: Откроем браузер и перейдите по адресу http://your_server_ip:9090.

> Установка Grafana

```
sudo apt install -y apt-transport-https software-properties-common wget
```

> репозиторий Grafana

```
sudo mkdir -p /etc/apt/keyrings/
wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee /etc/apt/sources.list.d/grafana.list

sudo apt update
sudo apt install grafana -y
```

> Запустим включим Grafana

```
sudo systemctl daemon-reload
sudo systemctl start grafana-server
sudo systemctl enable grafana-server
```

> Проверим статус

```
sudo systemctl status grafana-server

http://your_server_ip:3000
```

```
Настройка Grafana для работы с Prometheus
Добавьте Prometheus как источник данных:
В Grafana перейдите в Connections > Data Sources > Add data source.
Выберите Prometheus.
В поле URL укажите http://localhost:9090 (или IP сервера, если Prometheus на другом сервере).
Нажмите Save & Test. Вы должны увидеть сообщение "Data source is working".
Импортируйте дашборд для Node Exporter:
Перейдите в Dashboards > New > Import.
Введите ID дашборда 1860 (популярный дашборд "Node Exporter Full") или 14513 (альтернатива).
Выберите источник данных Prometheus и нажмите Import.
Вы увидите дашборд с метриками CPU, памяти, диска и сети.
```

> Установить на web01 и db01 Prometheus-exporter и настроить сбор метрик для мониторинга на mon01 

> Установка и настройка mysqld_exporter на сервере B (MySQL)

```
sudo mysql

CREATE USER 'mysqld_exporter'@'localhost' IDENTIFIED BY 'exporter_secure_password';
GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO 'mysqld_exporter'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

```
wget https://github.com/prometheus/mysqld_exporter/releases/download/v0.15.1/mysqld_exporter-0.15.1.linux-amd64.tar.gz
tar xvf mysqld_exporter-0.15.1.linux-amd64.tar.gz
sudo mv mysqld_exporter-0.15.1.linux-amd64/mysqld_exporter /usr/local/bin/
```

> Создадим конфигурацию для mysqld_exporter

```
sudo nano /etc/mysqld_exporter.cnf

[client]
user=mysqld_exporter
password=exporter_secure_password
```

```
sudo chown root:prometheus /etc/mysqld_exporter.cnf
sudo chmod 640 /etc/mysqld_exporter.cnf
```

> Создадим systemd-сервис для mysqld_exporter

```
sudo nano /etc/systemd/system/mysqld_exporter.service

[Unit]
Description=Prometheus MySQL Exporter
After=network.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/mysqld_exporter \
    --config.my-cnf=/etc/mysqld_exporter.cnf
Restart=always

[Install]
WantedBy=multi-user.target
```

> Запустим службу

```
sudo systemctl daemon-reload
sudo systemctl start mysqld_exporter
sudo systemctl enable mysqld_exporter
```

> Проверим статус 

```
sudo systemctl status mysqld_exporter
```

> Установка и настройка mysqld_exporter на сервере A (NGINX, phpMyAdmin)

> Создадим пользователя MySQL для мониторинга

```
mysql -u root -h 192.168.1.100 -p

CREATE USER 'mysqld_exporter'@'192.168.1.200' IDENTIFIED BY 'exporter_secure_password';
GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO 'mysqld_exporter'@'192.168.1.200';
FLUSH PRIVILEGES;
EXIT;
```

```
wget https://github.com/prometheus/mysqld_exporter/releases/download/v0.15.1/mysqld_exporter-0.15.1.linux-amd64.tar.gz
tar xvf mysqld_exporter-0.15.1.linux-amd64.tar.gz
sudo mv mysqld_exporter-0.15.1.linux-amd64/mysqld_exporter /usr/local/bin/
```

```
sudo nano /etc/mysqld_exporter.cnf

[client]
user=mysqld_exporter
password=exporter_secure_password
host=192.168.1.100
port=3306
```


> systemd-сервис

```
sudo nano /etc/systemd/system/mysqld_exporter.service

[Unit]
Description=Prometheus MySQL Exporter
After=network.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/mysqld_exporter \
    --config.my-cnf=/etc/mysqld_exporter.cnf
Restart=always

[Install]
WantedBy=multi-user.target
```

```
sudo systemctl daemon-reload
sudo systemctl start mysqld_exporter
sudo systemctl enable mysqld_exporter
```

> Настройка Prometheus на сервере mon01

```
sudo nano /etc/prometheus/prometheus.yml

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
  - job_name: 'node_exporter'
    static_configs:
      - targets: ['localhost:9100']
  - job_name: 'mysql_server_b'
    static_configs:
      - targets: ['192.168.1.100:9104']
  - job_name: 'mysql_server_a'
    static_configs:
      - targets: ['192.168.1.200:9104']
```

```
promtool check config /etc/prometheus/prometheus.yml

sudo systemctl restart prometheus
```

> Настройка Grafana на mon01 

```
Добавьте Prometheus как источник данных:
Откройте Grafana: http://192.168.1.300:3000 (логин: admin, пароль: установленный ранее).
Перейдите в Connections > Data Sources > Add data source.
Выберите Prometheus.
Укажите URL: http://localhost:9090.
Нажмите Save & Test.
Импортируйте дашборд для MySQL:
Перейдите в Dashboards > New > Import.
Введите ID дашборда 7362 (популярный дашборд "MySQL Overview") или 14057 (альтернатива).
Выберите источник данных Prometheus.
Нажмите Import.
Вы увидите метрики MySQL (например, запросы, соединения, использование ресурсов).
(Опционально) Настройте дашборд для нескольких серверов: Если хотите видеть метрики с обоих серверов (A и B), настройте дашборд с переменной для выбора job (mysql_server_a или mysql_server_b).
```

```
Источники
Официальная документация mysqld_exporter
Настройка Prometheus и Grafana
Grafana MySQL Dashboards
```