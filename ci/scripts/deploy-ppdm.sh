#!/bin/bash
set -eu
PPDM_VERSION=$(cat powerprotect/version)
echo "preparing powerprotect ${PPDM_VERSION} base install"

govc about

echo "installing jq...."
DEBIAN_FRONTEND=noninteractive apt-get install -qq jq < /dev/null > /dev/null
govc import.spec powerprotect/dellemc-ppdm-sw-${PPDM_VERSION}.ova > powerprotect.json
echo "configuring appliance (vami) settings"
jq  '(.PropertyMapping[] | select(.Key == "vami.ip0.brs") | .Value) |= env.PPDM_ADDRESS' powerprotect.json > "tmp" && mv "tmp" powerprotect.json
jq  '(.PropertyMapping[] | select(.Key == "vami.gateway.brs") | .Value) |= env.PPDM_GATEWAY' powerprotect.json > "tmp" && mv "tmp" powerprotect.json
jq  '(.PropertyMapping[] | select(.Key == "vami.netmask0.brs") | .Value) |= env.PPDM_NETMASK' powerprotect.json  > "tmp" && mv "tmp" powerprotect.json
jq  '(.PropertyMapping[] | select(.Key == "vami.DNS.brs") | .Value) |= env.PPDM_DNS' powerprotect.json  > "tmp" && mv "tmp" powerprotect.json
jq  '(.PropertyMapping[] | select(.Key == "vami.fqdn.brs") | .Value) |= env.PPDM_FQDN' powerprotect.json  > "tmp" && mv "tmp" powerprotect.json
jq  '(.NetworkMapping[].Name |= env.PPDM_NETWORK)' powerprotect.json  > "tmp" && mv "tmp" powerprotect.json
echo "importing powerprotect ${PPDM_VERSION} template"
govc import.ova -name ${PPDM_VMNAME}  -options=powerprotect.json powerprotect/dellemc-ppdm-sw-${PPDM_VERSION}.ova
govc vm.network.change -vm ${PPDM_VMNAME} -net=VLAN250 ethernet-0

govc vm.power -on=true ${PPDM_VMNAME}
echo "finished DELLEMC PowerProtect ${PPDM_VERSION} base install"
echo "Waiting for Appliance Fresh Install to become ready, this can take up to 10 Minutes"
until [[ 200 == $(curl -k --write-out "%{http_code}\n" --silent --output /dev/null "https://${PPDM_FQDN}:443/#/fresh") ]] ; do
    printf '.'
    sleep 5
done
echo
echo "Appliance https://${PPDM_FQDN}:8443/api/v2 ready for Configuration"

