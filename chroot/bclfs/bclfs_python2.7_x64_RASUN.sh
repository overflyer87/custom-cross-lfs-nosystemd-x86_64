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
export MAKEFLAGS="-j$(nproc)"
export BUILD32="-m32"
export BUILD64="-m64"
export CLFS_TARGET32="i686-pc-linux-gnu"
export PKG_CONFIG_PATH=/usr/lib64/pkgconfig
export PKG_CONFIG_PATH64=/usr/lib64/pkgconfig
export ACLOCAL="aclocal -I $XORG_PREFIX/share/aclocal"

cd ${CLFSSOURCES}

#Python2.7.6 64-bit
wget https://www.python.org/ftp/python/2.7.14/Python-2.7.14.tar.xz -O \
  Python-2.7.14.tar.xz
  
wget https://www.python.org/ftp/python/doc/2.7.14/python-2.7.14-docs-html.tar.bz2 -O \
  python-2.7.14-docs-html.tar.bz2
  
mkdir Python-2 && tar xf Python-2.7.14.tar.* -C Python-2 --strip-components 1
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
LDFLAGS="-Wl,-rpath /usr/lib64" make LIBDIR=/usr/lib64 PREFIX=/usr 

sudo make LIBDIR=/usr/lib64 PREFIX=/usr altinstall

sudo chmod -v 755 /usr/lib64/libpython2.7.so.1.0

sudo ln -sfv /usr/bin7python2.7 /usr/bin/python2

#sudo mv -v /usr/bin/python{,-64}
sudo mv -v /usr/bin/python2{,-64}
sudo mv -v /usr/bin/python2.7{,-64}
sudo ln -sfv python2.7-64 /usr/bin/python2-64
sudo ln -sfv python2-64 /usr/bin/python-64
#sudo ln -sfv multiarch_wrapper /usr/bin/python
sudo ln -sfv multiarch_wrapper /usr/bin/python2
sudo ln -sfv multiarch_wrapper /usr/bin/python2.7 
#Deactivate renaming header according to cblfs
#mate-menu will not find since Python.h includes pyconfig.h not pyconfig-64.h
#sudo mv -v /usr/include/python2.7/pyconfig{,-64}.h

sudo install -v -dm755 /usr/share/doc/python-2.7.13 

sudo bash -c 'tar --strip-components=1       \
    --no-same-owner                          \
    --directory /usr/share/doc/python-2.7.13 \
    -xvf ../python-2.7.*.tar.*' 

sudo bash -c 'find /usr/share/doc/python-2.7.13 -type d -exec chmod 0755 {} \;'
sudo bash -c 'find /usr/share/doc/python-2.7.13 -type f -exec chmod 0644 {} \;'

sudo ln -sfv /usr/bin/python2.7-config /usr/bin/python2-config
            
cd ${CLFSSOURCES}
checkBuiltPackage
rm -rf Python-2
