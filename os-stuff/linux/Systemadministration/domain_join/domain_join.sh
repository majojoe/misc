#!/bin/bash -e

trap onexit ERR

#trap handler 
onexit() { 
        echo "!!!!!!!!!!!!!!!!! ERROR while executing domain join !!!!!!!!!!!!!!!!!"
        exit 1
}


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
DOMAIN_CONTROLLER=$(dialog --title "domain controller" --inputbox "Enter the domain controller you want to use as NTP server. \\nE.g.: srv-dc01.example.local" 12 40 "${DNS_SERVER_NAME}" 3>&1 1>&2 2>&3 3>&-) 

#set domain name in realm configuration
REALMD_FILE="/etc/realmd.conf"
if [ -f "${REALMD_FILE}" ]; then
        sed -i "s/DOMAIN_NAME/${DOMAIN_NAME}/g" "${REALMD_FILE}"
fi

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

DOMAIN_NAME=$(dialog --title "domain name" --inputbox "Enter the domain name you want to join to. \\nE.g.: example.com or example.local" 12 40 "${DOMAIN_NAME}" 3>&1 1>&2 2>&3 3>&-)

JOIN_USER=$(dialog --title "User for domain join" --inputbox "Enter the user to use for the domain join" 10 30 "Administrator" 3>&1 1>&2 2>&3 3>&-)
#join the given domain with the given user
JOIN_PASSWORD=$(dialog --title "Password" --clear --insecure --passwordbox "Enter your password" 10 30 "" 3>&1 1>&2 2>&3 3>&-)
echo "${JOIN_PASSWORD}" | realm -v join -U "${JOIN_USER}" "${DOMAIN_NAME}"
JOIN_PASSWORD=""


#install krb5-user package in order to not get any dialogs presented, since the configuration files must be there, first.
echo "install krb5-user"
KRB5_UNCONF="/etc/krb5.conf.unconfigured"
KRB5_CONF="/etc/krb5.conf"
if [ -f "${KRB5_UNCONF}" ]; then
        cp "${KRB5_UNCONF}" "${KRB5_CONF}"
        sed -i "s/REALM_NAME/${DOMAIN_NAME^^}/g" "${KRB5_CONF}"
fi
apt install krb5-user -y



PERMITTED_GROUPS=$(dialog --title "permitted groups"  --inputbox "Enter the groups of the domain that shall be permitted to log in. Groups must be comma separated.\\nLeave blank if you want allow all domain users to login." 12 50 "" 3>&1 1>&2 2>&3 3>&-)

#remove spaces
PERMITTED_GROUPS=$(echo ${PERMITTED_GROUPS} | tr -d '[:space:]')

clear

if [ -z "${PERMITTED_GROUPS}" ]; then
        echo "permit all users to login"
        realm permit --all
else
        #allow all groups that shall be able to log in
        echo "allow given groups"
        realm deny --all
        realm permit "${JOIN_USER}@${DOMAIN_NAME}"
        SAVEIFS=$IFS
        IFS=","
        for i in ${PERMITTED_GROUPS}
        do
                realm permit -g "${i}" 
        done
        IFS=$SAVEIFS
fi

systemctl restart sssd



echo "############### DOMAIN JOIN SUCCESSFUL #################"
