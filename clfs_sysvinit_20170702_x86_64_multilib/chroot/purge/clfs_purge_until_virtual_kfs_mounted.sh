
#!/bin/bash

#Reverse CLFS Installation until Temporary System

CLFS=/mnt/clfs
CLFSHOME=/mnt/clfs/home
CLFSUSER="clfs"

sudo -f umount ${CLFS}/home
sudo rm -r /home/${CLFSUSER}
sudo userdel ${CLFSUSER}
sudo groupdel ${CLFSUSER}
sudo rm -rf ${CLFS}/*
sudo umount -f ${CLFS}
sudo unlink /cross-tools 
sudo unlink /tools
