#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

export TEST_API_ENDPOINT=https://protoapp.kube.benco.io
export TEST_STAGE_TIME=20

#INFLUXDB_IP=20.73.203.191
INFLUXDB_IP=$(kubectl get svc -l app.kubernetes.io/name=influxdb -o jsonpath='{.items[0].status.loadBalancer.ingress[0].ip}')

echo "### INFLUXDB_IP is ${INFLUXDB_IP}"
k6 run $DIR/loadtest.js --out influxdb=http://${INFLUXDB_IP}:8086/k6_results
