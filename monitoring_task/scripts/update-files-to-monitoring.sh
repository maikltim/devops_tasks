#!/bin/bash
cd /home/vagrant/laravel-monitoring

sudo cat > docker-compose.yml <<EOF
version: "3.7"
services:
  app:
    build:
      context: ./
      dockerfile: Dockerfile
    image: travellist
    container_name: travellist_app
    restart: unless-stopped
    working_dir: /var/www/
    volumes:
      - ./:/var/www
    networks:
      - travellist

  db:
    image: mysql:8.0
    container_name: travellist_db
    restart: unless-stopped
    environment:
      MYSQL_DATABASE: ${DB_DATABASE}
      MYSQL_ROOT_PASSWORD: ${DB_PASSWORD}
      MYSQL_PASSWORD: ${DB_PASSWORD}
      MYSQL_USER: ${DB_USERNAME}
      SERVICE_TAGS: build
      SERVICE_NAME: mysql
    volumes:
      - ./docker-compose/mysql:/docker-entrypoint-initdb.d
    networks:
      - travellist

  nginx:
    image: nginx:alpine
    container_name: travellist_nginx
    restart: unless-stopped
    ports:
      - 8000:80
    volumes:
      - ./:/var/www
      - ./docker-compose/nginx:/etc/nginx/conf.d/
    networks:
      - travellist
    healthcheck:
      test: curl --fail -s http://localhost:8000 || exit 1
      interval: 20s
      timeout: 10s
      retries: 5

  sidecar:
    build:
      context: .
      dockerfile: Dockerfile_sidecar
    container_name: travellist-sidecar
    restart: "no"
    command: sh ./sidecar.sh
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    networks:
      - travellist
    depends_on:
      - app


networks:
  travellist:
    driver: bridge
EOF

# add docker metrics-addr
cd /etc/docker
sudo touch daemon.json
sudo cat > daemon.json <<EOF
{
  "metrics-addr" : "127.0.0.1:9323",
  "experimental" : true
}
EOF

sudo systemctl daemon-reload
sudo systemctl restart docker
