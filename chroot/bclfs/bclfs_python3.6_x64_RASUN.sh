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

sudo chown -Rv overflyer /sources

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

sudo bash -c 'chmod -Rv overflyer ${CLFSSOURCES}'

echo " "
echo "You need to install expat first. Abort otherwise"
echo " "

checkBuiltPackage

#Python 3 64-bit
wget https://www.python.org/ftp/python/3.6.3/Python-3.6.3.tar.xz -O \
  Python-3.6.3.tar.xz

#wget http://pkgs.fedoraproject.org/rpms/python3/raw/master/f/00102-lib64.patch -O \
#python360-multilib2.patch
  
#wget https://docs.python.org/3.6/archives/python-3.6.0-docs-html.tar.bz2 -O \
# python-360-docs.tar.bz2
  
mkdir Python-3 && tar xf Python-3.6*.tar.xz -C Python-3 --strip-components 1
cd Python-3

patch -Np1 -i ../python360-multilib.patch

checkBuiltPackage

############################################################################
#  Let's see later if adding /usr/lib64 to ld.so.conf is really neccessary #
############################################################################

USE_ARCH=64 CXX="/usr/bin/g++ ${BUILD64}" \
    CC="/usr/bin/gcc ${BUILD64}" \
    LD_LIBRARY_PATH=/usr/lib64 \
    LD_LIB_PATH=/usr/lib64 \
    LIBRARY_PATH=/usr/lib64 \
    PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure \
            --prefix=/usr       \
            --enable-shared     \
            --disable-static    \
            --with-system-expat \
            --with-system-ffi   \
            --libdir=/usr/lib64 \
            --with-custom-platlibdir=/usr/lib64 \
            --with-ensurepip=yes \
            LDFLAGS="-Wl,-rpath /usr/lib64"

LDFLAGS="-Wl,-rpath /usr/lib64" \
LD_LIBRARY_PATH=/usr/lib64 \
LD_LIB_PATH=/usr/lib64 \
LIBRARY_PATH=/usr/lib64 make PREFIX=/usr LIBDIR=/usr/lib64 PLATLIBDIR=/usr/lib64 \
  platlibdir=/usr/lib64

sudo make altinstall PREFIX=/usr LIBDIR=/usr/lib64 PLATLIBDIR=/usr/lib64 \
  platlibdir=/usr/lib64
  
sudo cp -rv /usr/lib/python3.6/ /usr/lib64/
sudo sudo rm -rf /usr/lib/python3.6/

sudo chmod -v 755 /usr/lib64/libpython3.6m.so
sudo chmod -v 755 /usr/lib64/libpython3.so

#sudo install -v -dm755 /usr/share/doc/python-3.6.0/html &&
#sudo tar --strip-components=1 \
#    --no-same-owner \
#    --no-same-permissions \
#    -C /usr/share/doc/python-3.6.0/html \
#    -xvf ../python-360-docs.tar.bz2

#sudo ln -svfn python-3.6.0 /usr/share/doc/python-3
sudo ln -svf /usr/lib64/libpython3.6m.so /usr/lib64/libpython3.6.so
sudo ln -svf /usr/lib64/libpython3.6m.so.1.0 /usr/lib64/libpython3.6.so.1.0
sudo ln -sfv /usr/bin/python3.6 /usr/bin/python3

cd ${CLFSSOURCES}
checkBuiltPackage
sudo sudo rm -rf Python-3
