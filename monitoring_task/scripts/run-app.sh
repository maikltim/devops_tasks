#!/bin/bash

cd /home/vagrant/laravel-monitoring
export CONTAINER_PREFIX=travellist
sudo docker compose -p $CONTAINER_PREFIX -f docker-compose.yml up -d

# transfer managment rights to vagrant user (fix Permission dinied error after starting application)
sudo chown -R vagrant:vagrant /home/vagrant/laravel-monitoring/