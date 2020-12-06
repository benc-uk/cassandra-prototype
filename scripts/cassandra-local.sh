#!/bin/bash
set -e

echo " ➥ Removing old cassandra container"
docker rm -f local-cassandra-instance
echo " ➥ Starting cassandra!"
docker run -d --name local-cassandra-instance \
-p 7000:7000 \
-p 7001:7001 \
-p 7199:7199 \
-p 9042:9042 \
-p 9160:9160 \
-p 9404:9404 \
launcher.gcr.io/google/cassandra3

echo " ➥ Waiting..."
sleep 20

echo " ➥ Creating keyspace & table"
docker exec -it local-cassandra-instance cqlsh -e \
"CREATE KEYSPACE IF NOT EXISTS k1 WITH replication = {'class':'SimpleStrategy', 'replication_factor':1}"
docker exec -it local-cassandra-instance cqlsh -e \
"CREATE TABLE IF NOT EXISTS k1.fruit(store_id text, name text, description text, PRIMARY KEY((store_id), name))"