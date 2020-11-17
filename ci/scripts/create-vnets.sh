#!/bin/bash
set -eu
figlet AzureStackHub Automation

DEPLOYMENT=$(\
az deployment group create \
--mode Incremental \
--template-file ~/workspace/azs-concourse/templates/aks-network-azuredeploy.json \
--resource-group AKSvnets \
--parameters VNETName=AKSVnet0 \
--parameters MasterSubnet=MasterSubnet0 \
--parameters AgentSubnet=AgentSubnet0 \
--parameters AgentAddressPrefix="10.200.0.0/24" \
--parameters MasterAddressPrefix="10.100.0.0/24" \

)