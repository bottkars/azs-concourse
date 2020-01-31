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
SOURCE_URI=$(grep -A0 "${OPSMAN_IMAGE_LOCATION}:" image/*.yml  | tail -n1 | awk '{ print $2 }')
DESTINATION_BLOB=$(basename $SOURCE_URI)
if [[ $(az storage blob exists \
    --account-name ${ACCOUNT_NAME} \
    --account-key ${ACCOUNT_KEY} \
    --container-name ${DESTINATION_CONTAINER} \
    --name ${DESTINATION_BLOB} \
    --query exists) ==  "true" ]]; then 
    echo ${DESTINATION_BLOB} already exists in ${DESTINATION_CONTAINER}
else
    echo "Starting Copy Operation"
    az storage blob copy start \
    --destination-blob ${DESTINATION_BLOB} \
    --destination-container ${DESTINATION_CONTAINER} \
    --source-uri ${SOURCE_URI} \
    --account-key ${ACCOUNT_KEY} \
    --account-name ${ACCOUNT_NAME}

    until az storage blob show \
    --account-name ${ACCOUNT_NAME} \
    --account-key ${ACCOUNT_KEY} \
    --container-name ${DESTINATION_CONTAINER} \
    --name $DESTINATION_BLOB \
    --output json --query "[properties.copy.status=='success']" \
    2>/dev/null 
    do 
        echo "copy operation in progress, retrying in 60 seconds"
        sleep 60
    done
fi


