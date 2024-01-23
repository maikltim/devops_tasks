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
