#!/bin/bash
set -eu

echo "installing jq...."
DEBIAN_FRONTEND=noninteractive apt-get install -qq jq sshpass < /dev/null > /dev/null
exit1

sshpass -p "changeme" /usr/bin/ssh -o "StrictHostKeyChecking no"  \
admin@${NVE_FQDN} \
avi-cli --user root --password "changeme" --install localhost \
timezone_name=${NVE_TIMEZONE} \
admin_password_os=${NVE_ADMIN_PASSWORD_OS} \
root_password_os=${NVE_ROOT_PASSWORD_OS} \
snmp_string=${NVE_SNMP_STRING} \
datadomain_host=${NVE_DATADOMAIN_HOST} \
storage_path=${NVE_STORAGE_PATH} \
ddboost_user=${NVE_DDBOOST_USER} \
ddboost_user_pwd=${NVE_DDBOOST_USER_PWD} \
ddboost_user_pwd_cf=${NVE_DDBOOST_USER_PWD_CF} \
datadomain_sysadmin=${NVE_DATADOMAIN_SYSADMIN} \
datadomain_sysadmin_pwd=${NVE_DATADOMAIN_SYSADMIN_PWD} \
tomcat_keystore_password=${NVE_TOMCAT_KEYSTORE_PASSWORD} \
authc_admin_password=${NVE_AUTHC_ADMIN_PASSWORD} 