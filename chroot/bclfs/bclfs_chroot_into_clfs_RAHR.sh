#!/bin/bash

#Use this after your system stands and boots and tools and cross-tools are gone
#Use this to root into CLFS from another linux system

CLFS=/mnt/clfs
export CLFS=/mnt/clfs

echo " "
echo " "
echo "Mount all your CLFS partitions first"
echo "root to /mnt/clfs"
echo "Press Ctrl+C if you did not."
echo "Press ENTER if you did"
echo " "
echo " "

read

sudo mkdir -pv ${CLFS}/{dev,proc,run,sys}

sudo mknod -m 600 ${CLFS}/dev/console c 5 1
sudo mknod -m 666 ${CLFS}/dev/null c 1 3

sudo mount -v -o bind /dev ${CLFS}/dev

sudo mount -vt devpts -o gid=5,mode=620 devpts ${CLFS}/dev/pts

sudo mount -vt proc proc ${CLFS}/proc
sudo mount -vt tmpfs tmpfs ${CLFS}/run
sudo mount -vt sysfs sysfs ${CLFS}/sys

sudo mkdir -pv ${CLFS}/sys/firmware/efi/efivars
sudo mount -v -o bind /sys/firmware/efi/efivars ${CLFS}/sys/firmware/efi/efivars

[ -h ${CLFS}/dev/shm ] && sudo mkdir -pv ${CLFS}/$(readlink ${CLFS}/dev/shm)

chroot "${CLFS}" env -i \
    HOME=/root TERM="${TERM}" PS1='\u:\w\$ ' \
    PATH=/bin:/usr/bin:/sbin:/usr/sbin \
    bash --login +h
