# Light task (just for local test)

1. Развернуть виртуальные машины с linux: kafka01,db01, web01 
2. Install Apache Kafka on kafka01 
3. Install Kafka UI on web01, убедитьсься, что web-интерфайс доступен изх браузера
4. Подключить Kafka UI к  Kafka 
5. Install ClickHouse on db01 
6. Настроить базу данных ClickHouse для хранения данных из Kafka 
7. Через UI записать сообщение в Kafka и проверить, что оно появилось в  ClickHouse

## Выполнение
1. Развернем виртуальные машины с помощью Vagrant 

2. Install Apache Kafka on kafka01 

'''
download kafka from https://downloads.apache.org/kafka/3.9.0/
su -l kafka
pass: 123tim
'''

> use this instruction: https://ru.linux-console.net/?p=14017&ysclid=m5qly8v9w83162798


3. Install Kafka UI on web01

> https://inaword.ru/entrprise/kafka-ui-zapusk-bez-dokera-na-lokalnoj-mashine/?ysclid=m5zifoqif1376937516


4. Подключить Kafka UI к Kafka 


5. Install ClickHouse on db01 

```
sudo apt update
sudo apt upgrade -y
sudo apt install -y apt-transport-https ca-certificates dirmngr curl gnupg
curl -fsSL 'https://packages.clickhouse.com/rpm/lts/repodata/repomd.xml.key' | sudo gpg --dearmor -o /usr/share/keyrings/clickhouse-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/clickhouse-keyring.gpg] https://packages.clickhouse.com/deb stable main" | sudo tee /etc/apt/sources.list.d/clickhouse.list
sudo apt update
sudo apt install -y clickhouse-server clickhouse-client
sudo systemctl enable clickhouse-server
sudo systemctl start clickhouse-server
clickhouse-client --password
```

6. Настроить базу данных ClickHouse для хранения данных из Kafka 

> https://clickhouse.com/docs/ru/engines/table-engines/integrations/kafka

```
CREATE TABLE queue (
    timestamp UInt64,
    level String,
    message String
  ) ENGINE = Kafka('localhost:9092', 'topic', 'group1', 'JSONEachRow');

  SELECT * FROM queue LIMIT 5;

  CREATE TABLE queue2 (
    timestamp UInt64,
    level String,
    message String
  ) ENGINE = Kafka SETTINGS kafka_broker_list = 'localhost:9092',
                            kafka_topic_list = 'topic',
                            kafka_group_name = 'group1',
                            kafka_format = 'JSONEachRow',
                            kafka_num_consumers = 4;

  CREATE TABLE queue2 (
    timestamp UInt64,
    level String,
    message String
  ) ENGINE = Kafka('localhost:9092', 'topic', 'group1')
              SETTINGS kafka_format = 'JSONEachRow',
                       kafka_num_consumers = 4;
```
