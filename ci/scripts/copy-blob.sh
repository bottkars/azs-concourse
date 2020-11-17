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
az storage blob copy start \
--destination-blob ${DESTINATION_BLOB} \
--destination-container ${DESTINATION_CONTAINER} \
--source-uri ${SOURCE_URI} \
--account-key ${ACCOUNT_KEY} \
--account-name ${ACCOUNT_NAME}