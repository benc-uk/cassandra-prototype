#!/bin/bash
set -e 

echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "💥 Running a load test in Azure with k6 🚀"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Change as required
region=uksouth
rg=loadtest
prefix=ltbc45
sa_name=${prefix}store
share_name=loadtests
aci_name=${prefix}-runner
# Parameters for the load test 
test_endpoint=https://testapp.kube.benco.io
test_time=30

echo -e "\n🔨 Creating base infra"
az group create --name $rg --location $region -o table
az storage account create --name $sa_name -g $rg --location $region --sku Standard_LRS --query "provisioningState" -o table

export AZURE_STORAGE_CONNECTION_STRING="$(az storage account show-connection-string --name $sa_name -o tsv)"
export STORAGE_KEY="$(az storage account keys list -g $rg -n $sa_name --query "[0].value" -o tsv)"
az storage share create --name $share_name -o table

echo -e "\n📂 Uploading load test file(s)"
az storage file upload --source ./loadtest.js --share-name $share_name --no-progress -o table

echo -e "\n📦 Starting load test container..."
az container create -g $rg --name $aci_name \
  --image loadimpact/k6 \
  --restart-policy Never \
  --command-line "k6 run /home/k6/loadtest.js" \
  --azure-file-volume-share-name $share_name \
  --azure-file-volume-account-name $sa_name \
  --azure-file-volume-account-key $STORAGE_KEY \
  --azure-file-volume-mount-path /home/k6 \
  --environment-variables TEST_API_ENDPOINT=$endpoint TEST_STAGE_TIME=$test_time \
  --query "provisioningState" -o table

echo -e "\n📜 Reading logs..."
az container logs --name $aci_name -g $rg --follow