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
#That should suffice

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" 
USE_ARCH=64 
CXX="g++ ${BUILD64}" 
CC="gcc ${BUILD64}"

export PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" 
export USE_ARCH=64 
export CXX="g++ ${BUILD64}" 
export CC="gcc ${BUILD64}"

#PCRE (NOT PCRE2!!!)
wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.41.tar.bz2 -O \
  pcre-8.41.tar.bz2

mkdir pcre && tar xf pcre-*.tar.* -C pcre --strip-components 1
cd pcre

./configure --prefix=/usr                     \
            --docdir=/usr/share/doc/pcre-8.41 \
            --enable-unicode-properties       \
            --enable-pcre16                   \
            --enable-pcre32                   \
            --enable-pcregrep-libz            \
            --enable-pcregrep-libbz2          \
            --enable-pcretest-libreadline     \
            --disable-static                  \
            --libdir=/usr/lib64

make PREFIX=/usr LIBDIR=/usr/lib64
sudo make PREFIX=/usr LIBDIR=/usr/lib64 install 
sudo mv -v /usr/lib64/libpcre.so.* /lib64 &&
sudo ln -sfv ../../../../lib64/$(readlink /usr/lib64/libpcre.so) /usr/lib64/libpcre.so
sudo ldconfig

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf pcre

#Glib
wget http://ftp.gnome.org/pub/gnome/sources/glib/2.52/glib-2.52.3.tar.xz -O \
  glib-2.52.3.tar.xz

mkdir glib && tar xf glib-*.tar.* -C glib --strip-components 1
cd glib

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure \
    --prefix=/usr \
    --with-pcre=system \
    --libdir=/usr/lib64

make PREFIX=/usr LIBDIR=/usr/lib64
sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf glib

#libxfce4util
wget http://archive.xfce.org/src/xfce/libxfce4util/4.12/libxfce4util-4.12.1.tar.bz2 -O \
  libxfce4util-4.12.1.tar.bz2

mkdir libxfce4util && tar xf libxfce4util-*.tar.* -C libxfce4util --strip-components 1
cd libxfce4util

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure --prefix=/usr \
    --libdir=/usr/lib64 \
    --disable-gtk-doc

make PREFIX=/usr LIBDIR=/usr/lib64
sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf libxfce4util

#dbus
wget http://dbus.freedesktop.org/releases/dbus/dbus-1.10.20.tar.gz -O \
  dbus-1.10.20.tar.gz

mkdir dbus && tar xf dbus-*.tar.* -C dbus --strip-components 1
cd dbus

sudo groupadd -g 18 messagebus &&
sudo useradd -c "D-Bus Message Daemon User" -d /var/run/dbus \
        -u 18 -g messagebus -s /bin/false messagebus

./configure --prefix=/usr                        \
            --sysconfdir=/etc                    \
            --libdir=/usr/lib64                  \
            --localstatedir=/var                 \
            --disable-doxygen-docs               \
            --disable-xml-docs                   \
            --disable-static                     \
            --docdir=/usr/share/doc/dbus-1.10.20 \
            --with-console-auth-dir=/run/console \
            --with-system-pid-file=/run/dbus/pid \
            --with-system-socket=/run/dbus/system_bus_socket \
            --disable-systemd \
            --without-systemdsystemunitdir
            
make PREFIX=/usr LIBDIR=/usr/lib64
sudo make PREFIX=/usr LIBDIR=/usr/lib64 install 

sudo mkdir /lib/lsb
sudo mkdir /lib64/lsb
sudo ln -sfv /etc/rc.d/init.d/functions /lib/lsb/init-functions
sudo ln -sfv /etc/rc.d/init.d/functions /lib64/lsb/init-functions

sed -i 's/\/lib\/lsb\/init-functions/\/lib64\/lsb\/init-functions/' /etc/rc.d/init.d/*
sed -i 's/loadproc/start_daemon/' /etc/rc.d/init.d/functions
sed -i 's/load_msg_info/echo/' /etc/rc.d/init.d/functions

sudo mkdir /etc/dbus-1/
sudo mkdir /usr/share/dbus-1/
sudo mkdir /var/run/dbus
 
sudo dbus-uuidgen --ensure

sudo bash -c 'cat > /etc/dbus-1/session-local.conf << "EOF"
<!DOCTYPE busconfig PUBLIC
 "-//freedesktop//DTD D-BUS Bus Configuration 1.0//EN"
 "http://www.freedesktop.org/standards/dbus/1.0/busconfig.dtd">
<busconfig>
  <!-- Search for .service files in /usr/share -->
  <servicedir>/usr/share/dbus-1/services</servicedir>
</busconfig>
EOF'

cd ${CLFSSOURCES}/blfs-bootscripts
sudo make install-dbus

sudo /etc/rc.d/init.d/dbus start

#More info ondbus:
#http://www.linuxfromscratch.org/hints/downloads/files/execute-session-scripts-using-kdm.txt

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf dbus

#dbus-glib
wget http://dbus.freedesktop.org/releases/dbus-glib/dbus-glib-0.108.tar.gz -O \
    dbus-glib-0.108.tar.gz

mkdir dbus-glib && tar xf dbus-glib-*.tar.* -C dbus-glib --strip-components 1
cd dbus-glib

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure --prefix=/usr \
            --sysconfdir=/etc \
            --libdir=/usr/lib64 \
            --disable-static \
            --disable-gtk-doc
            
make PREFIX=/usr LIBDIR=/usr/lib4
sudo make PREFIX=/usr LIBDIR=/usr/lib4 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf dbus-glib

#Xfconf
wget http://archive.xfce.org/src/xfce/xfconf/4.12/xfconf-4.12.1.tar.bz2 -O \
  xfconf-4.12.1.tar.bz2

mkdir xfconf && tar xf xfconf-*.tar.* -C xfconf --strip-components 1
cd 

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure --prefix=/usr \
            --libdir=/usr/lib64 \
            --disable-static \
            --disable-gtk-doc
            
make PREFIX=/usr LIBDIR=/usr/lib4
sudo make PREFIX=/usr LIBDIR=/usr/lib4 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf xfconf

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

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf desktop-file-utils

#gobj-introspection
wget http://ftp.gnome.org/pub/gnome/sources/gobject-introspection/1.52/gobject-introspection-1.52.1.tar.xz -O \
gobject-introspection-1.52.1.tar.xz

mkdir gobject-introspection && tar xf gobject-introspection-*.tar.* -C gobject-introspection --strip-components 1
cd gobject-introspection

export PYTHON=/usr/bin/python2.7

PYTHON=/usr/bin/python2.7 \
PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure \
     --prefix=/usr \
     --libdir=/usr/lib64 \
     --disable-static \
     --enable-shared && 

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make PREFIX=/usr LIBDIR=/usr/lib64
sudo make PREFIX=/usr LIBDIR=/usr/lib64 PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" install

unset PYTHON

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf gobject-introspection

#at-spi2-core
wget http://ftp.gnome.org/pub/gnome/sources/at-spi2-core/2.24/at-spi2-core-2.24.1.tar.xz -O \
  at-spi2-core-2.24.1.tar.xz

mkdir atspi2core && tar xf at-spi2-core-*.tar.* -C atspi2core --strip-components 1
cd atspi2core

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure \
     --prefix=/usr \
     --libdir=/usr/lib64 \
     --disable-static \
     --enable-shared \
     --sysconfdir=/etc

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make PREFIX=/usr LIBDIR=/usr/lib64
sudo make PREFIX=/usr LIBDIR=/usr/lib64 PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf atspi2core

#ATK
wget http://ftp.gnome.org/pub/gnome/sources/atk/2.24/atk-2.24.0.tar.xz -O \
    atk-2.24.0.tar.xz

mkdir atk && tar xf atk-*.tar.* -C atk --strip-components 1
cd atk

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure \
     --prefix=/usr \
     --libdir=/usr/lib64 \
     --disable-static \
     --enable-shared \
     --sysconfdir=/etc

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make PREFIX=/usr LIBDIR=/usr/lib64
sudo make PREFIX=/usr LIBDIR=/usr/lib64 PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf atk

#at-spi2-atk
wget http://ftp.gnome.org/pub/gnome/sources/at-spi2-atk/2.24/at-spi2-atk-2.24.1.tar.xz -O \
  at-spi2-atk-2.24.1.tar.xz

mkdir atspi2atk && tar xf at-spi2-atk-*.tar.* -C atspi2atk --strip-components 1
cd atspi2atk

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure \
     --prefix=/usr \
     --libdir=/usr/lib64 \
     --disable-static \
     --enable-shared \
     --sysconfdir=/etc

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make PREFIX=/usr LIBDIR=/usr/lib64
sudo make PREFIX=/usr LIBDIR=/usr/lib64 PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf atspi2atk

#Cython
wget https://pypi.python.org/packages/10/d5/753d2cb5073a9f4329d1ffed1de30b0458821780af8fdd8ba1ad5adb6f62/Cython-0.26.tar.gz -O \
    Cython-0.26.tar.gz

mkdir cython && tar xf Cython-*.tar.* -C cython --strip-components 1
cd cython

python3 setup.py build
sudo python3 setup.py install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf cython

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

cd ${CLFSSOURCES}/xc/mate
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

cd ${CLFSSOURCES}/xc/mate
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

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf libtiff

#ICU
wget http://download.icu-project.org/files/icu4c/59.1/icu4c-59_1-src.tgz -O \
    icu4c-59_1-src.tgz

mkdir icu && tar xf icu*.tgz -C icu --strip-components 1
cd icu
cd source

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure \
     --prefix=/usr \
     --libdir=/usr/lib64 \
     --disable-static

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make PREFIX=/usr LIBDIR=/usr/lib64
sudo make install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf icu

#harfbuzz, freetype2 and which were installed by Xorg scripts
#Pixman and libpng needed by  Cairo are also already installed by UEFI-bootloader script and Xorg script, respectively

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

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf cairo

#Nevertheless I seem to need to rebuild
#harfbuzz, fontconfig and freetype
#Pango is complaining that it wont find any backends

cd ${CLFSSOURCES}

#freetype 64-bit
mkdir freetype && tar xf freetype-*.tar.* -C freetype --strip-components 1
cd freetype

sed -ri "s:.*(AUX_MODULES.*valid):\1:" modules.cfg

sed -r "s:.*(#.*SUBPIXEL_RENDERING) .*:\1:" \
    -i include/freetype/config/ftoption.h 

sed -i -r 's:.*(#.*BYTE.*) .*:\1:' include/freetype/config/ftoption.h

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
USE_ARCH=64 \
CC="gcc ${BUILD64}" ./configure \
--prefix=/usr \
--disable-static \
--libdir=/usr/lib64

PREFIX=/usr LIBDIR=/usr/lib64 make
sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

sudo mv -v /usr/bin/freetype-config{,-64}
sudo ln -sf multiarch_wrapper /usr/bin/freetype-config
sudo install -v -m755 -d /usr/share/doc/freetype-2.4.12
sudo cp -v -R docs/* /usr/share/doc/freetype-2.4.12

sudo install -v -m755 -d /usr/share/doc/freetype-2.8
sudo cp -v -R docs/*     /usr/share/doc/freetype-2.8

cd ${CLFSSOURCES} 
#checkBuiltPackage
rm -rf freetype

#harfbuzz 64-bit
mkdir harfbuzz && tar xf harfbuzz-*.tar.* -C harfbuzz --strip-components 1
cd harfbuzz

LIBDIR=/usr/lib64 USE_ARCH=64 PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
CXX="g++ ${BUILD64}" CC="gcc ${BUILD64}" \
./configure --prefix=/usr --libdir=/usr/lib64
PREFIX=/usr LIBDIR=/usr/lib64 make 
sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES} 
#checkBuiltPackage
rm -rf harfbuzz

cd ${CLFSSOURCES} 
#checkBuiltPackage
rm -rf freetype

#freeype 64-bit
mkdir freetype && tar xf freetype-*.tar.* -C freetype --strip-components 1
cd freetype

sed -ri "s:.*(AUX_MODULES.*valid):\1:" modules.cfg

sed -r "s:.*(#.*SUBPIXEL_RENDERING) .*:\1:" \
    -i include/freetype/config/ftoption.h 

sed -i -r 's:.*(#.*BYTE.*) .*:\1:' include/freetype/config/ftoption.h

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
USE_ARCH=64 \
CC="gcc ${BUILD64}" ./configure \
--prefix=/usr \
--disable-static \
--libdir=/usr/lib64

PREFIX=/usr LIBDIR=/usr/lib64 make
sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

sudo mv -v /usr/bin/freetype-config{,-64}
sudo ln -sf multiarch_wrapper /usr/bin/freetype-config
sudo install -v -m755 -d /usr/share/doc/freetype-2.4.12
sudo cp -v -R docs/* /usr/share/doc/freetype-2.4.12

sudo install -v -m755 -d /usr/share/doc/freetype-2.8
sudo cp -v -R docs/*     /usr/share/doc/freetype-2.8

cd ${CLFSSOURCES} 
#checkBuiltPackage
rm -rf freetype

cd ${CLFSSOURCES}/xc/mate

#Pango
wget http://ftp.gnome.org/pub/gnome/sources/pango/1.40/pango-1.40.6.tar.xz -O \
    pango-1.40.6.tar.xz

mkdir pango && tar xf pango-*.tar.* -C pango --strip-components 1
cd pango

ln -sv ${XORG_PREFIX}/share/fonts /usr/share/

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure \
     --prefix=/usr \
     --libdir=/usr/lib64 \
     --disable-static \
     --sysconfdir=/etc

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make PREFIX=/usr LIBDIR=/usr/lib64
sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

sudo ldconfig

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf pango

#hicolor-icon-theme
wget http://icon-theme.freedesktop.org/releases/hicolor-icon-theme-0.15.tar.xz -O \
    hicolor-icon-theme-0.15.tar.xz

mkdir hicoloricontheme && tar xf hicolor-icon-theme-*.tar.* -C hicoloricontheme --strip-components 1
cd hicoloricontheme

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure \
     --prefix=/usr \
     --libdir=/usr/lib64 

sudo make PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf hicoloricontheme

#adwaita-icon-theme
wget http://ftp.gnome.org/pub/gnome/sources/adwaita-icon-theme/3.24/adwaita-icon-theme-3.24.0.tar.xz -O \
    adwaita-icon-theme-3.24.0.tar.xz

mkdir adwaiticontheme && tar xf adwaita-icon-theme-*.tar.* -C adwaiticontheme --strip-components 1
cd adwaiticontheme

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure --prefix=/usr \
     --libdir=/usr/lib64 

sudo make PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf adwaiticontheme

#gdk-pixbuf
wget http://ftp.gnome.org/pub/gnome/sources/gdk-pixbuf/2.36/gdk-pixbuf-2.36.6.tar.xz -O \
    gdk-pixbuf-2.36.6.tar.xz

mkdir gdk-pixbuf && tar xf gdk-pixbuf-*.tar.* -C gdk-pixbuf --strip-components 1
cd gdk-pixbuf

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure \
     --prefix=/usr \
     --libdir=/usr/lib64 \
     --with-x11

make PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" PREFIX=/usr LIBDIR=/usr/lib64

#make -k check
#checkBuiltPackage

sudo make PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" PREFIX=/usr LIBDIR=/usr/lib64 install

sudo ldconfig

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf gdk-pixbuf

#GTK2
wget http://ftp.gnome.org/pub/gnome/sources/gtk+/2.24/gtk+-2.24.31.tar.xz -O \
    gtk+-2.24.31.tar.xz

mkdir gtk2 && tar xf gtk+-2*.tar.* -C gtk2 --strip-components 1
cd gtk2

sed -e 's#l \(gtk-.*\).sgml#& -o \1#' \
    -i docs/{faq,tutorial}/Makefile.in      

CC="gcc ${BUILD64}" \
  CXX="g++ ${BUILD64}" USE_ARCH=64 \
  PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
  --sysconfdir=/etc --libdir=/usr/lib64

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make LIBDIR=/usr/lib64 PREFIX=/usr
sudo make LIBDIR=/usr/lib64 PREFIX=/usr install

cat > ~/.gtkrc-2.0 << "EOF"
include "/usr/share/themes/Glider/gtk-2.0/gtkrc"
gtk-icon-theme-name = "hicolor"
EOF

sudo bash -c 'cat > /etc/gtk-2.0/gtkrc << "EOF"
include "/usr/share/themes/Clearlooks/gtk-2.0/gtkrc"
gtk-icon-theme-name = "elementary"
EOF'

sudo ldconfig

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf gtk2

#gtk3
wget http://ftp.gnome.org/pub/gnome/sources/gtk+/3.22/gtk+-3.22.16.tar.xz -O \
    gtk+-3.22.16.tar.xz

mkdir gtk3 && tar xf gtk+-3*.tar.* -C gtk3 --strip-components 1
cd gtk3

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure \
     --prefix=/usr \
     --libdir=/usr/lib64 \
     --sysconfdir=/etc         \
     --enable-broadway-backend \
     --enable-x11-backend      \
     --disable-wayland-backend 

make PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" PREFIX=/usr LIBDIR=/usr/lib64

make -k check
checkBuiltPackage

sudo make PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" PREFIX=/usr LIBDIR=/usr/lib64 install

mkdir -vp ~/.config/gtk-3.0
cat > ~/.config/gtk-3.0/settings.ini << "EOF"
[Settings]
gtk-theme-name = Adwaita
gtk-icon-theme-name = oxygen
gtk-font-name = DejaVu Sans 12
gtk-cursor-theme-size = 18
gtk-toolbar-style = GTK_TOOLBAR_BOTH_HORIZ
gtk-xft-antialias = 1
gtk-xft-hinting = 1
gtk-xft-hintstyle = hintslight
gtk-xft-rgba = rgb
gtk-cursor-theme-name = Adwaita
EOF

sudo ldconfig

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf gtk3

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

#Test::Needs (optional for Perl Module Tests)

#URI
wget https://www.cpan.org/authors/id/E/ET/ETHER/URI-1.72.tar.gz -O \
  URI-1.72.tar.gz

mkdir URI && tar xf URI-*.tar.* -C URI --strip-components 1
cd URI

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" perl Makefile.PL 
PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make prefix=/usr libdir=/usr/lib64
#make test
sudo make PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" prefix=/usr libdir=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf URI

##HTML-Tagset
#http://search.cpan.org/CPAN/authors/id/P/PE/PETDANCE/HTML-Tagset-3.20.tar.gz -O \
#  HTML-Tagset-3.20.tar.gz
#
#mkdir HTML-Tagset && tar xf HTML-Tagset-*.tar.* -C HTML-Tagset --strip-components 1
#cd HTML-Tagset
#
#PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" perl Makefile.PL 
#PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make prefix=/usr libdir=/usr/lib64
##make test
#sudo make PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" prefix=/usr libdir=/usr/lib64 install
#
#cd ${CLFSSOURCES}/xc/mate
#checkBuiltPackage
#rm -rf HTML-Tagset
#
##HTML::Parser
#wget https://www.cpan.org/authors/id/G/GA/GAAS/HTML-Parser-3.72.tar.gz -O \
#  HTML-Parser-3.72.tar.gz
# 
#mkdir HTML-Parser && tar xf HTML-Parser-*.tar.* -C HTML-Parser --strip-components 1
#cd HTML-Parser
#
#PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" perl Makefile.PL 
#PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make prefix=/usr libdir=/usr/lib64
##make test
#sudo make PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" prefix=/usr libdir=/usr/lib64 install
#
#cd ${CLFSSOURCES}/xc/mate
#checkBuiltPackage
#rm -rf HTML-Parser
#
#Encode::Locale
#URI
#HTML::Parser
#HTTP::Date
#IO::HTML
#LWP:MediaTypes
#HTTP::Message
#HTML::Form
#HTTP::Cookies
#HTTP::Negotiate
#Net::HTTP
#WWW::RobotRules
#HTTP::Daemon
#File::Listing
#Test::RequiresInternet
#Test::Fatal
#libwww-perl

#Insert optional GLADE dependency here
#wget http://ftp.gnome.org/pub/GNOME/sources/glade3/3.8/ for gtk2
#wget http://ftp.gnome.org/pub/GNOME/sources/glade/3.20/ for gtk3
#https://glade.gnome.org/

#libxfce4ui
wget http://archive.xfce.org/src/xfce/libxfce4ui/4.12/libxfce4ui-4.12.1.tar.bz2 -O \
  libxfce4ui-4.12.1.tar.bz2

mkdir libxfce4ui && tar xf libxfce4ui-*.tar.* -C libxfce4ui --strip-components 1
cd libxfce4ui

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure --prefix=/usr \
     --sysconfdir=/etc \
     --libdir=/usr/lib64 \
     --disable-gtk-doc

make PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" PREFIX=/usr LIBDIR=/usr/lib64
sudo make PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" PREFIX=/usr LIBDIR=/usr/lib64 install 

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf libxfce4ui

#Exo
wget http://archive.xfce.org/src/xfce/exo/0.10/exo-0.10.7.tar.bz2 -O \
  exo-0.10.7.tar.bz2

mkdir exo && tar xf exo-*.tar.* -C exo --strip-components 1
cd exo

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure --prefix=/usr \
     --sysconfdir=/etc \
     --libdir=/usr/lib64 \
     --disable-gtk-doc

make PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" PREFIX=/usr LIBDIR=/usr/lib64
sudo make PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" PREFIX=/usr LIBDIR=/usr/lib64 install 

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf exo

#Garcon
wget http://archive.xfce.org/src/xfce/garcon/0.6/garcon-0.6.1.tar.bz2 -O \
  garcon-0.6.1.tar.bz2

mkdir garcon && tar xf garcon-*.tar.* -C garcon --strip-components 1
cd garcon

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure --prefix=/usr \
     --sysconfdir=/etc \
     --libdir=/usr/lib64 \
     --disable-gtk-doc

make PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" PREFIX=/usr LIBDIR=/usr/lib64
sudo make PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" PREFIX=/usr LIBDIR=/usr/lib64 install 

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf garcon

#gtk-xfce-engine
wget http://archive.xfce.org/src/xfce/gtk-xfce-engine/3.2/gtk-xfce-engine-3.2.0.tar.bz2 -O \
gtk-xfce-engine-3.2.0.tar.bz2

mkdir gtk-xfce-engine && tar xf gtk-xfce-engine-*.tar.* -C gtk-xfce-engine --strip-components 1
cd gtk-xfce-engine

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure --prefix=/usr \
     --sysconfdir=/etc \
     --libdir=/usr/lib64 \
     --disable-gtk-doc

make PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" PREFIX=/usr LIBDIR=/usr/lib64
sudo make PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf gtk-xfce-engine

#libwnk
wget http://ftp.gnome.org/pub/gnome/sources/libwnck/2.30/libwnck-2.30.7.tar.xz -O \
    libwnck-2.30.7.tar.xz

mkdir libwnck && tar xf libwnck-*.tar.* -C libwnck --strip-components 1
cd libwnck

CC="gcc ${BUILD64}"   CXX="g++ ${BUILD64}" USE_ARCH=64    \
  PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr    \
  --libdir=/usr/lib64 --sysconfdir=/etc --disable-static \
  --program-suffix=-1
  
PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make GETTEXT_PACKAGE=libwnck-1 LIBDIR=/usr/lib64 PREFIX=/usr
sudo make GETTEXT_PACKAGE=libwnck-1 LIBDIR=/usr/lib64 PREFIX=/usr install
  
cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf libwnck

#xfce4-panel
wget http://archive.xfce.org/src/xfce/xfce4-panel/4.12/xfce4-panel-4.12.1.tar.bz2 -O \
  xfce4-panel-4.12.1.tar.bz2
  
mkdir xfce4-panel && tar xf xfce4-panel-*.tar.* -C xfce4-panel --strip-components 1
cd xfce4-panel

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" USE_ARCH=64    \
  PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr    \
  --libdir=/usr/lib64 --sysconfdir=/etc --disable-static \
  --disable-gtk-doc --enable-gtk3
  
make PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" PREFIX=/usr LIBDIR=/usr/lib64
sudo make PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf xfce4-panel


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

#xfce4-xkb-plugin
wget http://archive.xfce.org/src/panel-plugins/xfce4-xkb-plugin/0.7/xfce4-xkb-plugin-0.7.1.tar.bz2 -O \
  xfce4-xkb-plugin-0.7.1.tar.bz2

mkdir xfce4-xkb-plugin && tar xf xfce4-xkb-plugin-*.tar.* -C xfce4-xkb-plugin --strip-components 1
cd xfce4-xkb-plugin

sed -e 's|xfce4/panel-plugins|xfce4/panel/plugins|' \
    -i panel-plugin/{Makefile.in,xkb-plugin.desktop.in.in} 

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" USE_ARCH=64    \
  PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr  \
  --libdir=/usr/lib64 --libexecdir=/usr/lib64 --disable-static \
  --disable-debug
  
make PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" PREFIX=/usr LIBDIR=/usr/lib64
sudo make PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf xfce4-xkb-plugin

#gnome-icon-theme

#libgudev

#libnotify

#Gvfs

#libexif

#gstreamer

#gst-plugins

#yasm

#libjpeg-turbo

#libxml2

#libgsf

#LittleCMS

#LibTIFF

#libexif

#OpenJPEG

#Cairo

#NSPR

#libtasn

#libffi

#p11-kit

#NSPR

#Poppler

#Tumbler

#Thunar

#mozjs

#polkit

#polkit-gnome

#thunar-volman

#xfce-appfinder

#UPower

#libatasmart

#Which

#Optional dependencies for LVM2

#LVM2

#parted

#sg3_utils

#UDisks

#xfce4-power-manager

#lxde-icon-theme

#libcanberra

#xfce4-settings

#Xfdesktop

#Xfwm4

#desktop-file-utils

#shared-mime-info

#polkit-gnome

#xfce4-session

## Xfce4 Applications ##

#vte

#xfce4-terminal

#ristretto

#xfce-notifyd

