#!/bin/bash
set -eu
NVE_VERSION=$(cat networker/version)
echo "preparing networker ${NVE_VERSION} nve"

govc about

echo "installing jq...."
DEBIAN_FRONTEND=noninteractive apt-get install -qq jq < /dev/null > /dev/null
govc import.spec networker/NVE-${NVE_VERSION}.ova > networker.json
echo "configuring appliance (vami) settings"


jq  --arg address "${NVE_ADDRESS}" '(.PropertyMapping[] | select(.Key == "vami.ip0.brs") | .Value) |= $address' networker.json > "tmp" && mv "tmp" networker.json
jq  --arg gateway "${NVE_GATEWAY}" '(.PropertyMapping[] | select(.Key == "vami.gateway.brs") | .Value) |= $gateway' networker.json > "tmp" && mv "tmp" networker.json
jq  --arg netmask "${NVE_NETMASK}" '(.PropertyMapping[] | select(.Key == "vami.netmask0.brs") | .Value) |= $netmask' networker.json  > "tmp" && mv "tmp" networker.json
jq  --arg dns "${NVE_DNS}" '(.PropertyMapping[] | select(.Key == "vami.DNS.brs") | .Value) |= $dns' networker.json  > "tmp" && mv "tmp" networker.json
jq  --arg fqdn "${NVE_FQDN}" '(.PropertyMapping[] | select(.Key == "vami.fqdn.brs") | .Value) |= $fqdn' networker.json  > "tmp" && mv "tmp" networker.json
jq  --arg network "${NVE_NETWORK}" '(.NetworkMapping[].Name |= $network)' networker.json  > "tmp" && mv "tmp" networker.json
echo "importing networker ${NVE_VERSION} NVE template"
govc import.ova -name ${NVE_VMNAME}  -options=networker.json networker/NVE-${NVE_VERSION}.ova
govc vm.network.change -vm ${NVE_VMNAME} -net=VLAN250 ethernet-0

govc vm.power -on=true ${NVE_VMNAME}
echo "finished DELLEMC Networker  ${NVE_VERSION} NVE install"
echo "Waiting for Appliance Fresh Install to become ready, this can take up to 10 Minutes"
until [[ 200 == $(curl -k --write-out "%{http_code}\n" --silent --output /dev/null "https://${NVE_FQDN}:443/#/fresh") ]] ; do
    printf '.'
    sleep 5
done
echo
echo "Appliance https://${NVE_FQDN}:8443/api/v2 ready for Configuration"

