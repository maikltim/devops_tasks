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