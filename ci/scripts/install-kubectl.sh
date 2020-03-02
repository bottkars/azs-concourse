#!/bin/bash
set -eux


# KUBECTL_VERSION=$(cat kubectl-release/version)
KUBECTL_VERSION=$(wget -O- -q https://storage.googleapis.com/kubernetes-release/release/stable.txt)
echo $KUBECTL_VERSION

curl -LO https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl
chmod +x ./kubectl

export KUBECONFIG=kubeconfig/kubeconfig*.json

kubectl cluster-info

# echo $STATE | jq --arg iaas azurestack '. + {IAAS: $iaas}' > ${generated_state_path} 
# ls -al
# ls -al generated-state

