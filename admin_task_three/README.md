# Admin task

## 1.

```
Разверните две виртуальные машины с linux: web01 и files01. 
Можно использовать любые способы создания, 
например в Яндекс Облаке или локально на Vagrant
```

## 2. 

```
Установите NFS-сервер на виртуальную машину “files01”. 
Настройте экспорт директории /files 
sudo apt update
sudo apt install nfs-kernel-server

sudo mkdir /var/nfs/files -p

ls -la /var/nfs/files 
Output
drwxr-xr-x 2 root root 4096 May 14 18:36 

sudo chown nobody:nogroup /var/nfs/files 

sudo nano /etc/exports

example
directory_to_share    client(share_option1,...,share_optionN)

/var/nfs/files *(rw,sync,no_root_squash,no_subtree_check)

sudo systemctl restart nfs-kernel-server
```
## 3. 

```
Установить NFS-клиент на виртуальную машину “web01”.  
Настроить подключение к серверу и получить директории с сервера
sudo apt update
sudo apt install nfs-common

sudo mkdir -p /nfs/files

sudo mount host_ip:/var/nfs/files /nfs/files

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
192.168.11.160:/var/nfs/files   39G  2.0G   37G   5% /nfs/files
```

> Test 

```
sudo touch /nfs/files/general.test

ls -l /nfs/files/general.test

Output
-rw-r--r-- 1 nobody nogroup 0 May  6 12:51 /nfs/files/general.test
```

### Монтирование удаленных каталогов NFS при загрузке 

```
даленные общие ресурсы NFS можно автоматически монтировать при загрузке, 
для чего их нужно добавить в файл /etc/fstab на клиентской системе.

sudo nano /etc/fstab
host_ip:/var/nfs/files    /nfs/files   nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0

man nfs
```

## 4.

### Установите и настройте Nginx на виртуальную машину “web01”. Настроить сервер в качестве proxy на localhost
