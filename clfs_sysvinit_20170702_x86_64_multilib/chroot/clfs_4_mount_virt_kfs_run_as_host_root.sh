#!/bin/bash

CLFS=/mnt/clfs
CLFSHOME=${CLFS}/home
CLFSSOURCES=${CLFS}/sources
CLFSTOOLS=${CLFS}/tools
CLFSCROSSTOOLS=${CLFS}/cross-tools
CLFSFILESYSTEM=ext4
CLFSROOTDEV=/dev/sda4
CLFSHOMEDEV=/dev/sda5

export CLFS=/mnt/clfs
export CLFSHOME=/mnt/clfs/home
export FILESYSTEM=ext4
export CLFSROOTDEV=/dev/sda4
export CLFSHOMEDEV=/dev/sda5
export CLFSSOURCES=/mnt/clfs/sources
export CLFSTOOLS=/mnt/clfs/tools
export CLFSCROSSTOOLS=/mnt/clfs/cross-tools

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

chroot "${CLFS}" /tools/bin/env -i \
    HOME=/root TERM="${TERM}" PS1='\u:\w\$ ' \
    PATH=/bin:/usr/bin:/sbin:/usr/sbin:/tools/bin \
    /tools/bin/bash --login +h