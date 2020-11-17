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
# set -x
# set +eu
az account set --subscription ${AZURE_SUBSCRIPTION_ID}
IFS=', ' read -r -a array <<< "${RESOURCE_GROUP}"
for GROUP_NAME in "${array[@]}"
do
echo
echo "==> deleting ${GROUP_NAME}"
az group delete --name ${GROUP_NAME} --yes
done
az group list 

