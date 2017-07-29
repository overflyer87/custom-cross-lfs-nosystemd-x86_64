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

function as_root()
{
  if   [ $EUID = 0 ];        then $*
  elif [ -x /usr/bin/sudo ]; then sudo $*
  else                            su -c \\"$*\\"
  fi
}

export -f as_root

function buildSingleXLib32() {
  ./configure $XORG_CONFIG32
  make
  as_root make install
}

export -f buildSingleXLib32

#Building the final CLFS System
CLFS=/
CLFSHOME=/home
CLFSSOURCES=/sources
CLFSTOOLS=/tools
CLFSCROSSTOOLS=/cross-tools
CLFSFILESYSTEM=ext4
CLFSROOTDEV=/dev/sda4
CLFSHOMEDEV=/dev/sda5
MAKEFLAGS='j8'
BUILD32="-m32"
BUILD64="-m64"
CLFS_TARGET32="i686-pc-linux-gnu"
PKG_CONFIG_PATH32=/usr/lib/pkgconfig
PKG_CONFIG_PATH=/usr/lib/pkgconfig
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
export MAKEFLAGS=j8
export BUILD32="-m32"
export BUILD64="-m64"
export CLFS_TARGET32="i686-pc-linux-gnu"
export PKG_CONFIG_PATH32=/usr/lib/pkgconfig
export PKG_CONFIG_PATH=/usr/lib/pkgconfig
export ACLOCAL="aclocal -I $XORG_PREFIX/share/aclocal"

cd ${CLFSSOURCES}

rm -rf xc

mkdir xc && cd xc

export XORG_PREFIX="/usr"
export XORG_CONFIG32="--prefix=$XORG_PREFIX --sysconfdir=/etc --localstatedir=/var \
  --libdir=$XORG_PREFIX/lib"
  
XORG_CONFIG32="--prefix=$XORG_PREFIX --sysconfdir=/etc --localstatedir=/var \
  --libdir=$XORG_PREFIX/lib"

cat > /etc/profile.d/xorg.sh << EOF
export XORG_PREFIX="/usr"
export XORG_CONFIG32="--prefix=$XORG_PREFIX --sysconfdir=/etc --localstatedir=/var \
  --libdir=$XORG_PREFIX/lib"
export XORG_CONFIG64="--prefix=$XORG_PREFIX --sysconfdir=/etc --localstatedir=/var \
  --libdir=$XORG_PREFIX/lib64"
EOF

chmod 644 /etc/profile.d/xorg.sh

#util-macros 32-bit
wget https://www.x.org/pub/individual/util/util-macros-1.19.1.tar.bz2 -O \
  util-macros-1.19.1.tar.bz2
  
mkdir util-macros && tar xf util-macros-*.tar.* -C util-macros --strip-components 1
cd util-macros

PKG_CONFIG_PATH="${PKG_CONFIG_PATH32}" \
USE_ARCH=32 CC="gcc ${BUILD32}" CXX="g++ ${BUILD32}" ./configure $XORG_CONFIG32
as_root make PREFIX=/usr LIBDIR=/usr/lib install

cd ${CLFSSOURCES}/xc
checkBuiltPackage
rm -rf util-macros

#Xorg Protocol Headers 
cat > proto-7.md5 << "EOF"
1a05fb01fa1d5198894c931cf925c025  bigreqsproto-1.1.2.tar.bz2
98482f65ba1e74a08bf5b056a4031ef0  compositeproto-0.4.2.tar.bz2
998e5904764b82642cc63d97b4ba9e95  damageproto-1.2.1.tar.bz2
4ee175bbd44d05c34d43bb129be5098a  dmxproto-2.3.1.tar.bz2
b2721d5d24c04d9980a0c6540cb5396a  dri2proto-2.8.tar.bz2
a3d2cbe60a9ca1bf3aea6c93c817fee3  dri3proto-1.0.tar.bz2
e7431ab84d37b2678af71e29355e101d  fixesproto-5.0.tar.bz2
36934d00b00555eaacde9f091f392f97  fontsproto-2.1.3.tar.bz2
5565f1b0facf4a59c2778229c1f70d10  glproto-1.4.17.tar.bz2
b290a463af7def483e6e190de460f31a  inputproto-2.3.2.tar.bz2
94afc90c1f7bef4a27fdd59ece39c878  kbproto-1.0.7.tar.bz2
92f9dda9c870d78a1d93f366bcb0e6cd  presentproto-1.1.tar.bz2
a46765c8dcacb7114c821baf0df1e797  randrproto-1.5.0.tar.bz2
1b4e5dede5ea51906f1530ca1e21d216  recordproto-1.14.2.tar.bz2
a914ccc1de66ddeb4b611c6b0686e274  renderproto-0.11.1.tar.bz2
cfdb57dae221b71b2703f8e2980eaaf4  resourceproto-1.2.0.tar.bz2
edd8a73775e8ece1d69515dd17767bfb  scrnsaverproto-1.2.2.tar.bz2
fe86de8ea3eb53b5a8f52956c5cd3174  videoproto-2.3.3.tar.bz2
5f4847c78e41b801982c8a5e06365b24  xcmiscproto-1.2.2.tar.bz2
70c90f313b4b0851758ef77b95019584  xextproto-7.3.0.tar.bz2
120e226ede5a4687b25dd357cc9b8efe  xf86bigfontproto-1.2.0.tar.bz2
a036dc2fcbf052ec10621fd48b68dbb1  xf86dgaproto-2.1.tar.bz2
1d716d0dac3b664e5ee20c69d34bc10e  xf86driproto-2.1.1.tar.bz2
e793ecefeaecfeabd1aed6a01095174e  xf86vidmodeproto-2.3.1.tar.bz2
9959fe0bfb22a0e7260433b8d199590a  xineramaproto-1.2.1.tar.bz2
16791f7ca8c51a20608af11702e51083  xproto-7.0.31.tar.bz2
EOF

mkdir proto
cd proto

USE_ARCH=32 CC="gcc ${BUILD32}" CXX="g++ ${BUILD32}" \
PKG_CONFIG_PATH="${PKG_CONFIG_PATH32}" \

grep -v '^#' ../proto-7.md5 | awk '{print $2}' | wget -i- -c \
    -B https://www.x.org/pub/individual/proto/ &&
md5sum -c ../proto-7.md5

export PKG_CONFIG_PATH="${PKG_CONFIG_PATH32}" 

for package in $(grep -v '^#' ../proto-7.md5 | awk '{print $2}')
do
  packagedir=${package%.tar.bz2}
  tar -xf $package
  pushd $packagedir  
  USE_ARCH=32 CC="gcc ${BUILD32}" CXX="g++ ${BUILD32}" \
  PKG_CONFIG_PATH="${PKG_CONFIG_PATH32}" ./configure $XORG_CONFIG32 &&
  as_root make install
  checkBuiltPackage
  popd
  rm -rf $packagedir
done

#libXau 32-bit
wget https://www.x.org/pub/individual/lib/libXau-1.0.8.tar.bz2 -O \
  libXau-1.0.8.tar.bz2
  
mkdir libxau && tar xf libXau-*.tar.* -C libxau --strip-components 1
cd libxau

buildSingleXLib32

cd ${CLFSSOURCES}/xc
checkBuiltPackage
rm -rf libxau

#libXdmcp 32-bit
wget https://www.x.org/pub/individual/lib/libXdmcp-1.1.2.tar.bz2 -O \
  libXdcmp-1.1.2.tar.bz2

mkdir libxdcmp && tar xf libXdcmp-*.tar.* -C libxdcmp --strip-components 1
cd libxdcmp

buildSingleXLib32

cd ${CLFSSOURCES}/xc
checkBuiltPackage
rm -rf libxdcmp

#libffi 32-bit
wget ftp://sourceware.org/pub/libffi/libffi-3.2.1.tar.gz -O \
  libffi-3.2.1.tar.gz

mkdir libffi && tar xf libffi-*.tar.* -C libffi --strip-components 1
cd libffi

buildSingleXLib32

cd ${CLFSSOURCES}/xc
checkBuiltPackage
rm -rf libffi

cd ${CLFSSOURCES}

#Expat (Needed by Python) 32-bit
wget http://downloads.sourceforge.net/expat/expat-2.1.0.tar.gz -O \
  expat-2.1.0.tar.gz

mkdir expat && tar xf expat-*.tar.* -C expat --strip-components 1
cd expat

USE_ARCH=32 PKG_CONFIG_PATH="${PKG_CONFIG_PATH32}"
CC="gcc ${BUILD32}" CXX="g++ ${BUILD32}" ./configure \
  --prefix=/usr \
  --libdir=/usr/lib \
  --disable-static \
  --enable-shared &&
  
make LIBDIR=/usr/lib PREFIX=/usr 
as_root make LIBDIR=/usr/lib PREFIX=/usr install
  
install -v -m755 -d /usr/share/doc/expat-2.1.0 &&
install -v -m644 doc/*.{html,png,css} /usr/share/doc/expat-2.1.0

cd ${CLFSSOURCES}
checkBuiltPackage
rm -rf expat

#Python2.7.6 32-bit
wget https://www.python.org/ftp/python/2.7.13/Python-2.7.13.tar.xz -O \
  Python-2.7.13.tar.xz
  
wget https://www.python.org/ftp/python/doc/2.7.13/python-2.7.13-docs-html.tar.bz2 -O \
  python-2.7.13-docs-html.tar.bz2

mkdir Python-2 && tar xf Python-2.7.13.tar.* -C Python-2 --strip-components 1
cd Python-2

patch -Np0 -i python2713-lib64-patch.patch

USE_ARCH=32 PKG_CONFIG_PATH="${PKG_CONFIG_PATH32}" \
CC="gcc ${BUILD32}" CXX="g++ ${BUILD32}" LDFLAGS="-L/usr/lib" ./configure \
            --prefix=/usr       \
            --enable-shared     \
            --with-system-expat \
            --with-system-ffi   \
            --enable-unicode=ucs4 \
            --libdir=/usr/lib &&

make LIBDIR=/usr/lib PREFIX=/usr 
as_root make LIBDIR=/usr/lib PREFIX=/usr install

as_root chmod -v 755 /usr/lib/libpython2.7.so.1.0

as_root ln -sfv python2.7-32 /usr/bin/python2-32 &&
as_root ln -sfv python2-32 /usr/bin/python-32 &&
as_root ln -sfv multiarch_wrapper /usr/bin/python &&
as_root ln -sfv multiarch_wrapper /usr/bin/python2 &&
as_root ln -sfv multiarch_wrapper /usr/bin/python2.7 &&

as_root install -v -dm755 /usr/share/doc/python-2.7.13 &&

as_root tar --strip-components=1                     \
    --no-same-owner                          \
    --directory /usr/share/doc/python-2.7.13 \
    -xvf ../python-2.7.*.tar.* &&

as_root find /usr/share/doc/python-2.7.13 -type d -exec chmod 0755 {} \; &&
as_root find /usr/share/doc/python-2.7.13 -type f -exec chmod 0644 {} \;
            
cd ${CLFSSOURCES}
checkBuiltPackage
rm -rf Python-2

#Python 3 64-bit
wget https://www.python.org/ftp/python/3.6.0/Python-3.6.0.tar.xz -O \
  Python-3.6.0.tar.xz

wget https://docs.python.org/3.6/archives/python-3.6.0-docs-html.tar.bz2 -O \
  python-360-docs.tar.bz2
  
mkdir Python-3 && tar xf Python-3.6*.tar.xz -C Python-3 --strip-components 1
cd Python-3

USE_ARCH=32 CXX="/usr/bin/g++ ${BUILD32}" \
    CC="/usr/bin/gcc ${BUILD32}" \
    PKG_CONFIG_PATH="${PKG_CONFIG_PATH32}" ./configure \
            --prefix=/usr       \
            --enable-shared     \
            --with-system-expat \
            --with-system-ffi   \
            --libdir=/usr/lib64 \
            --with-ensurepip=yes &&

make PREFIX=/usr LIBDIR=/usr/lib &&
as_root make install PREFIX=/usr LIBDIR=/usr/lib 

as_root chmod -v 755 /usr/lib/libpython3.6m.so
as_root chmod -v 755 /usr/lib/libpython3.so

install -v -dm755 /usr/share/doc/python-3.6.0/html &&
tar --strip-components=1 \
    --no-same-owner \
    --no-same-permissions \
    -C /usr/share/doc/python-3.6.0/html \
    -xvf ../python-360-docs.tar.bz2

ln -svfn python-3.6.0 /usr/share/doc/python-3

as_root ln -sfv python2.7-32 /usr/bin/python3-32 &&
as_root ln -sfv multiarch_wrapper /usr/bin/python &&
as_root ln -sfv multiarch_wrapper /usr/bin/python &&
as_root ln -sfv multiarch_wrapper /usr/bin/python3.6 &&

cd ${CLFSSOURCES}
checkBuiltPackage
rm -rf Python-3

cd ${CLFSSOURCES}/xc

#xcb-proto 32-bit
wget http://xcb.freedesktop.org/dist/xcb-proto-1.12.tar.bz2 -O \
  xcb-proto-1.12.tar.bz2
wget http://www.linuxfromscratch.org/patches/blfs/svn/xcb-proto-1.12-python3-1.patch -O \
  xcb-proto-1.12-python3-1.patch
wget http://www.linuxfromscratch.org/patches/blfs/svn/xcb-proto-1.12-schema-1.patch -O \
  xcb-proto-1.12-schema-1.patch

mkdir xcb-proto && tar xf xcb-proto-1.12.tar.* -C xcb-proto --strip-components 1
cd xcb-proto

patch -Np1 -i ../xcb-proto-1.12-schema-1.patch
patch -Np1 -i ../xcb-proto-1.12-python3-1.patch

CXX="/usr/bin/g++ ${BUILD32}" \
CC="/usr/bin/gcc ${BUILD32}" \
USE_ARCH=32 PKG_CONFIG_PATH="${PKG_CONFIG_PATH32}" ./configure $XORG_CONFIG32 && 

make check
checkBuiltPackage

make PREFIX=/usr LIBDIR=/usr/lib
as_root make PREFIX=/usr LIBDIR=/usr/lib install

cd ${CLFSSOURCES}/xc
checkBuiltPackage
rm -rf xcb-proto

#libxcb 32-bit
wget http://xcb.freedesktop.org/dist/libxcb-1.12.tar.bz2 -O \
  libxcb-1.12.tar.bz2

wget http://www.linuxfromscratch.org/patches/blfs/svn/libxcb-1.12-python3-1.patch -O \
  libxcb-1.12-python3-1.patch

mkdir libxcb && tar xf libxcb-*.tar.* -C libxcb --strip-components 1
cd libxcb

patch -Np1 -i ../libxcb-1.12-python3-1.patch

sed -i "s/pthread-stubs//" configure

USE_ARCH=32 CXX="g++ ${BUILD32}" CC="gcc ${BUILD32}" \
PKG_CONFIG_PATH="${PKG_CONFIG_PATH32}" ./configure $XORG_CONFIG32    \
            --enable-xinput   \
            --without-doxygen \
            --libdir=/usr/lib \
            --without-doxygen \
            --docdir='${datadir}'/doc/libxcb-1.12 &&
            
make PREFIX=/usr LIBDIR=/usr/lib
as_root make PREFIX=/usr LIBDIR=/usr/lib install

cd ${CLFSSOURCES}/xc
checkBuiltPackage
rm -rf libxcb

#fontconfig 32-bit
wget http://www.freedesktop.org/software/fontconfig/release/fontconfig-2.12.4.tar.bz2 -O \
  fontconfig-2.12.4.tar.bz2
  
mkdir fontconfig && tar xf fontconfig-*.tar.* -C fontconfig --strip-components 1
cd fontconfig

rm -f src/fcobjshash.h

USE_ARCH=32 CXX="g++ ${BUILD32}" CC="gcc ${BUILD32}" \
PKG_CONFIG_PATH="${PKG_CONFIG_PATH32}" ./configure --prefix=/usr \
            --sysconfdir=/etc    \
            --localstatedir=/var \
            --disable-docs       \
            --docdir=/usr/share/doc/fontconfig-2.12.4 \
            --libdir=/usr/lib

make PREFIX=/usr LIBDIR=/usr/lib
as_root make PREFIX=/usr LIBDIR=/usr/lib install

cd ${CLFSSOURCES/xc}
checkBuiltPackage
rm -rf fontconfig

