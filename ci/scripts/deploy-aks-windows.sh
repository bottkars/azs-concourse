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
aks-engine-${TAG}-linux-amd64/aks-engine deploy \
--azure-env AzureStackCloud \
--location ${LOCATION} \
--resource-group ${AKS_RESOURCE_GROUP} \
--api-model apimodel-json/kubernetes-azurestack.json \
--output-directory ${AKS_RESOURCE_GROUP} \
--client-id ${AZURE_CLIENT_ID} \
--client-secret ${AZURE_CLIENT_SECRET} \
--subscription-id ${AZURE_SUBSCRIPTION_ID} \
--set \
orchestratorProfile.orchestratorRelease=${AKS_ORCHESTRATOR_RELEASE},\
customCloudProfile.portalURL=https://portal.${SUFFIX_STORAGE_ENDPOINT},\
linuxProfile.ssh.publicKeys[0].keyData="${SSH_PUBLIC_KEY}",\
windowsProfile.adminUsername="azureuser",\
windowsProfile.adminPassword="${AKS_WINDOWS_ADMIN_PASSWORD}",\
windowsProfile.sshEnabled="true",\
windowsProfile.windowsPublisher=MicrosoftWindowsServer,\
windowsProfile.windowsOffer=WindowsServer,\
windowsProfile.windowsSku=2019-Datacenter-Core-with-Containers,\
windowsProfile.imageVersion=2019.127.20200204,\
masterProfile.dnsPrefix=${AKS_MASTER_DNS_PREFIX},\
masterProfile.vmSize=${AKS_MASTER_VMSIZE},\
masterProfile.count=${AKS_MASTER_NODE_COUNT},\
masterProfile.distro=${AKS_MASTER_DISTRO},\
agentPoolProfiles[0].vmSize=${AKS_AGENT_0_VMSIZE},\
agentPoolProfiles[0].count=${AKS_AGENT_0_NODE_COUNT},\
agentPoolProfiles[0].osType=${AKS_AGENT_OS_TYPE_0},\
agentPoolProfiles[0].name=${AKS_AGENT_0_POOL_NAME},
servicePrincipalProfile.clientId=${AZURE_CLIENT_ID},\
servicePrincipalProfile.secret=${AZURE_CLIENT_SECRET} --debug

timestamp="$(date '+%Y%m%d.%-H%M.%S+%Z')"
export timestamp

APIMODEL_OUTPUT_FILE="$(echo "$APIMODEL_FILE" | envsubst '$timestamp')"
cp ${AKS_RESOURCE_GROUP}/apimodel.json apimodel/"$APIMODEL_OUTPUT_FILE"

KUBECONFIG_OUTPUT_FILE="$(echo "$KUBECONFIG_FILE" | envsubst '$timestamp')"
cp ${AKS_RESOURCE_GROUP}/kubeconfig/kubeconfig.*.json kubeconfig/"${KUBECONFIG_OUTPUT_FILE}"

INSTALLATION_OUTPUT_FILE="$(echo "$INSTALLATION_FILE" | envsubst '$timestamp')" 
zip -qq -r aks-installation/"${INSTALLATION_OUTPUT_FILE}" ${AKS_RESOURCE_GROUP}

