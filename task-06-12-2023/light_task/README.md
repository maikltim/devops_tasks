# Admin task

## 1.

```
Разверните две виртуальные машины с linux: web01(vm1) и (vm2). 
Можно использовать любые способы создания, 
например в Яндекс Облаке или локально на Vagrant
```

## 2. 

```
Установите NFS-сервер на виртуальную машину "vm2". 
Настройте экспорт директории /files 
sudo apt update
sudo apt install nfs-kernel-server

sudo mkdir sudo mkdir -p /mnt/nfsdir

ls -la sudo mkdir -p /mnt/nfsdir
Output
drwxr-xr-x 2 root root 4096 May 14 18:36 

sudo chown nobody:nogroup /mnt/nfsdir
sudo chmod 777 /mnt/nfsdir

Добавляем в /etc/exports
sudo nano /etc/exports
/mnt/nfsdir 192.168.50.10/0(rw,sync,no_subtree_check,insecure)

sudo exportfs -a

sudo systemctl restart nfs-kernel-server
```
> Посмотреть смонтированные директории


```
showmount -e
*Export list for files01:
/mnt/nfsdir 192.168.50.10/0


Рестартуем NFS Kernel Server для применения изменений
sudo systemctl restart nfs-kernel-server
```

## 3. 

```
Установить NFS-клиент на виртуальную машину “vm1”.  
Настроить подключение к серверу и получить директории с сервера
sudo apt update
sudo apt install nfs-common -y

sudo mkdir -p /mnt/nfsdir_client

sudo mount 192.168.50.11:/mnt/nfsdir /mnt/nfsdir_client


df -h
root@web01:~# df -h
Filesystem                     Size  Used Avail Use% Mounted on
udev                           975M     0  975M   0% /dev
tmpfs                          199M  972K  198M   1% /run
/dev/sda1                       39G  1.6G   38G   5% /
tmpfs                          992M     0  992M   0% /dev/shm
tmpfs                          5.0M     0  5.0M   0% /run/lock
tmpfs                          992M     0  992M   0% /sys/fs/cgroup
/dev/loop0                      64M   64M     0 100% /snap/core20/1623
/dev/loop1                      68M   68M     0 100% /snap/lxd/22753
/dev/loop2                      48M   48M     0 100% /snap/snapd/17029
vagrant                        937G  379G  559G  41% /vagrant
tmpfs                          199M     0  199M   0% /run/user/1000
192.168.50.11:/mnt/nfsdir	   39G  2.0G   37G   5% /nfs/files
```
> Добавуляем в /etc/fstab


### Монтирование удаленных каталогов NFS при загрузке 

```
даленные общие ресурсы NFS можно автоматически монтировать при загрузке, 
для чего их нужно добавить в файл /etc/fstab на клиентской системе.

sudo nano /etc/fstab

192.168.50.11:/mnt/nfsdir /mnt/nfsdir_client nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0

man nfs
```

## 4.

### Установите и настройте Nginx на виртуальную машину “web01”. Настроить сервер в качестве proxy на localhost

```
sudo apt-get install nginx -y

mv /etc/nginx/sites-available/default /etc/nginx/sites-available/default.bak

bash -c 'cat > /etc/nginx/sites-available/default << EOF 
server {
server_name myproxy;
	listen 80;

	location / {
		proxy_pass http://127.0.0.1:8000;
	}

	location /media/ {
		alias /mnt/nfsdir_client;
	}
}
EOF'

service restart 
Check Nginx service status
systemctl status nginx
```

### Clone project

```
cd /nfs/files/
git clone https://gitfront.io/r/deusops/BC6tmrogTrbh/django-filesharing.git
```

### Install Python && pip
```
sudo apt-get install -y python3-pip
sudo pip3 install django
sudo apt-get install -y python3-venv
sudo pip install djangorestframework whitenoise
sudo python3 -m venv venv
. venv/bin/activate
```

### Copy image directory
```
nano filesharing/settings.py

MEDIA_ROOT = '/mnt/nfsdir_client'
MEDIA_URL = '/media/'
```

### Move to project directory

```
cd /home/vagrant/files/django-filesharing
```
### Set up and activate virtual enviroment, Install requirements, Start server

```
python3 -m venv venv
source venv/bin/activate

pip3 install -r requirements.txt
python3 manage.py migrate
python3 manage.py runserver
```
