#!/bin/bash
    set -e
    for i in $( seq $FROM $TO )
      do
        i=${i##(0)}
        build=$(printf "%02d" $i)
        url="https://azurestackhub.azureedge.net/PR/download/ASDK_1.${ASDK_VERSION}.0.${build}/AzureStackDevelopmentKit.exe"
        if curl --output /dev/null --silent --head --fail "$url"; then
            echo "URL exists: $url"
            RELEASE=https://azurestack.azureedge.net/asdk${ASDK_VERSION}-${build}
            break
        else
            echo "URL does not exist: $url"
        fi
      done
    if [[ -z "${RELEASE}" ]]
    then
        url="https://azurestackhub.azureedge.net/PR/download/ASDK_1.${ASDK_VERSION}.0.${build}/AzureStackDevelopmentKit.exe"
        echo "trying without build number from $url"
        if curl --output /dev/null --silent --head --fail "$url"
        then
            echo "URL exists: $url"
            RELEASE=https://azurestackhub.azureedge.net/PR/download/ASDK_1.${ASDK_VERSION}
            RELEASEFILE=asdk-release/asdk-${ASDK_VERSION}.yml
            echo "RELEASE: $ASDK_VERSION" >> ${RELEASEFILE}
            echo "BUILD: NONE" >> ${RELEASEFILE}
         else   
            echo "No new Release found"
         fi   
    else
      RELEASEFILE=asdk-release/asdk-1.${ASDK_VERSION}.0.${build}.yml
      echo "RELEASE: $ASDK_VERSION" >> ${RELEASEFILE}
      echo "BUILD: ${build}" >> ${RELEASEFILE}
      cat ${RELEASEFILE}
    fi