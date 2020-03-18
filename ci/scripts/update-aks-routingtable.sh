#!/bin/bash
set -eu
echo "${CA_CERT}" >> ${AZURE_CLI_CA_PATH} # beware in "" for keep as single literal
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
az account set --subscription ${AZURE_SUBSCRIPTION_ID}

ROUTINGTABLE=$(az network route-table list -g ${RESOURCE_GROUP} -o json --query '[].id' --output tsv)
az network vnet subnet update \
--route-table ${ROUTINGTABLE} \
--ids "\
/subscriptions/${AZURE_SUBSCRIPTION_ID}/resourceGroups/${AKS_VNET_RG}/providers/Microsoft.Network/VirtualNetworks/${AKS_VNET_NAME}/subnets/${AKS_MASTER_SUBNET_NAME} \
/subscriptions/${AZURE_SUBSCRIPTION_ID}/resourceGroups/${AKS_VNET_RG}/providers/Microsoft.Network/VirtualNetworks/${AKS_VNET_NAME}/subnets/${AKS_AGENT_0_NAME} \
"
