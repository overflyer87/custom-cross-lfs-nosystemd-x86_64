#!/bin/bash

function checkBuiltPackage() {
echo " "
echo "Make sure you are able to continue... [Y/N]"
while read -n1 -r -p "[Y/N]   " && [[ $REPLY != q ]]; do
  case $REPLY in
    Y) break 1;;
    N) echo "$EXIT"
       echo "Fix it!"
       exit 1;;
    *) echo " Try again. Type y or n";;
  esac
done
echo " "
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

cd ${CLFSSOURCES}
cd ${CLFSSOURCES}/xc/mate

#We will only do 64-bit builds in this script
#We compiled Xorg with 32-bit libraries
#That should suffice

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" 
USE_ARCH=64 
CXX="g++ ${BUILD64}" 
CC="gcc ${BUILD64}"

export PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" 
export USE_ARCH=64 
export CXX="g++ ${BUILD64}" 
export CC="gcc ${BUILD64}"

#elogind
wget https://github.com/wingo/elogind/archive/v219.12.tar.gz -O \
	elogind-219.12.tar.gz

mkdir elogind && tar xf elogind-*.tar.* -C elogind --strip-components 1
cd elogind

autoreconf -fi 
intltoolize --force 

CPPFLAGS="-I/usr/include" LD_LIBRARY_PATH="/usr/lib64" \
LD_LIB_PATH="/usr/lib64" LIBRARY_PATH="/usr/lib64" \
CC="gcc ${BUILD64} -lrt" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr  \
            --sysconfdir=/etc     \
            --localstatedir=/var  \
            --libdir=/usr/lib64   \
            --disable-static      \
            --libexecdir=/usr/lib64   \
            --enable-split-usr \
            --disable-gtk-doc \
            --disable-tests   \
            --disable-gtk-pdf \
            --disable-gtk-html \
            --enable-pam \
            --with-pamlibdir=/lib64/security \
            --with-pamconfdir=/etc/pam.d \
            --disable-static \
            --enable-shared \
            --disable-manpages

CPPFLAGS="-I/usr/include" LD_LIBRARY_PATH="/usr/lib64" \
LD_LIB_PATH="/usr/lib64" LIBRARY_PATH="/usr/lib64" \
PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64} -lrt" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install
sudo mkdir -pv /run/systemd
sudo chmod 755 /run/systemd

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
sudo rm -rf elogind
