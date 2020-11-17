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
az cloud list --output table
az login --service-principal \
  -u ${AZURE_CLIENT_ID} \
  -p ${AZURE_CLIENT_SECRET} \
  --tenant ${AZURE_TENANT_ID}
set -eux
az account set --subscription ${AZURE_SUBSCRIPTION_ID}
IDS=$(az image list --resource-group ${RESOURCE_GROUP} --query '[].id' --output tsv)
if [ -z "${IDS}" ]
then
      echo "no orphan images found"
else
          az image delete --ids ${IDS}
fi
