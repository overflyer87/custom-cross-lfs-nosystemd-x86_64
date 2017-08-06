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

#Expat (Needed by Python) 64-bit
wget http://downloads.sourceforge.net/expat/expat-2.1.0.tar.gz -O \
  expat-2.1.0.tar.gz
  
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
  
sudo install -v -m755 -d /usr/share/doc/expat-2.1.0
sudo install -v -m644 doc/*.{html,png,css} /usr/share/doc/expat-2.1.0

cd ${CLFSSOURCES}
checkBuiltPackage
rm -rf expat

#Python2.7.6 64-bit
wget https://www.python.org/ftp/python/2.7.13/Python-2.7.13.tar.xz -O \
  Python-2.7.13.tar.xz
  
wget https://www.python.org/ftp/python/doc/2.7.13/python-2.7.13-docs-html.tar.bz2 -O \
  python-2.7.13-docs-html.tar.bz2
  
mkdir Python-2 && tar xf Python-2.7.13.tar.* -C Python-2 --strip-components 1
cd Python-2

cp ${CLFSSOURCES}/python2713-lib64-patch.patch ${CLFSSOURCES}/Python-2

patch -Np0 -i python2713-lib64-patch.patch

checkBuiltPackage

LD_LIBRARY_PATH=/usr/lib64 \
LD_LIB_PATH=/usr/lib64 \
LIBRARY_PATH=/usr/lib64 \
USE_ARCH=64 PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" LDFLAGS="-L/usr/lib64" ./configure \
            --prefix=/usr       \
            --enable-shared     \
            --with-system-expat \
            --with-system-ffi   \
            --enable-unicode=ucs4 \
            --libdir=/usr/lib64 \
            LDFLAGS="-Wl,-rpath /usr/lib64"


LD_LIBRARY_PATH=/usr/lib64 \
LD_LIB_PATH=/usr/lib64 \
LIBRARY_PATH=/usr/lib64 \
USE_ARCH=64 PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
LDFLAGS="-Wl,-rpath /usr/lib64" make LIBDIR=/usr/lib64 PREFIX=/usr 

sudo make LIBDIR=/usr/lib64 PREFIX=/usr -n install
sudo make clean
sudo make distclean 
sudo rm -rf /usr/lib64/python3.6
sudo rm -rf /usr/lib64/libpython3*
sudo rm -rf /usr/include/python3.6m
sudo rm .rf /usr/bin/python3*
sudo rm -rf /usr/bin/py3*
sudo rm -rf /usr/share/doc/python-3*
sudo rm -rf /usr/share/man/man1/python-3*


cd ${CLFSSOURCES}
checkBuiltPackage
rm -rf Python-2
