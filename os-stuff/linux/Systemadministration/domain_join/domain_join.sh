#!/bin/bash

JOIN_USER=""
PERMITTED_GROUPS=""
JOIN_PASSWORD=""
DOMAIN_NAME=""
TIMEZONE="Europe/Berlin"



if [ $(id -u) -ne 0 ]; then
        echo "This script must be run as root in order to join to the given domain. Exiting..."
        exit
fi


choose_timezone () {
        local TIMELIST=$(timedatectl list-timezones)
        local COUNTER=1
        local RADIOLIST=""  # variable where we will keep the list entries for radiolist dialog
        local TIMEZONE_NR=0
        
        for i in $TIMELIST; do
                RADIOLIST="$RADIOLIST $COUNTER $i off "
                let COUNTER=COUNTER+1
        done

        TIMEZONE_NR=$(dialog --backtitle "choose timezone" --radiolist "Select option:" 0 0 $COUNTER $RADIOLIST 3>&1 1>&2 2>&3 3>&-)

        COUNTER=1
        for i in $TIMELIST; do
                if [ $COUNTER -eq $TIMEZONE_NR ]; then
                        TIMEZONE=$i
                        break
                fi
                let COUNTER=COUNTER+1
        done
}
 
#find domain controller
DNS_IP=$(systemd-resolve --status | grep "DNS Servers" | cut -d ':' -f 2 | tr -d '[:space:]')
DNS_SERVER_NAME=$(dig +noquestion -x ${DNS_IP} | grep in-addr.arpa | awk -F'PTR' '{print $2}' | tr -d '[:space:]' )
DNS_SERVER_NAME=${DNS_SERVER_NAME%?}
DOMAIN_NAME=$(echo ${DNS_SERVER_NAME} | cut -d '.' -f2-)
DOMAIN_CONTROLLER=$(dialog --title "domain controller" --inputbox "Enter the domain controller you want to use as NTP server. E.g.: srv-dc01.example.local" 10 30 "${DNS_SERVER_NAME}" 3>&1 1>&2 2>&3 3>&-) 
 
#choose the timezone
choose_timezone

#replace the timeserver with domain controller
echo "set timezone"
TIMESYNCD_FILE="/etc/systemd/timesyncd.conf"
if grep -q "#[[:space:]]*NTP" "$TIMESYNCD_FILE"; then
        # if NTP is commented out
        sed -i "s/#[[:space:]]*NTP=/NTP=/g" "$TIMESYNCD_FILE"
fi
sed -i "s/^NTP=.*/NTP=${DOMAIN_CONTROLLER}/g" "$TIMESYNCD_FILE"
timedatectl set-timezone "${TIMEZONE}"
systemctl restart systemd-timesyncd.service


DOMAIN_NAME=$(dialog --title "domain name" --inputbox "Enter the domain name you want to join to. E.g.: example.com or example.local" 10 30 "${DOMAIN_NAME}" 3>&1 1>&2 2>&3 3>&-)

JOIN_USER=$(dialog --title "User for domain join" --inputbox "Enter the user to use for the domain join" 10 30 "" 3>&1 1>&2 2>&3 3>&-)
#join the given domain with the given user
JOIN_PASSWORD=$(dialog --title "Password" --clear --insecure --passwordbox "Enter your password" 10 30 "" 3>&1 1>&2 2>&3 3>&-)
echo "${JOIN_PASSWORD}" | realm -v join -U "${JOIN_USER}" "${DOMAIN_NAME}"
JOIN_PASSWORD=""


#remove later again
exit 0



PERMITTED_GROUPS=$(dialog --title "permitted groups"  --inputbox "Enter the groups of the domain that shall be permitted to log in. Groups must be comma separated." 10 30 "" 3>&1 1>&2 2>&3 3>&-)

#allow all groups that shall be able to log in
echo "allow given groups"
realm deny --all
realm permit "${JOIN_USER}"
IFS=","
for i in ${PERMITTED_GROUPS}
do
    realm permit -g "${i}" 
done

#install krb5-user package in order to not get any dialogs presented, since the configuration files must be there, first.
echo "install krb5-user"
apt install krb5-user -y
#insert rdns=false in section [libdefaults]
sed '/^[libdefaults].*/a rdns=false' /etc/krb5.conf

systemctl restart sssd
