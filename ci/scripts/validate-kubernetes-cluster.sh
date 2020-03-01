#!/bin/bash
set -euy


SONOBUOY_VERSION=$(cat sonobuoy-release/version)
tar xzf sonobuoy-release/sonobuoy_${SONOBUOY_VERSION}_linux_amd64.tar.gz
echo "Starting Sonobuoy Validation"
./sonobuoy run --kubeconfig kubeconfig/kubeconfig-*.json --mode ${SONOBUOY_MODE} --wait
RESULTS=$(./sonobuoy retrieve --kubeconfig kubeconfig/kubeconfig-*.json)
./sonobuoy results ${RESULTS}
echo "$RESULTS"
cp ${RESULTS} validation-report/
echo "Removing Sonobuoy"
./sonobuoy delete --kubeconfig kubeconfig/kubeconfig-*.json --wait


# echo $STATE | jq --arg iaas azurestack '. + {IAAS: $iaas}' > ${generated_state_path} 
# ls -al
# ls -al generated-state

