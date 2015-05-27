#!/bin/bash

# $1 is devicename from udev

# Config
VOLUME_ID="2A92E6F52A68A814"
SRC_DIR="/home/ellen/"
BACK_MOUNT=/media/backup

# Programs used
GOODBEEP="aplay /usr/share/sounds/KDE-Im-Phone-Ring.wav "
BADBEEP="aplay /usr/share/sounds/pop.wav "
FDISK="/sbin/fdisk"
AWK="/usr/bin/awk"
GREP="/bin/grep"
ECHO="/bin/echo"
LS="/bin/ls"
VOL_ID=$(blkid -s UUID -o value /dev/backup)
VOL_TYPE=$(blkid -s TYPE -o value /dev/backup)
RSYNC="/usr/bin/rsync"
MOUNT="/bin/mount"
UMOUNT="/bin/umount"
EGREP="/bin/egrep"
LOGGER_TAG="usb backup script: "
R_CODE=1
DATE_LOG=$(date)
USB_BACK_DIR=usb-backup
USB_BACK_LOG=usb-backup-log
LOG_FILE=${BACK_MOUNT}/${USB_BACK_LOG}/${DATE_LOG}.txt

${ECHO} ${1} | ${EGREP} "^sd[a-z][0-9]" || {
        logger -t ${LOGGER_TAG} "- Usage: usb-backup <partition>"
        logger -t ${LOGGER_TAG} "- Example: usb-backup sdd1"
        exit
}


logger -t ${LOGGER_TAG} "backing up data on device: /dev/$1 with UUID: ${VOL_ID}, source: ${SRC_DIR}"
if [ ${VOL_ID} == ${VOLUME_ID} ]; then
	if [ ! -d ${BACK_MOUNT} ]; then
                logger -t ${LOGGER_TAG} "creating backup directory: " ${BACK_MOUNT}
		mkdir -p ${BACK_MOUNT}
	fi
	${MOUNT} /dev/backup ${BACK_MOUNT}
        if [ $? -ne 0 ]; then
                logger -t ${LOGGER_TAG} "device couln't be mounted"
                ${BADBEEP}
                exit 1;
        fi
        #create backup directory
        if [ ! -d ${BACK_MOUNT}/${USB_BACK_DIR} ]; then
                logger -t ${LOGGER_TAG} "creating backup directory on device: " ${BACK_MOUNT}/${USB_BACK_DIR}
		mkdir -p ${BACK_MOUNT}/${USB_BACK_DIR}
	fi
	#create log directory
	if [ ! -d ${BACK_MOUNT}/${USB_BACK_LOG} ]; then
                logger -t ${LOGGER_TAG} "creating backup directory on device: " ${BACK_MOUNT}/${USB_BACK_LOG}
		mkdir -p ${BACK_MOUNT}/${USB_BACK_LOG}
	fi	
	#check if SRC_DIR is available
	if [ ! -d ${SRC_DIR} ]; then
	        logger -t ${LOGGER_TAG} "given source directory is not available: " ${SRC_DIR}
	else
                if [ ${VOL_TYPE} == "vfat" -o ${VOL_TYPE} == "ntfs" ]; then
                        logger -t ${LOGGER_TAG} "syncing data on vfat/ntfs partition type"
                        logger -t ${LOGGER_TAG} "logging to file: " ${LOG_FILE}
                        ${RSYNC} -rlpt --delete --safe-links ${SRC_DIR} ${BACK_MOUNT}/${USB_BACK_DIR} --log-file="${LOG_FILE}" 2>&1 >> "${LOG_FILE}"
                else
                        logger -t ${LOGGER_TAG} "syncing data on ext2/3/4/reiser or other partition type"
                        logger -t ${LOGGER_TAG} "logging to file: " ${LOG_FILE}
                        ${RSYNC} -rlptgoD --delete ${SRC_DIR} ${BACK_MOUNT}/${USB_BACK_DIR} --log-file="${LOG_FILE}" 2>&1 >> "${LOG_FILE}"
                fi
                R_CODE=$?
                sync
        fi
	${UMOUNT} -fr ${BACK_MOUNT}
        if [ $? -eq 0 ]; then
                logger -t ${LOGGER_TAG} "device unmounted successful!"
        fi
	if [ $R_CODE -eq 0 ]; then
		${GOODBEEP}
                logger -t ${LOGGER_TAG} "backing up data successful"
	else
		${BADBEEP}
                logger -t ${LOGGER_TAG} "error backing up some data: "${R_CODE}"."
                logger -t ${LOGGER_TAG} "maybe some permissions couldn't be preserved?"
                logger -t ${LOGGER_TAG} "Please have a look at: " ${USB_BACK_LOG}/${DATE_LOG}.txt
	fi
else
        logger -t ${LOGGER_TAG}  "volume id does not match! Did you reformat the device? If so, then change the volume id in backup script '/usr/local/bin/usb-backup.sh'"
fi

logger -t ${LOGGER_TAG} "backup finished!" 



