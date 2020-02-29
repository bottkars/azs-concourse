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
TAG=$(cat aks-engine/tag)
tar xzf aks-engine/aks-engine-${TAG}-linux-amd64.tar.gz
export SSL_CERT_FILE=${AZURE_CLI_CA_PATH}
aks-engine-${TAG}-linux-amd64/aks-engine scale \
    --azure-env AzureStackCloud \
    --location ${LOCATION} \
    --resource-group ${AKS_RESOURCE_GROUP} \
    --subscription-id ${AZURE_SUBSCRIPTION_ID} \
    --client-id ${AZURE_CLIENT_ID} \
    --client-secret ${AZURE_CLIENT_SECRET} \
    --api-model current-installation/${AKS_RESOURCE_GROUP}/apimodel.json \
    --new-node-count ${AKS_AGENT_0_NEW_NODE_COUNT} --debug


timestamp="$(date '+%Y%m%d.%-H%M.%S+%Z')"
export timestamp
APIMODEL_OUTPUT_FILE="$(echo "$APIMODEL_FILE" | envsubst '$timestamp')"
cp current-installation/${AKS_RESOURCE_GROUP}/apimodel.json apimodel/"$APIMODEL_OUTPUT_FILE"

KUBECONFIG_OUTPUT_FILE="$(echo "$KUBECONFIG_FILE" | envsubst '$timestamp')"
cp current-installation/${AKS_RESOURCE_GROUP}/kubeconfig/kubeconfig.*.json kubeconfig/"${KUBECONFIG_OUTPUT_FILE}"

INSTALLATION_OUTPUT_FILE="$(echo "$INSTALLATION_FILE" | envsubst '$timestamp')" 
pushd current-installation
tar -qq -r $OLDPWD/aks-installation/"${INSTALLATION_OUTPUT_FILE}" ${AKS_RESOURCE_GROUP}
popd
