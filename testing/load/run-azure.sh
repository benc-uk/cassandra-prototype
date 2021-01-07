#!/bin/bash
set -e 

echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "💥 Running a load test in Azure with k6 🚀"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Azure parameters
region=uksouth
rg=loadtest
prefix=bcloadtest0601
# Important parameters for the load test 
test_endpoint=https://protoapp.kube.benco.io
test_stage_time=10

# No need to change these really
sa_name=${prefix}store
share_name_k6=loadtests
k6_name=${prefix}-k6runner

echo -e "\n🔨 Creating base infra"
az group create --name $rg --location $region -o table
az storage account create --name $sa_name -g $rg --location $region --sku Standard_LRS --query "provisioningState" -o table

export AZURE_STORAGE_CONNECTION_STRING="$(az storage account show-connection-string --name $sa_name -o tsv)"
export storage_key="$(az storage account keys list -g $rg -n $sa_name --query "[0].value" -o tsv)"
az storage share create --name $share_name_k6 -o table

echo -e "\n📂 Uploading load test"
az storage file upload --source ./loadtest.js --share-name $share_name_k6 --no-progress -o table

echo -e "\n📦 Starting K6 load test container..."
az container create -g $rg --name $k6_name \
  --image loadimpact/k6 \
  --restart-policy Never \
  --cpu 4 \
  --memory 2 \
  --command-line "k6 run /home/k6/loadtest.js --summary-export \"/home/k6/results_$(date +\"%m-%d-%y_%k-%M\").json\"" \
  --azure-file-volume-share-name $share_name_k6 \
  --azure-file-volume-account-name $sa_name \
  --azure-file-volume-account-key $storage_key \
  --azure-file-volume-mount-path /home/k6 \
  --environment-variables TEST_API_ENDPOINT=$test_endpoint TEST_STAGE_TIME=$test_stage_time \
  --query "provisioningState" -o table

echo -e "\n📜 Reading logs..."
az container logs --name $k6_name -g $rg --follow