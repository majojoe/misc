#!/bin/sh -e
# backup daily all data
# don't forget the slash at the end of the paths
echo "Starting syncronization of Download"
nice -19 rsync -av --info=progress2 --delete /media/jo/bfa82597-dd99-4380-8137-d8f12e8812d5/rsync/Download/ /Download/

echo "Starting syncronization of Dokumente"
nice -19 rsync -av --info=progress2 --delete /media/jo/bfa82597-dd99-4380-8137-d8f12e8812d5/rsync/home_jo/Dokumente/ /home/jo/Dokumente/ 

echo "Starting syncronization of Mail"
#nice -19 rsync -av --info=progress2 /media/jo/bfa82597-dd99-4380-8137-d8f12e8812d5/rsync/home_jo/Mail/ /home/jo/Mail/ 

echo "Starting syncronization of localgit"
nice -19 rsync -av --info=progress2 --delete /media/jo/bfa82597-dd99-4380-8137-d8f12e8812d5/rsync/home_jo/localgit/ /home/jo/localgit/ 

echo "Starting syncronization of Virtualbox VMs"
#nice -19 rsync -av --info=progress2  --delete "/media/jo/bfa82597-dd99-4380-8137-d8f12e8812d5/rsync/home_jo/VirtualBox VMs/" "/home/jo/VirtualBox VMs/"
#nice -19 rsync -av --info=progress2  --delete "/media/jo/bfa82597-dd99-4380-8137-d8f12e8812d5/rsync/home_jo/VirtualBox VMs/Windows 10 64bit/" "/home/jo/VirtualBox VMs/Windows 10 64bit/" 

echo "Starting syncronization of public"
nice -19 rsync -av --info=progress2 --delete /media/jo/bfa82597-dd99-4380-8137-d8f12e8812d5/rsync/public/ /public/ 

sudo nice -19 rsync -av --info=progress2 --delete /media/jo/bfa82597-dd99-4380-8137-d8f12e8812d5/rsync/home_ellen/Dokumente/ /home/ellen/Dokumente/ 
sudo nice -19 rsync -av --info=progress2 --delete /media/jo/bfa82597-dd99-4380-8137-d8f12e8812d5/rsync/home_ellen/Bilder/ /home/ellen/Bilder/ 

echo "restore complete."


