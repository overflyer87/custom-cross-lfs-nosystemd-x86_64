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

#libxml2 WITH ITS PYTHON MODULE
wget http://xmlsoft.org/sources/libxml2-2.9.4.tar.gz -O \
    libxml2-2.9.4.tar.gz

#Download testsuite. WE NEED IT to build the Python module!
wget http://www.w3.org/XML/Test/xmlts20130923.tar.gz -O \
    xmlts20130923.tar.gz

mkdir libxml2 && tar xf libxml2-*.tar.* -C libxml2 --strip-components 1
cd libxml2

#run this to build Pytghon3 module
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

as_root make PREFIX=/usr LIBDIR=/usr/lib64 install 

cd ${CLFSSOURCES}/xc/mate
as_root updatedb
as_root locate libxml | grep /usr/lib64/python3.6/
echo "Did locate libxml | grep /usr/lib64/python3.6/ find the libxml python modules?"
echo ""
checkBuiltPackage
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
as_root make PREFIX=/usr LIBDIR=/usr/lib64 install

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
as_root make PREFIX=/usr LIBDIR=/usr/lib64 install

tar -xf ../dconf-editor-3.22.3.tar.xz &&
cd dconf-editor-3.22.3 &&

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure --prefix=/usr \
   --libdir=/usr/lib64 \
   --sysconfdir=/etc

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make PREFIX=/usr LIBDIR=/usr/lib64
as_root make PREFIX=/usr LIBDIR=/usr/lib64 install

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
as_root make PREFIX=/usr LIBDIR=/usr/lib64 install

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
as_root make PREFIX=/usr LIBDIR=/usr/lib64 install

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
as_root make PREFIX=/usr LIBDIR=/usr/lib64 install

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
as_root make PREFIX=/usr LIBDIR=/usr/lib64 install

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
as_root make PREFIX=/usr LIBDIR=/usr/lib64 install

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
as_root make PREFIX=/usr LIBDIR=/usr/lib64 install

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
as_root make PREFIX=/usr LIBDIR=/usr/lib64 install
as_root install -v -m644 doc/Vorbis* /usr/share/doc/libvorbis-1.3.5

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

as_root make PREFIX=/usr LIBDIR=/usr/lib64 install

as_root install -v -d -m755 /usr/share/doc/alsa-lib-1.1.4.1/html/search &&
as_root install -v -m644 doc/doxygen/html/*.* \
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

as_root make PREFIX=/usr LIBDIR=/usr/lib64 install

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

as_root make PREFIX=/usr LIBDIR=/usr/lib64 install

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

as_root make PREFIX=/usr LIBDIR=/usr/lib64 install

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
as_root make PREFIX=/usr LIBDIR=/usr/lib64 install

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
as_root make PREFIX=/usr LIBDIR=/usr/lib64 install

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
as_root make PREFIX=/usr LIBDIR=/usr/lib64 install

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
   --disable-static \
   --datadir=/usr/share/doc/valgrind-3.13.0

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make PREFIX=/usr LIBDIR=/usr/lib64
as_root make PREFIX=/usr LIBDIR=/usr/lib64 install

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
as_root make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf libgudev

#libgusb
