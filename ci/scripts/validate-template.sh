#!/bin/bash
set -eu
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
az group create --name ${RESOURCE_GROUP} --location ${LOCATION}
az deployment group validate \
  --mode incremental \
  --resource-group ${RESOURCE_GROUP} \
  --parameters ${PARAMETER_FILE} \
  --parameters ${ADDITIONAL_PARAMETERS} \
  --template-uri ${TEMPLATE_URI} \
  --parameter location=${LOCATION} \
  --debug



