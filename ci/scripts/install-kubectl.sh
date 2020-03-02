#!/bin/bash
set -eu
# KUBECTL_VERSION=$(cat kubectl-release/version)
KUBECTL_VERSION=$(curl https://storage.googleapis.com/kubernetes-release/release/stable.txt)
echo $KUBECTL_VERSION

curl -LO https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl
chmod +x ./kubectl

export KUBECONFIG=kubeconfig/kubeconfig-$(cat kubeconfig/version).json

./kubectl cluster-info

./kubectl get nodes

# echo $STATE | jq --arg iaas azurestack '. + {IAAS: $iaas}' > ${generated_state_path} 
# ls -al
# ls -al generated-state

