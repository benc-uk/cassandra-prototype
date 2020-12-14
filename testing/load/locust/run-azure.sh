#!/bin/bash
set -e 

echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "💥 Running a load test in Azure with Locust 🚀"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Azure parameters
region=westeurope
rg=loadtest
prefix=bcloadtest1210
# Important parameters for the load test 
# test_endpoint=https://testapp.kube.benco.io
# test_stage_time=35
# influx_dbname=k6_results

# No need to change these really
sa_name=${prefix}store
share_name_locust=loadtests
locust_name=${prefix}-locust

echo -e "\n🔨 Creating base infra"
az group create --name $rg --location $region -o table
az storage account create --name $sa_name -g $rg --location $region --sku Standard_LRS --query "provisioningState" -o table

export AZURE_STORAGE_CONNECTION_STRING="$(az storage account show-connection-string --name $sa_name -o tsv)"
export storage_key="$(az storage account keys list -g $rg -n $sa_name --query "[0].value" -o tsv)"
az storage share create --name $share_name_locust -o table

echo -e "\n📂 Uploading load test & config files"
az storage file upload --source ./loadtest.py --share-name $share_name_locust --no-progress -o table

echo -e "\n📦 Starting load test container..."
az container create -g $rg --name $locust_name \
  --image loadimpact/k6 \
  --restart-policy Never \
  --cpu 4 \
  --memory 2 \
  --azure-file-volume-share-name $share_name_k6 \
  --azure-file-volume-account-name $sa_name \
  --azure-file-volume-account-key $storage_key \
  --azure-file-volume-mount-path /home/k6 \
  --environment-variables TEST_API_ENDPOINT=$test_endpoint TEST_STAGE_TIME=$test_stage_time \
  --query "provisioningState" -o table

echo -e "\n📜 Reading logs..."
az container logs --name $k6_name -g $rg --follow