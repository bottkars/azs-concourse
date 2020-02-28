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
tar xzfv aks-engine/aks-engine-${TAG}-linux-amd64.tar.gz
export SSL_CERT_FILE=${AZURE_CLI_CA_PATH}
aks-engine-${TAG}-linux-amd64/aks-engine upgrade \
    --api-model current-installation/${AKS_RESOURCE_GROUP}/apimodel.json \
    --resource-group $AKS_RESOURCE_GROUP --location ${LOCATION}\
    --upgrade-version ${AKS_ORCHESTRATOR_VERSION_UPDATE} --client-id ${AZURE_CLIENT_ID} \
    --client-secret ${AZURE_CLIENT_SECRET} \
    --subscription-id ${AZURE_SUBSCRIPTION_ID} \
    --azure-env AzureStackCloud --force
timestamp="$(date '+%Y%m%d.%-H%M.%S+%Z')"
export timestamp
APIMODEL_OUTPUT_FILE="$(echo "$APIMODEL_FILE" | envsubst '$timestamp')"
cp current-installation/${AKS_RESOURCE_GROUP}/apimodel.json apimodel/"$APIMODEL_OUTPUT_FILE"

KUBECONFIG_OUTPUT_FILE="$(echo "$KUBECONFIG_FILE" | envsubst '$timestamp')"
cp current-installation/${AKS_RESOURCE_GROUP}/kubeconfig/kubeconfig.*.json kubeconfig/"${KUBECONFIG_OUTPUT_FILE}"

INSTALLATION_OUTPUT_FILE="$(echo "$INSTALLATION_FILE" | envsubst '$timestamp')" 
pushd current-installation
zip -r $OLDPWD/aks-installation/"${INSTALLATION_OUTPUT_FILE}" ${AKS_RESOURCE_GROUP}
popd
