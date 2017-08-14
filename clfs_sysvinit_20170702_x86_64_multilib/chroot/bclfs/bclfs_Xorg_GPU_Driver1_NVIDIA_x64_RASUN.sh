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
MAKEFLAGS="-j$(nproc)"
BUILD32="-m32"
BUILD64="-m64"
CLFS_TARGET32="i686-pc-linux-gnu"
PKG_CONFIG_PATH=/usr/lib64/pkgconfig
PKG_CONFIG_PATH64=/usr/lib64/pkgconfig
ACLOCAL="aclocal -I $XORG_PREFIX/share/aclocal"

export CLFS=/
export CLFSUSER=clfs
export CLFSHOME=/home
export CLFSSOURCES=/sources
export CLFSTOOLS=/tools
export CLFSCROSSTOOLS=/cross-tools
export CLFSFILESYSTEM=ext4
export CLFSROOTDEV=/dev/sda4
export CLFSHOMEDEV=/dev/sda5
export MAKEFLAGS="-j$(nproc)"
export BUILD32="-m32"
export BUILD64="-m64"
export CLFS_TARGET32="i686-pc-linux-gnu"
export PKG_CONFIG_PATH=/usr/lib64/pkgconfig
export PKG_CONFIG_PATH64=/usr/lib64/pkgconfig
export ACLOCAL="aclocal -I $XORG_PREFIX/share/aclocal"

cd ${CLFSSOURCES}
cd ${CLFSSOURCES/xc}

export XORG_PREFIX="/usr"
export XORG_CONFIG64="--prefix=$XORG_PREFIX --sysconfdir=/etc --localstatedir=/var \
  --libdir=$XORG_PREFIX/lib64"

XORG_PREFIX="/usr"
XORG_CONFIG64="--prefix=$XORG_PREFIX --sysconfdir=/etc --localstatedir=/var \
  --libdir=$XORG_PREFIX/lib64"


#NVIDIA PROPRIETARY DRIVER
wget http://us.download.nvidia.com/XFree86/Linux-x86_64/384.59/NVIDIA-Linux-x86_64-384.59.run -O \
  NVIDIA-Linux-x86_64-384.59.run

sudo chmod +x NVIDIA-Linux-x86_64-384.59.run
sudo bash -c 'PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" CC="gcc" CXX="g++" ./NVIDIA-Linux-x86_64-384.59.run --kernel-source-path=/lib/modules/CLFS-4.12.7_ORIGINAL'

checkBuiltPackage

sudo mkdir -v /etc/modprobe.d

sudo bash -c 'cat > /etc/modprobe.d/blacklist-nouveau.conf << "EOF"
blacklist nouveau
EOF'
