#!/bin/bash

DOMAIN_CONTROLLER="srv-dc01.maier.localnet"
JOIN_USER="Administrator"



FILE_SERVER=$(dialog --title "fileserver" --inputbox "Enter the fileserver to use for mounting of drives when a user logs in. \\nE.g.: srv-file01.example.local" 12 40 "${DOMAIN_CONTROLLER}" 3>&1 1>&2 2>&3 3>&-) 
DRIVE_LIST=$(smbclient -k -N  -U ${JOIN_USER} -L "${FILE_SERVER}" 2> /dev/null | grep Disk  | grep -v -E "ADMIN\\$|SYSVOL|NETLOGON" | cut -d " " -f 1 | grep -E "[a-zA-Z0-9]{2,}(\\$)*" | tr -d '\t')

COUNTER=1
for i in $DRIVE_LIST; do
        CHECKLIST="$CHECKLIST $i ${COUNTER} off "
        let COUNTER=COUNTER+1
done

DRIVE_LIST=$(dialog --backtitle "Choose Drives to mount" --checklist "Choose which drives shall be mounted when a user logs in..." 0 0 ${COUNTER} ${CHECKLIST} 3>&1 1>&2 2>&3 3>&-)
dialog --clear
clear

for i in ${DRIVE_LIST}; do
        i=$(echo ${i} | tr -d '"')
        MNT_POINT=$(echo ${i} | tr -d '$')
        echo "<volume fstype=\"cifs\" server=\"${FILE_SERVER}\" path=\"${i}\" mountpoint=\"/media/%(USER)/${MNT_POINT}\" options=\"iocharset=utf8,nosuid,nodev\" uid=\"5000-999999999\" />"
done
