#!/bin/bash

function checkBuiltPackage() {

echo "Did everything build fine?: [Y/N]"
while read -n1 -r -p "[Y/N]   " && [[ $REPLY != q ]]; do
  case $REPLY in
    Y) break 1;;
    N) echo "$EXIT"
       echo "Fix it!"
       exit 1;;
    *) echo " Try again. Type y or n";;
  esac
done

}

#Building the final CLFS System
CLFS=/
CLFSHOME=/home
CLFSSOURCES=/sources
CLFSTOOLS=/tools
CLFSCROSSTOOLS=/cross-tools
CLFSFILESYSTEM=ext4
CLFSROOTDEV=/dev/sda4
CLFSHOMEDEV=/dev/sda5
MAKEFLAGS=j8
BUILD32="-m32"
BUILD64="-m64"
CLFS_TARGET32="i686-pc-linux-gnu"
PKG_CONFIG_PATH32=/usr/lib/pkgconfig
PKG_CONFIG_PATH64=/usr/lib64/pkgconfig

export CLFS=/
export CLFSUSER=clfs
export CLFSHOME=/home
export CLFSSOURCES=/sources
export CLFSTOOLS=/tools
export CLFSCROSSTOOLS=/cross-tools
export CLFSFILESYSTEM=ext4
export CLFSROOTDEV=/dev/sda4
export CLFSHOMEDEV=/dev/sda5
export MAKEFLAGS=j8
export BUILD32="-m32"
export BUILD64="-m64"
export CLFS_TARGET32="i686-pc-linux-gnu"
export PKG_CONFIG_PATH32=/usr/lib/pkgconfig
export PKG_CONFIG_PATH64=/usr/lib64/pkgconfig

cd ${CLFSSOURCES}

#Cracklib 64-bit
mkdir cracklib && tar xf cracklib-*.tar.* -C cracklib --strip-components 1
cd cracklib

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf cracklib

#Linux-PAM 64-bit
mkdir linuxpam && tar xf Linux-PAM-1.3.0.tar.* -C linuxpam --strip-components 1
cd linuxpam

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf linuxpam

#Shadow
mkdir shadow && tar xf shadow-*.tar.* -C shadow --strip-components 1
cd shadow

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf shadow

#Sudo
mkdir sudo && tar xf sudo-*.tar.* -C sudo --strip-components 1
cd sudo 

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf sudo 

