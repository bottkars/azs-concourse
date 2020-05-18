#!/bin/bash
set -eu

echo "installing jq...."
# DEBIAN_FRONTEND=noninteractive apt-get install -qq jq sshpass < /dev/null > /dev/null
exit1

sshpass -p "changeme" /usr/bin/ssh -o "StrictHostKeyChecking no"  \
admin@nve-dr.home.labbuildr.com \
avi-cli --user root --password "changeme" --install localhost \
timezone_name=${NVE_TIMEZONE} \
admin_password_os=${NVE_ADMIN_PASSWORD_OS} \
root_password_os=${NVE_ROOT_PASSWORD_OS} \
snmp_string=${NVE_SNMP_STRING} \
datadomain_host=${NVE_DATADOMAIN_HOST} \
storage_path=${NVE_STORAGE_PATH} \
ddboost_user=${} \
ddboost_user_pwd=${} \
ddboost_user_pwd_cf=${} \
datadomain_sysadmin=${} \
datadomain_sysadmin_pwd=${} \
tomcat_keystore_password=${} \
authc_admin_password=${} 