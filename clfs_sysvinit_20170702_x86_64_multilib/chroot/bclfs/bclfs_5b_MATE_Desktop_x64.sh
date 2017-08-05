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
#Now we continue with libxslt which first needs libxml2 (WITH THE PYTHON MODULE!!!)

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
sudo locate libxml | grep /usr/lib64/python2.7/
echo "Did locate libxml \| grep /usr/lib64/python2.7/ find the libxml python modules?"
echo ""

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf libxml2

#libxml2 WITH ITS PYTHON 3 MODULE
wget http://xmlsoft.org/sources/libxml2-2.9.4.tar.gz -O \
    libxml2-2.9.4.tar.gz

#Download testsuite. WE NEED IT to build the Python module!
wget http://www.w3.org/XML/Test/xmlts20130923.tar.gz -O \
    xmlts20130923.tar.gz

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
   --with-python=/usr/bin/python3 \
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
sudo locate libxml | grep /usr/lib64/python3.6/
echo "Did locate libxml | grep /usr/lib64/python3.6/ find the libxml python modules?"
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
   --libdir=/usr/lib64 \

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make PREFIX=/usr LIBDIR=/usr/lib64
sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

ldconfig

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
   --libdir=/usr/lib64 \
   --disable-static 

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make PREFIX=/usr LIBDIR=/usr/lib64
make check
checkBuiltPackage

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

sudo install -v -d -m755 /usr/share/doc/alsa-lib-1.1.4.1/html/search &&
sudo install -v -m644 doc/doxygen/html/*.* \
                /usr/share/doc/alsa-lib-1.1.4.1/html 


cat > /etc/asound.conf << "EOF"
pcm.!default {
  type hw
  card 0
}

ctl.!default {
  type hw           
  card 0
}
EOF

cat > /usr/share/alsa/alsa.conf << "EOF"
pcm.!default {
  type hw
  card 0
}

ctl.!default {
  type hw           
  card 0
}
EOF

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf alsa-lib

#gstreamer
wget https://gstreamer.freedesktop.org/src/gstreamer/gstreamer-1.12.1.tar.xz -O \
    gstreamer-1.12.1.tar.xz

mkdir gstreamer && tar xf gstreamer-*.tar.* -C gstreamer --strip-components 1
cd gstreamer

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure --prefix=/usr \
   --libdir=/usr/lib64 \
   --disable-static \
   --with-package-name="GStreamer 1.12.1 BLFS" \
   --with-package-origin="http://www.linuxfromscratch.org/blfs/view/svn/" 

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make PREFIX=/usr LIBDIR=/usr/lib64

rm -rf /usr/bin/gst-* /usr/{lib,libexec}/gstreamer-1.0

make check
checkBuiltPackage

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

ldconfig

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf gstreamer

#gst-plugins-base
wget https://gstreamer.freedesktop.org/src/gst-plugins-base/gst-plugins-base-1.12.1.tar.xz -O \
    gst-plugins-base-1.12.1.tar.xz

mkdir gstplgbase && tar xf gst-plugins-base-*.tar.* -C gstplgbase --strip-components 1
cd gstplgbase

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure --prefix=/usr \
   --libdir=/usr/lib64 \
   --disable-static \
   --with-package-name="GStreamer 1.12.1 BLFS" \
   --with-package-origin="http://www.linuxfromscratch.org/blfs/view/svn/" 

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make PREFIX=/usr LIBDIR=/usr/lib64

make check
checkBuiltPackage

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf gstplgbase

#gst-plugins-good
wget https://gstreamer.freedesktop.org/src/gst-plugins-good/gst-plugins-good-1.12.1.tar.xz -O \
    gst-plugins-good-1.12.1.tar.xz

mkdir gstplggood && tar xf gst-plugins-good-*.tar.* -C gstplggood --strip-components 1
cd gstplggood

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure --prefix=/usr \
   --libdir=/usr/lib64 \
   --disable-static \
   --with-package-name="GStreamer 1.12.1 BLFS" \
   --with-package-origin="http://www.linuxfromscratch.org/blfs/view/svn/" 

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make PREFIX=/usr LIBDIR=/usr/lib64

make check
checkBuiltPackage

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf gstplggood

#libcanberra
wget http://0pointer.de/lennart/projects/libcanberra/libcanberra-0.30.tar.xz -O \
    libcanberra-0.30.tar.xz

mkdir libcanberra && tar xf libcanberra-*.tar.* -C libcanberra --strip-components 1
cd libcanberra

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure --prefix=/usr \
   --libdir=/usr/lib64 \
   --disable-static \
   --disable-oss 

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make PREFIX=/usr LIBDIR=/usr/lib64
sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf libcanberra

#littleCMS2
wget http://downloads.sourceforge.net/lcms/lcms2-2.8.tar.gz -O \
    lcms2-2.8.tar.gz

mkdir lcms2 && tar xf lcms2-*.tar.* -C lcms2 --strip-components 1
cd lcms2

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure --prefix=/usr \
   --libdir=/usr/lib64 \
   --disable-static \

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make PREFIX=/usr LIBDIR=/usr/lib64
sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf lcms2

#sqlite
wget http://sqlite.org/2017/sqlite-autoconf-3190300.tar.gz -O \
    sqlite-autoconf-3190300.tar.gz

mkdir sqlite-autoconf && tar xf sqlite-autoconf-*.tar.* -C sqlite-autoconf --strip-components 1
cd sqlite-autoconf

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure --prefix=/usr \
            --disable-static        \
            --libdir=/usr/lib64     \
            CFLAGS="-g -O2 -DSQLITE_ENABLE_FTS3=1 \
            -DSQLITE_ENABLE_COLUMN_METADATA=1     \
            -DSQLITE_ENABLE_UNLOCK_NOTIFY=1       \
            -DSQLITE_SECURE_DELETE=1              \
            -DSQLITE_ENABLE_DBSTAT_VTAB=1" &&

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make PREFIX=/usr LIBDIR=/usr/lib64
sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf sqlite-autoconf

#Valgrind
wget ftp://sourceware.org/pub/valgrind/valgrind-3.13.0.tar.bz2 -O \
    valgrind-3.13.0.tar.bz2

mkdir valgrind && tar xf valgrind-*.tar.* -C valgrind --strip-components 1
cd valgrind

sed -i 's|/doc/valgrind||' docs/Makefile.in

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure --prefix=/usr \
   --libdir=/usr/lib64 \
   --disable-static 

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make PREFIX=/usr LIBDIR=/usr/lib64
sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf valgrind

#libgudev
wget http://ftp.gnome.org/pub/gnome/sources/libgudev/231/libgudev-231.tar.xz -O \
    libgudev-231.tar.xz

mkdir libgudev && tar xf libgudev-*.tar.* -C libgudev --strip-components 1
cd libgudev

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure --prefix=/usr \
   --libdir=/usr/lib64 \
   --disable-static \
   --disable-umockdev

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make PREFIX=/usr LIBDIR=/usr/lib64
sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf libgudev

#libusb
wget https://github.com//libusb/libusb/releases/download/v1.0.21/libusb-1.0.21.tar.bz2 -O \
    libusb-1.0.21.tar.bz2

mkdir libusb && tar xf libusb-*.tar.* -C libusb --strip-components 1
cd libusb

sed -i "s/^PROJECT_LOGO/#&/" doc/doxygen.cfg.in

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure --prefix=/usr \
   --libdir=/usr/lib64 \
   --disable-static 

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make -j1 PREFIX=/usr LIBDIR=/usr/lib64
sudo make -j1 PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf libusb

#libgusb
wget http://people.freedesktop.org/~hughsient/releases/libgusb-0.2.10.tar.xz -O \
    libgusb-0.2.10.tar.xz

mkdir libgusb && tar xf libgusb-*.tar.* -C libgusb --strip-components 1
cd libgusb

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure --prefix=/usr \
   --libdir=/usr/lib64 \
   --disable-static 

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make PREFIX=/usr LIBDIR=/usr/lib64
sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf libgusb

#NSPR
wget https://ftp.mozilla.org/pub/mozilla.org/nspr/releases/v4.15/src/nspr-4.15.tar.gz -O \
    nspr-4.15.tar.gz

mkdir nspr && tar xf nspr-*.tar.* -C nspr --strip-components 1
cd nspr

cd nspr                                                     &&
sed -ri 's#^(RELEASE_BINS =).*#\1#' pr/src/misc/Makefile.in &&
sed -i 's#$(LIBRARY) ##'            config/rules.mk         &&

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure --prefix=/usr \
   --libdir=/usr/lib64 \
   --with-mozilla \
   --with-pthreads \
   $([ $(uname -m) = x86_64 ] && echo --enable-64bit)

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make PREFIX=/usr LIBDIR=/usr/lib64
sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf nspr

#startup-notification
wget http://www.freedesktop.org/software/startup-notification/releases/startup-notification-0.12.tar.gz -O \
    startup-notification-0.12.tar.gz

mkdir startup-notification && tar xf startup-notification-*.tar.* -C startup-notification --strip-components 1
cd startup-notification

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure --prefix=/usr \
   --libdir=/usr/lib64 \
   --disable-static 

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make PREFIX=/usr LIBDIR=/usr/lib64
sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

sudo install -v -m644 -D doc/startup-notification.txt \
    /usr/share/doc/startup-notification-0.12/startup-notification.txt

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf startup-notification

#mate-common
wget https://github.com/mate-desktop/mate-common/releases/download/v1.13.0/mate-common-1.13.0.tar.xz -O \
    mate-common-1.13.0.tar.gz

mkdir mate-common && tar xf mate-common-*.tar.* -C mate-common --strip-components 1
cd mate-common

ACLOCAL_FLAG=/usr/share/aclocal/ CC="gcc ${BUILD64}" \
  CXX="g++ ${BUILD64}" USE_ARCH=64 \
   PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} sh autogen.sh --prefix=/usr \
   --libdir=/usr/lib64 --sysconfdir=/etc --disable-static \
   --localstatedir=/var --bindir=/usr/bin --sbindir=/usr/sbin \
   --disable-docbook-docs

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make PREFIX=/usr LIBDIR=/usr/lib64
sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

sudo cp macros/*.m4 /usr/share/aclocal 
sudo mkdir /usr/share/mate-common
sudo cp -rv data/* /usr/share/mate-common

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf mate-common

#Damned now we really need to build GTK-doc

#sgml-common
wget http://anduin.linuxfromscratch.org/BLFS/sgml-common/sgml-common-0.6.3.tgz -O \
    sgml-common-0.6.3.tgz

wget http://www.linuxfromscratch.org/patches/blfs/svn/sgml-common-0.6.3-manpage-1.patch -O \
    Sgml-common-0.6.3-manpage-1.patch 

mkdir sgml-common && tar xf sgml-common-*.tgz -C sgml-common --strip-components 1
cd sgml-common

patch -Np1 -i ../Sgml-common-0.6.3-manpage-1.patch

autoreconf -f -i

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure --prefix=/usr \
   --libdir=/usr/lib64 \
   --sysconfdir=/etc

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make PREFIX=/usr LIBDIR=/usr/lib64
sudo make PREFIX=/usr LIBDIR=/usr/lib64 docdir=/usr/share/doc install

sudo install-catalog --remove /etc/sgml/sgml-ent.cat \
    /usr/share/sgml/sgml-iso-entities-8879.1986/catalog &&

sudo install-catalog --remove /etc/sgml/sgml-docbook.cat \
    /etc/sgml/sgml-ent.cat

sudo install-catalog --add /etc/sgml/sgml-ent.cat \
    /usr/share/sgml/sgml-iso-entities-8879.1986/catalog &&

sudo install-catalog --add /etc/sgml/sgml-docbook.cat \
    /etc/sgml/sgml-ent.cat

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf sgml-common

#Unzip
wget http://downloads.sourceforge.net/infozip/unzip60.tar.gz -O \
    unzip60.tar.gz

mkdir unzip && tar xf unzip*.tar.* -C unzip --strip-components 1
cd unzip

sed -i 's/CC = cc#/CC = gcc#/' unix/Makefile

CC="gcc ${BUILD64}" \
PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make prefix=/usr libdir=/usr/lib64 -f unix/Makefile generic
sudo make prefix=/usr libdir=/usr/lib64 -f unix/Makefile install

sudo mv /usr/local/bin/*zip* /usr/bin/

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf unzip

#docbook-xml
wget http://www.docbook.org/xml/4.5/docbook-xml-4.5.zip -O \
    docbook-xml-4.5.zip

unzip docbook-xml-*.zip

sudo install -v -d -m755 /usr/share/xml/docbook/xml-dtd-4.5 &&
sudo install -v -d -m755 /etc/xml &&
sudo chown -R root:root . &&
sudo cp -v -af docbook.cat *.dtd ent/ *.mod \
    /usr/share/xml/docbook/xml-dtd-4.5

if [ ! -e /etc/xml/docbook ]; then
    sudo xmlcatalog --noout --create /etc/xml/docbook
fi &&
sudo xmlcatalog --noout --add "public" \
    "-//OASIS//DTD DocBook XML V4.5//EN" \
    "http://www.oasis-open.org/docbook/xml/4.5/docbookx.dtd" \
    /etc/xml/docbook &&
sudo xmlcatalog --noout --add "public" \
    "-//OASIS//DTD DocBook XML CALS Table Model V4.5//EN" \
    "file:///usr/share/xml/docbook/xml-dtd-4.5/calstblx.dtd" \
    /etc/xml/docbook &&
sudo xmlcatalog --noout --add "public" \
    "-//OASIS//DTD XML Exchange Table Model 19990315//EN" \
    "file:///usr/share/xml/docbook/xml-dtd-4.5/soextblx.dtd" \
    /etc/xml/docbook &&
as_rootxmlcatalog --noout --add "public" \
    "-//OASIS//ELEMENTS DocBook XML Information Pool V4.5//EN" \
    "file:///usr/share/xml/docbook/xml-dtd-4.5/dbpoolx.mod" \
    /etc/xml/docbook &&
sudo xmlcatalog --noout --add "public" \
    "-//OASIS//ELEMENTS DocBook XML Document Hierarchy V4.5//EN" \
    "file:///usr/share/xml/docbook/xml-dtd-4.5/dbhierx.mod" \
    /etc/xml/docbook &&
sudo xmlcatalog --noout --add "public" \
    "-//OASIS//ELEMENTS DocBook XML HTML Tables V4.5//EN" \
    "file:///usr/share/xml/docbook/xml-dtd-4.5/htmltblx.mod" \
    /etc/xml/docbook &&
sudo xmlcatalog --noout --add "public" \
    "-//OASIS//ENTITIES DocBook XML Notations V4.5//EN" \
    "file:///usr/share/xml/docbook/xml-dtd-4.5/dbnotnx.mod" \
    /etc/xml/docbook &&
sudo xmlcatalog --noout --add "public" \
    "-//OASIS//ENTITIES DocBook XML Character Entities V4.5//EN" \
    "file:///usr/share/xml/docbook/xml-dtd-4.5/dbcentx.mod" \
    /etc/xml/docbook &&
sudo xmlcatalog --noout --add "public" \
    "-//OASIS//ENTITIES DocBook XML Additional General Entities V4.5//EN" \
    "file:///usr/share/xml/docbook/xml-dtd-4.5/dbgenent.mod" \
    /etc/xml/docbook &&
sudo xmlcatalog --noout --add "rewriteSystem" \
    "http://www.oasis-open.org/docbook/xml/4.5" \
    "file:///usr/share/xml/docbook/xml-dtd-4.5" \
    /etc/xml/docbook &&
sudo xmlcatalog --noout --add "rewriteURI" \
    "http://www.oasis-open.org/docbook/xml/4.5" \
    "file:///usr/share/xml/docbook/xml-dtd-4.5" \
    /etc/xml/docbook

if [ ! -e /etc/xml/catalog ]; then
    xmlcatalog --noout --create /etc/xml/catalog
fi &&
sudo xmlcatalog --noout --add "delegatePublic" \
    "-//OASIS//ENTITIES DocBook XML" \
    "file:///etc/xml/docbook" \
    /etc/xml/catalog &&
sudo xmlcatalog --noout --add "delegatePublic" \
    "-//OASIS//DTD DocBook XML" \
    "file:///etc/xml/docbook" \
    /etc/xml/catalog &&
sudo xmlcatalog --noout --add "delegateSystem" \
    "http://www.oasis-open.org/docbook/" \
    "file:///etc/xml/docbook" \
    /etc/xml/catalog &&
sudo xmlcatalog --noout --add "delegateURI" \
    "http://www.oasis-open.org/docbook/" \
    "file:///etc/xml/docbook" \
    /etc/xml/catalog

for DTDVERSION in 4.1.2 4.2 4.3 4.4
do
  sudo xmlcatalog --noout --add "public" \
    "-//OASIS//DTD DocBook XML V$DTDVERSION//EN" \
    "http://www.oasis-open.org/docbook/xml/$DTDVERSION/docbookx.dtd" \
    /etc/xml/docbook
  sudo xmlcatalog --noout --add "rewriteSystem" \
    "http://www.oasis-open.org/docbook/xml/$DTDVERSION" \
    "file:///usr/share/xml/docbook/xml-dtd-4.5" \
    /etc/xml/docbook
  sudo xmlcatalog --noout --add "rewriteURI" \
    "http://www.oasis-open.org/docbook/xml/$DTDVERSION" \
    "file:///usr/share/xml/docbook/xml-dtd-4.5" \
    /etc/xml/docbook
  sudo xmlcatalog --noout --add "delegateSystem" \
    "http://www.oasis-open.org/docbook/xml/$DTDVERSION/" \
    "file:///etc/xml/docbook" \
    /etc/xml/catalog
  sudo xmlcatalog --noout --add "delegateURI" \
    "http://www.oasis-open.org/docbook/xml/$DTDVERSION/" \
    "file:///etc/xml/docbook" \
    /etc/xml/catalog
done

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage

#docbook-xsl
wget http://downloads.sourceforge.net/docbook/docbook-xsl-1.79.1.tar.bz2 -O \
    docbook-xsl-1.79.1.tar.bz2

mkdir docbook-xsl && tar xf docbook-xsl-*.tar.* -C docbook-xsl --strip-components 1
cd docbook-xsl

sudo install -v -m755 -d /usr/share/xml/docbook/xsl-stylesheets-1.79.1 &&

sudo cp -v -R VERSION assembly common eclipse epub epub3 extensions fo        \
         highlighting html htmlhelp images javahelp lib manpages params  \
         profiling roundtrip slides template tests tools webhelp website \
         xhtml xhtml-1_1 xhtml5                                          \
    /usr/share/xml/docbook/xsl-stylesheets-1.79.1 &&

sudo ln -s VERSION /usr/share/xml/docbook/xsl-stylesheets-1.79.1/VERSION.xsl &&

sudo install -v -m644 -D README \
                    /usr/share/doc/docbook-xsl-1.79.1/README.txt &&
sudo install -v -m644    RELEASE-NOTES* NEWS* \
                    /usr/share/doc/docbook-xsl-1.79.1

sudo xmlcatalog --noout --add "rewriteSystem" \
           "http://docbook.sourceforge.net/release/xsl/<version>" \
           "/usr/share/xml/docbook/xsl-stylesheets-<version>" \
    /etc/xml/catalog &&

sudo xmlcatalog --noout --add "rewriteURI" \
           "http://docbook.sourceforge.net/release/xsl/<version>" \
           "/usr/share/xml/docbook/xsl-stylesheets-<version>" \
    /etc/xml/catalog

cp ${CLFSSOURCES}/docbook-xml-xsl.tar.* .
mkdir xml && tar xf docbook-xml-xsl.tar.* -C xml --strip-components 1

sudo cp -rv xml /etc/

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
echo " "
echo "For me xmlcatalog --noout --add was failing"
echo "With \"add command failed\""
echo "I cheated and copied /etc/xml/* over to clfs from my host distro"
echo " "
rm -rf docbook-xsl

#itstool
wget http://files.itstool.org/itstool/itstool-2.0.2.tar.bz2 -O \
    itstool-2.0.2.tar.bz2

mkdir itstool && tar xf itstool-*.tar.* -C itstool --strip-components 1
cd itstool

sed -i 's/python \- \&/python3 \- \&/' configure

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure --prefix=/usr 

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make PREFIX=/usr 
sudo make PREFIX=/usr install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf itstool

#gtk-doc
wget http://ftp.gnome.org/pub/gnome/sources/gtk-doc/1.25/gtk-doc-1.25.tar.xz -O \
    gtk-doc-1.25.tar.xz

mkdir gtk-doc && tar xf gtk-doc-*.tar.* -C gtk-doc --strip-components 1
cd gtk-doc

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure --prefix=/usr \
    --libdir=/usr/lib64

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make PREFIX=/usr LIBDIR=/usr/lib64
sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf gtk-doc

#mate-desktop
wget https://github.com/mate-desktop/mate-desktop/archive/v1.18.0.tar.gz -O \
    mate-desktop-1.18.0.tar.gz

mkdir mate-desktop && tar xf mate-desktop-*.tar.* -C mate-desktop --strip-components 1
cd mate-desktop

cp -rv /usr/share/aclocal/*.m4 m4/

ACLOCAL_FLAG=/usr/share/aclocal/ CC="gcc ${BUILD64}" \
CXX="g++ ${BUILD64}" USE_ARCH=64 \
PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} sh autogen.sh --prefix=/usr \
--libdir=/usr/lib64 --sysconfdir=/etc --disable-static \
--localstatedir=/var --bindir=/usr/bin --sbindir=/usr/sbin \
--disable-docbook-docs
    
#Deactivate building of the help subdir because it will fail
sed -i 's/HELP_DIR/#HELP_DIR/' Makefile Makefile.in
sed -i 's/help/#help/' Makefile Makefile.in Makefile.am

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make PREFIX=/usr LIBDIR=/usr/lib64
sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

sudo mkdir /usr/share/mate-desktop
sudo cp -rv data/* /usr/share/mate-desktop

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf mate-desktop
