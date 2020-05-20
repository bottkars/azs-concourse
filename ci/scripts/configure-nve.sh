#!/bin/bash
# set -eu
DEBIAN_FRONTEND=noninteractive apt-get install -qq sshpass < /dev/null > /dev/null

echo "waiting for DELLEMC Networker Workflow NveConfig to be ready"
### get the SW Version
until [[ ! -z $NVE_PACKAGE ]]
do
NVE_PACKAGE=$(echo $(govc guest.run -l=admin:changeme \
 /usr/bin/avi-cli --user root --password "changeme" \
 --listbycategory 'SW\ Releases' localhost 2> /dev/null ) \
 | grep NveConfig | awk  '{print $8}')
sleep 5
printf "."
done

echo
if [[ ${NVE_DATADOMAIN_HOST} == "null" ]]; 
then
    echo  "Configuring Networker without DataDomain"
    set -eu
    govc guest.start -i=false -l=root:changeme \
    /usr/bin/avi-cli --user root --password "changeme" --install ${NVE_PACKAGE} \
    --input timezone_name="${NVE_TIMEZONE}" \
    --input admin_password_os=${NVE_ADMIN_PASSWORD_OS} \
    --input root_password_os=${NVE_ROOT_PASSWORD_OS} \
    --input snmp_string=${NVE_SNMP_STRING} \
    --input tomcat_keystore_password=${NVE_TOMCAT_KEYSTORE_PASSWORD} \
    --input authc_admin_password=${NVE_AUTHC_ADMIN_PASSWORD} \
    localhost 
else
    set -eux
    echo "Configuring Networker with DataDomain ${NVE_DATADOMAIN_HOST}"
    # govc guest.start -i=false -l=root:changeme \
    sshpass -p "changeme" /usr/bin/ssh -o "StrictHostKeyChecking no"  \
    admin@nve-dr.home.labbuildr.com \
    /usr/bin/avi-cli --user root --password "changeme" --user root --password "changeme" --install ${NVE_PACKAGE} \
    --input timezone_name="${NVE_TIMEZONE}" \
    --input admin_password_os=${NVE_ADMIN_PASSWORD_OS} \
    --input root_password_os=${NVE_ROOT_PASSWORD_OS} \
    --input snmp_string=${NVE_SNMP_STRING} \
    --input datadomain_host=$NVE_DATADOMAIN_HOST \
    --input storage_path=${NVE_STORAGE_PATH} \
    --input new_ddboost_user=${NVE_NEW_DDBOOST_USER} \
    --input ddboost_user=${NVE_DDBOOST_USER} \
    --input ddboost_user_pwd=${NVE_DDBOOST_USER_PWD} \
    --input ddboost_user_pwd_cf=${NVE_DDBOOST_USER_PWD_CF} \
    --input datadomain_sysadmin=${NVE_DATADOMAIN_SYSADMIN} \
    --input datadomain_sysadmin_pwd=${NVE_DATADOMAIN_SYSADMIN_PWD} \
    --input tomcat_keystore_password=${NVE_TOMCAT_KEYSTORE_PASSWORD} \
    --input authc_admin_password=${NVE_AUTHC_ADMIN_PASSWORD} \
    --input install_avpasswd=false \
    --input add_datadomain_config=true \
    localhost 
fi 


echo "started DELLEMC Networker Workflow ${NVE_PACKAGE}"
echo "Waiting for Networker to become Ready, this can take up to 10 Minutes"
until [[ 200 == $(curl -k --write-out "%{http_code}\n" --silent --output /dev/null "https://${NVE_FQDN}:9000") ]] ; do
    printf '.'
    sleep 5
done

echo
echo "Networker Appliance https://${NVE_FQDN}:9000 is ready !"

## validate new_ddboost_user over ddboost_user

