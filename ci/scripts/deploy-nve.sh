#!/bin/bash
set -eu
NVE_VERSION=$(cat networker/version)
echo "preparing networker ${NVE_VERSION} nve"

govc about

echo "installing jq...."
DEBIAN_FRONTEND=noninteractive apt-get install -qq jq < /dev/null > /dev/null
govc import.spec networker/NVE-${NVE_VERSION}.ova > networker.json
echo "configuring appliance (vami) settings"

jq  '(.PropertyMapping[] | select(.Key == "vami.ipv4.NetWorker_Virtual_Edition") | .Value) |= env.NVE_ADDRESS' networker.json > "tmp" && mv "tmp" networker.json
jq  '(.PropertyMapping[] | select(.Key == "vami.gatewayv4.NetWorker_Virtual_Edition") | .Value) |= env.NVE_GATEWAY' networker.json > "tmp" && mv "tmp" networker.json
jq  '(.PropertyMapping[] | select(.Key == "vami.DNS.NetWorker_Virtual_Edition") | .Value) |= env.NVE_DNS' networker.json  > "tmp" && mv "tmp" networker.json
jq  '(.PropertyMapping[] | select(.Key == "vami.searchpaths.NetWorker_Virtual_Edition") | .Value) |= env.NVE_SEARCHPATHS' networker.json  > "tmp" && mv "tmp" networker.json
jq  '(.PropertyMapping[] | select(.Key == "vami.NVEtimezone.NetWorker_Virtual_Edition") | .Value) |= env.NVE_TIMEZONE' networker.json  > "tmp" && mv "tmp" networker.json
jq  '(.PropertyMapping[] | select(.Key == "vami.NTP.NetWorker_Virtual_Edition") | .Value) |= env.NVE_NTP' networker.json  > "tmp" && mv "tmp" networker.json
jq  '(.PropertyMapping[] | select(.Key == "vami.vCenterFQDN.NetWorker_Virtual_Edition") | .Value) |= env.GOVC_URL' networker.json  > "tmp" && mv "tmp" networker.json
jq  '(.PropertyMapping[] | select(.Key == "vami.vCenterUsername.NetWorker_Virtual_Edition") | .Value) |= env.GOVC_USERNAME' networker.json  > "tmp" && mv "tmp" networker.json
jq  '(.PropertyMapping[] | select(.Key == "vami.FQDN.NetWorker_Virtual_Edition") | .Value) |= env.NVE_FQDN' networker.json  > "tmp" && mv "tmp" networker.json
# jq  '(.NetworkMapping[].Name |= env.NVE_NETWORK)' networker.json  > "tmp" && mv "tmp" networker.json
# jq  '(.NetworkMapping[].Network |= "ethernet-0")' networker.json  > "tmp" && mv "tmp" networker.json
# jq  '(.PowerOn |= false)' networker.json  > "tmp" && mv "tmp" networker.json
jq  '(.InjectOvfEnv |= true)' networker.json  > "tmp" && mv "tmp" networker.json

echo "importing networker ${NVE_VERSION} NVE template"
govc import.ova -name ${NVE_VMNAME}  -options=networker.json networker/NVE-${NVE_VERSION}.ova
govc vm.network.change -vm ${NVE_VMNAME} -net=VLAN250 ethernet-0

govc vm.power -on=true ${NVE_VMNAME}
echo "finished DELLEMC Networker  ${NVE_VERSION} NVE install"
echo "Waiting for NVE aviinstaller to bevome ready, this can take up to 5 Minutes"
until [[ 200 == $(curl -k --write-out "%{http_code}\n" --silent --output /dev/null "https://${NVE_FQDN}:443/avi/avigui.html") ]] ; do
    printf '.'
    sleep 5
done
echo
echo "Appliance https://${NVE_FQDN}:443/avi/avigui.html is ready for Configuration with root:changeme"

