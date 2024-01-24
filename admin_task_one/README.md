# Admin tasks

> Развернуть виртуальные машины с linux с именами: app01, gitlab, vpn01, db01 локально на Vagrant 

> Развернуть СУБД PostgreSQL на виртуальной машине db01. Создать базу данных и пользователя. Разрешить доступ
> только из внутренней сети.

> Развернуть и запустить собственный GitLab по официальной инструкции 

> Создать репозиторий и залить код приложения в собственный GitLab 

> Подготовить окружение и развернуть приложения на сервере app01


# 1 Install GitLab 

```
apt-get update
apt-get install -y curl openssh-server ca-certificates tzdata htop
curl -sS https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | sudo bash
sudo EXTERNAL_URL="http://gitlab.int" apt-get install -y gitlab-ce
```

> Затем запустим машину Vagrant up и по IP можно открыть Gitlab в браузере.

# 2 Install LEMP
> Installing Required PHP modules

"""
Before you can install Laravel, you need to install a few PHP modules that are required by the framework. We’ll use apt to install the php-mbstring, php-xml and php-bcmath PHP modules. These PHP extensions provide extra support for dealing with character encoding, XML and precision mathematics.

If this is the first time using apt in this session, you should first run the update command to update the package manager cache:
"""

"""
sudo apt update
sudo apt install php-mbstring php-xml php-bcmath
"""

> Creating a Database for the Application
"""
To demonstrate Laravel’s basic installation and usage, we’ll create a travel list application to show a list of places a user would like to travel to, and a list of places that they already visited. This can be stored in a places table with a field for locations that we’ll call name and another field to mark them as visited or not visited, which we’ll call visited. Additionally, we’ll include an id field to uniquely identify each entry.

To connect to the database from the Laravel application, we’ll create a dedicated MySQL user, and grant this user full privileges over the travellist database.

At the time of this writing, the native MySQL PHP library mysqlnd doesn’t support caching_sha2_authentication, the default authentication method for MySQL 8. We’ll need to set up our database user with the mysql_native_password authentication method in order to be able to connect to the MySQL database from PHP.

To get started, log in to the MySQL console as the root database user with:
"""

"""
sudo mysql
CREATE DATABASE travellist;
"""

"""
Now you can create a new user and grant them full privileges on the custom database you’ve just created. In this example, we’re creating a user named travellist_user with the password password, though you should change this to a secure password of your choosing:

CREATE USER 'travellist_user'@'%' IDENTIFIED WITH mysql_native_password BY '123tima';

Now we need to give this user permission over the travellist database:

GRANT ALL ON travellist.* TO 'travellist_user'@'%';

This will give the travellist_user user full privileges over the travellist database, while preventing this user from creating or modifying other databases on your server.

Following this, exit the MySQL shell:

mysql> exit
"""

"""
You can now test if the new user has the proper permissions by logging in to the MySQL console again, this time using the custom user credentials:
mysql -u travellist_user -p

Note the -p flag in this command, which will prompt you for the password used when creating the travellist_user user. After logging in to the MySQL console, confirm that you have access to the travellist database:

mysql> SHOW DATABASES;
This will give you the following output:

+--------------------+
| Database           |
+--------------------+
| information_schema |
| travellist        |
+--------------------+
2 rows in set (0.01 sec)
"""

"""
Next, create a table named places in the travellist database. From the MySQL console, run the following statement:

mysql> CREATE TABLE travellist.places (
         id INT AUTO_INCREMENT,
         name VARCHAR(255),
	visited BOOLEAN,
	PRIMARY KEY(id)
);

"""

"""
Now, populate the places table with some sample data:
mysql> INSERT INTO travellist.places (name, visited)
VALUES ("Tokyo", false),
("Budapest", true),
("Nairobi", false),
("Berlin", true),
("Lisbon", true),
("Denver", false),
("Moscow", false),
("Olso", false),
("Rio", true),
("Cincinnati", false),
("Helsinki", false);
"""

"""
To confirm that the data was successfully saved to your table, run:

mysql> SELECT * FROM travellist.places;
"""

"""
You will see output similar to this:
+----+-----------+---------+
| id | name      | visited |
+----+-----------+---------+
|  1 | Tokyo     |       0 |
|  2 | Budapest  |       1 |
|  3 | Nairobi   |       0 |
|  4 | Berlin    |       1 |
|  5 | Lisbon    |       1 |
|  6 | Denver    |       0 |
|  7 | Moscow    |       0 |
|  8 | Oslo      |       0 |
|  9 | Rio       |       1 |
| 10 | Cincinnati|       0 |
| 11 | Helsinki  |       0 |
+----+-----------+---------+
11 rows in set (0.00 sec)
"""

"""
After confirming that you have valid data in your test table, you can exit the MySQL console:
mysql> exit

You’re now ready to create the application and configure it to connect to the new database.
"""

> Creating a New Laravel Application

"""
You will now create a new Laravel application using the composer create-project command. This Composer command is typically used to bootstrap new applications based on existing frameworks and content management systems.

Throughout this guide, we’ll use travellist as an example application, but you are free to change this to something else. The travellist application will display a list of locations pulled from a local MySQL server, intended to demonstrate Laravel’s basic configuration and confirm that you’re able to connect to the database.

First, go to your user’s home directory:

cd ~
"""

"""
The following command will create a new travellist directory containing a barebones Laravel application based on default settings:

composer create-project --prefer-dist laravel/laravel travellist
"""

"""
You will see output similar to this:

Installing laravel/laravel (v5.8.17)
  - Installing laravel/laravel (v5.8.17): Downloading (100%)         
Created project in travellist
> @php -r "file_exists('.env') || copy('.env.example', '.env');"
Loading composer repositories with package information
Updating dependencies (including require-dev)
Package operations: 80 installs, 0 updates, 0 removals
  - Installing symfony/polyfill-ctype (v1.11.0): Downloading (100%)         
  - Installing phpoption/phpoption (1.5.0): Downloading (100%)         
  - Installing vlucas/phpdotenv (v3.4.0): Downloading (100%)         
  - Installing symfony/css-selector (v4.3.2): Downloading (100%)     
...
"""

"""
When the installation is finished, access the application’s directory and run Laravel’s artisan command to verify that all components were successfully installed:

cd travellist
php artisan

You’ll see output similar to this:

Laravel Framework 6.20.44

Usage:
  command [options] [arguments]

Options:
  -h, --help            Display this help message
  -q, --quiet           Do not output any message
  -V, --version         Display this application version
      --ansi            Force ANSI output
      --no-ansi         Disable ANSI output
  -n, --no-interaction  Do not ask any interactive question
      --env[=ENV]       The environment the command should run under
  -v|vv|vvv, --verbose  Increase the verbosity of messages: 1 for normal output, 2 for more verbose output and 3 for debug
...

This output confirms that the application files are in place, and the Laravel command-line tools are working as expected. However, 
we still need to configure the application to set up the database and a few other details.
"""

> Configuring Laravel

"""
The Laravel configuration files are located in a directory called config, inside the application’s root directory. Additionally, when you install Laravel with Composer, it creates an environment file. This file contains settings that are specific to the current environment the application is running, and will take precedence over the values set in regular configuration files located at the config directory. Each installation on a new environment requires a tailored environment file to define things such as database connection settings, debug options, application URL, among other items that may vary depending on which environment the application is running.

We’ll now edit the .env file to customize the configuration options for the current application environment.

Open the .env file using your command line editor of choice. Here we’ll use vi:

vi .env
"""


> Setting Up Nginx

"""
We have installed Laravel on a local folder of your remote user’s home directory, and while this works well for local development environments, it’s not a recommended practice for web servers that are open to the public internet. We’ll move the application folder to /var/www, which is the usual location for web applications running on Nginx.

First, use the mv command to move the application folder with all its contents to /var/www/travellist:

sudo mv ~/travellist /var/www/travellist

Now we need to give the web server user write access to the storage and cache folders, where Laravel stores application-generated files:

sudo chown -R www-data.www-data /var/www/travellist/storage
sudo chown -R www-data.www-data /var/www/travellist/bootstrap/cache


The application files are now in order, but we still need to configure Nginx to serve the content. To do this, we’ll create a new virtual host configuration file at /etc/nginx/sites-available:

sudo vi /etc/nginx/sites-available/travellist

Copy this content to your /etc/nginx/sites-available/travellist file and, if necessary, adjust the highlighted values to align with your own configuration. Save and close the file when you’re done editing.

To activate the new virtual host configuration file, create a symbolic link to travellist in sites-enabled:

sudo ln -s /etc/nginx/sites-available/travellist /etc/nginx/sites-enabled/
"""

"""
To confirm that the configuration doesn’t contain any syntax errors, you can use:

sudo nginx -t

nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
"""

"""
To apply the changes, reload Nginx with:

sudo systemctl reload nginx
"""

"""
usfull links:
https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-laravel-with-nginx-on-ubuntu-20-04
https://www.digitalocean.com/community/tutorials/how-to-install-and-use-composer-on-ubuntu-20-04
"""

> The infrustructure and app is ready to use.

# Развернуть СУБД PostgreSQL на виртуальной машине db01. Создать базу данных и пользователя