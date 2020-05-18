#!/bin/bash
set -eu

echo "installing jq...."
DEBIAN_FRONTEND=noninteractive apt-get install -qq jq < /dev/null > /dev/null

exit1

timezone_name: "Europe/Berlin"
admin_password_os: "Password123!"
root_password_os: "Password123!"
snmp_string: public
datadomain_host: ddve1.home.labbuildr.com
storage_path: nvedr
ddboost_user: boostnvedr
ddboost_user_pwd: "Password123!"
ddboost_user_pwd_cf: "Password123!"
datadomain_sysadmin: sysadmin
datadomain_sysadmin_pwd: "Password123!"
tomcat_keystore_password: "Password123!"
authc_admin_password: "Password123!"