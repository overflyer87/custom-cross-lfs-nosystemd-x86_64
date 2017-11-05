
#!/bin/bash

#Reverse CLFS Installation until Temporary System

CLFS=/mnt/clfs
CLFSHOME=/mnt/clfs/home
CLFSUSER="clfs"

sudo -f umount ${CLFS}/dev/pts
sudo -f umount ${CLFS}/dev
sudo -f umount ${CLFS}/home
sudo -f umount ${CLFS}/boot/efi
sudo -f umount ${CLFS}/sys/firmware/efi/efivars
sudo -f umount ${CLFS}/sys
sudo -f umount ${CLFS}/run
sudo -f umount ${CLFS}/proc
sudo userdel ${CLFSUSER}
sudo groupdel ${CLFSUSER}
sudo rm -rf /home/${CLFSUSER}
sudo unlink /cross-tools 
sudo unlink /tools
sudo rm -rf ${CLFS}/*
sudo umount -f ${CLFS}

