#!/bin/bash
set -eu
cat $(pwd)/config/${CA_CERT} >> ${AZURE_CLI_CA_PATH}
az cloud register -n AzureStackUser \
--endpoint-resource-manager ${ENDPOINT_RESOURCE_MANAGER} \
--suffix-storage-endpoint ${SUFFIX_STORAGE_ENDPOINT} \
--suffix-keyvault-dns ${VAULT_DNS} \
--profile ${PROFILE}
az cloud set -n AzureStackUser
az cloud list --output table
az login --service-principal \
  -u ${AZURE_CLIENT_ID} \
  -p ${AZURE_CLIENT_SECRET} \
  --tenant ${AZURE_TENANT_ID}
set -eux
az account set --subscription ${AZURE_SUBSCRIPTION_ID}
until az storage blob show --account-name ${ACCOUNT_NAME} \
--container-name ${DESTINATION_CONTAINER} \
--name $DESTINATION_BLOB \
--output json --query "[properties.copy.status=='success']" \
2>/dev/null 
do 
  echo "copy operation in progress, retrying in 60 seconds"
  sleep 60
done
