# Настройка PXE сервера для автоматической установки 
### Настройка призводилась на Ubuntu server 22.04

## Для теста использовался слдующее оборудование:
> HP ProDesk 490 G2 MT 
> HP ProDesk 400 G4
> Switch HP ProCurve 2708

![alt text](dhcppxetftp.png)

> Установим DHCP, TFTP, NFS, syslinux

```
sudo apt install tftpd-hpa isc-dhcp-server syslinux-common
```

> Создадим директорию для загрузочных файлов
```
sudo mkdir /tftpboot
sudo mkdir /tftpboot/pxelinux.cfg
sudo touch /tftpboot/pxelinux.cfg/default
```

> Сечас необходимо открыть TFTP конфигурационный файл 

```
sudo vi /etc/default/tftpd-hpa

# /etc/default/tftpd-hpa

TFTP_USERNAME="tftp"
TFTP_DIRECTORY="/tftpboot"
TFTP_ADDRESS=":69"
TFTP_OPTIONS="--secure"
```

> Также необходимо проверить, что UDP порт 69 доступен в нашей локальной сети, затем

```
sudo systemctl restart tftpd-hpa
```

> Конфигурация DHCP Server 

sudo vi /etc/dhcp/dhcpd.conf 

# Specify the nameservers
option domain-name-servers 8.8.8.8, 8.8.4.4;

# Uncomment this line if you are using your local network
authoritative;

# Configure your subnet
subnet 10.0.0.0 netmask 255.255.0.0 {
    range 10.0.0.30 10.0.0.50;
    #option routers 10.10.30.10;
    filename "pxelinux.0"; # Load file 
    next-server 10.0.0.20; # TFTP Server 
    #option bootfile-name "syslinux.efi";
}

```
> В связи с тем, что это тест, необходимо отключить SELinux and Firewall

```
setenforce 0
sudo uwf disable
```

> Потом стартуем DHCP Server

```
sudo systemctl restart isc-dhcp-server
```

# Устанавливаем и конфигурируем NFS 

```
sudo apt install -y nfs-kernel-server
```

> Создаем папки 

```
sudo mkdir /srv/nfs/ubuntu22_src
```

> Затем редактируем конфигурацию 

```
SETTINGS="/srv/nfs *(ro,sync,no_wdelay,insecure_locks,no_root_squash,insecure,no_subtree_check)"
echo $SETTINGS | sudo tee -a /etc/exports

# Reload the settings
sudo exportfs -a
```

> Модифицируем pxelinux.cfg/default и копируем необходимые файлы

```
sudo apt install -y syslinux pxelinux

sudo cp /usr/lib/PXELINUX/pxelinux.0 /tftpboot
sudo cp /usr/lib/syslinux/modules/bios/{ldlinux.c32,libcom32.c32,libutil.c32,vesamenu.c32} /tftpboot
sudo mkdir -p /tftpboot/pxelinux.cfg
sudo touch /tftpboot/pxelinux.cfg/default
```

```
В качестве основной системы мы взяли ubuntu-22.04.1-live-server-amd64.iso 1.5GB
образ был загружен на флешку
втыкаем ее в системние и проверям командой 
sudo fdisk -l 
Как правило usb устройства идут в конце: sde1 (пример)
Предварительно создадим директорию для монтирования USB 
sudo mkdir /mnt/usb 
sudo mount /dev/sde1 /mnt/usb/
Затем нам необходимо примонтировать все содержимое iso  просто в папку /mnt 

sudo mount -o ro ubuntu-22.04.1-live-server-amd64.iso /mnt 
копируем все содержимое в nfs папку 
sudo cp -r /mnt/* /srv/nfs/ubuntu22_src/

и  в папку созданную для загрузки
sudo cp -r /srv/nfs/ubuntu22_src/casper/{vmlinuz,initrd} /tftpboot/

необходимо также скопировать скрытые директории в нашем случае .disc/
sudo cp -r /mnt/. /srv/nfs/ubuntu22_src/
и 

sudo cp -r /mnt/. /tftpboot/
```
> Редактируем /tftpboot/pxelinux.cfg/default файл следующей конфигурацией
```
default vesamenu.c32

label 18040001
   menu label ^Install Ubuntu 18.04.6
   menu default
   kernel vmlinuz
   append initrd=initrd ip=dhcp boot=casper netboot=nfs nfsroot=10.0.0.10:/srv/nfs/ubuntu22_src/ nosplash toram ---
```

> Рестартуем NFS & tftpd-hpa 

```
sudo systemctl restart tftpd-hpa
sudo systemctl restart nfs-kernel-server
```
> Проверям status services

> Включаем тестовый компьютер (бездисковую станцию) и на мониторе должны быть отображены шаги загрузки  

> Материалы использоване в процессе подготовки:
> https://etesami.github.io/2021/01/03/install-ubuntu-20-04-uefi-pxe.html 
> https://www.youtube.com/watch?v=AMfzFl06zEU&list=PLHHm04DXWzeKl81My_cwbGBqnPdHuIjsv&index=1



