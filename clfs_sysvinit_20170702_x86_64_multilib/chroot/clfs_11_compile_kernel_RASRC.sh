#!/bin/bash

#=================
#LET'S BUILD THE KERNEL
#
#CONFIGURE THE KERNEL EXACTLY TO THESE
#INSTRUCTIONS:
#
#http://www.linuxfromscratch.org/~krejzi/basic-kernel.txt 
#http://www.linuxfromscratch.org/hints/downloads/files/lfs-uefi-20170207.txt
#=====================

#Building the final CLFS System
CLFS=/
CLFSSOURCES=/sources
MAKEFLAGS="-j$(nproc)"
BUILD32="-m32"
BUILD64="-m64"
CLFS_TARGET32="i686-pc-linux-gnu"
PKG_CONFIG_PATH32=/usr/lib/pkgconfig
PKG_CONFIG_PATH64=/usr/lib64/pkgconfig

export CLFS=/
export CLFSUSER=clfs
export CLFSSOURCES=/sources
export MAKEFLAGS="-j$(nproc)"
export BUILD32="-m32"
export BUILD64="-m64"
export CLFS_TARGET32="i686-pc-linux-gnu"
export PKG_CONFIG_PATH32=/usr/lib/pkgconfig
export PKG_CONFIG_PATH64=/usr/lib64/pkgconfig

cd ${CLFSSOURCES}

#LINUX KERNEL
mkdir linux && tar xf linux-*.tar.* -C linux --strip-components 1
cd linux

make mrproper
cp ${CLFSSOURCES}/kernel.conf ${CLFSSOURCES}/linux/.config

make
make modules_install
make firmware_install
cp -v arch/x86_64/boot/bzImage /boot/efi/vmlinuz-clfs-4.12.8
cp -v System.map /boot/efi/System.map-4.12.8
cp -v .config /boot/efi/config-4.12.8
cd ${CLFSSOURCES}

#Copy source folder to /lib/modules
mv ${CLFSSOURCES}/linux /lib/modules/CLFS-4.12.8_SOURCE

#Properly link the new kernel source folder path to subdirectories
# build/ and source/
unlink /lib/modules/4.12.8-CLFS-SYSVINIT-SVN-x86_64/build
unlink /lib/modules/4.12.8-CLFS-SYSVINIT-SVN-x86_64/source
ln -sfv /lib/modules/CLFS-4.12.8_SOURCE /lib/modules/4.12.8-CLFS-SYSVINIT-SVN-x86_64/build
ln -sfv /lib/modules/CLFS-4.12.8_SOURCE /lib/modules/4.12.8-CLFS-SYSVINIT-SVN-x86_64/source

echo " "
echo "CONGRATS. You are done! Your very own CLFS is now bootable."
echo "Please install bclfs_1 anmd bclfs_2 scripts before reboot NOW!"
echo " "
