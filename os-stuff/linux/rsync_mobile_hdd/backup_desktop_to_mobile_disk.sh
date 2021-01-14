#!/bin/sh 
# backup daily all data
# don't forget the slash at the end of the paths
echo "Starting syncronization of Download"
##nice -19 rsync -av --info=progress2 --delete /Download/ /media/jo/cd57d2cf-1665-4651-a1bc-15496dec5fcd/rsync/Download/

echo "Starting syncronization of Dokumente"
nice -19 rsync -av --info=progress2 --delete /home/jo/Dokumente/ /media/jo/cd57d2cf-1665-4651-a1bc-15496dec5fcd/rsync/home_jo/Dokumente/

echo "Starting syncronization of Mail"
#nice -19 rsync -av --info=progress2 --delete /home/jo/Mail/ /media/jo/cd57d2cf-1665-4651-a1bc-15496dec5fcd/rsync/home_jo/Mail/

echo "Starting syncronization of localgit"
#nice -19 rsync -av --info=progress2 --delete /home/jo/localgit/ /media/jo/cd57d2cf-1665-4651-a1bc-15496dec5fcd/rsync/home_jo/localgit/

echo "Starting syncronization of Virtualbox VMs"
##nice -19 rsync -av --info=progress2 --delete "/home/jo/VirtualBox VMs/" "/media/jo/cd57d2cf-1665-4651-a1bc-15496dec5fcd/rsync/home_jo/VirtualBox VMs/"

##nice -19 rsync -av --info=progress2 --delete "/home/jo/VirtualBox VMs/Kali_linux/" "/media/jo/cd57d2cf-1665-4651-a1bc-15496dec5fcd/rsync/home_jo/VirtualBox VMs/Kali_linux/"                                                                                                                                                           
##nice -19 rsync -av --info=progress2 --delete "/home/jo/VirtualBox VMs/Kubuntu 14.04 LTS/" "/media/jo/cd57d2cf-1665-4651-a1bc-15496dec5fcd/rsync/home_jo/VirtualBox VMs/Kubuntu 14.04 LTS/"
##nice -19 rsync -av --info=progress2 --delete "/home/jo/VirtualBox VMs/vista/" "/media/jo/cd57d2cf-1665-4651-a1bc-15496dec5fcd/rsync/home_jo/VirtualBox VMs/vista/"
##nice -19 rsync -av --info=progress2 --delete "/home/jo/VirtualBox VMs/Windows10/" "/media/jo/cd57d2cf-1665-4651-a1bc-15496dec5fcd/rsync/home_jo/VirtualBox VMs/Windows10/"
##nice -19 rsync -av --info=progress2 --delete "/home/jo/VirtualBox VMs/Win_xp/" "/media/jo/cd57d2cf-1665-4651-a1bc-15496dec5fcd/rsync/home_jo/VirtualBox VMs/Win_xp/"
##nice -19 rsync -av --info=progress2 --delete "/home/jo/VirtualBox VMs/win xp test/" "/media/jo/cd57d2cf-1665-4651-a1bc-15496dec5fcd/rsync/home_jo/VirtualBox VMs/win xp test/"
#nice -19 rsync -av --info=progress2 --delete "/home/jo/VirtualBox VMs/Windows 10 64bit/" "/media/jo/cd57d2cf-1665-4651-a1bc-15496dec5fcd/rsync/home_jo/VirtualBox VMs/Windows 10 64bit/"

echo "Starting syncronization of public"
#nice -19 rsync -av --info=progress2 --delete /public/ /media/jo/cd57d2cf-1665-4651-a1bc-15496dec5fcd/rsync/public/

#echo "Starting syncronization of ellen's stuff"
sudo nice -19 rsync -av --info=progress2 --delete /home/ellen/Dokumente/ /media/jo/cd57d2cf-1665-4651-a1bc-15496dec5fcd/rsync/home_ellen/Dokumente/
sudo nice -19 rsync -av --info=progress2 --delete /home/ellen/Bilder/ /media/jo/cd57d2cf-1665-4651-a1bc-15496dec5fcd/rsync/home_ellen/Bilder/



echo "backup complete."
