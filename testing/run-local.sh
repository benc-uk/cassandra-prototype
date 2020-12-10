#!/bin/bash
export TEST_API_ENDPOINT=https://testapp.kube.benco.io
export TEST_STAGE_TIME=1

k6 run loadtest.js
#k6 run loadtest.js --out influxdb=http://20.71.19.111:8086/k6_results
