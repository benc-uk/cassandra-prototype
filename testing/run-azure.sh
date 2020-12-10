#!/bin/bash
set -e 

echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "💥 Running a load test in Azure with k6 🚀"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Azure parameters
region=westeurope
rg=loadtest
prefix=bcloadtest1210
# Important parameters for the load test 
test_endpoint=https://testapp.kube.benco.io
test_stage_time=35
influx_dbname=k6_results

# No need to change these really
sa_name=${prefix}store
share_name_k6=loadtests
share_name_influx=influx-data
share_name_grafana=grafana-provisioning
k6_name=${prefix}-k6runner
influx_name=${prefix}-influx-grafana

echo -e "\n🔨 Creating base infra"
az group create --name $rg --location $region -o table
az storage account create --name $sa_name -g $rg --location $region --sku Standard_LRS --query "provisioningState" -o table

export AZURE_STORAGE_CONNECTION_STRING="$(az storage account show-connection-string --name $sa_name -o tsv)"
export storage_key="$(az storage account keys list -g $rg -n $sa_name --query "[0].value" -o tsv)"
az storage share create --name $share_name_k6 -o table
az storage share create --name $share_name_influx -o table
az storage share create --name $share_name_grafana -o table

echo -e "\n📂 Uploading load test & config files"
az storage file upload --source ./loadtest.js --share-name $share_name_k6 --no-progress -o table
az storage directory create --name datasources --share-name $share_name_grafana -o table
az storage file upload --source ./datasource.yaml --share-name $share_name_grafana --path datasources/influx.yaml --no-progress -o table

# Build YAML for influx-grafana ACI
REGION=$region \
ACI_NAME=$influx_name \
STORAGE_ACCOUNT=$sa_name \
STORAGE_KEY=$storage_key \
envsubst < ./influx-grafana.yaml > /tmp/influx-grafana.yaml

echo -e "\n📦 Starting InfluxDB & Grafana container..."
az container create -g $rg --file /tmp/influx-grafana.yaml \
  --query "provisioningState" -o table

influxdb_ip=$(az container show  -g $rg --name $influx_name --query "ipAddress.ip" -o tsv)
echo -e "\n🌐 InfluxDB IP address: $influxdb_ip"
echo -e "🌐 InfluxDB database: $influx_dbname"
echo -e "🌐 Login to Grafana here: http://$influxdb_ip:3000/"

echo -e "\n📦 Starting load test container..."
az container create -g $rg --name $k6_name \
  --image loadimpact/k6 \
  --restart-policy Never \
  --cpu 4 \
  --memory 2 \
  --command-line "k6 run /home/k6/loadtest.js --out influxdb=http://$influxdb_ip:8086/$influx_dbname" \
  --azure-file-volume-share-name $share_name_k6 \
  --azure-file-volume-account-name $sa_name \
  --azure-file-volume-account-key $storage_key \
  --azure-file-volume-mount-path /home/k6 \
  --environment-variables TEST_API_ENDPOINT=$test_endpoint TEST_STAGE_TIME=$test_stage_time \
  --query "provisioningState" -o table

echo -e "\n📜 Reading logs..."
az container logs --name $k6_name -g $rg --follow