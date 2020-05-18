#!/bin/bash
# set -eu

echo "installing jq...."
DEBIAN_FRONTEND=noninteractive apt-get install -qq jq sshpass < /dev/null > /dev/null
exit1


### get the SW Version
NVE_PACKAGE=$(sshpass -p "changeme" /usr/bin/ssh -o "StrictHostKeyChecking no"  admin@${NVE_FQDN} avi-cli --user root --password "changeme" --listbycategory 'SW\ Releases' localhost | grep NveConfig | awk  '{print $1}')

sshpass -p "changeme" /usr/bin/ssh -o "StrictHostKeyChecking no"  \
admin@${NVE_FQDN} \
avi-cli --user root --password "changeme" \
--listbycategory "SW Releases" localhost

if [[ -z ${NVE_DATADOMAIN_HOST} ]]; 
then
    echo  "Configuring without DataDomain Host"

# without DD Host
    set -eu
    sshpass -p "changeme" /usr/bin/ssh -f -o "StrictHostKeyChecking no"  \
    admin@${NVE_FQDN} \
    avi-cli --user root --password "changeme" --install ${NVE_PACKAGE} \
    --input timezone_name="${NVE_TIMEZONE}" \
    --input admin_password_os=${NVE_ADMIN_PASSWORD_OS} \
    --input root_password_os=${NVE_ROOT_PASSWORD_OS} \
    --input snmp_string=${NVE_SNMP_STRING} \
    --input tomcat_keystore_password=${NVE_TOMCAT_KEYSTORE_PASSWORD} \
    --input authc_admin_password=${NVE_AUTHC_ADMIN_PASSWORD} \
    localhost 
else
    set -eu
    echo "Configuring With DataDomain"
    sshpass -p "changeme" /usr/bin/ssh -f  -o "StrictHostKeyChecking no"  \
    admin@${NVE_FQDN} \
    avi-cli --user root --password "changeme" --install ${NVE_PACKAGE} \
    --input timezone_name="${NVE_TIMEZONE}" \
    --input admin_password_os=${NVE_ADMIN_PASSWORD_OS} \
    --input root_password_os=${NVE_ROOT_PASSWORD_OS} \
    --input snmp_string=${NVE_SNMP_STRING} \
    --input datadomain_host=$NVE_DATADOMAIN_HOST \
    --input storage_path=${NVE_STORAGE_PATH} \
    --input ddboost_user=${NVE_DDBOOST_USER} \
    --input ddboost_user_pwd=${NVE_DDBOOST_USER_PWD} \
    --input ddboost_user_pwd_cf=${NVE_DDBOOST_USER_PWD_CF} \
    --input datadomain_sysadmin=${NVE_DATADOMAIN_SYSADMIN} \
    --input datadomain_sysadmin_pwd=${NVE_DATADOMAIN_SYSADMIN_PWD} \
    --input tomcat_keystore_password=${NVE_TOMCAT_KEYSTORE_PASSWORD} \
    --input authc_admin_password=${NVE_AUTHC_ADMIN_PASSWORD} \
    localhost 
fi 
sshpass -p "changeme" /usr/bin/ssh -o "StrictHostKeyChecking no"  \
admin@${NVE_FQDN} \
avi-cli --user root --password "changeme" \
--monitor localhost   