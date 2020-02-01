#!/bin/bash
set -e
export AWS_SECRET_ACCESS_KEY=$secret_access_key
export AWS_DEFAULT_REGION=$region_name
export AWS_ACCESS_KEY_ID=$access_key_id
IFS='.'
read -r ASDK_VERSION ASDK_BUILD <<< $(cat asdk/version)
unset IFS
if [[ "${ASDK_BUILD}" != "NONE" ]]
then
    ASDK_VERSION="${ASDK_VERSION}-${ASDK_BUILD}"
fi
URI="${BASEURI}${ASDK_VERSION}"
echo "Downloading AzureStackDevelopmentKit Files from $URI, this may take a wile"
curl "$URI/AzureStackDevelopmentKit.exe" --silent --output cloudbuilder/AzureStackDevelopmentKit.exe
file cloudbuilder/AzureStackDevelopmentKit.exe
aws --endpoint-url "${endpoint}" s3 cp ./cloudbuilder/AzureStackDevelopmentKit.exe s3://${bucket}/${ASDK_VERSION}/AzureStackDevelopmentKit.exe
i=1
filetype=""
until [[ "$filetype" == "text/xml" ]]
do
    if [[ $(aws --endpoint-url "${endpoint}"  s3 ls s3://${bucket}/${ASDK_VERSION}/AzureStackDevelopmentKit-${i}.bin) ]]
    then
        echo "s3://${bucket}/${ASDK_VERSION}/AzureStackDevelopmentKit-${i}.bin already exists, not downloading"
    else
        set +e
        echo "now downloading ${URI}/AzureStackDevelopmentKit-${i}.bin"
        curl "$URI/AzureStackDevelopmentKit-${i}.bin" \
        --connect-timeout 30 \
        --retry 300 \
        --retry-delay 5 \
        --compressed --retry-connrefused \
        --progress-bar -C - --fail \
        --output "cloudbuilder/AzureStackDevelopmentKit-${i}.bin" 
        filetype=$(file cloudbuilder/AzureStackDevelopmentKit-${i}.bin -b --mime-type -E )
        set -e
        if [[ "$filetype" == *"ERROR"* ]] 
        then
            echo "file not Downloaded, retrying"
        elif  [[ "$filetype" != "text/xml" ]] 
        then    
            aws --endpoint-url "${endpoint}" s3 cp ./cloudbuilder/AzureStackDevelopmentKit-${i}.bin s3://${bucket}/${ASDK_VERSION}/AzureStackDevelopmentKit-${i}.bin
            rm -rf ./cloudbuilder/*
        fi  
    fi    
    ((i++))
done