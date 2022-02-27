#!/bin/bash

#this needs to be done since udev would kill the backup script if it lasts to long
/usr/local/bin/usb-backup-script.sh ${1} &