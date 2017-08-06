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
cd ${CLFSSOURCES}/xc

mkdir mate
cd mate

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

#dbus
wget http://dbus.freedesktop.org/releases/dbus/dbus-1.10.20.tar.gz -O \
  dbus-1.10.20.tar.gz

mkdir dbus && tar xf dbus-*.tar.* -C dbus --strip-components 1
cd dbus

groupadd -g 18 messagebus &&
useradd -c "D-Bus Message Daemon User" -d /var/run/dbus \
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

sudo mkdir /etc/dbus-1/
sudo mkdir /usr/share/dbus-1/
sudo mkdir /var/run/dbus
 
sudo dbus-uuidgen --ensure

sudo cat > /etc/dbus-1/session-local.conf << "EOF"
<!DOCTYPE busconfig PUBLIC
 "-//freedesktop//DTD D-BUS Bus Configuration 1.0//EN"
 "http://www.freedesktop.org/standards/dbus/1.0/busconfig.dtd">
<busconfig>

  <!-- Search for .service files in /usr/share -->
  <servicedir>/usr/share/dbus-1/services</servicedir>

</busconfig>
EOF

cd ${CLFSSOURCES}/blfs-bootscripts
sudo make install-dbus

sudo /etc/rc.d/init.d/dbus start

#More info ondbus:
#http://www.linuxfromscratch.org/hints/downloads/files/execute-session-scripts-using-kdm.txt

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf dbus

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

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure \
     --prefix=/usr \
     --libdir=/usr/lib64 \
     --disable-static \
     --enable-shared && 

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make PREFIX=/usr LIBDIR=/usr/lib64
sudo make PREFIX=/usr LIBDIR=/usr/lib64 PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" install

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
sudo make install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf cairo

#Nevertheless I seem to need to rebuild
#harfbuzz, fontconfig and freetype
#Pango is complaining that it wont find any backends

cd ${CLFSSOURCES}

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

mv -v /usr/bin/freetype-config{,-64}
ln -sf multiarch_wrapper /usr/bin/freetype-config
install -v -m755 -d /usr/share/doc/freetype-2.4.12
cp -v -R docs/* /usr/share/doc/freetype-2.4.12

install -v -m755 -d /usr/share/doc/freetype-2.8
cp -v -R docs/*     /usr/share/doc/freetype-2.8

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

mv -v /usr/bin/freetype-config{,-64}
ln -sf multiarch_wrapper /usr/bin/freetype-config
install -v -m755 -d /usr/share/doc/freetype-2.4.12
cp -v -R docs/* /usr/share/doc/freetype-2.4.12

install -v -m755 -d /usr/share/doc/freetype-2.8
cp -v -R docs/*     /usr/share/doc/freetype-2.8

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
sudo make install

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

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure \
     --prefix=/usr \
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
make -k check
checkBuiltPackage
make PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" PREFIX=/usr LIBDIR=/usr/lib64 install

ldconfig

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf gdk-pixbuf

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
