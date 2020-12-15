#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

echo "🔹 Removing old Cassandra container"
docker rm -f cassandradb

set -e
echo "🔹 Starting Cassandra..."
docker run -d --name cassandradb \
-v "$DIR:/tmp/cql" \
-p 9042:9042 \
bitnami/cassandra

echo "🔹 Waiting 20s for Cassandra to start..."
sleep 20

echo "🔹 Initialising the daatabase"
docker exec -it cassandradb cqlsh -u cassandra -p cassandra -f /tmp/cql/init.cql
