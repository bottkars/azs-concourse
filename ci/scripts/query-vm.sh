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
set -x 
az account set --subscription ${AZURE_SUBSCRIPTION_ID}
generated_state_path="generated-state/$(basename "$STATE_FILE")"
STATE=$(az vm show --name ${VM_NAME} \
  --resource-group ${RESOURCE_GROUP} \
  --output json \
  --query '{VM_ID:name}') 
echo $STATE > ${generated_state_path}   

ls -al
ls -al generated-state


