#!/bin/bash

echo "Starting cassandra!"

docker run \
   --name local-cassandra-instance \
   -p 7000:7000 \
   -p 7001:7001 \
   -p 7199:7199 \
   -p 9042:9042 \
   -p 9160:9160 \
   -p 9404:9404 \
   -d \
   launcher.gcr.io/google/cassandra3