#!/bin/bash
# set -eu
#!/usr/bin/env bash
function retryop()
{
  retry=0
  max_retries=$2
  interval=$3
  while [ ${retry} -lt ${max_retries} ]; do
    echo "Operation: $1, Retry #${retry}"
    eval $1
    if [ $? -eq 0 ]; then
      echo "Successful"
      break
    else
      let retry=retry+1
      echo "Sleep $interval seconds, then retry..."
      sleep $interval
    fi
  done
  if [ ${retry} -eq ${max_retries} ]; then
    echo "Operation failed: $1"
    exit 1
  fi
}

echo "Installing jq"
curl -s -O -L https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
chmod 755 jq-linux64
chmod +X  jq-linux64
mv jq-linux64 /usr/local/bin/jq


function get_setting() {
  key=$1
  local value=$(echo $settings | jq ".$key" -r)
  echo "${value}" ## ( use "${VAR}" to retain spaces, KB)
}
custom_data_file="/var/lib/waagent/CustomDataClear"
settings=$(cat ${custom_data_file})



AVE_COMMON_PASSWORD=$(get_setting AVE_COMMON_PASSWORD)
EXTERNAL_HOSTNAME=$(get_setting EXTERNAL_HOSTNAME)


WORKFLOW=AveConfig
echo "waiting for AVAMAR $WORKFLOW  to be available"
### get the SW Version
AVE_PASSWORD=$(ip addr | grep -Po '(?!(inet 127.\d.\d.1))(inet \K(\d{1,3}\.){3}\d{1,3})')
until [[ ! -z $AVE_CONFIG ]]
do
AVE_CONFIG=$( /opt/emc-tools/bin/avi-cli --user root --password "${AVE_PASSWORD}" \
 --listrepository localhost 2> /dev/null  \
 | grep ${WORKFLOW} | awk  '{print $1}' )
sleep 5
printf "."
done


echo "waiting for ave-config to become ready"
until [[ $(/opt/emc-tools/bin/avi-cli --user root --password "${AVE_PASSWORD}" \
 --listhistory localhost | grep ave-config | awk  '{print $5}') == "ready" ]]
do
printf "."
sleep 5
done



AVE_TIMEZONE="Europe/Berlin"
AVE_COMMON_PASSWORD="Change_Me12345_"
/opt/emc-tools/bin/avi-cli --user root --password "${AVE_PASSWORD}" --install ave-config  \
    --input timezone_name="${AVE_TIMEZONE}" \
    --input common_password=${AVE_COMMON_PASSWORD} \
    --input use_common_password=true \
    --input repl_password=${AVE_COMMON_PASSWORD} \
    --input rootpass=${AVE_COMMON_PASSWORD} \
    --input mcpass=${AVE_COMMON_PASSWORD} \
    --input viewuserpass=${AVE_COMMON_PASSWORD} \
    --input admin_password_os=${AVE_COMMON_PASSWORD} \
    --input root_password_os=${AVE_COMMON_PASSWORD} \
    localhost
#until [[ 200 == $(curl -k --write-out "%{http_code}\n" --silent --output /dev/null "https://${NVE_FQDN}:9000") ]] ; do
#    printf '.'
#    sleep 5
#done

#echo
#echo "Networker Appliance https://${NVE_FQDN}:9000 is ready !"

## validate new_ddboost_user over ddboost_user

