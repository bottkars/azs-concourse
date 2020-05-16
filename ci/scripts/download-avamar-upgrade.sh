#!/bin/bash
set -eu

echo "installing jq...."
DEBIAN_FRONTEND=noninteractive apt-get install -qq jq < /dev/null > /dev/null
AV_BASEURL=$(echo $avamar | jq -r ".BaseURL")
AV_LOCATION=$(echo $avamar | jq -r ".location")
AV_RELEASE=$(echo $avamar | jq -r ".release")
AV_VERSION=$(echo $avamar | jq -r ".version")

for PACKAGE in AvamarUpgrade UpgradeAvinstaller UpgradeClientDownloads UpgradeClientPluginCatalog ChangeNetworkSettings
# for PACKAGE in UpgradeAvinstaller  ChangeNetworkSettings
do
    echo "downloading ${PACKAGE} ${AV_RELEASE}"
    echo "from ${AV_BASEURL}/${AV_LOCATION}/${PACKAGE}-${AV_RELEASE}.avp"
    curl --disable-epsv -o ${PACKAGE}/${PACKAGE}-${AV_RELEASE}.avp ${AV_BASEURL}/${AV_LOCATION}/${PACKAGE}-${AV_RELEASE}.avp
done

