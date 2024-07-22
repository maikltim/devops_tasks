#!/bin/bash


sudo apt-get update
sudo apt-get install apt-transport-https ca-certificates -y
sudo update-ca-certificates

cd /home/vagrant
git clone https://gitfront.io/r/deusops/B2vPJxQWdXLf/laravel-monitoring.git