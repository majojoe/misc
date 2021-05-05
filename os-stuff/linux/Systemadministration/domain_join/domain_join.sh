#!/bin/bash

JOIN_USER=""
PERMITTED_GROUPS=""
JOIN_PASSWORD=""
DOMAIN_NAME=""


if [ $(id -u) -ne 0 ]; then
        echo "This script must be run as root in order to join to the given domain. Exiting..."
        exit
fi


#install krb5-user package in order to not get any dialogs presented, since the configuration files must be there, first.
echo "install krb5-user"
apt install krb5-user
#insert rdns=false in section [libdefaults]
sed '/^[libdefaults].*/a rdns=false' /etc/krb5.conf

systemctl restart sssd

DOMAIN_NAME=$(dialog --title "domain name" --default-button ok --inputbox "Enter the domain name you want to join to. E.g.: example.com or example.local" 10 30 "" 3>&1 1>&2 2>&3 3>&-)

JOIN_USER=$(dialog --title "User for domain join" --default-button ok --inputbox "Enter the user to use for the domain join" 10 30 "" 3>&1 1>&2 2>&3 3>&-)
#join the given domain with the given user
JOIN_PASSWORD=$(dialog --title "Password" --clear --insecure --passwordbox "Enter your password" --default-button ok 10 30 "" 3>&1 1>&2 2>&3 3>&-)
echo "${JOIN_PASSWORD}" | realm -v join -U "${JOIN_USER}" "${DOMAIN_NAME}"
JOIN_PASSWORD=""

PERMITTED_GROUPS=$(dialog --title "permitted groups" --default-button ok --inputbox "Enter the groups of the domain that shall be permitted to log in. Groups must be comma separated." 10 30 "" 3>&1 1>&2 2>&3 3>&-)

#allow all groups that shall be able to log in
echo "allow given groups"
realm deny --all
realm permit "${JOIN_USER}"
IFS=","
for i in ${PERMITTED_GROUPS}
do
    realm permit -g "${i}" 
done
