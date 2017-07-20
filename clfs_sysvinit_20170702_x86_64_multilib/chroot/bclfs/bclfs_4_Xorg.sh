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
  PKG_CONFIG_PATH="${PKG_CONFIG_PATH32}" \
  USE_ARCH=32 CC="gcc ${BUILD32}" CXX="g++ ${BUILD32}" ./configure $XORG_CONFIG32
  make PREFIX=/usr LIBDIR=/usr/lib
  as_root make PREFIX=/usr LIBDIR=/usr/lib install
}

export -f buildSingleXLib32

function buildSingleXLib64() {
  PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
  USE_ARCH=64 CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" ./configure $XORG_CONFIG64
  make PREFIX=/usr LIBDIR=/usr/lib64
  as_root make PREFIX=/usr LIBDIR=/usr/lib64 install
}


export -f buildSingleXLib64

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

#Let's continue
#Final system is seperated into several parts 
#to make bugfixing and maintenance easier

cd ${CLFSSOURCES}

mkdir xc && cd xc

export XORG_PREFIX="/usr"
export XORG_CONFIG32="--prefix=$XORG_PREFIX --sysconfdir=/etc --localstatedir=/var \
  --libdir=$XORG_PREFIX/lib"
export XORG_CONFIG64="--prefix=$XORG_PREFIX --sysconfdir=/etc --localstatedir=/var \
  --libdir=$XORG_PREFIX/lib64"


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

#util-macros 64-bit
  
mkdir util-macros && tar xf util-macros-*.tar.* -C util-macros --strip-components 1
cd util-macros

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
USE_ARCH=64 CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" ./configure $XORG_CONFIG64
as_root make PREFIX=/usr LIBDIR=/usr/lib64 install

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

mkdir proto &&
cd proto &&
grep -v '^#' ../proto-7.md5 | awk '{print $2}' | wget -i- -c \
    -B https://www.x.org/pub/individual/proto/ &&
md5sum -c ../proto-7.md5

for package in $(grep -v '^#' ../proto-7.md5 | awk '{print $2}')
do
  packagedir=${package%.tar.bz2}
  tar -xf $package
  pushd $packagedir  
  USE_ARCH=32 CC="gcc ${BUILD32}" CXX="g++ ${BUILD32}" \
  PKG_CONFIG_PATH="${PKG_CONFIG_PATH32}" ./configure $XORG_CONFIG32  &&
  as_root make PREFIX=/usr LIBDIR=/usr/lib install
  popd
  rm -rf $packagedir
done

checkBuiltPackage

for package in $(grep -v '^#' ../proto-7.md5 | awk '{print $2}')
do
  packagedir=${package%.tar.bz2}
  tar -xf $package
  pushd $packagedir  
  PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
  USE_ARCH=64 CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" ./configure $XORG_CONFIG64 &&
  as_root make PREFIX=/usr LIBDIR=/usr/lib64 install
  popd
  rm -rf $packagedir
done

cd ${CLFSSOURCES}/xc

checkBuiltPackage

USE_ARCH="" CC="" CXX="" PKG_CONFIG_PATH="" LIBDIR=""

#libXau 32-bit
wget https://www.x.org/pub/individual/lib/libXau-1.0.8.tar.bz2 -O \
  libXau-1.0.8.tar.bz2
  
mkdir libxau && tar xf libXau-*.tar.* -C libxau --strip-components 1
cd libxau

buildSingleXLib32

cd ${CLFSSOURCES}/xc
checkBuiltPackage
rm -rf libxau

#libXau 64-bit
mkdir libxau && tar xf libXau-*.tar.* -C libxau --strip-components 1
cd libxau

buildSingleXLib64

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

#libXdmcp 64-bit
mkdir libxdcmp && tar xf libXdcmp-*.tar.* -C libxdcmp --strip-components 1
cd libxdcmp

buildSingleXLib64

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

#libffi 32-bit
mkdir libffi && tar xf libffi-*.tar.* -C libffi --strip-components 1
cd libffi

buildSingleXLib64

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
CC="gcc ${BUILD32}" CXX="g++ ${BUILD32}" 
./configure --prefix=/usr \
  --libdir=/usr/lib \
  --disable-static \
  --enable-shared
  
make LIBDIR=/usr/lib PREFIX=/usr 
as_root make LIBDIR=/usr/lib PREFIX=/usr install
  
install -v -m755 -d /usr/share/doc/expat-2.1.0 &&
install -v -m644 doc/*.{html,png,css} /usr/share/doc/expat-2.1.0

cd ${CLFSSOURCES}
checkBuiltPackage
rm -rf expat

#Expat (Needed by Python) 64-bit
mkdir expat && tar xf expat-*.tar.* -C expat --strip-components 1
cd expat

USE_ARCH=64 PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}"
CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" 
./configure --prefix=/usr \
  --libdir=/usr/lib64 \
  --disable-static \
  --enable-shared
  
make LIBDIR=/usr/lib64 PREFIX=/usr 
as_root make LIBDIR=/usr/lib64 PREFIX=/usr install
  
install -v -m755 -d /usr/share/doc/expat-2.1.0 &&
install -v -m644 doc/*.{html,png,css} /usr/share/doc/expat-2.1.0

cd ${CLFSSOURCES}
checkBuiltPackage
rm -rf expat

#Python2.7.6 64-bit
wget https://www.python.org/ftp/python/2.7.13/Python-2.7.13.tar.xz -O \
  Python-2.7.13.tar.xz
  
wget https://www.williamfeely.info/download/lfs-multilib/Python-2.7.13-multilib-1.patch -O \
  python-2713-multilib-1.patch

wget https://www.python.org/ftp/python/doc/2.7.13/python-2.7.13-docs-html.tar.bz2 -O \
  python-2.7.13-docs-html.tar.bz2
  
mkdir Python-2 && tar xf Python-2.7.13.tar.* -C Python-2 --strip-components 1
cd Python-2

patch -Np1 -i ../python-2713-multilib-1.patch

sed -i -e "s|@@MULTILIB_DIR@@|/lib64|g" Lib/distutils/command/install.py \
       Lib/distutils/sysconfig.py \
       Lib/pydoc.py \
       Lib/site.py \
       Lib/sysconfig.py \
       Lib/test/test_dl.py \
       Lib/test/test_site.py \
       Lib/trace.py \
       Makefile.pre.in \
       Modules/getpath.c \
       setup.py
       
sed -i "s@/usr/X11R6@${XORG_PREFIX}@g" setup.py

sed -i 's@lib/python@lib64/python@g' Modules/getpath.c

USE_ARCH=64 PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" 
CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" LDFLAGS="-L/usr/lib64"
./configure --prefix=/usr       \
            --enable-shared     \
            --with-system-expat \
            --with-system-ffi   \
            --enable-unicode=ucs4 \
            --libdir=/usr/lib64 \

make EXTRA_CFLAGS="-fwrapv" LIBDIR=/usr/lib64 PREFIX=/usr 
as_root make EXTRA_CFLAGS="-fwrapv" LIBDIR=/usr/lib64 PREFIX=/usr install

chmod -v 755 /usr/lib/libpython2.7.so.1.0

mv -v /usr/bin/python{,-64} &&
mv -v /usr/bin/python2{,-64} &&
mv -v /usr/bin/python2.7{,-64} &&
ln -sfv python2.7-64 /usr/bin/python2-64 &&
ln -sfv python2-64 /usr/bin/python-64 &&
ln -sfv multiarch_wrapper /usr/bin/python &&
ln -sfv multiarch_wrapper /usr/bin/python2 &&
ln -sfv multiarch_wrapper /usr/bin/python2.7 &&
mv -v /usr/include/python2.7/pyconfig{,-64}.h

install -v -dm755 /usr/share/doc/python-2.7.6 &&

tar --strip-components=1                     \
    --no-same-owner                          \
    --directory /usr/share/doc/python-2.7.6 \
    -xvf ../python-2.7.6-docs-html.tar.bz2 &&

find /usr/share/doc/python-2.7.6 -type d -exec chmod 0755 {} \; &&
find /usr/share/doc/python-2.7.6 -type f -exec chmod 0644 {} \;

            
cd ${CLFSSOURCES}
checkBuiltPackage
rm -rf Python-2

cd ${CLFSSOURCES}

#Python 3 64-bit
wget https://www.python.org/ftp/python/3.6.0/Python-3.6.0.tar.xz -O \
  Python-3.6.0.tar.xz

wget http://pkgs.fedoraproject.org/cgit/rpms/python3.git/plain/00102-lib64.patch -O \
  python360-multilib.patch
  
wget https://docs.python.org/3.6/archives/python-3.6.0-docs-html.tar.bz2 -O \
  python-360-docs.tar.bz2
  
mkdir Python-3 && tar xf Python-3.6*.tar.xz -C Python-3 --strip-components 1
cd Python-3

patch -Np1 -i ../python360-multilib.patch

USE_ARCH=64 PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}"
CXX="/usr/bin/g++ ${BUILD64}" CC="/usr/bin/gcc ${BUILD64}"
./configure --prefix=/usr       \
            --enable-shared     \
            --with-system-expat \
            --with-system-ffi   \
            --libdir=/usr/lib64 \
            --with-custom-platlibdir=/usr/lib64 \
            --with-ensurepip=yes &&

make PREFIX=/usr LIBDIR=/usr/lib64 PLATLIBDIR=/usr/lib64 platlibdir=/usr/lib64
as_root make install PREFIX=/usr LIBDIR=/usr/lib64 PLATLIBDIR=/usr/lib64 \
  platlibdir=/usr/lib64

chmod -v 755 /usr/lib/libpython3.6m.so &&
chmod -v 755 /usr/lib/libpython3.so

install -v -dm755 /usr/share/doc/python-3.6.0/html &&
tar --strip-components=1 \
    --no-same-owner \
    --no-same-permissions \
    -C /usr/share/doc/python-3.6.0/html \
    -xvf ../python-3.6.0-docs-html.tar.bz2

ln -svfn python-3.6.0 /usr/share/doc/python-3

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

PYTHONHOME="/usr/lib64/python3.6/"
PYTHONPATH="/usr/lib64/python3.6/"
USE_ARCH=32 PKG_CONFIG_PATH="${PKG_CONFIG_PATH32}"
CXX="/usr/bin/g++ ${BUILD32}" CC="/usr/bin/gcc ${BUILD32}"

./configure $XORG_CONFIG32

make check

make PREFIX=/usr LIBDIR=/usr/lib
make PREFIX=/usr LIBDIR=/usr/lib install

cd ${CLFSSOURCES}/xc
checkBuiltPackage
rm -rf xcb-proto

#xcb-proto 64-bit
mkdir xcb-proto && tar xf xcb-proto-1.12.tar.* -C xcb-proto --strip-components 1
cd xcb-proto

patch -Np1 -i ../xcb-proto-1.12-schema-1.patch

patch -Np1 -i ../xcb-proto-1.12-python3-1.patch

PYTHONHOME="/usr/lib64/python3.6/"
PYTHONPATH="/usr/lib64/python3.6/"
USE_ARCH=64 PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}"
CXX="/usr/bin/g++ ${BUILD64}" CC="/usr/bin/gcc ${BUILD64}"

./configure $XORG_CONFIG64

make check

make PREFIX=/usr LIBDIR=/usr/lib64
make PREFIX=/usr LIBDIR=/usr/lib64 install

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

PYTHONHOME="/usr/lib64/python3.6/" PYTHONPATH="/usr/lib64/python3.6/" \
USE_ARCH=32 CXX="g++ ${BUILD32}" CC="gcc ${BUILD32}" \
PKG_CONFIG_PATH="${PKG_CONFIG_PATH32}" ./configure $XORG_CONFIG32    \
            --enable-xinput   \
            --without-doxygen \
            --libdir=/usr/lib \
            --without-doxygen \
            --docdir='${datadir}'/doc/libxcb-1.12 &&
            
make PREFIX=/usr LIBDIR=/usr/lib
make PREFIX=/usr LIBDIR=/usr/lib install

cd ${CLFSSOURCES}/xc
checkBuiltPackage
rm -rf libxdcmp

#libxcb 64-bit
mkdir libxcb && tar xf libxcb-*.tar.* -C libxcb --strip-components 1
cd libxcb

patch -Np1 -i ../libxcb-1.12-python3-1.patch
sed -i "s/pthread-stubs//" configure

PYTHONHOME="/usr/lib64/python3.6/" PYTHONPATH="/usr/lib64/python3.6/" \
USE_ARCH=64 CXX="g++ ${BUILD64}" CC="gcc ${BUILD64}" \
PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure $XORG_CONFIG64   \
            --enable-xinput   \
            --without-doxygen \
            --libdir=/usr/lib64 \
            --without-doxygen \
            --docdir='${datadir}'/doc/libxcb-1.12 &&
            
make PREFIX=/usr LIBDIR=/usr/lib64
make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc
checkBuiltPackage
rm -rf libxdcmp

cat > lib-7.md5 << "EOF"
c5ba432dd1514d858053ffe9f4737dd8  xtrans-1.3.5.tar.bz2
0f618db70c4054ca67cee0cc156a4255  libX11-1.6.5.tar.bz2
52df7c4c1f0badd9f82ab124fb32eb97  libXext-1.3.3.tar.bz2
d79d9fe2aa55eb0f69b1a4351e1368f7  libFS-1.0.7.tar.bz2
addfb1e897ca8079531669c7c7711726  libICE-1.0.9.tar.bz2
499a7773c65aba513609fe651853c5f3  libSM-1.2.2.tar.bz2
7a773b16165e39e938650bcc9027c1d5  libXScrnSaver-1.2.2.tar.bz2
8f5b5576fbabba29a05f3ca2226f74d3  libXt-1.1.5.tar.bz2
41d92ab627dfa06568076043f3e089e4  libXmu-1.1.2.tar.bz2
20f4627672edb2bd06a749f11aa97302  libXpm-3.5.12.tar.bz2
e5e06eb14a608b58746bdd1c0bd7b8e3  libXaw-1.0.13.tar.bz2
07e01e046a0215574f36a3aacb148be0  libXfixes-5.0.3.tar.bz2
f7a218dcbf6f0848599c6c36fc65c51a  libXcomposite-0.4.4.tar.bz2
802179a76bded0b658f4e9ec5e1830a4  libXrender-0.9.10.tar.bz2
1e7c17afbbce83e2215917047c57d1b3  libXcursor-1.1.14.tar.bz2
0cf292de2a9fa2e9a939aefde68fd34f  libXdamage-1.1.4.tar.bz2
0920924c3a9ebc1265517bdd2f9fde50  libfontenc-1.1.3.tar.bz2
0d9f6dd9c23bf4bcbfb00504b566baf5  libXfont2-2.0.1.tar.bz2
331b3a2a3a1a78b5b44cfbd43f86fcfe  libXft-2.3.2.tar.bz2
1f0f2719c020655a60aee334ddd26d67  libXi-1.7.9.tar.bz2
9336dc46ae3bf5f81c247f7131461efd  libXinerama-1.1.3.tar.bz2
28e486f1d491b757173dd85ba34ee884  libXrandr-1.5.1.tar.bz2
45ef29206a6b58254c81bea28ec6c95f  libXres-1.0.7.tar.bz2
ef8c2c1d16a00bd95b9fdcef63b8a2ca  libXtst-1.2.3.tar.bz2
210b6ef30dda2256d54763136faa37b9  libXv-1.0.11.tar.bz2
4cbe1c1def7a5e1b0ed5fce8e512f4c6  libXvMC-1.0.10.tar.bz2
d7dd9b9df336b7dd4028b6b56542ff2c  libXxf86dga-1.1.4.tar.bz2
298b8fff82df17304dfdb5fe4066fe3a  libXxf86vm-1.1.4.tar.bz2
ba983eba5a9f05d152a0725b8e863151  libdmx-1.1.3.tar.bz2
d810ab17e24c1418dedf7207fb2841d4  libpciaccess-0.13.5.tar.bz2
4a4cfeaf24dab1b991903455d6d7d404  libxkbfile-1.0.9.tar.bz2
66662e76899112c0f99e22f2fc775a7e  libxshmfence-1.2.tar.bz2
EOF

cd ${CLFSSOURCES}/xc

mkdir lib
cd lib
grep -v '^#' ../lib-7.md5 | awk '{print $2}' | wget -i- -c \
    -B https://www.x.org/pub/individual/lib/ &&
md5sum -c ../lib-7.md5

for package in $(grep -v '^#' ../lib-7.md5 | awk '{print $2}')
do
  packagedir=${package%.tar.bz2}
  tar -xf $package
  pushd $packagedir
  case $packagedir in
    libICE* )
    
    PYTHONHOME="/usr/lib64/python3.6/" \
    PYTHONPATH="/usr/lib64/python3.6/" \
    USE_ARCH=32 PKG_CONFIG_PATH="${PKG_CONFIG_PATH32}" \
    CXX="g++ ${BUILD32}" CC="gcc ${BUILD32}" ./configure $XORG_CONFIG32 \
      ICE_LIBS=-lpthread
    ;;
    
    libXfont2-[0-9]* )
    PYTHONHOME="/usr/lib64/python3.6/" \
    PYTHONPATH="/usr/lib64/python3.6/" \
    USE_ARCH=32 PKG_CONFIG_PATH="${PKG_CONFIG_PATH32}" \
    CXX="g++ ${BUILD32}" CC="gcc ${BUILD32}" ./configure $XORG_CONFIG32 \
      --disable-devel-docs
    ;;

    libXt-[0-9]* )
     PYTHONHOME="/usr/lib64/python3.6/" \
     PYTHONPATH="/usr/lib64/python3.6/" \
     USE_ARCH=32 PKG_CONFIG_PATH="${PKG_CONFIG_PATH32}" \
     CXX="g++ ${BUILD32}" CC="gcc ${BUILD32}" ./configure $XORG_CONFIG32 \
                  --with-appdefaultdir=/etc/X11/app-defaults
    ;;

    * )
     PYTHONHOME="/usr/lib64/python3.6/" \
     PYTHONPATH="/usr/lib64/python3.6/" \
     USE_ARCH=32 PKG_CONFIG_PATH="${PKG_CONFIG_PATH32}" \
     CXX="g++ ${BUILD32}" CC="gcc ${BUILD32}" ./configure $XORG_CONFIG32
    ;;
  esac
  make PREFIX=/usr LIBDIR=/usr/lib
  #make check 2>&1 | tee ../$packagedir-make_check.log
  #grep -A9 summary *make_check.log
  as_root make PREFIX=/usr LIBDIR=/usr/lib install
  checkBuiltPackage
  popd
  rm -rf $packagedir
  as_root /sbin/ldconfig
done

PYTHONHOME="/usr/lib64/python3.6/"
PYTHONPATH="/usr/lib64/python3.6/"
USE_ARCH=64 PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}"
CXX="g++ ${BUILD64}" CC="gcc ${BUILD64}"

cd ${CLFSSOURCES}/xc
cd lib

for package in $(grep -v '^#' ../lib-7.md5 | awk '{print $2}')
do
  packagedir=${package%.tar.bz2}
  tar -xf $package
  pushd $packagedir
  case $packagedir in
    libICE* )
      ./configure $XORG_CONFIG64 ICE_LIBS=-lpthread
    ;;

    libXfont2-[0-9]* )
      ./configure $XORG_CONFIG64 --disable-devel-docs
    ;;

    libXt-[0-9]* )
      ./configure $XORG_CONFIG64 \
                  --with-appdefaultdir=/etc/X11/app-defaults
    ;;

    * )
      ./configure $XORG_CONFIG64
    ;;
  esac
  make PREFIX=/usr LIBDIR=/usr/lib64
  #make check 2>&1 | tee ../$packagedir-make_check.log
  #grep -A9 summary *make_check.log
  as_root make PREFIX=/usr LIBDIR=/usr/lib64 install
  checkBuiltPackage
  popd
  rm -rf $packagedir
  as_root /sbin/ldconfig
done

cd ${CLFSSOURCES}/xc

#xcb-util 32-bit
wget http://xcb.freedesktop.org/dist/xcb-util-0.4.0.tar.bz2 -O \
  xcb-util-0.4.0.tar.bz2

mkdir xcb-util && tar xf xcb-util-*.tar.* -C xcb-util --strip-components 1
cd xcb-util

buildSingleXLib32

cd ${CLFSSOURCES}/xc
checkBuiltPackage
rm -rf xcb-util

#xcb-util 64-bit
mkdir xcb-util && tar xf xcb-util-*.tar.* -C xcb-util --strip-components 1
cd xcb-util

buildSingleXLib64

cd ${CLFSSOURCES}/xc
checkBuiltPackage
rm -rf xcb-util

#xcb-util-image 32-bit
wget http://xcb.freedesktop.org/dist/xcb-util-image-0.4.0.tar.bz2 -O \
  xcb-util-image-0.4.0.tar.bz2

mkdir xcb-util-image && tar xf xcb-util-image-*.tar.* -C xcb-util-image --strip-components 1
cd xcb-util-image

buildSingleXLib32
#LD_LIBRARY_PATH=$XORG_PREFIX/lib make check

cd ${CLFSSOURCES}/xc
checkBuiltPackage
rm -rf xcb-util-image

#xcb-util-image 64-bit
mkdir xcb-util-image && tar xf xcb-util-image-*.tar.* -C xcb-util-image --strip-components 1
cd xcb-util-image

buildSingleXLib64
#LD_LIBRARY_PATH=$XORG_PREFIX/lib make check

cd ${CLFSSOURCES}/xc
checkBuiltPackage
rm -rf xcb-util-image

#xcb-util-keysyms 32-bit
wget http://xcb.freedesktop.org/dist/xcb-util-keysyms-0.4.0.tar.bz2 -O \
  xcb-util-keysyms-0.4.0.tar.bz2

mkdir xcb-util-keysyms && tar xf xcb-util-keysyms-*.tar.* -C xcb-util-keysyms --strip-components 1
cd xcb-util-keysyms

buildSingleXLib32

cd ${CLFSSOURCES}/xc
checkBuiltPackage
rm -rf xcb-util-keysyms

#xcb-util-keysyms 64-bit
mkdir xcb-util-keysyms && tar xf xcb-util-keysyms-*.tar.* -C xcb-util-keysyms --strip-components 1
cd xcb-util-keysyms

buildSingleXLib64

cd ${CLFSSOURCES}/xc
checkBuiltPackage
rm -rf xcb-util-keysyms

#xcb-util-renderutil 32-bit
wget http://xcb.freedesktop.org/dist/xcb-util-renderutil-0.3.9.tar.bz2 -O \
  xcb-util-renderutil-0.3.9.tar.bz2

mkdir xcb-util-renderutil && tar xf xcb-util-renderutil-*.tar.* -C xcb-util-renderutil --strip-components 1
cd xcb-util-renderutil

buildSingleXLib32

cd ${CLFSSOURCES}/xc
checkBuiltPackage
rm -rf xcb-util-renderutil

#xcb-util-keysyms 64-bit
mkdir xcb-util-renderutil && tar xf xcb-util-renderutil-*.tar.* -C xcb-util-renderutil --strip-components 1
cd xcb-util-renderutil

buildSingleXLib64

cd ${CLFSSOURCES}/xc
checkBuiltPackage
rm -rf xcb-util-renderutil

#xcb-util-wm 32-bit
wget http://xcb.freedesktop.org/dist/xcb-util-wm-0.4.1.tar.bz2 -O \
  xcb-util-wm-0.4.1.tar.bz2

mkdir xcb-util-wm && tar xf xcb-util-wm-*.tar.* -C xcb-util-wm --strip-components 1
cd xcb-util-wm

buildSingleXLib32

cd ${CLFSSOURCES}/xc
checkBuiltPackage
rm -rf xcb-util-wm

#xcb-util-wm 64-bit
mkdir xcb-util-wm && tar xf xcb-util-wm-*.tar.* -C xcb-util-wm --strip-components 1
cd xcb-util-wm

buildSingleXLib64

cd ${CLFSSOURCES}/xc
checkBuiltPackage
rm -rf xcb-util-wm

#xcb-util-cursor 32-bit
wget http://xcb.freedesktop.org/dist/xcb-util-cursor-0.1.3.tar.bz2 -O \
  xcb-util-cursor-0.1.3.tar.bz2

mkdir xcb-util-cursor && tar xf xcb-util-cursor-*.tar.* -C xcb-util-cursor --strip-components 1
cd xcb-util-cursor

buildSingleXLib32

cd ${CLFSSOURCES}/xc
checkBuiltPackage
rm -rf xcb-util-cursor

#xcb-util-cursor 64-bit
mkdir xcb-util-cursor && tar xf xcb-util-cursor-*.tar.* -C xcb-util-cursor --strip-components 1
cd xcb-util-cursor

buildSingleXLib64

cd ${CLFSSOURCES}/xc
checkBuiltPackage
rm -rf xcb-util-cursor

#libdrm 32-bit
wget http://dri.freedesktop.org/libdrm/libdrm-2.4.81.tar.bz2 -O \
  libdrm-2.4.81.tar.bz2

mkdir libdrm && tar xf libdrm-*.tar.* -C libdrm --strip-components 1
cd libdrm

PKG_CONFIG_PATH="${PKG_CONFIG_PATH32}" \
  USE_ARCH=32 CC="gcc ${BUILD32}" CXX="g++ ${BUILD32}"

./configure --prefix=/usr --enable-udev --libdir=/usr/lib
make PREFIX=/usr LIBDIR=/usr/lib
make PREFIX=/usr LIBDIR=/usr/lib install

cd ${CLFSSOURCES}/xc
checkBuiltPackage
rm -rf libdrm

#libdrm 64-bit
mkdir libdrm && tar xf libdrm-*.tar.* -C libdrm --strip-components 1
cd libdrm

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
  USE_ARCH=64 CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}"

./configure --prefix=/usr --enable-udev --libdir=/usr/lib64
make PREFIX=/usr LIBDIR=/usr/lib64
make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc
checkBuiltPackage
rm -rf libdrm

#Build Python Module Beaker
#required by Python Module Mako
cd ${CLFSSOURCES}

wget https://pypi.python.org/packages/93/b2/12de6937b06e9615dbb3cb3a1c9af17f133f435bdef59f4ad42032b6eb49/Beaker-1.9.0.tar.gz -O \
  Beaker-1.9.0.tar.gz

mkdir pybeaker && tar xf Beaker-*.tar.* -C pybeaker --strip-components 1
cd pybeaker

PYTHONHOME="/usr/lib64/python3.6/"
PYTHONPATH="/usr/lib64/python3.6/"

python3-32 setup.py install --optimize=1
python3-64 setup.py install --optimize=1

PYTHONHOME="/usr/lib64/python2.7/"
PYTHONPATH="/usr/lib64/python2.7/"

python2-32 setup.py install --optimize=1
python2-64 setup.py install --optimize=1


cd ${CLFSSOURCES}
checkBuiltPackage
rm -rf pybeaker

#Build Python Module MarkupSafe
#required by Python Module Mako
cd ${CLFSSOURCES}

wget https://files.pythonhosted.org/packages/4d/de/32d741db316d8fdb7680822dd37001ef7a448255de9699ab4bfcbdf4172b/MarkupSafe-1.0.tar.gz -O \
  MarkupSafe-1.0.tar.gz

mkdir pyMarkupSafe && tar xf MarkupSafe-*.tar.* -C pyMarkupSafe --strip-components 1
cd pyMarkupSafe

PYTHONHOME="/usr/lib64/python3.6/"
PYTHONPATH="/usr/lib64/python3.6/"
python3-32 setup.py build
python3-32 setup.py install --optimize=1
python3-64 setup.py build
python3-64 setup.py install --optimize=1


PYTHONHOME="/usr/lib64/python2.7/"
PYTHONPATH="/usr/lib64/python2.7/"
python2-32 setup.py build
python2-32 setup.py install --optimize=1
python2-64 setup.py build
python2-64 setup.py install --optimize=1


cd ${CLFSSOURCES}
checkBuiltPackage
rm -rf pyMarkupSafe

#Build Python Mako modules for Mesa
#Both for Python 2.7 and 3.6
#32-bit and 64-bit each

cd ${CLFSSOURCES}

wget https://pypi.python.org/packages/source/M/Mako/Mako-1.0.4.tar.gz -O \
  Mako-1.0.4.tar.gz

#Let's start with Python 2.7 Mako modules
#32-bit
mkdir pymako && tar xf Mako-*.tar.* -C pymako --strip-components 1
cd pymako

PYTHONHOME="/usr/lib64/python2.7/"
PYTHONPATH="/usr/lib64/python2.7/"
python2-32 setup.py install --optimize=1

cd ${CLFSSOURCES}
checkBuiltPackage
rm -rf pymako

#64-bit
mkdir pymako && tar xf Mako-*.tar.* -C pymako --strip-components 1
cd pymako

PYTHONHOME="/usr/lib64/python2.7/"
PYTHONPATH="/usr/lib64/python2.7/"
python2-64 setup.py install --optimize=1

cd ${CLFSSOURCES}
checkBuiltPackage
rm -rf pymako

#Python 3.6 Mako modules
#32-bit
mkdir pymako && tar xf Mako-*.tar.* -C pymako --strip-components 1
cd pymako

PYTHONHOME="/usr/lib64/python3.6/"
PYTHONPATH="/usr/lib64/python3.6/"
sed -i "s:mako-render:&3:g" setup.py &&
python3-32 setup.py install --optimize=1

cd ${CLFSSOURCES}
checkBuiltPackage
rm -rf pymako

#64-bit
mkdir pymako && tar xf Mako-*.tar.* -C pymako --strip-components 1
cd pymako

PYTHONHOME="/usr/lib64/python3.6/"
PYTHONPATH="/usr/lib64/python3.6/"
sed -i "s:mako-render:&3:g" setup.py &&
python3-64 setup.py install --optimize=1

cd ${CLFSSOURCES}
checkBuiltPackage
rm -rf pymako

#So before we can build Mesa
#There are some reccomended deps
#elfutils-0.169 (required for the radeonsi driver)
#libvdpau-1.1.1 (to build VDPAU drivers)
#LLVM-4.0.1 (required for Gallium3D, r300, and radeonsi drivers and for the llvmpipe software rasterizer)
#See http://www.mesa3d.org/systems.html for more information)
#I have an NVIDIA GTX 1080
#I will go with vdpau for now
#Later I will install the proprietary NVIDIA drivers

#libvdpau 32-bit
wget http://people.freedesktop.org/~aplattner/vdpau/libvdpau-1.1.1.tar.bz2 -O \
  libvdpau-1.1.1.tar.bz2

mkdir libvdpau && tar xf libvdpau-*.tar.* -C libvdpau --strip-components 1
cd libvdpau

PKG_CONFIG_PATH="${PKG_CONFIG_PATH32}" \
USE_ARCH=32 CC="gcc ${BUILD32}" CXX="g++ ${BUILD32}"
./configure $XORG_CONFIG32 \
            --docdir=/usr/share/doc/libvdpau-1.1.1 &&

make PREFIX=/usr LIBDIR=/usr/lib
make PREFIX=/usr LIBDIR=/usr/lib install

cd ${CLFSSOURCES}
checkBuiltPackage
rm -rf libvdpau

#libvdpau 64-bit
mkdir libvdpau && tar xf libvdpau-*.tar.* -C libvdpau --strip-components 1
cd libvdpau

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
USE_ARCH=64 CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}"
./configure $XORG_CONFIG64 \
            --docdir=/usr/share/doc/libvdpau-1.1.1 &&

make PREFIX=/usr LIBDIR=/usr/lib64
make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}
checkBuiltPackage
rm -rf libvdpau

#Mesa 32-bit
wget https://mesa.freedesktop.org/archive/mesa-17.1.4.tar.xz -O \
  Mesa-17.1.4.tar.xz

wget http://www.linuxfromscratch.org/patches/blfs/svn/mesa-17.1.4-add_xdemos-1.patch -O \
mesa-17.1.4-add_xdemos-1.patch
  
mkdir Mesa && tar xf Mesa-*.tar.* -C Mesa --strip-components 1
cd Mesa

patch -Np1 -i ../mesa-17.1.4-add_xdemos-1.patch
GLL_DRV="i915,nouveau,svga,swrast"

PKG_CONFIG_PATH="${PKG_CONFIG_PATH32}" \
USE_ARCH=32 CC="gcc ${BUILD32}" CXX="g++ ${BUILD32}"

./autogen.sh CFLAGS='-O2' CXXFLAGS='-O2' \
            --prefix=$XORG_PREFIX        \
            --sysconfdir=/etc            \
            --enable-texture-float       \
            --libdir=/usr/lib            \
            --enable-osmesa              \
            --enable-xa                  \
            --enable-glx-tls             \
            --with-platforms="drm,x11"   \
            --with-gallium-drivers=$GLL_DRV \
            --with-egl-platforms

unset GLL_DRV

make PREFIX=/usr LIBDIR=/usr/lib
make -C xdemos DEMOS_PREFIX=$XORG_PREFIX LIBDIR=/usr/lib
make PREFIX=/usr LIBDIR=/usr/lib install
make -C xdemos DEMOS_PREFIX=$XORG_PREFIX LIBDIR=/usr/lib install

install -v -dm755 /usr/share/doc/mesa-17.1.4 &&
cp -rfv docs/* /usr/share/doc/mesa-17.1.4

cd ${CLFSSOURCES}
checkBuiltPackage
rm -rf Mesa

#Mesa 64-bit
mkdir Mesa && tar xf Mesa-*.tar.* -C Mesa --strip-components 1
cd Mesa

patch -Np1 -i ../mesa-17.1.4-add_xdemos-1.patch
GLL_DRV="i915,nouveau,svga,swrast"

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
USE_ARCH=64 CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}"

./autogen.sh CFLAGS='-O2' CXXFLAGS='-O2' \
            --prefix=$XORG_PREFIX        \
            --sysconfdir=/etc            \
            --enable-texture-float       \
            --libdir=/usr/lib64          \
            --enable-osmesa              \
            --enable-xa                  \
            --enable-glx-tls             \
            --with-platforms="drm,x11"   \
            --with-gallium-drivers=$GLL_DRV \
            --with-egl-platforms

unset GLL_DRV

make PREFIX=/usr LIBDIR=/usr/lib64
make -C xdemos DEMOS_PREFIX=$XORG_PREFIX LIBDIR=/usr/lib64
make PREFIX=/usr LIBDIR=/usr/lib64 install
make -C xdemos DEMOS_PREFIX=$XORG_PREFIX LIBDIR=/usr/lib64 install

install -v -dm755 /usr/share/doc/mesa-17.1.4 &&
cp -rfv docs/* /usr/share/doc/mesa-17.1.4

cd ${CLFSSOURCES}
checkBuiltPackage
rm -rf Mesa

cd ${CLFSSOURCES}/xc

#xbitmaps 32-bit
wget https://www.x.org/pub/individual/data/xbitmaps-1.1.1.tar.bz2 -O \
  xbitmaps-1.1.1.tar.bz2
  
mkdir xbitmaps && tar xf xbitmaps-*.tar.* -C xbitmaps --strip-components 1
cd xbitmaps

buildSingleXLib32

cd ${CLFSSOURCES}/xc
checkBuiltPackage
rm -rf xbitmaps

#xbitmaps 64-bit
mkdir xbitmaps && tar xf xbitmaps-*.tar.* -C xbitmaps --strip-components 1
cd xbitmaps

buildSingleXLib64

cd ${CLFSSOURCES}/xc
echo " "
echo "Add this point you COULD install Linux-PAM!"
echo "Xorg Apps will follow now and accept Linux-PAM as ooptional dep"
echo "If you want that answer next question with No"
echo "And after Linux-PAM is install, sudo and shadow and cracklib are rebuilt"
echo "start thies script again with"
echo "bash \<\(sed -n \'\<linenumber\>\,\$\p\' \<scriptname.sh\>\)"
echo "Also you must run cblfs_1 script for installing libpng!!! Required Dep!"
echo " "

checkBuiltPackage
rm -rf xbitmaps

#Add this point you COULD install Linux-PAM

#Xorg Apps
cat > app-7.md5 << "EOF"
25dab02f8e40d5b71ce29a07dc901b8c  iceauth-1.0.7.tar.bz2
c4a3664e08e5a47c120ff9263ee2f20c  luit-1.1.1.tar.bz2
18c429148c96c2079edda922a2b67632  mkfontdir-1.0.7.tar.bz2
9bdd6ebfa62b1bbd474906ac86a40fd8  mkfontscale-1.1.2.tar.bz2
e475167a892b589da23edf8edf8c942d  sessreg-1.1.1.tar.bz2
2c47a1b8e268df73963c4eb2316b1a89  setxkbmap-1.3.1.tar.bz2
3a93d9f0859de5d8b65a68a125d48f6a  smproxy-1.0.6.tar.bz2
f0b24e4d8beb622a419e8431e1c03cd7  x11perf-1.6.0.tar.bz2
f3f76cb10f69b571c43893ea6a634aa4  xauth-1.0.10.tar.bz2
0066f23f69ca3ef62dcaeb74a87fdc48  xbacklight-1.2.1.tar.bz2
9956d751ea3ae4538c3ebd07f70736a0  xcmsdb-1.0.5.tar.bz2
b58a87e6cd7145c70346adad551dba48  xcursorgen-1.0.6.tar.bz2
8809037bd48599af55dad81c508b6b39  xdpyinfo-1.3.2.tar.bz2
fceddaeb08e32e027d12a71490665866  xdriinfo-1.0.5.tar.bz2
249bdde90f01c0d861af52dc8fec379e  xev-1.2.2.tar.bz2
90b4305157c2b966d5180e2ee61262be  xgamma-1.0.6.tar.bz2
f5d490738b148cb7f2fe760f40f92516  xhost-1.0.7.tar.bz2
6a889412eff2e3c1c6bb19146f6fe84c  xinput-1.6.2.tar.bz2
cc22b232bc78a303371983e1b48794ab  xkbcomp-1.4.0.tar.bz2
c747faf1f78f5a5962419f8bdd066501  xkbevd-1.1.4.tar.bz2
502b14843f610af977dffc6cbf2102d5  xkbutils-1.0.4.tar.bz2
0ae6bc2a8d3af68e9c76b1a6ca5f7a78  xkill-1.0.4.tar.bz2
5dcb6e6c4b28c8d7aeb45257f5a72a7d  xlsatoms-1.1.2.tar.bz2
9fbf6b174a5138a61738a42e707ad8f5  xlsclients-1.1.3.tar.bz2
2dd5ae46fa18abc9331bc26250a25005  xmessage-1.0.4.tar.bz2
723f02d3a5f98450554556205f0a9497  xmodmap-1.0.9.tar.bz2
6101f04731ffd40803df80eca274ec4b  xpr-1.0.4.tar.bz2
fae3d2fda07684027a643ca783d595cc  xprop-1.2.2.tar.bz2
ebffac98021b8f1dc71da0c1918e9b57  xrandr-1.5.0.tar.bz2
b54c7e3e53b4f332d41ed435433fbda0  xrdb-1.1.0.tar.bz2
a896382bc53ef3e149eaf9b13bc81d42  xrefresh-1.0.5.tar.bz2
dcd227388b57487d543cab2fd7a602d7  xset-1.2.3.tar.bz2
7211b31ec70631829ebae9460999aa0b  xsetroot-1.1.1.tar.bz2
558360176b718dee3c39bc0648c0d10c  xvinfo-1.1.3.tar.bz2
6b5d48464c5f366e91efd08b62b12d94  xwd-1.0.6.tar.bz2
b777bafb674555e48fd8437618270931  xwininfo-1.1.3.tar.bz2
3025b152b4f13fdffd0c46d0be587be6  xwud-1.0.4.tar.bz2
EOF

mkdir app &&
cd app &&
grep -v '^#' ../app-7.md5 | awk '{print $2}' | wget -i- -c \
    -B https://www.x.org/pub/individual/app/ &&
md5sum -c ../app-7.md5

#PKG_CONFIG_PATH="${PKG_CONFIG_PATH32}" \
#USE_ARCH=32 CC="gcc ${BUILD32}" CXX="g++ ${BUILD32}"
#
#for package in $(grep -v '^#' ../app-7.md5 | awk '{print $2}')
#do
#  packagedir=${package%.tar.bz2}
#  tar -xf $package
#  pushd $packagedir
#     case $packagedir in
#       luit-[0-9]* )
#         sed -i -e "/D_XOPEN/s/5/6/" configure
#       ;;
#     esac
#
#     ./configure $XORG_CONFIG32
#     make PREFIX=/usr LIBDIR=/usr/lib
#     as_root make PREFIX=/usr LIBDIR=/usr/lib install
#  popd
#  rm -rf $packagedir
#done
#as_root rm -f $XORG_PREFIX/bin/xkeystone

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
USE_ARCH=64 CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}"

for package in $(grep -v '^#' ../app-7.md5 | awk '{print $2}')
do
  packagedir=${package%.tar.bz2}
  tar -xf $package
  pushd $packagedir
     case $packagedir in
       luit-[0-9]* )
         sed -i -e "/D_XOPEN/s/5/6/" configure
       ;;
     esac

     ./configure $XORG_CONFIG64
     make PREFIX=/usr LIBDIR=/usr/lib64
     as_root make PREFIX=/usr LIBDIR=/usr/lib64 install
  popd
  rm -rf $packagedir
done

as_root rm -f $XORG_PREFIX/bin/xkeystone

cd ${CLFSSOURCES}/xc

#xcursor-themes 32-bit
wget https://www.x.org/pub/individual/data/xcursor-themes-1.0.4.tar.bz2 -O \
  xcursor-themes-1.0.4.tar.bz2 
  
mkdir xcursor-themes && tar xf xcursor-themes-*.tar.* -C xcursor-themes --strip-components 1
cd xcursor-themes

buildSingleXLib32

cd ${CLFSSOURCES}/xc
checkBuiltPackage
rm -rf xcursor-themes

#xcursor-themes 64-bit
mkdir xcursor-themes && tar xf xcursor-themes-*.tar.* -C xcursor-themes --strip-components 1
cd xcursor-themes

buildSingleXLib64

cd ${CLFSSOURCES}/xc
checkBuiltPackage
rm -rf xcursor-themes

#Xorg Fonts
cat > font-7.md5 << "EOF"
23756dab809f9ec5011bb27fb2c3c7d6  font-util-1.3.1.tar.bz2
0f2d6546d514c5cc4ecf78a60657a5c1  encodings-1.0.4.tar.bz2
6d25f64796fef34b53b439c2e9efa562  font-alias-1.0.3.tar.bz2
fcf24554c348df3c689b91596d7f9971  font-adobe-utopia-type1-1.0.4.tar.bz2
e8ca58ea0d3726b94fe9f2c17344be60  font-bh-ttf-1.0.3.tar.bz2
53ed9a42388b7ebb689bdfc374f96a22  font-bh-type1-1.0.3.tar.bz2
bfb2593d2102585f45daa960f43cb3c4  font-ibm-type1-1.0.3.tar.bz2
6306c808f7d7e7d660dfb3859f9091d2  font-misc-ethiopic-1.0.3.tar.bz2
3eeb3fb44690b477d510bbd8f86cf5aa  font-xfree86-type1-1.0.4.tar.bz2
EOF

mkdir font
cd font

grep -v '^#' ../font-7.md5 | awk '{print $2}' | wget -i- -c \
    -B https://www.x.org/pub/individual/font/ &&
md5sum -c ../font-7.md5

PKG_CONFIG_PATH="${PKG_CONFIG_PATH32}" \
USE_ARCH=32 CC="gcc ${BUILD32}" CXX="g++ ${BUILD32}"

for package in $(grep -v '^#' ../font-7.md5 | awk '{print $2}')
do
  packagedir=${package%.tar.bz2}
  tar -xf $package
  pushd $packagedir
    ./configure $XORG_CONFIG32
    make PREFIX=/usr LIBDIR=/usr/lib
    as_root make PREFIX=/usr LIBDIR=/usr/lib install
  popd
  as_root rm -rf $packagedir
done

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
USE_ARCH=64 CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}"

for package in $(grep -v '^#' ../font-7.md5 | awk '{print $2}')
do
  packagedir=${package%.tar.bz2}
  tar -xf $package
  pushd $packagedir
    ./configure $XORG_CONFIG64
    make PREFIX=/usr LIBDIR=/usr/lib64
    as_root make PREFIX=/usr LIBDIR=/usr/lib64 install
  popd
  as_root rm -rf $packagedir
done

install -v -d -m755 /usr/share/fonts
ln -svfn $XORG_PREFIX/share/fonts/X11/OTF /usr/share/fonts/X11-OTF
ln -svfn $XORG_PREFIX/share/fonts/X11/TTF /usr/share/fonts/X11-TTF

cd ${CLFSSOURCES}/xc

#XKeyboardConfig 32-bit
wget http://xorg.freedesktop.org/archive/individual/data/xkeyboard-config/xkeyboard-config-2.21.tar.bz2 -O \
  xkeyboard-config-2.21.tar.bz2

mkdir xkeyboard-config && tar xf xkeyboard-config-*.tar.* -C xkeyboard-config --strip-components 1
cd xkeyboard-config

./configure $XORG_CONFIG32 --with-xkb-rules-symlink=xorg
make PREFIX=/usr LIBDIR=/usr/lib
make PREFIX=/usr LIBDIR=/usr/lib install

cd ${CLFSSOURCES}/xc
checkBuiltPackage
rm -rf xkeyboard-config

#XKeyboardConfig 64-bit
mkdir xkeyboard-config && tar xf xkeyboard-config-*.tar.* -C xkeyboard-config --strip-components 1
cd xkeyboard-config

./configure $XORG_CONFIG64 --with-xkb-rules-symlink=xorg
make PREFIX=/usr LIBDIR=/usr/lib64
make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc
checkBuiltPackage
rm -rf xkeyboard-config

#libepoxy 32-bit
wget https://github.com/anholt/libepoxy/releases/download/1.4.3/libepoxy-1.4.3.tar.xz -O \
  libepoxy-1.4.3.tar.xz

mkdir libepoxy && tar xf libepoxy-*.tar.* -C libepoxy --strip-components 1
cd libepoxy

PKG_CONFIG_PATH="${PKG_CONFIG_PATH32}" \
USE_ARCH=32 CC="gcc ${BUILD32}" CXX="g++ ${BUILD32}"

./configure --prefix=/usr --libdir=/usr/lib
make PREFIX=/usr LIBDIR=/usr/lib
make PREFIX=/usr LIBDIR=/usr/lib install

cd ${CLFSSOURCES}/xc
checkBuiltPackage
rm -rf libepoxy


#libepoxy 64-bit
mkdir libepoxy && tar xf libepoxy-*.tar.* -C libepoxy --strip-components 1
cd libepoxy

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
USE_ARCH=64 CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}"

./configure --prefix=/usr --libdir=/usr/lib64
make PREFIX=/usr LIBDIR=/usr/lib64
make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc
checkBuiltPackage
rm -rf libepoxy

#Pixman 32-bit
wget http://cairographics.org/releases/pixman-0.34.0.tar.gz -O \
  pixman-0.34.0.tar.gz

mkdir pixman && tar xf pixman-*.tar.* -C pixman --strip-components 1
cd pixman

PKG_CONFIG_PATH="${PKG_CONFIG_PATH32}" \
USE_ARCH=32 CC="gcc ${BUILD32}" CXX="g++ ${BUILD32}"

./configure --prefix=/usr \
  --disable-static \
  --libdir=/usr/lib
  
make PREFIX=/usr LIBDIR=/usr/lib
make PREFIX=/usr LIBDIR=/usr/lib install

cd ${CLFSSOURCES}/xc
checkBuiltPackage
rm -rf pixman

#Pixman 64-bit
mkdir pixman && tar xf pixman-*.tar.* -C pixman --strip-components 1
cd pixman

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
USE_ARCH=64 CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}"

./configure --prefix=/usr \
  --disable-static \
  --libdir=/usr/lib64
  
make PREFIX=/usr LIBDIR=/usr/lib64
make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc
checkBuiltPackage
rm -rf pixman

##Xorg Server 32-bit
#wget https://www.x.org/pub/individual/xserver/xorg-server-1.19.3.tar.bz2 -O \
#  xorg-server-1.19.3.tar.bz2 
#
#wget http://www.linuxfromscratch.org/patches/blfs/svn/xorg-server-1.19.3-add_prime_support-1.patch -O \
#  Xorg-server-1.19.3-add_prime_support-1.patch
#  
#mkdir xorg-server && tar xf xorg-server-*.tar.* -C xorg-server --strip-components 1
#cd xorg-server
#
#patch -Np1 -i ../xorg-server-1.19.3-add_prime_support-1.patch
#
#PKG_CONFIG_PATH="${PKG_CONFIG_PATH32}" \
#USE_ARCH=32 CC="gcc ${BUILD32}" CXX="g++ ${BUILD32}"
#
#./configure $XORG_CONFIG32            \
#           --enable-glamor          \
#           --enable-install-setuid  \
#           --enable-suid-wrapper    \
#           --disable-systemd-logind \
#           --with-xkb-output=/var/lib/xkb
#           
#make PREFIX=/usr LIBDIR=/usr/lib
#ldconfig
#make check
#make PREFIX=/usr LIBDIR=/usr/lib install
#mkdir -pv /etc/X11/xorg.conf.d
#
#cat >> /etc/sysconfig/createfiles << "EOF"
#/tmp/.ICE-unix dir 1777 root root
#/tmp/.X11-unix dir 1777 root root
#EOF
#
#cd ${CLFSSOURCES}/xc
#checkBuiltPackage
#rm -rf xorg-server

#Xorg Server 64-bit
wget https://www.x.org/pub/individual/xserver/xorg-server-1.19.3.tar.bz2 -O \
  xorg-server-1.19.3.tar.bz2 

wget http://www.linuxfromscratch.org/patches/blfs/svn/xorg-server-1.19.3-add_prime_support-1.patch -O \
  Xorg-server-1.19.3-add_prime_support-1.patch
  
mkdir xorg-server && tar xf xorg-server-*.tar.* -C xorg-server --strip-components 1
cd xorg-server

patch -Np1 -i ../xorg-server-1.19.3-add_prime_support-1.patch

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
USE_ARCH=32 CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}"

./configure $XORG_CONFIG64            \
           --enable-glamor          \
           --enable-install-setuid  \
           --enable-suid-wrapper    \
           --disable-systemd-logind \
           --with-xkb-output=/var/lib/xkb
           
make PREFIX=/usr LIBDIR=/usr/lib64
ldconfig
make check
checkBuiltPackage
make PREFIX=/usr LIBDIR=/usr/lib64 install
mkdir -pv /etc/X11/xorg.conf.d

cat >> /etc/sysconfig/createfiles << "EOF"
/tmp/.ICE-unix dir 1777 root root
/tmp/.X11-unix dir 1777 root root
EOF

cd ${CLFSSOURCES}/xc
checkBuiltPackage
rm -rf xorg-server

#Xorg Drivers
#http://www.linuxfromscratch.org/blfs/view/svn/x/x7driver.html
#Check there if you want synaptips, wacom, nouveau, Intel or AMD drivers!

cd ${CLFSSOURCES}

#pcituils
wget https://www.kernel.org/pub/software/utils/pciutils/pciutils-3.5.5.tar.xz -O \
  pciutils-3.5.5.tar.xz

mkdir pciutils && tar xf pciutils-*.tar.* -C pciutils --strip-components 1
cd pciutils

make PREFIX=/usr                \
     SHAREDIR=/usr/share/hwdata \
     LIBDIR=/usr/lib64          \
     SHARED=yes

make PREFIX=/usr                \
     SHAREDIR=/usr/share/hwdata \
     LIBDIR=/usr/lib64          \
     SHARED=yes                 \
     install install-lib        &&

chmod -v 755 /usr/lib/libpci.so


cd ${CLFSSOURCES}
checkBuiltPackage
rm -rf xorg-server

cd ${CLFSSOURCES}/xc

#libevdev 32-bit
wget http://www.freedesktop.org/software/libevdev/libevdev-1.5.7.tar.xz -O \
  libevdev-1.5.7.tar.xz

mkdir libevdev && tar xf libevdev-*.tar.* -C libevdev --strip-components 1
cd libevdev

buildSingleXLib32

cd ${CLFSSOURCES}/xc
checkBuiltPackage
rm -rf libevdev

#libevdev 64-bit
mkdir libevdev && tar xf libevdev-*.tar.* -C libevdev --strip-components 1
cd libevdev

buildSingleXLib64

cd ${CLFSSOURCES}/xc
checkBuiltPackage
rm -rf libevdev

#Xorg Evdev Driver 32-bit
wget https://www.x.org/pub/individual/driver/xf86-input-evdev-2.10.5.tar.bz2 -O \
  xf86-input-evdev-2.10.5.tar.bz2
  
mkdir xf86-input-evdev && tar xf xf86-input-evdev-*.tar.* -C xf86-input-evdev --strip-components 1
cd xf86-input-evdev

buildSingleXLib32

cd ${CLFSSOURCES}
checkBuiltPackage
rm -rf xf86-input-evdev

#Xorg Evdev Driver 64-bit
mkdir xf86-input-evdev && tar xf xf86-input-evdev-*.tar.* -C xf86-input-evdev --strip-components 1
cd xf86-input-evdev

buildSingleXLib64

cd ${CLFSSOURCES}/xc
checkBuiltPackage
rm -rf xf86-input-evdev

#mtdev 32-bit
wget http://bitmath.org/code/mtdev/mtdev-1.1.5.tar.bz2 -O \
  mtdev-1.1.5.tar.bz2
  
mkdir mtdev && tar xf mtdev-*.tar.* -C mtdev --strip-components 1
cd mtdev

PKG_CONFIG_PATH="${PKG_CONFIG_PATH32}" \
USE_ARCH=32 CC="gcc ${BUILD32}" CXX="g++ ${BUILD32}"

./configure --prefix=/usr \
  --disable-static \
  --libdir=/usr/lib
  
make PREFIX=/usr LIBDIR=/usr/lib
make PREFIX=/usr LIBDIR=/usr/lib install

cd ${CLFSSOURCES}/xc
checkBuiltPackage
rm -rf mtdev

#mtdev 64-bit
wget http://bitmath.org/code/mtdev/mtdev-1.1.5.tar.bz2 -O \
  mtdev-1.1.5.tar.bz2
  
mkdir mtdev && tar xf mtdev-*.tar.* -C mtdev --strip-components 1
cd mtdev

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
USE_ARCH=64 CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}"

./configure --prefix=/usr \
  --disable-static \
  --libdir=/usr/lib64
  
make PREFIX=/usr LIBDIR=/usr/lib64
make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc
checkBuiltPackage
rm -rf mtdev

#libinput 32-bit
wget http://www.freedesktop.org/software/libinput/libinput-1.8.0.tar.xz -O \
  libinput-1.8.0.tar.xz

mkdir libinput && tar xf libinput-*.tar.* -C libinput --strip-components 1
cd libinput

PKG_CONFIG_PATH="${PKG_CONFIG_PATH32}" \
USE_ARCH=32 CC="gcc ${BUILD32}" CXX="g++ ${BUILD32}"

./configure $XORG_CONFIG32          \
            --disable-libwacom      \
            --disable-debug-gui     \
            --disable-tests         \
            --disable-documentation \
            --with-udev-dir=/lib/udev
            
make PREFIX=/usr LIBDIR=/usr/lib
make PREFIX=/usr LIBDIR=/usr/lib install


cd ${CLFSSOURCES}/xc
checkBuiltPackage
rm -rf libinput


#libinput 64-bit
mkdir libinput && tar xf libinput-*.tar.* -C libinput --strip-components 1
cd libinput

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
USE_ARCH=64 CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}"

./configure $XORG_CONFIG64          \
            --disable-libwacom      \
            --disable-debug-gui     \
            --disable-tests         \
            --disable-documentation \
            --with-udev-dir=/lib64/udev
            
make PREFIX=/usr LIBDIR=/usr/lib64
make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc
checkBuiltPackage
rm -rf libinput

#Xorg Fbdev Driver 32-bit
wget https://www.x.org/pub/individual/driver/xf86-video-fbdev-0.4.4.tar.bz2 -O \
  xf86-video-fbdev-0.4.4.tar.bz2
  
mkdir xf86vidfbdev && tar xf xf86-video-fbdev-*.tar.* -C xf86vidfbdev --strip-components 1
cd xf86vidfbdev

buildSingleXLib32

cd ${CLFSSOURCES}/xc
checkBuiltPackage
rm -rf xf86vidfbdev

#Xorg Fbdev Driver 64-bit
mkdir xf86vidfbdev && tar xf xf86-video-fbdev-*.tar.* -C xf86vidfbdev --strip-components 1
cd xf86vidfbdev

buildSingleXLib64

cd ${CLFSSOURCES}/xc
checkBuiltPackage
rm -rf xf86vidfbdev

#NVIDIA PROPRIETARY DRIVER
wget http://us.download.nvidia.com/XFree86/Linux-x86_64/384.47/NVIDIA-Linux-x86_64-384.47.run -O \
  NVIDIA-Linux-x86_64-384.47.run

as_root chmod +x NVIDIA-Linux-x86_64-384.47.run
as_root /NVIDIA-Linux-x86_64-384.47.run \
 --kernel-source-path=/lib/modules/CLFS-4.12.2_ORIGINAL \
 USE_ARCH=64 PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
 CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}"

#twm 64-bit
wget https://www.x.org/pub/individual/app/twm-1.0.9.tar.bz2 -O \
  twm-1.0.9.tar.bz2
  
mkdir twm && tar xf twm-*.tar.* -C twm --strip-components 1
cd twm

sed -i -e '/^rcdir =/s,^\(rcdir = \).*,\1/etc/X11/app-defaults,' src/Makefile.in

buildSingleXLib64

cd ${CLFSSOURCES}/xc
checkBuiltPackage
rm -rf twm

USE_ARCH=64 PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}"

#xterm 64-bit
wget ftp://invisible-island.net/xterm/xterm-330.tgz -O \
  xterm-330.tgz
  
mkdir xterm && tar xf xterm-*.tar.* -C xterm --strip-components 1
cd xterm

sed -i '/v0/{n;s/new:/new:kb=^?:/}' termcap &&
printf '\tkbs=\\177,\n' >> terminfo &&

TERMINFO=/usr/share/terminfo \
./configure $XORG_CONFIG     \
    --with-app-defaults=/etc/X11/app-defaults &&

make PREFIX=/usr LIBDIR=/usr/lib64
make install PREFIX=/usr LIBDIR=/usr/lib64
make PREFIX=/usr LIBDIR=/usr/lib64 install-ti

cat >> /etc/X11/app-defaults/XTerm << "EOF"
*VT100*locale: true
*VT100*faceName: Monospace
*VT100*faceSize: 10
*backarrowKeyIsErase: true
*ptyInitialErase: true
EOF

cd ${CLFSSOURCES}/xc
checkBuiltPackage
rm -rf xterm

#xclock 64-bit
wget https://www.x.org/pub/individual/app/xclock-1.0.7.tar.bz2 -O \
  xclock-1.0.7.tar.bz2

mkdir xclock && tar xf xclock-*.tar.* -C xclock --strip-components 1
cd xclock

buildSingleXLib64

cd ${CLFSSOURCES}/xc
checkBuiltPackage
rm -rf xclock

#xinit 64-bit
wget https://www.x.org/pub/individual/app/xinit-1.0.7.tar.bz2 -O \
  xinit-1.0.7.tar.bz2

mkdir xinit && tar xf xinit-*.tar.* -C xclock --strip-components 1
cd xinit

sed -e '/$serverargs $vtarg/ s/serverargs/: #&/' \
    -i startx.cpp

USE_ARCH=64 PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}"

./configure $XORG_CONFIG64 --with-xinitdir=/etc/X11/app-defaults
make PREFIX=/usr LIBDIR=/usr/lib64
make PREFIX=/usr LIBDIR=/usr/lib64 install
ldconfig

cd ${CLFSSOURCES}/xc
checkBuiltPackage
rm -rf xinit

#DejaVu Fonts
wget https://netcologne.dl.sourceforge.net/project/dejavu/dejavu/2.37/dejavu-fonts-ttf-2.37.tar.bz2 -O \
  dejavu-fonts-ttf-2.37.tar.bz2

mkdir dejavu-fonts && tar xf dejavu-fonts-*.tar.* -C dejavu-fonts --strip-components 1
cd dejavu-fonts

mkdir /etc/fonts
mkdir /etc/fonts/conf.d
mkdir /etc/fonts.conf.avail
mkdir -pv /usr/share/fonts/TTF

cp -v fontconfig/* /etc/fonts/conf.avail
cp -v fontconfig/* /etc/fonts/conf.d
cp -v ttf/* /usr/share/fonts/TTF

cd ${CLFSSOURCES}/xc
checkBuiltPackage
rm -rf dejavu-fonts

cat > /etc/X11/xorg.conf.d/xkb-defaults.conf << "EOF"
Section "InputClass"
    Identifier "XKB Defaults"
    MatchIsKeyboard "yes"
    Option "XkbLayout" "de-latin1"
    Option "XkbOptions" "terminate:ctrl_alt_bksp"
EndSection
EOF

as_root usermod -a -G video overflyer

cat > /etc/X11/xorg.conf.d/xkb-defaults.conf << "EOF"
Section "InputClass"
    Identifier "XKB Defaults"
    MatchIsKeyboard "yes"
    Option "XkbLayout" "fr"
    Option "XkbOptions" "terminate:ctrl_alt_bksp"
EndSection
EOF

#I will not install Xorg legacy
#If you want to
#Go to http://www.linuxfromscratch.org/blfs/view/svn/x/x7legacy.html
