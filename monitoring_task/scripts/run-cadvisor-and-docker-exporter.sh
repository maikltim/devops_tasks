#!/bin/bash
sudo docker run \
    --volume=/:/rootfs:ro \
    --volume=/var/run:/var/run:ro \
    --volume=/sys:/sys:ro \
    --volume=/var/lib/docker/:/var/lib/docker:ro \
    --volume=/dev/disk/:/dev/disk:ro \
    --publish=8080:8080 \
    --detach=true \
    --name=cadvisor \
    google/cadvisor:latest

docker run \
    --name=docker-exporter \
    --detach \
    --restart=always \
    --volume "/var/run/docker.sock":"/var/run/docker.sock" \
    --publish 9417:9417 prometheus/docker_exporter
    