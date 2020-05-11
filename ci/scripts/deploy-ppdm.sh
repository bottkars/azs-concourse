#!/bin/bash
set -eux

PPDM_VERSION=$(cat powerprotect/version)
echo "installing jq...."
DEBIAN_FRONTEND=noninteractive apt-get install -qq jq < /dev/null > /dev/null
govc import.spec powerprotect/dellemc-ppdm-sw-${PPDM_VERSION}.ova > powerprotect.json
echo "configuring appliance (vami) settings"
jq  --arg address "${PPDM_ADDRESS}" '(.PropertyMapping[] | select(.Key == "vami.ip0.brs") | .Value) |= $address' powerprotect.json > "tmp" && mv "tmp" powerprotect.json
jq  --arg gateway "${PPDM_GATEWAY}" '(.PropertyMapping[] | select(.Key == "vami.gateway.brs") | .Value) |= $gateway' powerprotect.json > "tmp" && mv "tmp" powerprotect.json
jq  --arg netmask "${PPDM_NETMASK}" '(.PropertyMapping[] | select(.Key == "vami.netmask0.brs") | .Value) |= $netmask' powerprotect.json  > "tmp" && mv "tmp" powerprotect.json
jq  --arg dns "${PPDM_DNS}" '(.PropertyMapping[] | select(.Key == "vami.DNS.brs") | .Value) |= $dns' powerprotect.json  > "tmp" && mv "tmp" powerprotect.json
jq  --arg fqdn "${PPDM_FQDN}" '(.PropertyMapping[] | select(.Key == "vami.fqdn.brs") | .Value) |= $fqdn' powerprotect.json  > "tmp" && mv "tmp" powerprotect.json
jq  --arg network "${PPDM_NETWORK}" '(.NetworkMapping[].Name |= $network)' powerprotect.json  > "tmp" && mv "tmp" powerprotect.json
echo "importing template"
govc import.ova -name ${PPDM_VMNAME}  -options=powerprotect.json powerprotect/dellemc-ppdm-sw-${PPDM_VERSION}.ova
govc vm.network.change -vm /home_dc/vm/${PPDM_VMNAME} -net=VLAN250 ethernet-0

govc vm.power -on=true  /home_dc/vm/${PPDM_VMNAME}



govc vm.destroy /home_dc/vm/${PPDM_VMNAME}

exit 1
