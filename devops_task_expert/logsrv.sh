#!/bin/bash


curl -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list

sudo apt update

sudo apt install elasticsearch
sudo vi /etc/elasticsearch/elasticsearch.yml

sudo systemctl start elasticsearch

sudo systemctl enable elasticsearch

# check 

curl -X GET "localhost:9200"

# Kibana

sudo apt install kibana

sudo systemctl enable kibana
sudo systemctl start kibana

echo "kibanaadmin:`openssl passwd -apr1`" | sudo tee -a /etc/nginx/htpasswd.users


# /etc/nginx/sites-available/your_domain

server {
    listen 80;

    server_name your_domain;

    auth_basic "Restricted Access";
    auth_basic_user_file /etc/nginx/htpasswd.users;

    location / {
        proxy_pass http://localhost:5601;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}

sudo ln -s /etc/nginx/sites-available/your_domain /etc/nginx/sites-enabled/your_domain

sudo nginx -t

sudo systemctl reload nginx

sudo ufw allow 'Nginx Full'

# http://your_domain/status

# install Logstash

sudo apt install logstash

vi /etc/logstash/conf.d

# create config file 02-beats-input.conf

sudo vi /etc/logstash/conf.d/02-beats-input.conf

[label /etc/logstash/conf.d/02-beats-input.conf] input { beats { port => 5044 }
}

# create config file 30-elasticsearch-output.conf

sudo vi /etc/logstash/conf.d/30-elasticsearch-output.conf

[label /etc/logstash/conf.d/30-elasticsearch-output.conf] output { if
[@metadata][pipeline] { elasticsearch { hosts => ["localhost:9200"]
manage_template => false index =>
"%{[@metadata][beat]}-%{[@metadata][version]}-%{+YYYY.MM.dd}" pipeline =>
"%{[@metadata][pipeline]}" } } else { elasticsearch { hosts =>
["localhost:9200"] manage_template => false index =>
"%{[@metadata][beat]}-%{[@metadata][version]}-%{+YYYY.MM.dd}" } } }

# test 
sudo -u logstash /usr/share/logstash/bin/logstash --path.settings /etc/logstash -t

sudo systemctl start logstash
sudo systemctl enable logstash

# install  Filebeat

sudo apt install filebeat

sudo vi /etc/filebeat/filebeat.yml

...
#output.elasticsearch:
  # Array of hosts to connect to.
  #hosts: ["localhost:9200"]
...

output.logstash:
  # The Logstash hosts
  hosts: ["localhost:5044"]


################################################
sudo filebeat modules enable system

sudo filebeat modules list

sudo filebeat setup --pipelines --modules system

sudo filebeat setup --index-management -E output.logstash.enabled=false -E 'output.elasticsearch.hosts=["localhost:9200"]'

Output
Index setup finished.

sudo filebeat setup -E output.logstash.enabled=false -E output.elasticsearch.hosts=['localhost:9200'] -E setup.kibana.host=localhost:5601

Output
Overwriting ILM policy is disabled. Set `setup.ilm.overwrite:true` for enabling.

Index setup finished.
Loading dashboards (Kibana must be running and reachable)
Loaded dashboards
Setting up ML using setup --machine-learning is going to be removed in 8.0.0. Please use the ML app instead.
See more: https://www.elastic.co/guide/en/elastic-stack-overview/current/xpack-ml.html
Loaded machine learning job configurations
Loaded Ingest pipelines

sudo systemctl start filebeat
sudo systemctl enable filebeat


curl -XGET 'http://localhost:9200/filebeat-*/_search?pretty'


Output
...
{
{
  "took" : 4,
  "timed_out" : false,
  "_shards" : {
    "total" : 2,
    "successful" : 2,
    "skipped" : 0,
    "failed" : 0
  },
  "hits" : {
    "total" : {
      "value" : 4040,
      "relation" : "eq"
    },
    "max_score" : 1.0,
    "hits" : [
      {
        "_index" : "filebeat-7.7.1-2020.06.04",
        "_type" : "_doc",
        "_id" : "FiZLgXIB75I8Lxc9ewIH",
        "_score" : 1.0,
        "_source" : {
          "cloud" : {
            "provider" : "digitalocean",
            "instance" : {
              "id" : "194878454"
            },
            "region" : "nyc1"
          },
          "@timestamp" : "2020-06-04T21:45:03.995Z",
          "agent" : {
            "version" : "7.7.1",
            "type" : "filebeat",
            "ephemeral_id" : "cbcefb9a-8d15-4ce4-bad4-962a80371ec0",
            "hostname" : "june-ubuntu-20-04-elasticstack",
            "id" : "fbd5956f-12ab-4227-9782-f8f1a19b7f32"
          },


...

# Use 
https://www.digitalocean.com/community/tutorials/how-to-install-elasticsearch-logstash-and-kibana-elastic-stack-on-ubuntu-20-04-ru#4-filebeat