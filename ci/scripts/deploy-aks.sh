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
TAG=$(cat aks-engine/tag)
tar xzfv aks-engine/aks-engine-${TAG}-linux-amd64.tar.gz
export SSL_CERT_FILE=${AZURE_CLI_CA_PATH}
 ./aks-engine-${TAG}-linux-amd64/aks-engine deploy \
--azure-env AzureStackCloud \
--location ${LOCATION} \
--resource-group ${AKS_RESOURCE_GROUP} \
--api-model ./kubernetes-azurestack.json \
--output-directory ${AKS_RESOURCE_GROUP} \
--client-id ${AZURE_CLIENT_ID} \
--client-secret ${AZURE_CLIENT_SECRET} \
--subscription-id ${AZURE_SUBSCRIPTION_ID} \
--set \
orchestratorProfile.orchestratorRelease=${AKS_ORCHESTRATOR_RELEASE},\
customCloudProfile.portalURL=https://portal.${SUFFIX_STORAGE_ENDPOINT},\
linuxProfile.ssh.publicKeys[0].keyData="${SSH_PUBLIC_KEY}",\
masterProfile.dnsPrefix=${AKS_MASTER_DNS_PREFIX},\
masterProfile.vmSize=${AKS_MASTER_VMSIZE},\
masterProfile.count=${AKS_MASTER_COUNT},\
masterProfile.distro=${AKS_DISTRO},\
agentPoolProfiles[0].vmSize=${AKS_AGENT_VMSIZE},\
agentPoolProfiles[0].count=${AKS_AGENT_COUNT},\
agentPoolProfiles[0].distro=${AKS_DISTRO},\
servicePrincipalProfile.clientId=${AZURE_CLIENT_ID},\
servicePrincipalProfile.secret=${AZURE_CLIENT_SECRET} \
--debug

cp ${AKS_RESOURCE_GROUP}/apimodel.json /apimodel
cp ${AKS_RESOURCE_GROUP}/kubeconfig/kubeconfig.local.json /kubeconfig
tar -czvf installation/installation-${AKS_RESOURCE_GROUP}.tar.gz ./${AKS_RESOURCE_GROUP}

ls -lisaR
printenv