#!/bin/bash
# Output to a logfile
BACKUP_DIR="/home/ncbackup/"    
KEEP_ONLY_ONE_BACKUP=1

#create Backup directory if not existing
if [ ! -d "${BACKUP_DIR}/Backups/" ]; then
        echo "creating backup dir"
        mkdir "${BACKUP_DIR}/Backups/"
        mkdir "${BACKUP_DIR}/Backups/Logs/"
fi

LOGFILE="${BACKUP_DIR}/Backups/Logs/$(date '+%Y-%m-%d_%H-%M-%S').txt"
echo "logging to logfile: ${LOGFILE}"
exec &> >(tee -a "${LOGFILE}")

if [ ${KEEP_ONLY_ONE_BACKUP} -eq 1 ]; then
        echo "delete all old backups..."
        rm "${BACKUP_DIR}/Backups/*.tar.gz"
        echo "old backups deleted"
fi

echo ""
echo "Starting Nextcloud export..."
# Run a Nextcloud backup (-a apps, -b database, -c configuration, -d data)
#nextcloud.export -a -b -c
#export all
nextcloud.export
echo "Export complete"

echo ""    
if [ ${KEEP_ONLY_ONE_BACKUP} -eq 0 ]; then
        echo "remove all old backups, but keep the 2 newest..."
        # Remove all backups but the newest 2 ones
        FILES_TO_REMOVE=$(find "${BACKUP_DIR}/Backups/" -maxdepth 1 -type f -printf '%T@\t"%p"\n' | sort -r -t $'\t' -g | tail +3 | cut -d $'\t' -f 2-)
        #remove old file if any files to remove
        if [ -n "${FILES_TO_REMOVE}" ]; then
                echo "removing files: "
                echo "${FILES_TO_REMOVE}"
                echo "${FILES_TO_REMOVE}" | xargs realpath | xargs -d '\n' rm
                echo "old backups removed."
        else
                echo "no old backups to remove."
        fi
fi

echo ""
echo "Compressing backup..."
# Compress backed up folder
tar -zcf "${BACKUP_DIR}/Backups/$(date '+%Y-%m-%d_%H-%M-%S').tar.gz" /var/snap/nextcloud/common/backups/*
echo "Nextcloud backup successfully compressed to ${BACKUP_DIR}/Backups"

# Remove uncompressed backup data
rm -rf /var/snap/nextcloud/common/backups/*

echo "Removing backup Logs older than 50 days..."
# Remove logs older than 50 days
find "${BACKUP_DIR}"/Backups/Logs -mtime +50 -type f -delete
echo "Complete"
