#!/bin/bash

function checkBuiltPackage() {
echo ""
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
echo ""
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
#THat should suffice

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" 
USE_ARCH=64 
CXX="g++ ${BUILD64}" 
CC="gcc ${BUILD64}"

export PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" 
export USE_ARCH=64 
export CXX="g++ ${BUILD64}" 
export CC="gcc ${BUILD64}"

#We left off installing gtk3

#libxml2 WITH ITS PYTHON 2 MODULE
wget http://xmlsoft.org/sources/libxml2-2.9.4.tar.gz -O \
    libxml2-2.9.4.tar.gz

#Download testsuite. WE NEED IT to build the Python module!
wget http://www.w3.org/XML/Test/xmlts20130923.tar.gz -O \
    xmlts20130923.tar.gz

mkdir libxml2 && tar xf libxml2-*.tar.* -C libxml2 --strip-components 1
cd libxml2

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure --prefix=/usr \
   --disable-static \
   --with-history   \
   --libdir=/usr/lib64 \
   --with-python=/usr/bin/python2.7 \
   --with-icu \
   --with-threads

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} make PREFIX=/usr LIBDIR=/usr/lib64

tar xf ../xmlts20130923.tar.gz
make check > check.log
grep -E '^Total|expected' check.log
checkBuiltPackage

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install 

cd ${CLFSSOURCES}/xc/mate
sudo updatedb
sudo bash -c 'locate libxml2 | grep python2.7'
echo "Did locate libxml | grep python2.7 find the libxml2 python2 modules?"
echo ""

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf libxml2

#libxml2 WITH ITS PYTHON 3 MODULE
mkdir libxml2 && tar xf libxml2-*.tar.* -C libxml2 --strip-components 1
cd libxml2

#run this to build Python3 module
#Python2 module would be the default
#We try not to use Python2 in CLFS multib!
sed -i '/_PyVerify_fd/,+1d' python/types.c

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure --prefix=/usr \
   --disable-static \
   --with-history   \
   --libdir=/usr/lib64 \
   --with-python=/usr/bin/python3.6 \
   --with-icu \
   --with-threads

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} make PREFIX=/usr LIBDIR=/usr/lib64

tar xf ../xmlts20130923.tar.gz
make check > check.log
grep -E '^Total|expected' check.log
checkBuiltPackage

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install 

cd ${CLFSSOURCES}/xc/mate
sudo updatedb
sudo bash -c 'locate libxml2 | grep python3.6/'
echo "Did locate libxml | grep python3.6 find the libxml2 python3 modules?"
echo ""

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf libxml2

#libxslt
wget http://xmlsoft.org/sources/libxslt-1.1.29.tar.gz -O \
    libxslt-1.1.29.tar.gz 

mkdir libxslt && tar xf libxslt-*.tar.* -C libxslt --strip-components 1
cd libxslt

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure --prefix=/usr \
   --disable-static \
   --libdir=/usr/lib64 

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make PREFIX=/usr LIBDIR=/usr/lib64
sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

sudo ldconfig

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf libxslt

#Before dconf we need to build everything needed for GTK-Doc
#That is when you have no internet connection!!!
#Otherwise disable nonet parameter for xsltproc in doc/Makefile
#BLFS does not mention that
#Otherwise dconf fails with 
#I/O error : Attempt to load network entity http://docbook.sourceforge.net/release/xsl/current/manpages/docbook.xsl

#dconf and dconf-editor
wget http://ftp.gnome.org/pub/gnome/sources/dconf/0.26/dconf-0.26.0.tar.xz -O \
    Dconf-0.26.0.tar.xz

wget http://ftp.gnome.org/pub/gnome/sources/dconf-editor/3.22/dconf-editor-3.22.3.tar.xz -O \
    dconf-editor-3.22.3.tar.xz

mkdir dconf && tar xf Dconf-*.tar.* -C dconf --strip-components 1
cd dconf

#This 'patch' only works when you have a working itnernet connection
sed -i 's/--nonet//' docs/Makefile

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure --prefix=/usr \
   --libdir=/usr/lib64 \
   --sysconfdir=/etc \
   --disable-gtk-doc

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make PREFIX=/usr LIBDIR=/usr/lib64
sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

tar -xf ../dconf-editor-3.22.3.tar.xz &&
cd dconf-editor-3.22.3 &&

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure --prefix=/usr \
   --libdir=/usr/lib64 \
   --sysconfdir=/etc

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make PREFIX=/usr LIBDIR=/usr/lib64
sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf dconf

#json-glib
wget http://ftp.gnome.org/pub/gnome/sources/json-glib/1.2/json-glib-1.2.8.tar.xz -O \
    json-glib-1.2.8.tar.xz

mkdir jsonglib && tar xf json-glib-*.tar.* -C jsonglib --strip-components 1
cd jsonglib

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure --prefix=/usr \
   --libdir=/usr/lib64 
    
PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make PREFIX=/usr LIBDIR=/usr/lib64
sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf jsonglib

#libcroco
wget http://ftp.gnome.org/pub/gnome/sources/libcroco/0.6/libcroco-0.6.12.tar.xz -O \
    libcroco-0.6.12.tar.xz

mkdir libcroco && tar xf libcroco-*.tar.* -C libcroco --strip-components 1
cd libcroco

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure --prefix=/usr \
   --libdir=/usr/lib64 \
   --disable-static

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make PREFIX=/usr LIBDIR=/usr/lib64
sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf libcroco

#Vala
wget http://ftp.gnome.org/pub/gnome/sources/vala/0.36/vala-0.36.4.tar.xz -O \
    vala-0.36.4.tar.xz

mkdir vala && tar xf vala-*.tar.* -C vala --strip-components 1
cd vala

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure --prefix=/usr \
   --libdir=/usr/lib64 \
   --disable-static 

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make PREFIX=/usr LIBDIR=/usr/lib64
sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf vala

#librsvg
wget http://ftp.gnome.org/pub/gnome/sources/librsvg/2.40/librsvg-2.40.17.tar.xz -O \
    librsvg-2.40.17.tar.xz

mkdir librsvg && tar xf librsvg-*.tar.* -C librsvg --strip-components 1
cd librsvg

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure --prefix=/usr \
   --libdir=/usr/lib64 \
   --disable-static \
   --enable-vala

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make PREFIX=/usr LIBDIR=/usr/lib64
sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf librsvg

#shared-mime-info
wget http://freedesktop.org/~hadess/shared-mime-info-1.8.tar.xz -O \
    shared-mime-info-1.8.tar.xz

mkdir sharedmimeinfo && tar xf shared-mime-info-*.tar.* -C sharedmimeinfo --strip-components 1
cd sharedmimeinfo

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure --prefix=/usr \
   --libdir=/usr/lib64 

make check
checkBuiltPackage

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make PREFIX=/usr LIBDIR=/usr/lib64
sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf sharedmimeinfo

#libogg
wget http://downloads.xiph.org/releases/ogg/libogg-1.3.2.tar.xz -O \
    libogg-1.3.2.tar.xz

mkdir libogg && tar xf libogg-*.tar.* -C libogg --strip-components 1
cd libogg

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure --prefix=/usr \
   --libdir=/usr/lib64 \
   --disable-static \
   --docdir=/usr/share/doc/libogg-1.3.2

make check
checkBuiltPackage

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make PREFIX=/usr LIBDIR=/usr/lib64
sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf libogg

#libvorbis
wget http://downloads.xiph.org/releases/vorbis/libvorbis-1.3.5.tar.xz -O \
    libvorbis-1.3.5.tar.xz

mkdir libvorbis && tar xf libvorbis-*.tar.* -C libvorbis --strip-components 1
cd libvorbis

sed -i '/components.png \\/{n;d}' doc/Makefile.in

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure --prefix=/usr \
   --libdir=/usr/lib64 \
   --disable-static 

make LIBS=-lm check
checkBuiltPackage

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make PREFIX=/usr LIBDIR=/usr/lib64
sudo make PREFIX=/usr LIBDIR=/usr/lib64 install
sudo install -v -m644 doc/Vorbis* /usr/share/doc/libvorbis-1.3.5

ldconfig 

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf libvorbis

#alsa-lib
wget ftp://ftp.alsa-project.org/pub/lib/alsa-lib-1.1.4.1.tar.bz2 -O \
    alsa-lib-1.1.4.1.tar.bz2

mkdir alsa-lib && tar xf alsa-lib-*.tar.* -C alsa-lib --strip-components 1
cd alsa-lib

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure --prefix=/usr \
   --libdir=/usr/lib64 

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make PREFIX=/usr LIBDIR=/usr/lib64
make check
checkBuiltPackage

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

sudo install -v -d -m755 /usr/share/doc/alsa-lib-1.1.4.1/html/search &&
sudo install -v -m644 doc/doxygen/html/*.* \
                /usr/share/doc/alsa-lib-1.1.4.1/html 


sudo bash -c 'cat > /etc/asound.conf << "EOF"
pcm.!default {
  type hw
  card 0
}
ctl.!default {
  type hw           
  card 0
}
EOF'

sudo bash -c 'cat > /usr/share/alsa/alsa.conf << "EOF"
pcm.!default {
  type hw
  card 0
}
ctl.!default {
  type hw           
  card 0
}
EOF'

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf alsa-lib

#alsa-utils
wget ftp://ftp.alsa-project.org/pub/plugins/alsa-plugins-1.1.4.tar.bz2 -O \
  alsa-plugins-1.1.4.tar.bz2

mkdir alsa-plugins && tar xf alsa-plugins-*.tar.* -C alsa-plugins --strip-components 1
cd alsa-plugins

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure --prefix=/usr \
   --libdir=/usr/lib64 

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make PREFIX=/usr LIBDIR=/usr/lib64
sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf alsa-plugins

#alsa-utils
wget ftp://ftp.alsa-project.org/pub/utils/alsa-utils-1.1.4.tar.bz2 -O \
  alsa-utils-1.1.4.tar.bz2  

mkdir alsa-utils && tar xf alsa-utils-*.tar.* -C alsa-utils --strip-components 1
cd alsa-utils

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure --prefix=/usr \
   --libdir=/usr/lib64 \
   --disable-alsaconf \
   --disable-bat   \
   --with-curses=ncursesw

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make PREFIX=/usr LIBDIR=/usr/lib64
sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

sudo alsactl -L store
usermod -a -G audio overflyer

cd ${CLFSSOURCES}/blfs-bootscripts
sudo make install-alsa

sudo /etc/rc.d/init.d/alsa/start

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf alsa-utils

#alsa-tools
wget ftp://ftp.alsa-project.org/pub/tools/alsa-tools-1.1.3.tar.bz2 -O \
  alsa-tools-1.1.3.tar.bz2 

mkdir alsa-tools && tar xf alsa-tools-*.tar.* -C alsa-tools --strip-components 1
cd alsa-tools

rm -rf qlo10k1 Makefile gitcompile

for tool in *
do
  case $tool in
    seq )
      tool_dir=seq/sbiload
    ;;
    * )
      tool_dir=$tool
    ;;
  esac

  pushd $tool_dir
    PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure --prefix=/usr \
      --libdir=/usr/lib64
    PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
    make PREFIX=/usr LIBDIR=/usr/lib64
    sudo make PREFIX=/usr LIBDIR=/usr/lib64 install
    sudo ldconfig
  popd

done
unset tool tool_dir

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf alsa-tools


#alsa-firmware
wget ftp://ftp.alsa-project.org/pub/firmware/alsa-firmware-1.0.29.tar.bz2 -O \
  alsa-firmware-1.0.29.tar.bz2
  
mkdir alsa-firmware && tar xf alsa-firmware-*.tar.* -C alsa-firmware --strip-components 1
cd alsa-firmware

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure --prefix=/usr \
   --libdir=/usr/lib64 

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make PREFIX=/usr LIBDIR=/usr/lib64
sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf alsa-firmware

#alsa-oss
wget ftp://ftp.alsa-project.org/pub/oss-lib/alsa-oss-1.0.28.tar.bz2 -O \
  alsa-oss-1.0.28.tar.bz2
  
mkdir alsa-oss && tar xf alsa-oss-*.tar.* -C alsa-oss --strip-components 1
cd alsa-oss

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure --prefix=/usr \
   --libdir=/usr/lib64 --disable-static

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make PREFIX=/usr LIBDIR=/usr/lib64
sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf alsa-oss
