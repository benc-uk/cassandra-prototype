#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

helm repo add bitnami https://charts.bitnami.com/bitnami

helm install cassdb bitnami/cassandra -f $DIR/values.yaml