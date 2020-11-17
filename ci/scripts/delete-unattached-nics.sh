#!/bin/bash
set -eu
figlet AzureStackHub Automation
echo "${CA_CERT}" >> ${AZURE_CLI_CA_PATH}# export AZURE_CLI_DISABLE_CONNECTION_VERIFICATION=1 
# export ADAL_PYTHON_SSL_NO_VERIFY=1
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
IDS=$(az network nic list --resource-group ${RESOURCE_GROUP} --query "[?virtualMachine==null && name!='$OPS_MAN_NIC'].[id]" -o tsv)
if [ -z "${IDS}" ]
then
      echo "no unattached nics found"
else
          az network nic delete --ids ${IDS}
fi
