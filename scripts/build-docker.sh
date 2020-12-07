#!/bin/bash
set -e

./mvnw package
docker build . -f ./src/main/docker/Dockerfile.jvm -t ghcr.io/benc-uk/java-cassandra-test
docker push ghcr.io/benc-uk/java-cassandra-test
