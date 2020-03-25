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
TAG=$(cat bosh-cli-release/version)
echo "copying bosh relase"
cp bosh-cli-release/bosh-cli-${TAG}-linux-amd64 /usr/local/bin/bosh
chmod 755 /usr/local/bin/bosh
bosh --version
# KUBECTL_VERSION=$(cat kubectl-release/version)
KUBECTL_VERSION=$(curl https://storage.googleapis.com/kubernetes-release/release/stable.txt)
echo $KUBECTL_VERSION
curl -LO https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl
chmod +x ./kubectl
cp kubectl /usr/bin

export KUBECONFIG=$(PWD)/kubeconfig/kubeconfig-$(cat kubeconfig/version).json

kubectl cluster-info
kubectl get nodes
kubectl get componentstatuses

echo "installing K14s"
curl -L https://k14s.io/install.sh | bash
echo "Creating registry gcr values"
echo $GCR_CRED  > gcr.json
tas-for-kubernetes-product/config/cf-for-k8s/hack/generate-values.sh -d "${DNS_DOMAIN}"  -g gcr.json  > cf-values/cf-values.yml
echo "Installing TAS for Kubernetes..."
pushd tas-for-kubernetes-product
echo "Tailoring installation"
rm custom-overlays/replace-loadbalancer-with-clusterip.yaml
rm config/cf-k8s-networking/config/istio/overlays/node-to-ingressgateway-daemonset.yaml

bin/install-tas.sh ${OLDPWD}/cf-values/cf-values.yml || :
popd
# " get cf_admin_password from cf-values/cf-values.yml "
echo "${DNS_DOMAIN}" 
echo "Configuring DNS..."
SERVICE_IP=""
echo "Waiting for Loadbalancer Service IP"
until [[ ! -z ${SERVICE_IP} ]]
do
    SERVICE_IP=$(kubectl get svc -n istio-system istio-ingressgateway --template="{{range .status.loadBalancer.ingress}}{{.ip}}{{end}}")
    sleep 5
    printf "."
done 
printf "\n"
echo $SERVICE_IP 
echo "Configuring DNS for ${DNS_DOMAIN} and *.${DNS_DOMAIN} with ${SERVICE_IP} ..."
az network dns zone create \
    --resource-group ${RESOURCE_GROUP} \
    --name ${DNS_DOMAIN}
az network dns record-set a add-record \
    --resource-group ${RESOURCE_GROUP} \
    --zone-name ${DNS_DOMAIN} \
    --record-set-name "*" \
    --ipv4-address ${SERVICE_IP}
    
timestamp="$(date '+%Y%m%d.%-H%M.%S+%Z')"
export timestamp
CF_CONFIG_OUTPUT_FILE="$(echo "$CF_CONFIG_FILE" | envsubst '$timestamp')"
cp cf-values/cf-values.yml cf-values/"$CF_CONFIG_OUTPUT_FILE"

