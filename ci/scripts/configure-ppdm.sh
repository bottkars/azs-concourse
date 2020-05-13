#!/bin/bash
set -x

echo "installing jq...."
DEBIAN_FRONTEND=noninteractive apt-get install -qq jq < /dev/null > /dev/null

### get api token
echo "requesting API token"

unset TOKEN
unset CONFIGURATION
i=1
## getting into dirty hack as there is not really a healtz endpoint to check API UP
until [[ ! -z $TOKEN ]]
do
  echo "retrieving TOKEN, try $i"
  TOKEN=$(curl -k -sS --request POST \
      --url "https://${PPDM_FQDN}:8443/api/v2/login" -k \
      --header 'content-type: application/json' \
      --data '{"username":"admin","password":"Password123!"}') 
  if   [[ ! -z $TOKEN ]]
    then
    TOKEN=$(echo $TOKEN | jq -r .access_token )
    echo "Validating token by retrieving Appliance Configuration"
    CONFIGURATION=$(curl -k -sS --request GET \
    --header "Authorization: Bearer ${TOKEN}" \
    --url "https://${PPDM_FQDN}:8443/api/v2/configurations" )
    if [[ ! -z $CONFIGURATION ]]
        then
        CONFIGURATION=$(echo $CONFIGURATION | jq -r ".content[0]" )
    else
        unset TOKEN
        echo "Next Try in 10 Seconds"
        sleep 10
    fi
  else
    echo "Next Try in 10 Seconds"
    sleep 10    
  fi 
((i++))
done

TOKEN=$(curl -k -sS --request POST \
    --url "https://${PPDM_FQDN}:8443/api/v2/login" -k \
    --header 'content-type: application/json' \
    --data '{"username":"admin","password":"admin"}' | jq -r .access_token )
set +x
set -eu

echo "Retrieving initial appliance configuration Template"
# curl -k -sS --request GET \
#     --header "Authorization: Bearer ${TOKEN}" \
#    --url "https://${PPDM_FQDN}:8443/api/v2/configurations"

# CONFIGURATION=$(curl -k -sS --request GET \
#    --header "Authorization: Bearer ${TOKEN}" \
#    --url "https://${PPDM_FQDN}:8443/api/v2/configurations" | jq -r ".content[0]" )
NODE_ID=$(echo $CONFIGURATION | jq -r .nodeId)  
CONFIGURATION_ID=$(echo $CONFIGURATION | jq -r .id)

echo "Customizing Appliance Configuration Template"
CONFIGURATION=$(echo $CONFIGURATION | jq --arg oldpassword changeme --arg password ${PPDM_PASSWORD} '(.osUsers[] | select(.userName == "root").newPassword) |= $password | (.osUsers[] | select(.userName == "root").password) |= $oldpassword')
CONFIGURATION=$(echo $CONFIGURATION | jq --arg oldpassword '@ppAdm1n' --arg password ${PPDM_PASSWORD} '(.osUsers[] | select(.userName == "admin").newPassword) |= $password | (.osUsers[] | select(.userName == "admin").password) |= $oldpassword')
CONFIGURATION=$(echo $CONFIGURATION | jq --arg oldpassword '$upp0rt!' --arg password ${PPDM_PASSWORD} '(.osUsers[] | select(.userName == "support").newPassword) |= $password | (.osUsers[] | select(.userName == "support").password) |= $oldpassword')
CONFIGURATION=$(echo $CONFIGURATION | jq --arg oldpassword 'Ch@ngeme1' --arg password ${PPDM_PASSWORD} '.lockbox.passphrase  |= $oldpassword | .lockbox.newPassphrase  |= $password')
CONFIGURATION=$(echo $CONFIGURATION | jq --arg password ${PPDM_PASSWORD} '.applicationUserPassword |= $password')
CONFIGURATION=$(echo $CONFIGURATION | jq --arg timezone "Europe/Berlin - Central European Time" '.timeZone |= $timezone')
CONFIGURATION=$(echo $CONFIGURATION | jq --arg ntpservers "192.168.1.1" '.ntpServers |= [$ntpservers]')
CONFIGURATION=$(echo $CONFIGURATION | jq 'del(._links)')
printf "Appliance Config State complete: "
STATE=$(curl -ks  \
  --header "Authorization: Bearer ${TOKEN}" \
  --url "https://${PPDM_FQDN}:8443/api/v2/configurations/${CONFIGURATION_ID}/config-status" | jq -r ".percentageCompleted")
echo "${STATE} %"

curl -k -s --request PUT \
  --url "https://${PPDM_FQDN}:8443/api/v2/configurations/${CONFIGURATION_ID}" \
  --header "content-type: application/json" \
  --header "Authorization: Bearer ${TOKEN}" \
  --data "$CONFIGURATION"
  

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
