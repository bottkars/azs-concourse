#!/bin/bash
# set -eu

echo "installing jq...."
DEBIAN_FRONTEND=noninteractive apt-get install -qq jq < /dev/null > /dev/null

### get api token
echo "requesting API token"

unset TOKEN
while [[  -z "$TOKEN" ]]; do
    TOKEN=$(curl -s --request POST \
    --url "https://${PPDM_FQDN}:8443/api/v2/login" -k \
    --header 'content-type: application/json' \
    --data '{"username":"admin","password":"admin"}' | jq -r .access_token )
    if [[  -z "$TOKEN" ]]; then
         sleep 5
        printf "."
    fi    
done
set -eu
echo "Retrieving initial appliance configuration"
CONFIGURATION=$(curl -k -sS \
  --header "Authorization: Bearer ${TOKEN}" \
  --fail \
  --url "https://${PPDM_FQDN}:8443/api/v2/configurations" | jq -r ".content[0]")
NODE_ID=$(echo $CONFIGURATION | jq -r .nodeId)  
CONFIGURATION_ID=$(echo $CONFIGURATION | jq -r .id)
printf "Appliance Config State completes: "
STATE=$(curl -ks  \
  --header "Authorization: Bearer ${TOKEN}" \
  --url "https://${PPDM_FQDN}:8443/api/v2/configurations/${CONFIGURATION_ID}/config-status" | jq -r ".percentageCompleted")
echo "${STATE} %"
#echo "retrieving session cookies"
#curl --url "https://${PPDM_FQDN}:443" \
#    --output /dev/null  
#    --cookie-jar cookies.txt -sk
#XSRF_TOKEN=$(cat cookies.txt | grep "XSRF-TOKEN" | awk '{printf $7}')
#CSRF_COOKIE=$(cat cookies.txt | grep "_csrf" | awk '{printf $7}')
# this is a dirty hack, going to build appliance config from jq merge
# most likely in form
# CONFIGURATION=$(echo $CONFIGURATION | jq '(.networks[] | select(.interfaceName == "eth0") | .ipAddressFamily) |= "IPv4"')
#echo "Posting appliance Configuration using CSRF Cookies"
curl -k -s --request PUT \
  --url "https://${PPDM_FQDN}:8443/api/v2/configurations/${CONFIGURATION_ID}" \
  --header "content-type: application/json" \
  --header "Authorization: Bearer ${TOKEN}" \
  --data '{
    "id": "'${CONFIGURATION_ID}'",
    "nodeId": "'${NODE_ID}'",
    "networks": [
      {
        "fqdn": "'${PPDM_FQDN}'",
        "ipAddress": [
          "'${PPDM_ADDRESS}'"
        ],
        "ipAddressFamily": "IPv4",
        "interfaceName": "eth0",
        "netMask": "'${PPDM_NETMASK}'",
        "gateway": "'${PPDM_GATEWAY}'",
        "dnsServers": [
          "'${PPDM_DNS}'"
        ],
        "nslookupSuccess": false
      },
      {
        "ipAddress": [
          "172.24.0.1"
        ],
        "ipAddressFamily": "IPv4",
        "interfaceName": "brpp0",
        "netMask": "255.255.255.0"
      },
      {
        "ipAddress": [
          "172.17.0.1"
        ],
        "ipAddressFamily": "IPv4",
        "interfaceName": "docker0",
        "netMask": "255.255.0.0"
      }
    ],
    "ntpServers": [
      "192.168.1.1"
    ],
    "timeZone": "Europe/Berlin - Central European Time",
    "osUsers": [
      {
        "userName": "root",
        "description": "OS root user account",
        "numberOfDaysToExpire": 59,
        "password": "changeme",
        "newPassword": "'${PPDM_PASSWORD}'"
      },
      {
        "userName": "admin",
        "description": "OS administrator user account",
        "numberOfDaysToExpire": 59,
        "password": "@ppAdm1n",
        "newPassword": "'${PPDM_PASSWORD}'"
      },
      {
        "userName": "support",
        "description": "OS support user account",
        "numberOfDaysToExpire": 59,
        "password": "$upp0rt!",
        "newPassword": "'${PPDM_PASSWORD}'"
      }
    ],
    "lockbox": {
      "name": "Lockbox",
      "lastUpdatedTime": "2020-05-11T18:37:02.576+0000",
      "passphrase": "Ch@ngeme1",
      "newPassphrase": "'${PPDM_PASSWORD}'"
    },
    "configType": "standalone",
    "gettingStartedCompleted": false,
    "autoSupport": false,
    "integratedStorageSecuritySetupCompleted": false,
    "applicationUserPassword": "'${PPDM_PASSWORD}'"
  }'


printf "Appliance Config State: "
curl -ks  \
  --header "Authorization: Bearer ${TOKEN}" \
  --fail \
  --url "https://${PPDM_FQDN}:8443/api/v2/configurations/${CONFIGURATION_ID}/config-status" | jq -r ".status"

echo "Waiting for appliance to reach Config State Success"
echo "% Done: "
while [[ "SUCCESS" != $(curl -ks  \
  --header "Authorization: Bearer ${TOKEN}" \
  --fail \
  --url "https://${PPDM_FQDN}:8443/api/v2/configurations/${CONFIGURATION_ID}/config-status" | jq -r ".status")  ]]; do
    printf '.'
    sleep 10
    printf "$(curl -ks  \
  --header "Authorization: Bearer ${TOKEN}" \
  --url "https://${PPDM_FQDN}:8443/api/v2/configurations/${CONFIGURATION_ID}/config-status" | jq -r ".percentageCompleted")"
done

echo 
echo "You can now login to the Appliance https://${PPDM_FQDN} with your Username and Password"

