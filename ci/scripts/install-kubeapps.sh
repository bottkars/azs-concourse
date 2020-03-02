#!/bin/bash
set -eu
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

echo " .. installing helm"

curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get-helm-3 > get_helm.sh
chmod 700 get_helm.sh
./get_helm.sh

helm repo add bitnami https://charts.bitnami.com/bitnami
kubectl create namespace kubeapps
helm install kubeapps --namespace kubeapps bitnami/kubeapps
kubectl create serviceaccount kubeapps-operator
kubectl create clusterrolebinding kubeapps-operator --clusterrole=cluster-admin --serviceaccount=default:kubeapps-operator
# echo $STATE | jq --arg iaas azurestack '. + {IAAS: $iaas}' > ${generated_state_path} 
# ls -al
# ls -al generated-state

