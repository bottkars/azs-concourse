#!/bin/bash
set -eux
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
TAG=$(cat bosh-cli-release/version)
cp bosh-cli-release/bosh-cli-${TAG}-linux-amd64 /usr/local/bin/bosh
bosh --version
# KUBECTL_VERSION=$(cat kubectl-release/version)
KUBECTL_VERSION=$(curl https://storage.googleapis.com/kubernetes-release/release/stable.txt)
echo $KUBECTL_VERSION
curl -LO https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl
chmod +x ./kubectl
cp kubectl /usr/bin

export KUBECONFIG=kubeconfig/kubeconfig-$(cat kubeconfig/version).json

kubectl cluster-info
kubectl get nodes
kubectl get componentstatuses

echo "installing K14s"
curl -L https://k14s.io/install.sh | bash

cf-for-k8s-master/hack/generate-values.sh "${DNS_DOMAIN}" > cf-values/cf-values.yml
echo "Installing CF..."
cf-for-k8s-master/bin/install-cf.sh cf-values/cf-values.yml  || :
# " get cf_admin_password from cf-values/cf-values.yml "
echo "${DNS_DOMAIN}" 
echo "Configuring DNS..."
SERVICE_IP=""
until [[ ! -z ${SERVICE_IP} ]]
do
    SERVICE_IP=$(kubectl get svc -n istio-system istio-ingressgateway --template="{{range .status.loadBalancer.ingress}}{{.ip}}{{end}}")
    sleep 5
    printf "."
done 
printf "\n"
echo $SERVICE_IP
echo "${DNS_DOMAIN}" 
echo "Configuring DNS for ${DNS_DOMAIN} and *.${DNS_DOMAIN} with ${SERVICE_IP} ..."
az network dns zone create \
    --resource-group aks-3 \
    --name ${DNS_DOMAIN}
az network dns record-set a add-record \
    --resource-group aks-3 \
    --zone-name ${DNS_DOMAIN} \
    --record-set-name "*" \
    --ipv4-address ${SERVICE_IP}
    
timestamp="$(date '+%Y%m%d.%-H%M.%S+%Z')"
export timestamp

CF_CONFIG_OUTPUT_FILE="$(echo "$CF_CONFIG_FILE:" | envsubst '$timestamp')"
cp cf-values/cf-values.yml cf-values/"$CF_CONFIG_OUTPUT_FILE"


