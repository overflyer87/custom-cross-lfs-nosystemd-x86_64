
#!/bin/bash

#Purge CLFS if you already used clfs_4 script to chroot into temp system

CLFS=/mnt/clfs
CLFSHOME=/mnt/clfs/home
CLFSUSER="clfs"

sudo umount -f ${CLFS}/dev/pts
sudo umount -f ${CLFS}/dev
sudo umount -f ${CLFSHOME}
sudo umount -f ${CLFS}/boot/efi
sudo umount -f ${CLFS}/sys/firmware/efi/efivars
sudo umount -f ${CLFS}/sys
sudo umount -f ${CLFS}/run
sudo umount -f ${CLFS}/proc
sudo userdel ${CLFSUSER}
sudo groupdel ${CLFSUSER}
sudo rm -rf /home/${CLFSUSER}
sudo unlink /cross-tools 
sudo unlink /tools
sudo rm -rf ${CLFS}/*
sudo umount -f ${CLFS}

