#!/bin/bash
set -eu
figlet AzureStackHub Automation
echo "${CA_CERT}" >> ${AZURE_CLI_CA_PATH}
az cloud register -n AzureStackUser \
  --endpoint-resource-manager ${ENDPOINT_RESOURCE_MANAGER} \
  --suffix-storage-endpoint ${SUFFIX_STORAGE_ENDPOINT} \
  --suffix-keyvault-dns ${VAULT_DNS} \
  --profile ${PROFILE}
az cloud set -n AzureStackUser
az login --service-principal \
    -u ${AZURE_CLIENT_ID} \
    -p ${AZURE_CLIENT_SECRET} \
    --tenant ${AZURE_TENANT_ID}
set -eux 
az account set --subscription ${AZURE_SUBSCRIPTION_ID}
SOURCE_URI=$(grep -A0 "${OPSMAN_IMAGE_LOCATION}:" image/*.yml  | tail -n1 | awk '{ print $2 }')
OPSMAN_VHD=$(basename $SOURCE_URI)
IMAGE_URI=https://${ACCOUNT_NAME}.blob.${SUFFIX_STORAGE_ENDPOINT}/${DESTINATION_CONTAINER}/${OPSMAN_VHD}
# opsManVHD will be overwritten to the actual source
az group create --name ${RESOURCE_GROUP} --location ${LOCATION}
az deployment group validate \
  --mode incremental \
  --resource-group ${RESOURCE_GROUP} \
  --parameters config/${PARAMETER_FILE} \
  --parameters ${ADDITIONAL_PARAMETERS} \
  --parameters opsManVHD=${OPSMAN_VHD} \
  --parameters OpsManImageURI=${IMAGE_URI} \
  --parameters boshstorageaccountname=${BOSHSTORAGEACCOUNT} \
  --template-uri ${TEMPLATE_URI} \
  --parameter location=${LOCATION}



