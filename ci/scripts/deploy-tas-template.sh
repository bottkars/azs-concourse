#!/bin/bash
set -eu
echo "${CA_CERT}" >> ${AZURE_CLI_CA_PATH}    
az cloud register -n AzureStackUser \
  --endpoint-resource-manager ${ENDPOINT_RESOURCE_MANAGER} \
  --suffix-storage-endpoint ${SUFFIX_STORAGE_ENDPOINT} \
  --suffix-keyvault-dns ${VAULT_DNS} \
  --profile ${PROFILE}
az cloud set -n AzureStackUser
az login --service-principal \
  -u ${AZURE_CLIENT_ID} \
  -p ${AZURE_CLIENT_SECRET} \
  --tenant ${AZURE_TENANT_ID}
az account set --subscription ${AZURE_SUBSCRIPTION_ID}
SOURCE_URI=$(grep -A0 "${OPSMAN_IMAGE_LOCATION}:" image/*.yml  | tail -n1 | awk '{ print $2 }')
OPSMAN_VHD=$(basename $SOURCE_URI)
IMAGE_URI=https://${ACCOUNT_NAME}.blob.${SUFFIX_STORAGE_ENDPOINT}/${DESTINATION_CONTAINER}/${OPSMAN_VHD}
# opsManVHD will be overwritten to the actual source
az group create --name ${RESOURCE_GROUP} --location ${LOCATION}
az group deployment create \
  --mode incremental \
  --resource-group ${RESOURCE_GROUP} \
  --parameters config/${PARAMETER_FILE} \
  --parameters ${ADDITIONAL_PARAMETERS} \
  --parameters opsManVHD=${OPSMAN_VHD} \
  --parameters OpsManImageURI=${IMAGE_URI} \
  --parameters boshstorageaccountname=${BOSHSTORAGEACCOUNT} \
  --parameter location=${LOCATION} \
  --parameters opsManVMName=${VM_NAME} \
  --template-uri ${TEMPLATE_URI}
echo "Now Creating Storage Containers"
## create storage containers for bosh
az storage container create --name bosh --account-name ${BOSHSTORAGEACCOUNT}
az storage container create --name stemcell --account-name ${BOSHSTORAGEACCOUNT}
az storage table create --name stemcells --account-name ${BOSHSTORAGEACCOUNT}
## cerate deploymewnt storage accounts
ACCOUNTS=$(az storage account list --resource-group ${RESOURCE_GROUP} --query "[?contains(name,'xtra')].name" --output tsv)   
echo ${ACCOUNTS} |  xargs -n 1 az storage container create --name bosh --account-name
echo ${ACCOUNTS} |  xargs -n 1 az storage container create --name stemcell --account-name
echo ${ACCOUNTS} |  xargs -n 1 az storage table create --name stemcells --account-name
echo "Now generating Config State"

generated_state_path="generated-state/$(basename "$STATE_FILE")"
DEPLOYMENT_ACCOUNTS=$(echo $ACCOUNTS | awk '{print $1;}')

MYSQLSTORAGEACCOUNT=$(az storage account list \
  --resource-group ${RESOURCE_GROUP} \
  --query "[?contains(name,'mysql')].name" \
  --output tsv  )    

MYSQLSTORAGEACCOUNTKEY=$(az storage account list \
  --resource-group ${RESOURCE_GROUP} \
  --query "[?contains(name,'mysql')].name" \
  --output tsv | xargs -n1 az storage account keys list \
  --query '[0].value' --output tsv -n )
echo "deployments_storage_account_name: ${DEPLOYMENT_ACCOUNTS:0:-1}" > ${generated_state_path}
echo "bosh_storage_account_name: ${BOSHSTORAGEACCOUNT}" >> ${generated_state_path}
echo "azure_storage_access_key: ${MYSQLSTORAGEACCOUNTKEY}" >> ${generated_state_path}
echo "azure_account: ${MYSQLSTORAGEACCOUNT}" >> ${generated_state_path}
echo "blob_store_base_url: ${SUFFIX_STORAGE_ENDPOINT}" >> ${generated_state_path}
echo "Waiting for opsman ready"

OPSMAN_PUBLIC_IP=$(az network public-ip list -g ${RESOURCE_GROUP} --query "[?name=='OpsManPublicIP'].ipAddress" --output tsv)
echo "we will use the following public IP´s for Loadbalancers and Opsman:"
az network public-ip list -g ${RESOURCE_GROUP} --query '[].[name,ipAddress]' --output tsv
echo "make sure that dns entries are correct for you domain"
echo "checking opsman api ready using the new fqdn ${OPSMAN_URL}, 
if the . keeps showing, check if ns record for ${OPSMAN_URL} points to ${OPSMAN_PUBLIC_IP}
as server entries"
until $(curl --output /dev/null --silent --head --fail -k -X GET "https://${OPSMAN_URL}/api/v0/info"); do
    printf '.'
    sleep 5
done
echo "done"

