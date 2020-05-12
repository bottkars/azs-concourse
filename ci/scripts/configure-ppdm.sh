#!/bin/bash
set -eux

echo "installing jq...."
DEBIAN_FRONTEND=noninteractive apt-get install -qq jq < /dev/null > /dev/null

until $(curl --output /dev/null --silent --head  -k -X GET "https://${PPDM_FQDN}:8443/api/v2/info"); do
    printf '.'
    sleep 5
done

curl --request POST \
  --url "https://${PPDM_FQDN}:8443/api/v2/login" -k \
  --header 'content-type: application/json' \
  --data '{"username":"admin","password":"admin"}'

TOKEN=$(curl -s --request POST \
  --url "https://${PPDM_FQDN}:8443/api/v2/login" -k \
  --header 'content-type: application/json' \
  --data '{"username":"admin","password":"admin"}' | jq -r .access_token)

CONFIGURATION_ID=$(curl -k -sS \
  --header "Authorization: Bearer ${TOKEN}" \
  --fail \
  --url "https://${PPDM_FQDN}:8443/api/v2/configurations" | jq -r ".content[0].id")

curl -k -vL --request PUT \
  --url "https://${PPDM_FQDN}/api/v2/configurations/${CONFIGURATION_ID}" \
  --header "authorization: Bearer ${TOKEN}" \
  --header "content-type: application/json" \
  --data '
{
    "applicationUserPassword": "Password123!",
    "autoSupport": true,
    "configType": "standalone",
    "lockbox": {
        "newPassphrase": "Password123!",
        "passphrase": "Password123!"            
    
    },
    "networks": [
        {
            "dnsServers": [
                "192.168.1.44",
                "192.168.1.1",
                "8.8.8.8"
            ],
            "fqdn": "pp-dr.home.labbuildr.com",
            "gateway": "100.250.1.1",
            "interfaceName": "eth0",
            "ipAddress": [
                "100.250.1.130"
            ],
            "ipAddressFamily": "IPv4",
            "netMask": "255.255.255.0",
            "nslookupSuccess": true,
        }
    ],
    "ntpServers": [
        "192.168.1.1"
    ],
    "osUsers": [
        {
            "userName": "root",
            "password": "Password123!",            
            "newPassword": "Password123!",
            "description": "OS root user account",
            "numberOfDaysToExpire": 60
        },
        {
            "userName": "admin",
            "password": "Password123!",            
            "newPassword": "Password123!",
            "numberOfDaysToExpire": 60
        },
        {
            "userName": "support",
            "password": "Password123!",            
            "newPassword": "Password123!",
            "numberOfDaysToExpire": 60
        }
    ],
    "timeZone": " Europe/Berlin - Central European Time"
}'

curl -k -sS \
  --header "Authorization: Bearer ${TOKEN}" \
  --fail \
  --url "https://${PPDM_FQDN}:8443/api/v2/configurations/${CONFIGURATION_ID}/config-status"

/api/v2/configurations/{configurationId}/config-status



#####


"id" : "7aabdac9-b354-4646-a36f-dcd0641fe19f",
    "activationDate" : "2020-05-12T04:48:11.710Z",
    "type" : "TRIAL",
    "status" : "VALID",
    "key" : "Trial Key",
    "licenseKeys" : [ {
      "featureName" : "POWERPROTECT SW TRIAL",
      "startDate" : "2020-05-12T04:48:11.710Z",
      "endDate" : "2020-08-10T04:48:11.710Z",
      "gracePeriod" : "2020-08-10T04:48:11.710Z",
      "plc" : "PPDM"

curl -k -sS \
  --header "Authorization: Bearer ${TOKEN}" \
  --fail \
  --url "https://${PPDM_FQDN}:8443/api/v2/common-settings"


/api/v2/common-settings




####

curl -k -vX --request PUT \
  --url https://${PPDM_FQDN}/api/v2/configurations/5a1bdf39-83c8-4cf4-a782-1763cf78f152 \
  --header "Authorization: Bearer ${TOKEN}" \
  --header "content-type: application/json" \
  --data '
{
"osUsers": [{
"userName": "root",
"newPassword": "Password123!",
"numberOfDaysToExpire": 60
},
{
"userName": "admin",
"newPassword": "Password123!",
"numberOfDaysToExpire": 60
},
{
"userName": "support",
"newPassword": "Password123!",
"numberOfDaysToExpire": 60
}
],
"timeZone": "PST8PDT - Pacific Standard Time"
}'