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
CLFSSOURCES=/sources
MAKEFLAGS="-j$(nproc)"
BUILD32="-m32"
BUILD64="-m64"
CLFS_TARGET32="i686-pc-linux-gnu"
PKG_CONFIG_PATH=/usr/lib64/pkgconfig
PKG_CONFIG_PATH64=/usr/lib64/pkgconfig

export CLFS=/
export CLFSUSER=clfs
export CLFSSOURCES=/sources
export MAKEFLAGS="-j$(nproc)"
export BUILD32="-m32"
export BUILD64="-m64"
export CLFS_TARGET32="i686-pc-linux-gnu"
export PKG_CONFIG_PATH=/usr/lib64/pkgconfig
export PKG_CONFIG_PATH64=/usr/lib64/pkgconfig

sudo rm -rf ${CLFSSOURCES}/xc/xfce4

sudo mkdir -pv ${CLFSSOURCES}/xc/xfce4
cd ${CLFSSOURCES}/xc/xfce4

sudo chown -Rv overflyer ${CLFSSOURCES}/xc

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

#icon-naming-utils
wget http://tango.freedesktop.org/releases/icon-naming-utils-0.8.90.tar.bz2 -O \
	icon-naming-utils-0.8.90.tar.bz2

mkdir icon-naming-utils && tar xf icon-naming-utils-*.tar.* -C icon-naming-utils --strip-components 1
cd icon-naming-utils

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" USE_ARCH=64    \
  PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr  \
  --libdir=/usr/lib64
 
make PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" PREFIX=/usr LIBDIR=/usr/lib64
sudo make PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/xfce4
checkBuiltPackage
sudo rm -rf icon-naming-utils

#gnome-icon-theme
wget http://ftp.gnome.org/pub/gnome/sources/gnome-icon-theme/3.12/gnome-icon-theme-3.12.0.tar.xz -O \
    gnome-icon-theme-3.12.0.tar.xz

mkdir gnome-icon-theme && tar xf gnome-icon-theme-*.tar.* -C gnome-icon-theme --strip-components 1
cd gnome-icon-theme

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure \
     --prefix=/usr \
     --libdir=/usr/lib64 

sudo make PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/xfce4
checkBuiltPackage
rm -rf gnome-icon-theme

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

cd ${CLFSSOURCES}/xc/xfce4
checkBuiltPackage
rm -rf libgudev

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

cd ${CLFSSOURCES}/xc/xfce4
checkBuiltPackage
rm -rf vala

#libgpg-error
wget ftp://ftp.gnupg.org/gcrypt/libgpg-error/libgpg-error-1.27.tar.bz2 -O \
    libgpg-error-1.27.tar.bz2
    
mkdir libgpgerror && tar xf libgpg-error-*.tar.* -C libgpgerror --strip-components 1
cd libgpgerror

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure --prefix=/usr --libdir=/usr/lib64
PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}"  make LIBDIR=/usr/lib64 PREFIX=/usr
sudo make LIBDIR=/usr/lib64 PREFIX=/usr install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -r libgpgerror

#libgcrypt
wget ftp://ftp.gnupg.org/gcrypt/libgcrypt/libgcrypt-1.7.8.tar.bz2 -O \
    libgcrypt-1.7.8.tar.bz2
    
mkdir libgcrypt && tar xf libgcrypt-*.tar.* -C libgcrypt --strip-components 1
cd libgcrypt

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure --prefix=/usr --libdir=/usr/lib64
PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}"  make LIBDIR=/usr/lib64 PREFIX=/usr
make check
checkBuiltPackage

sudo make LIBDIR=/usr/lib64 PREFIX=/usr install

cd ${CLFSSOURCES}/xc/xfce4
checkBuiltPackage
rm -r libgcrypt

#libsecret
wget http://ftp.gnome.org/pub/gnome/sources/libsecret/0.18/libsecret-0.18.5.tar.xz -O \
    libsecret-0.18.5.tar.xz

mkdir libsecret && tar xf libsecret-*.tar.* -C libsecret --strip-components 1
cd libsecret

CC="gcc ${BUILD64}" \
  CXX="g++ ${BUILD64}" USE_ARCH=64 \
  PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
  --libdir=/usr/lib64 --disable-gtk-doc --disable-manpages

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make LIBDIR=/usr/lib64 PREFIX=/usr
sudo make LIBDIR=/usr/lib64 PREFIX=/usr install

cd ${CLFSSOURCES}/xc/xfce4
checkBuiltPackage
rm -rf libsecret

#libwebp
wget http://downloads.webmproject.org/releases/webp/libwebp-0.6.0.tar.gz -O \
    libwebp-0.6.0.tar.gz

mkdir libwebp && tar xf libwebp-*.tar.* -C libwebp --strip-components 1
cd libwebp

CC="gcc ${BUILD64}" \
  CXX="g++ ${BUILD64}" USE_ARCH=64 \
  PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
  --libdir=/usr/lib64 \
  --enable-libwebpmux     \
  --enable-libwebpdemux   \
  --enable-libwebpdecoder \
  --enable-libwebpextras  \
  --enable-swap-16bit-csp \

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make LIBDIR=/usr/lib64 PREFIX=/usr
sudo make LIBDIR=/usr/lib64 PREFIX=/usr install

cd ${CLFSSOURCES}/xc/xfce4
checkBuiltPackage
rm -rf libwebp

#libnotify
wget http://ftp.gnome.org/pub/gnome/sources/libnotify/0.7/libnotify-0.7.7.tar.xz -O \
    libnotify-0.7.7.tar.xz

mkdir libnotify && tar xf libnotify-*.tar.* -C libnotify --strip-components 1
cd libnotify

CC="gcc ${BUILD64}" \
  CXX="g++ ${BUILD64}" USE_ARCH=64 \
   PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
   --libdir=/usr/lib64 --disable-static 

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make LIBDIR=/usr/lib64 PREFIX=/usr
sudo make LIBDIR=/usr/lib64 PREFIX=/usr install

cd ${CLFSSOURCES}/xc/xfce4
checkBuiltPackage
rm -rf libnotify

#libsoup
wget http://ftp.gnome.org/pub/gnome/sources/libsoup/2.58/libsoup-2.58.1.tar.xz -O \
    libsoup-2.58.1.tar.xz

mkdir libsoup && tar xf libsoup-*.tar.* -C libsoup --strip-components 1
cd libsoup

CC="gcc ${BUILD64}" \
  CXX="g++ ${BUILD64}" USE_ARCH=64 \
   PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
   --libdir=/usr/lib64 --disable-static 

sudo ln -sfv /usr/bin/python3.6 /usr/bin/python

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make LIBDIR=/usr/lib64 PREFIX=/usr
make check 
checkBuiltPackage

sudo make LIBDIR=/usr/lib64 PREFIX=/usr install
sudo unlink /usr/bin/python
sudo ldconfig

cd ${CLFSSOURCES}/xc/xfce4
checkBuiltPackage
rm -rf libsoup

#Gvfs
wget http://ftp.gnome.org/pub/gnome/sources/gvfs/1.32/gvfs-1.32.1.tar.xz
	gvfs-1.32.1.tar.xz 
#You need to recompile udev with this patch in order
#For Gvfs to support gphoto2
wget https://sourceforge.net/p/gphoto/patches/_discuss/thread/9180a667/9902/attachment/libgphoto2.udev-136.patch -O \
	libgphoto2.udev-136.patch

mkdir gvfs && tar xf gvfs-*.tar.* -C gvfs --strip-components 1
cd gvfs

#js17
wget wget http://ftp.mozilla.org/pub/mozilla.org/js/mozjs17.0.0.tar.gz -O \
  mozjs17.0.0.tar.gz

mkdir mozjs && tar xf mozjs*.tar.* -C mozjs --strip-components 1
cd mozjs
cd js/src

sed -i 's/(defined\((@TEMPLATE_FILE)\))/\1/' config/milestone.pl

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" USE_ARCH=64 \
PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr --libdir=/usr/lib64 \
  --enable-readline --enable-threadsafe \
  --with-system-ffi --with-system-nspr  

#Iso C++ can't compare pointer to Integer
#First element of array is seen as pointer
#So to make it a real value I just ficed it
#by derefferencing the pointer and compare THAT to '\0' (NULL)
sed -i 's/value\[0\] == /\*value\[0\] == /' shell/jsoptparse.cpp

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" USE_ARCH=64 
PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

sudo find /usr/include/js-17.0/            \
     /usr/lib64/libmozjs-17.0.a         \
     /usr/lib64/pkgconfig/mozjs-17.0.pc \
     -type f -exec chmod -v 644 {} \;

cd ${CLFSSOURCES}/xc/xfce4
checkBuiltPackage
rm -rf mozjs

#polkit 113
wget http://www.freedesktop.org/software/polkit/releases/polkit-0.113.tar.gz -O \
  polkit-0.113.tar.gz
  
mkdir polkit && tar xf polkit-*.tar.* -C polkit --strip-components 1
cd polkit

sudo mkdir /etc/polkit-1
sudo groupadd -fg 27 polkitd 
sudo useradd -c "PolicyKit Daemon Owner" -d /etc/polkit-1 -u 27 \
        -g polkitd -s /bin/false polkitd

echo " "
echo "Were polkitd group and user created successfully?"

checkBuiltPackage

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" USE_ARCH=64 \
PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
            --sysconfdir=/etc    \
            --libdir=/usr/lib64  \
            --localstatedir=/var \
            --disable-static     \
            --disable-man-pages  \
            --disable-gtk-doc    \
            --with-pam           \
            --enable-systemd-logind=no 

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" USE_ARCH=64 
PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

sudo chown root:root /usr/lib/polkit-1/polkit-agent-helper-1
sudo chown root:root /usr/bin/pkexec
sudo chmod 4755 /usr/lib/polkit-1/polkit-agent-helper-1
sudo chmod 4755 /usr/bin/pkexec
sudo chown -Rv polkitd /etc/polkit-1/rules.d
sudo chown -Rv polkitd /usr/share/polkit-1/rules.d
sudo chmod 700 /etc/polkit-1/rules.d
sudo chmod 700 /usr/share/polkit-1/rules.d

sudo bash -c 'cat > /etc/pam.d/polkit-1 << "EOF"
# Begin /etc/pam.d/polkit-1
auth     include        system-auth
account  include        system-account
password include        system-password
session  include        system-session
# End /etc/pam.d/polkit-1
EOF'

cd ${CLFSSOURCES}/xc/xfce4
checkBuiltPackage
rm -rf polkit

#polkit-gnome
wget http://ftp.gnome.org/pub/gnome/sources/polkit-gnome/0.105/polkit-gnome-0.105.tar.xz -O \
	polkit-gnome-0.105.tar.xz

mkdir polkit-gnome && tar xf polkit-gnome-*.tar.* -C polkit-gnome --strip-components 1
cd polkit-gnome	

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure --prefix=/usr --libdir=/usr/lib64
PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}"  make LIBDIR=/usr/lib64 PREFIX=/usr
sudo make LIBDIR=/usr/lib64 PREFIX=/usr install

sudo mkdir -p /etc/xdg/autostart &&
sudo bash -c 'cat > /etc/xdg/autostart/polkit-gnome-authentication-agent-1.desktop << "EOF"
[Desktop Entry]
Name=PolicyKit Authentication Agent
Comment=PolicyKit Authentication Agent
Exec=/usr/libexec/polkit-gnome-authentication-agent-1
Terminal=false
Type=Application
Categories=
NoDisplay=true
OnlyShowIn=GNOME;XFCE;Unity;
AutostartCondition=GNOME3 unless-session gnome
EOF'

cd ${CLFSSOURCES}/xc/xfce4
checkBuiltPackage
rm -rf gnome-polkit

#UDisks
wget https://github.com/storaged-project/udisks/releases/download/udisks-2.7.1/udisks-2.7.1.tar.bz2 -O \
	udisks-2.7.1.tar.bz2

mkdir udisks && tar xf udisks-*.tar.* -C udisks --strip-components 1
cd udisks	

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
    --libdir=/usr/lib64	\
    --libexecdir=/usr/lib64 \
    --disable-static    \
    --sysconfdir=/etc	\
    --localstatedir=/var \
    --disable-gtk-doc	\
    --disable-gtk-doc-pdf \
    --disable-gtk-doc-html \
    --disable-man 	\
    --enable-shared 	\
    --enable-btrfs 	\
    --enable-lvm2 	\
    --enable-lvmcache	\
    --enable-polkit	\
    --disable-tests

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/xfce4
checkBuiltPackage
rm -rf udisks

LD_LIB_PATH="/usr/lib64" LIBRARY_PATH="/usr/lib64" CPPFLAGS="-I/usr/include" \
LD_LIBRARY_PATH="/usr/lib64" CC="gcc ${BUILD64} -L/usr/lib64 -lacl" \
CXX="g++ ${BUILD64} -lacl" USE_ARCH=64 \
PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
	--libdir=/usr/lib64 \
	--disable-static    \
	--sysconfdir=/etc    \
    --disable-gtk-doc \
    --disable-gtk-doc-pdf \
    --disable-gtk-doc-html \
    --disable-libsystemd-login \
    --disable-admin \
    --disable-gphoto2 \
    --disable-documentation
    
sudo ln -sfv /usr/lib64/libacl.so /lib64/
sudo ln -sfv /usr/lib64/libattr.so /lib64/
    
LD_LIB_PATH="/usr/lib64" LIBRARY_PATH="/usr/lib64" CPPFLAGS="-I/usr/include" \
LD_LIBRARY_PATH="/usr/lib64" CC="gcc ${BUILD64} -L/usr/lib64 -lacl" \
CXX="g++ ${BUILD64} -lacl" USE_ARCH=64 \
PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/xfce4
checkBuiltPackage
rm -rf gvfs

#libexif
wget http://downloads.sourceforge.net/libexif/libexif-0.6.21.tar.bz2 -O \
	libexif-0.6.21.tar.bz2

mkdir libexif && tar xf libexif-*.tar.* -C libexif --strip-components 1
cd libexif

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr\
    --libdir=/usr/lib64 \
    --with-doc-dir=/usr/share/doc/libexif-0.6.21 \
	--disable-static

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/xfce4
checkBuiltPackage
rm -rf libexif

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

sudo ldconfig

cd ${CLFSSOURCES}/xc/xfce4
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

cd ${CLFSSOURCES}/xc/xfce4
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

cd ${CLFSSOURCES}/xc/xfce4
checkBuiltPackage
rm -rf gstplggood

#yasm
wget http://www.tortall.net/projects/yasm/releases/yasm-1.3.0.tar.gz -O \
    yasm-1.3.0.tar.gz

mkdir yasm && tar xf yasm-*.tar.* -C yasm --strip-components 1
cd yasm

sed -i 's#) ytasm.*#)#' Makefile.in

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure \
     --prefix=/usr \
     --libdir=/usr/lib64 

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make PREFIX=/usr LIBDIR=/usr/lib64
sudo make PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/xfce4
checkBuiltPackage
rm -rf yasm

#libjpeg-turbo
wget http://downloads.sourceforge.net/libjpeg-turbo/libjpeg-turbo-1.5.2.tar.gz -O \
    libjpeg-turbo-1.5.2.tar.gz

mkdir libjpeg-turbo && tar xf libjpeg-turbo-*.tar.* -C libjpeg-turbo --strip-components 1
cd libjpeg-turbo

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure \
     --prefix=/usr \
     --libdir=/usr/lib64 \
     --mandir=/usr/share/man \
     --with-jpeg8            \
     --disable-static        \
     --docdir=/usr/share/doc/libjpeg-turbo-1.5.2

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make PREFIX=/usr LIBDIR=/usr/lib64
sudo make PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" PREFIX=/usr LIBDIR=/usr/lib64 install

sudo ldconfig

cd ${CLFSSOURCES}/xc/xfce4
checkBuiltPackage
rm -rf libjpeg-turbo

#libpng installed by bootloader script clfs_6b1....sh
#libepoxy installed by Xorg script

#libtiff
wget http://download.osgeo.org/libtiff/tiff-4.0.8.tar.gz -O \
    tiff-4.0.8.tar.gz

mkdir libtiff && tar xf tiff-*.tar.* -C libtiff --strip-components 1
cd libtiff

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure \
     --prefix=/usr \
     --libdir=/usr/lib64 \
     --disable-static

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make PREFIX=/usr LIBDIR=/usr/lib64
sudo make PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/xfce4
checkBuiltPackage
rm -rf libtiff

#libgsf
wget http://ftp.gnome.org/pub/gnome/sources/libgsf/1.14/libgsf-1.14.41.tar.xz -O \
  libgsf-1.14.41.tar.xz

mkdir libgsf && tar xf libgsf-*.tar.* -C libgsf --strip-components 1
cd libgsf

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure --prefix=/usr \
     --libdir=/usr/lib64 \
     --disable-static

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make PREFIX=/usr LIBDIR=/usr/lib64
sudo make PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/xfce4
checkBuiltPackage
rm -rf libgsf

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

cd ${CLFSSOURCES}/xc/xfce4
checkBuiltPackage
rm -rf lcms2

#OpenJPEG
wget http://downloads.sourceforge.net/openjpeg.mirror/openjpeg-1.5.2.tar.gz -O \
    openjpeg-1.5.2.tar.gz
    
mkdir openjpeg && tar xf openjpeg-*.tar.* -C openjpeg --strip-components 1
cd openjpeg

autoreconf -f -i

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
    --libdir=/usr/lib64 \
    --sysconfdir=/etc \
    --disable-static

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/xfce4
checkBuiltPackage
rm -rf openjpeg
#Cairo
wget http://cairographics.org/releases/cairo-1.14.10.tar.xz -O \
    cairo-1.14.10.tar.xz

mkdir cairo && tar xf cairo-*.tar.* -C cairo --strip-components 1
cd cairo

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure \
     --prefix=/usr \
     --libdir=/usr/lib64 \
     --disable-static \
     --enable-tee

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make PREFIX=/usr LIBDIR=/usr/lib64
sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/xfce4
checkBuiltPackage
rm -rf cairo

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

cd ${CLFSSOURCES}/xc/xfce4
checkBuiltPackage
echo " "
echo "checking if /usr/include/pratom.h was installed..."
ls /usr/include | grep pratom.h
echo "... should be shown in output one line above. Mozjs 17.0.0 will fail otherwise."
rm -rf nspr

#libtasn1
wget http://ftp.gnu.org/gnu/libtasn1/libtasn1-4.12.tar.gz -O \
    libtasn1-4.12.tar.gz

mkdir libtasn1 && tar xf libtasn1-*.tar.* -C libtasn1 --strip-components 1
cd libtasn1

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure --prefix=/usr \
    --libdir=/usr/lib64 \
    --disable-static
    
PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}"  make LIBDIR=/usr/lib64 PREFIX=/usr
make check
checkBuiltPackage

sudo make LIBDIR=/usr/lib64 PREFIX=/usr install

cd ${CLFSSOURCES}/xc/xfce4
checkBuiltPackage
rm -r libtasn1

#p11-kit
wget https://github.com/p11-glue/p11-kit/releases/download/0.23.7/p11-kit-0.23.7.tar.gz -O \
    p11-kit-0.23.7.tar.gz
    
mkdir p11-kit && tar xf p11-kit-*.tar.* -C p11-kit --strip-components 1
cd p11-kit

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure --prefix=/usr \
    --libdir=/usr/lib64 \
    --disable-static \
    --sysconfdir=/etc \
    --with-trust-paths=/etc/pki/anchor
    
PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}"  make LIBDIR=/usr/lib64 PREFIX=/usr
make check
checkBuiltPackage

sudo make LIBDIR=/usr/lib64 PREFIX=/usr install

cd ${CLFSSOURCES}/xc/xfce4
checkBuiltPackage
rm -r p11-kit

#poppler-glib 
wget http://poppler.freedesktop.org/poppler-0.56.0.tar.xz -O \
    poppler-0.56.0.tar.xz
    
wget http://poppler.freedesktop.org/poppler-data-0.4.7.tar.gz -O \
    Poppler-data-0.4.7.tar.gz

mkdir poppler && tar xf poppler-*.tar.* -C poppler --strip-components 1
cd poppler

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
    --libdir=/usr/lib64 \
    --sysconfdir=/etc \
    --disable-static            \
    --enable-build-type=release \
    --enable-cmyk               \
    --enable-xpdf-headers       \
    --with-testdatadir=$PWD/testfile

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

mkdir poppler-data
tar -xf ../Poppler-data-*.tar.gz -C poppler-data --strip-components 1 
cd poppler-data

sudo make LIBDIR=/usr/lib64 prefix=/usr install

cd ${CLFSSOURCES}/xc/xfce4
checkBuiltPackage
rm -rf poppler

#Tumbler
wget http://archive.xfce.org/src/xfce/tumbler/0.2/tumbler-0.2.0.tar.bz2 -O \
	tumbler-0.2.0.tar.bz2
	
mkdir tumbler && tar xf tumbler-*.tar.* -C tumbler --strip-components 1
cd tumbler

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure --prefix=/usr \
    --libdir=/usr/lib64 
    
PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}"  make LIBDIR=/usr/lib64 PREFIX=/usr
sudo make LIBDIR=/usr/lib64 PREFIX=/usr install

cd ${CLFSSOURCES}/xc/xfce4
checkBuiltPackage
rm -rf tumbler

#Thunar
wget http://archive.xfce.org/src/xfce/thunar/1.6/Thunar-1.6.12.tar.bz2 -O \
	Thunar-1.6.12.tar.bz2
	
mkdir Thunar && tar xf Thunar-*.tar.* -C Thunar --strip-components 1
cd Thunar

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure --prefix=/usr \
    --libdir=/usr/lib64 --sysconfdir=/etc \
    --docdir=/usr/share/doc/Thunar-1.6.12
    
PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}"  make LIBDIR=/usr/lib64 PREFIX=/usr
sudo make LIBDIR=/usr/lib64 PREFIX=/usr install

cd ${CLFSSOURCES}/xc/xfce4
checkBuiltPackage
rm -rf Thunar

#thunar-volman
wget http://archive.xfce.org/src/xfce/thunar-volman/0.8/thunar-volman-0.8.1.tar.bz2 -O \
	thunar-volman-0.8.1.tar.bz2

mkdir thunar-volman && tar xf thunar-volman-*.tar.* -C thunar-volman --strip-components 1
cd thunar-volman

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure --prefix=/usr \
    --libdir=/usr/lib64 
    
PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}"  make LIBDIR=/usr/lib64 PREFIX=/usr
sudo make LIBDIR=/usr/lib64 PREFIX=/usr install

cd ${CLFSSOURCES}/xc/xfce4
checkBuiltPackage
rm -rf thunar-volman

#xfce-appfinder
wget http://archive.xfce.org/src/xfce/xfce4-appfinder/4.12/xfce4-appfinder-4.12.0.tar.bz2 -O \
	xfce4-appfinder-4.12.0.tar.bz2

mkdir xfce4-appfinder && tar xf xfce4-appfinder-*.tar.* -C xfce4-appfinder --strip-components 1
cd xfce4-appfinder

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure --prefix=/usr \
    --libdir=/usr/lib64 
    
PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}"  make LIBDIR=/usr/lib64 PREFIX=/usr
sudo make LIBDIR=/usr/lib64 PREFIX=/usr install

cd ${CLFSSOURCES}/xc/xfce4
checkBuiltPackage
rm -rf xfce4-appfinder

#UPower
wget https://upower.freedesktop.org/releases/upower-0.99.5.tar.xz -O \
	upower-0.99.5.tar.xz

mkdir upower && tar xf upower-*.tar.* -C upower --strip-components 1
cd upower

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure --prefix=/usr \
    --libdir=/usr/lib64 \
    --sysconfdir=/etc    \
    --localstatedir=/var \
    --enable-deprecated  \
    --disable-static \
    --disable-gtk-doc
    
PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}"  make LIBDIR=/usr/lib64 PREFIX=/usr
sudo make LIBDIR=/usr/lib64 PREFIX=/usr install

cd ${CLFSSOURCES}/xc/xfce4
checkBuiltPackage
rm -rf upower

#libatasmart
wget http://0pointer.de/public/libatasmart-0.19.tar.xz -O \
	libatasmart-0.19.tar.xz

mkdir libatasmart && tar xf libatasmart-*.tar.* -C libatasmart --strip-components 1
cd libatasmart

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr\
    --libdir=/usr/lib64 \
    --with-doc-dir=/usr/share/doc/libexif-0.6.21 \
	--disable-static

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/xfce4
checkBuiltPackage
rm -rf libatasmart

#parted
wget http://ftp.gnu.org/gnu/parted/parted-3.2.tar.xz -O \
	parted-3.2.tar.xz

#wget http://www.linuxfromscratch.org/patches/blfs/svn/parted-3.2-devmapper-1.patch -O \
#	Parted-3.2-devmapper-1.patch

mkdir parted && tar xf parted-*.tar.* -C parted --strip-components 1
cd parted

#patch -Np1 -i ../Parted-3.2-devmapper-1.patch

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr\
	--libdir=/usr/lib64 \
	--disable-static

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/xfce4
checkBuiltPackage
rm -rf parted

#dmraid
wget http://people.redhat.com/~heinzm/sw/dmraid/src/dmraid-current.tar.bz2 -O \
	dmraid-current.tar.bz2

mkdir dmraid && tar xf dmraid-*.tar.* -C dmraid --strip-components 3
cd dmraid

sudo cp -rv include/dmraid /usr/inlude/

cd ${CLFSSOURCES}/xc/xfce4
checkBuiltPackage
rm -rf dmraid

#mdadm
wget http://www.kernel.org/pub/linux/utils/raid/mdadm/mdadm-4.0.tar.xz -O \
	mdadm-4.0.tar.xz

mkdir mdadm && tar xf mdadm-*.tar.* -C mdadm --strip-components 1
cd mdadm

#Fix for GCC 7.1
sed 's@-Werror@@' -i Makefile

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/xfce4
checkBuiltPackage
rm -rf mdadm

#reiserfsprogs
wget https://www.kernel.org/pub/linux/kernel/people/jeffm/reiserfsprogs/v3.6.27/reiserfsprogs-3.6.27.tar.xz -O \
	reiserfsprogs-3.6.27.tar.xz

mkdir reiserfsprogs && tar xf reiserfsprogs-*.tar.* -C reiserfsprogs --strip-components 1
cd reiserfsprogs

autoreconf -fiv 

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr\
    --libdir=/usr/lib64 --sbin=/sbin

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/xfce4
checkBuiltPackage
rm -rf reiserfsprogs

#valgrind
wget https://sourceware.org/ftp/valgrind/valgrind-3.13.0.tar.bz2 -O \
	valgrind-3.13.0.tar.bz2

mkdir valgrind && tar xf valgrind-*.tar.* -C valgrind --strip-components 1
cd valgrind

sed -i 's|/doc/valgrind||' docs/Makefile.in 

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr\
    --libdir=/usr/lib64 --datadir=/usr/share/doc/valgrind-3.13.0

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/xfce4
checkBuiltPackage
rm -rf valgrind

#xfsprogs
wget https://www.kernel.org/pub/linux/utils/fs/xfs/xfsprogs/xfsprogs-4.12.0.tar.xz -O \
	xfsprogs-4.12.0.tar.xz
	
mkdir xfsprogs && tar xf xfsprogs-*.tar.* -C xfsprogs --strip-components 1
cd xfsprogs

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} \
CC="gcc ${BUILD64}"     \
USE_ARCH=64             \
CXX="g++ ${BUILD64}"    \
make DEBUG=-DNDEBUG     \
     INSTALL_USER=root  \
     INSTALL_GROUP=root \
     PREFIX=/usr        \
     LIBDIR=/usr/lib64  \
     LOCAL_CONFIGURE_OPTIONS="--enable-readline"

sudo make PKG_DOC_DIR=/usr/share/doc/xfsprogs-4.12.0 install    
sudo make PKG_DOC_DIR=/usr/share/doc/xfsprogs-4.12.0 install-dev

sudo rm -rfv /usr/lib/libhandle.a                               
sudo rm -rfv /lib/libhandle.{a,la,so}                           
sudo ln -sfv ../../lib/libhandle.so.1 /usr/lib/libhandle.so     
sudo sed -i "s@libdir='/lib@libdir='/usr/lib@" /usr/lib/libhandle.la

cd ${CLFSSOURCES}/xc/xfce4
checkBuiltPackage
rm -rf xfsprogs

#LVM2
wget ftp://sources.redhat.com/pub/lvm2/releases/LVM2.2.02.171.tgz -O \
	LVM2.2.02.171.tgz

mkdir LVM2 && tar xf LVM2*.tgz -C LVM2 --strip-components 1
cd LVM2

SAVEPATH=$PATH PATH=$PATH:/sbin:/usr/sbin \
CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr\
	--libdir=/usr/lib64 \
	--disable-static    \
    	--exec-prefix=      \
    	--enable-applib     \
    	--enable-cmdlib     \
    	--enable-pkgconfig  \
    	--enable-udev_sync
    
PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

PATH=$SAVEPATH                 
unset SAVEPATH

export PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin

sudo make -C tools install_dmsetup_dynamic 
sudo make -C udev  install                 
sudo make -C libdm install

sudo mv /usr/lib/pkgconfig/devmapper.pc ${PKG_CONFIG_PATH64}/
sudo sudo mv /usr/lib/libdevmapper.so /usr/lib64/

cd ${CLFSSOURCES}/xc/xfce4
checkBuiltPackage
rm -rf LVM2

#sg3_utils
wget http://sg.danny.cz/sg/p/sg3_utils-1.42.tar.xz -O \
	sg3_utils-1.42.tar.xz

mkdir sg3_utils && tar xf sg3_utils-*.tar.* -C sg3_utils --strip-components 1
cd sg3_utils

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure \
     --prefix=/usr \
     --libdir=/usr/lib64 \
     --disable-static

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make PREFIX=/usr LIBDIR=/usr/lib64
sudo make install

cd ${CLFSSOURCES}/xc/xfce4
checkBuiltPackage
rm -rf sg3_utils

#xfce4-power-manager
wget http://archive.xfce.org/src/xfce/xfce4-power-manager/1.6/xfce4-power-manager-1.6.0.tar.bz2 -O \
	xfce4-power-manager-1.6.0.tar.bz2

mkdir xfce4-power-manager && tar xf xfce4-power-manager-*.tar.* -C xfce4-power-manager --strip-components 1
cd xfce4-power-manager

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure \
     --prefix=/usr \
     --libdir=/usr/lib64 \
     --sysconfdir=/etc

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make PREFIX=/usr LIBDIR=/usr/lib64
sudo make install

cd ${CLFSSOURCES}/xc/xfce4
checkBuiltPackage
rm -rf xfce4-power-manager

#lxde-icon-theme
wget https://downloads.sourceforge.net/lxde/lxde-icon-theme-0.5.1.tar.xz -O \
    lxde-icon-theme-0.5.1.tar.xz

mkdir lxde-icon-theme && tar xf lxde-icon-theme-*.tar.* -C lxde-icon-theme --strip-components 1
cd lxde-icon-theme

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure \
     --prefix=/usr \
     --libdir=/usr/lib64 

sudo make PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" PREFIX=/usr LIBDIR=/usr/lib64 install
sudo gtk-update-icon-cache -qf /usr/share/icons/nuoveXT2

cd ${CLFSSOURCES}/xc/xfce4
checkBuiltPackage
rm -rf lxde-icon-theme

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

cd ${CLFSSOURCES}/xc/xfce4
checkBuiltPackage
rm -rf libcanberra

#xfce4-settings
wget http://archive.xfce.org/src/xfce/xfce4-settings/4.12/xfce4-settings-4.12.1.tar.bz2 -O \
	xfce4-settings-4.12.1.tar.bz2

mkdir xfce4-settings && tar xf xfce4-settings-*.tar.* -C xfce4-settings --strip-components 1
cd xfce4-settings

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure \
     --prefix=/usr \
     --libdir=/usr/lib64 \
     --sysconfdir=/etc

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make PREFIX=/usr LIBDIR=/usr/lib64
sudo make install

cd ${CLFSSOURCES}/xc/xfce4
checkBuiltPackage
rm -rf xfce4-settings

#Xfdesktop
wget http://archive.xfce.org/src/xfce/xfdesktop/4.12/xfdesktop-4.12.4.tar.bz2 -O \
	xfdesktop-4.12.4.tar.bz2

mkdir xfdesktop && tar xf xfdesktop-*.tar.* -C xfdesktop --strip-components 1
cd xfdesktop

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure \
     --prefix=/usr \
     --libdir=/usr/lib64 

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make PREFIX=/usr LIBDIR=/usr/lib64
sudo make install

cd ${CLFSSOURCES}/xc/xfce4
checkBuiltPackage
rm -rf xfdesktop

#Xfwm4
wget http://archive.xfce.org/src/xfce/xfwm4/4.12/xfwm4-4.12.4.tar.bz2 -O \
	xfwm4-4.12.4.tar.bz2

mkdir xfwm4 && tar xf xfwm4-*.tar.* -C xfwm4 --strip-components 1
cd xfwm4

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure \
     --prefix=/usr \
     --libdir=/usr/lib64 

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make PREFIX=/usr LIBDIR=/usr/lib64
sudo make install

cd ${CLFSSOURCES}/xc/xfce4
checkBuiltPackage
rm -rf xfwm4

#desktop-file-utils
wget http://freedesktop.org/software/desktop-file-utils/releases/desktop-file-utils-0.23.tar.xz -O \
  desktop-file-utils-0.23.tar.xz

mkdir desktop-file-utils && tar xf desktop-file-utils-*.tar.* -C desktop-file-utils --strip-components 1
cd desktop-file-utils

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure \
    --prefix=/usr \
    --libdir=/usr/lib64

make PREFIX=/usr LIBDIR=/usr/lib64
sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

sudo update-desktop-database /usr/share/applications

cd ${CLFSSOURCES}/xc/xfce4
checkBuiltPackage
rm -rf desktop-file-utils

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

cd ${CLFSSOURCES}/xc/xfce4
checkBuiltPackage
rm -rf sharedmimeinfo

#polkit-gnome
wget http://ftp.gnome.org/pub/gnome/sources/polkit-gnome/0.105/polkit-gnome-0.105.tar.xz -O \
	polkit-gnome-0.105.tar.xz


PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure --prefix=/usr \
   --libdir=/usr/lib64 

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make PREFIX=/usr LIBDIR=/usr/lib64
sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

sudo mkdir -p /etc/xdg/autostart &&
sudo bash -c 'cat > /etc/xdg/autostart/polkit-gnome-authentication-agent-1.desktop << "EOF"
[Desktop Entry]
Name=PolicyKit Authentication Agent
Comment=PolicyKit Authentication Agent
Exec=/usr/libexec/polkit-gnome-authentication-agent-1
Terminal=false
Type=Application
Categories=
NoDisplay=true
OnlyShowIn=GNOME;XFCE;Unity;
AutostartCondition=GNOME3 unless-session gnome
EOF'

mkdir polkit-gnome && tar xf polkit-gnome-*.tar.* -C polkit-gnome --strip-components 1
cd polkit-gnome

cd ${CLFSSOURCES}/xc/xfce4
checkBuiltPackage
rm -rf polkit-gnome

#xfce4-session
wget http://archive.xfce.org/src/xfce/xfwm4/4.12/xfwm4-4.12.4.tar.bz2 -O \
	xfwm4-4.12.4.tar.bz2

mkdir xfwm4 && tar xf xfwm4-*.tar.* -C xfwm4 --strip-components 1
cd xfwm4

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure \
     --prefix=/usr \
     --libdir=/usr/lib64 \
     --sysconfdir=/etc \
     --disable-legacy-sm

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make PREFIX=/usr LIBDIR=/usr/lib64
sudo make install

sudo update-desktop-database 
sudo update-mime-database /usr/share/mime

cd ${CLFSSOURCES}/xc/xfce4
checkBuiltPackage
rm -rf xfwm4

#Generate .xinitrc here

## Xfce4 Applications ##

#vte
wget http://ftp.gnome.org/pub/gnome/sources/vte/0.48/vte-0.48.3.tar.xz -O \
    vte-0.48.3.tar.xz

mkdir vte && tar xf vte-*.tar.* -C vte --strip-components 1
cd vte

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" USE_ARCH=64 \
PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
    --disable-static \
    --libdir=/usr/lib64 \
    --sysconfdir=/etc \
    --enable-introspection \
    --disable-gtk-doc
    
make PREFIX=/usr LIBDIR=/usr/lib64
sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/xfce4
checkBuiltPackage
rm -rf vte

#xfce4-terminal
wget http://archive.xfce.org/src/apps/xfce4-terminal/0.8/xfce4-terminal-0.8.6.tar.bz2 -O \
	xfce4-terminal-0.8.6.tar.bz2

mkdir xfce4-terminal && tar xf xfce4-terminal-*.tar.* -C xfce4-terminal --strip-components 1
cd xfce4-terminal

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" USE_ARCH=64 \
PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
    --libdir=/usr/lib64 

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} make PREFIX=/usr LIBDIR=/usr/lib64
sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/xfce4
checkBuiltPackage
rm -rf xfce4-terminal

#ristretto
wget http://archive.xfce.org/src/apps/ristretto/0.8/ristretto-0.8.2.tar.bz2 -O \
	ristretto-0.8.2.tar.bz2

mkdir ristretto && tar xf ristretto-*.tar.* -C ristretto --strip-components 1
cd ristretto

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" USE_ARCH=64 \
PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
    --libdir=/usr/lib64 

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} make PREFIX=/usr LIBDIR=/usr/lib64
sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/xfce4
checkBuiltPackage
rm -rf ristretto

#xfce-notifyd
wget http://archive.xfce.org/src/apps/xfce4-notifyd/0.2/xfce4-notifyd-0.2.4.tar.bz2 -O \
	xfce4-notifyd-0.2.4.tar.bz2

mkdir xfce4-notifyd && tar xf xfce4-notifyd-*.tar.* -C xfce4-notifyd --strip-components 1
cd xfce4-notifyd

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" USE_ARCH=64 \
PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
    --libdir=/usr/lib64 

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} make PREFIX=/usr LIBDIR=/usr/lib64
sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

notify-send -i info Information "Hi ${USER}, This is a Test"

cd ${CLFSSOURCES}/xc/xfce4
checkBuiltPackage
rm -rf xfce4-notifyd

