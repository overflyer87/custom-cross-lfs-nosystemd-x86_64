#!/bin/bash

function checkBuiltPackage() {
echo " "
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
echo " "
}

sudo chown -Rv overflyer ${CLFSSOURCES}

#Building the final CLFS System
CLFS=/
CLFSSOURCES=/sources
MAKEFLAGS="-j$(nproc)"
BUILD32="-m32"
BUILD64="-m64"
CLFS_TARGET32="i686-pc-linux-gnu"
PKG_CONFIG_PATH=/usr/lib64/pkgconfig
PKG_CONFIG_PATH64=/usr/lib64/pkgconfig
ACLOCAL="aclocal -I $XORG_PREFIX/share/aclocal"

export CLFS=/
export CLFSSOURCES=/sources
export MAKEFLAGS="-j$(nproc)"
export BUILD32="-m32"
export BUILD64="-m64"
export CLFS_TARGET32="i686-pc-linux-gnu"
export PKG_CONFIG_PATH=/usr/lib64/pkgconfig
export PKG_CONFIG_PATH64=/usr/lib64/pkgconfig
export ACLOCAL="aclocal -I $XORG_PREFIX/share/aclocal"

cd ${CLFSSOURCES}

#Expat (Needed by Python) 64-bit
wget https://downloads.sourceforge.net/project/expat/expat/2.2.4/expat-2.2.4.tar.bz2 -O \
  expat-2.2.4.tar.bz2
  
mkdir expat && tar xf expat-*.tar.* -C expat --strip-components 1
cd expat

USE_ARCH=64 PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}"
CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" ./configure \
  --prefix=/usr \
  --libdir=/usr/lib64 \
  --disable-static \
  --enable-shared &&
  
make LIBDIR=/usr/lib64 PREFIX=/usr 
sudo make LIBDIR=/usr/lib64 PREFIX=/usr install
  
sudo install -v -m755 -d /usr/share/doc/expat-2.2.4
sudo install -v -m644 doc/*.{html,png,css} /usr/share/doc/expat-2.2.4

cd ${CLFSSOURCES}
checkBuiltPackage
sudo rm -rf expat
