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
CLFSSOURCES=/sources
MAKEFLAGS="-j$(nproc)"
BUILD32="-m32"
BUILD64="-m64"
CLFS_TARGET32="i686-pc-linux-gnu"
PKG_CONFIG_PATH=/usr/lib64/pkgconfig
PKG_CONFIG_PATH64=/usr/lib64/pkgconfig
XORG_PREFIX=/usr

export CLFS=/
export CLFSSOURCES=/sources
export MAKEFLAGS="-j$(nproc)"
export BUILD32="-m32"
export BUILD64="-m64"
export CLFS_TARGET32="i686-pc-linux-gnu"
export PKG_CONFIG_PATH=/usr/lib64/pkgconfig
export PKG_CONFIG_PATH64=/usr/lib64/pkgconfig
export XORG_PREFIX=/usr

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

#gnome-common
wget http://ftp.gnome.org/pub/GNOME/sources/gnome-common/3.18/gnome-common-3.18.0.tar.xz -O \
    gnome-common-3.18.0.tar.xz

mkdir gnome-common && tar xf gnome-common-*.tar.* -C gnome-common --strip-components 1
cd gnome-common

ACLOCAL_FLAG=/usr/share/aclocal/ CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} sh autogen.sh --prefix=/usr\
    --libdir=/usr/lib64 \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin 
    
PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
sudo rm -rf gnome-common

#zenity
wget https://github.com/GNOME/zenity/archive/ZENITY_3_24_2.tar.gz -O \
    zenity-3.24.2.tar.gz
 
mkdir zenity && tar xf zenity-*.tar.* -C zenity --strip-components 1
cd zenity

sudo groupadd -fg 27 polkitd
sudo useradd -c "PolicyKit Daemon Owner" -d /etc/polkit-1 -u 27 \
        -g polkitd -s /bin/false polkitd

 
ACLOCAL_FLAG=/usr/share/aclocal/ CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" sh autogen.sh --prefix=/usr\
    --libdir=/usr/lib64 \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin 

sed -i 's/HELP_DIR/#HELP_DIR/' Makefile Makefile.in
sed -i 's/help/#help/' Makefile Makefile.in Makefile.am

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
sudo rm -rf zenity

#marco
git clone https://github.com/mate-desktop/marco
cd marco

ACLOCAL_FLAG=/usr/share/aclocal/ CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" sh autogen.sh --prefix=/usr\
    --libdir=/usr/lib64 \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin 

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
sudo rm -rf marco

#mate-control-center
git clone https://github.com/mate-desktop/mate-control-center
cd mate-control-center

ACLOCAL_FLAG=/usr/share/aclocal/ CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" sh autogen.sh --prefix=/usr \
    --libdir=/usr/lib64 \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin 
    
sed -i 's/HELP_DIR/#HELP_DIR/' Makefile Makefile.in
sed -i 's/help/#help/' Makefile Makefile.in Makefile.am

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
sudo rm -rf mate-control-center

#mate-notification-daemon
git clone https://github.com/mate-desktop/mate-notification-daemon
cd mate-notification-daemon

ACLOCAL_FLAG=/usr/share/aclocal/ CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" sh autogen.sh --prefix=/usr \
    --libdir=/usr/lib64 \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin 
    
sed -i 's/HELP_DIR/#HELP_DIR/' Makefile Makefile.in
sed -i 's/help/#help/' Makefile Makefile.in Makefile.am

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
sudo rm -rf mate-notification-daemon

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

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
sudo rm -rf mozjs

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

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
sudo rm -rf polkit

#accountservice
wget http://www.freedesktop.org/software/accountsservice/accountsservice-0.6.45.tar.xz -O \
  accountsservice-0.6.45.tar.xz

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" USE_ARCH=64 \
PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} 

mkdir accountsservice && tar xf accountsservice-*.tar.* -C accountsservice --strip-components 1
cd accountsservice

./configure --prefix=/usr \
            --sysconfdir=/etc    \
            --libdir=/usr/lib64  \
            --localstatedir=/var \
            --enable-admin-group=adm \
            --disable-static \
            --with-systemdunitdir=no \
            --disable-systemd \
            --disable-docbook-docs \
            --disable-gtk-doc

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" USE_ARCH=64 
PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
sudo rm -rf accountsservice

#mate-polkit
git clone https://github.com/mate-desktop/mate-polkit
cd mate-polkit

ACLOCAL_FLAG="/usr/share/aclocal/" LIBSOUP_LIBS=/usr/lib64   \
CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} sh autogen.sh --prefix=/usr \
    --libdir=/usr/lib64 \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin \
    --disable-gtk-doc 
    
#Deactivate building of the help subdir because it will fail
sed -i 's/HELP_DIR/#HELP_DIR/' Makefile Makefile.in
sed -i 's/help/#help/' Makefile Makefile.in Makefile.am
   
PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make LIBDIR=/usr/lib64 PREFIX=/usr
sudo make LIBDIR=/usr/lib64 PREFIX=/usr install
  
cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
sudo rm -rf mate-polkit

#Glib
wget http://ftp.gnome.org/pub/gnome/sources/glib/2.52/glib-2.52.3.tar.xz -O \
  glib-2.52.3.tar.xz

mkdir glib && tar xf glib-2.52.3.tar.xz -C glib --strip-components 1
cd glib

CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" \
PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure --prefix=/usr \
    --with-pcre=system \
    --libdir=/usr/lib64

make PREFIX=/usr LIBDIR=/usr/lib64
sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
sudo rm -rf glib

#caja
git clone https://github.com/mate-desktop/caja
cd caja

ACLOCAL_FLAG=/usr/share/aclocal/ CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" sh autogen.sh --prefix=/usr \
    --libdir=/usr/lib64 \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin 

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

sudo mkdir /usr/share/caja
sudo cp -rv data/* /usr/share/caja

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
sudo rm -rf caja

#caja-extensions
git clone https://github.com/mate-desktop/caja-extensions
cd caja-extensions

ACLOCAL_FLAG=/usr/share/aclocal/ CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} sh autogen.sh --prefix=/usr \
    --libdir=/usr/lib64 \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin 

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
sudo rm -rf caja-extensions

#mate-applets
git clone https://github.com/mate-desktop/mate-applets
cd mate-applets

ACLOCAL_FLAG=/usr/share/aclocal/ CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} sh autogen.sh --prefix=/usr\
    --libdir=/usr/lib64 \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin \
    --disable-stickynotes \
    --disable-battstat
    
sed -i 's/HELP_DIR/#HELP_DIR/' Makefile Makefile.in
sed -i 's/help/#help/' Makefile Makefile.in Makefile.am
sed -i 's/docs/#docs/' Makefile Makefile.in Makefile.am
sed -i 's/help/#help/' */Makefile*
sed -i 's/docs/#docs/' */Makefile*
sed -i 's/docs/#docs/' geyes/Makefile*
sed -i 's/docs/#docs/' stickynotes/Makefile*
sed -i 's/docs/#docs/' trashapplet/Makefile*
sed -i 's/docs/#docs/' multiload/Makefile*
sed -i 's/docs/#docs/' mateweather/Makefile*
sed -i 's/docs/#docs/' accessx-status/Makefile*
sed -i 's/docs/#docs/' invest-applet/Makefile*

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
sudo rm -rf mate-applets

#mate-themes
git clone https://github.com/mate-desktop/mate-themes
cd mate-themes

ACLOCAL_FLAG=/usr/share/aclocal/ CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} sh autogen.sh --prefix=/usr\
    --libdir=/usr/lib64 \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin 

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
sudo rm -rf mate-themes

#Start X at login
cat >> ~/.bash_profile << "EOF"
# Begin ~/.bash_profile
# Written for Beyond Linux From Scratch
# by James Robertson <jameswrobertson@earthlink.net>
# updated by Bruce Dubbs <bdubbs@linuxfromscratch.org>

# Personal environment variables and startup programs.

# Personal aliases and functions should go in ~/.bashrc.  System wide
# environment variables and startup programs are in /etc/profile.
# System wide aliases and functions are in /etc/bashrc.

if [ -f "$HOME/.bashrc" ] ; then
  source $HOME/.bashrc
fi

if [ -d "$HOME/bin" ] ; then
  pathprepend $HOME/bin
fi

# Having . in the PATH is dangerous
#if [ $EUID -gt 99 ]; then
#  pathappend .
#fi

if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then startx; fi

# End ~/.bash_profile

EOF

#gtksourceview
wget http://ftp.gnome.org/pub/gnome/sources/gtksourceview/3.24/gtksourceview-3.24.3.tar.xz -O \
    gtksourceview-3.24.3.tar.xz

mkdir gtksourceview && tar xf gtksourceview-*.tar.* -C gtksourceview --strip-components 1
cd gtksourceview

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr\
    --libdir=/usr/lib64 \
    --sysconfdir=/etc 

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
sudo rm -rf gtksourceview


export PYTHON=/usr/bin/python3.6

#libpeas
wget http://ftp.gnome.org/pub/gnome/sources/libpeas/1.20/libpeas-1.20.0.tar.xz -O \
    libpeas-1.20.0.tar.xz
    
mkdir libpeas && tar xf libpeas-*.tar.* -C libpeas --strip-components 1
cd libpeas

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr\
    --libdir=/usr/lib64 \
    --sysconfdir=/etc 

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
sudo rm -rf libpeas


#pluma
git clone https://github.com/mate-desktop/pluma
cd pluma

PYTHON=/usr/bin/python3.6 \
ACLOCAL_FLAG=/usr/share/aclocal/ CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} sh autogen.sh --prefix=/usr\
    --libdir=/usr/lib64 \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin 
    
sed -i 's/HELP_DIR/#HELP_DIR/' Makefile Makefile.in
sed -i 's/help/#help/' Makefile Makefile.in Makefile.am

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

unset PYTHON

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
sudo rm -rf pluma

#upower-glib
wget http://upower.freedesktop.org/releases/upower-0.99.5.tar.xz -O \
    upower-0.99.5.tar.xz

mkdir upower && tar xf upower-*.tar.* -C upower --strip-components 1
cd upower

ACLOCAL_FLAG=/usr/share/aclocal/ CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr\
    --libdir=/usr/lib64 \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin \
    --enable-deprecated \
    --disable-gtk-doc \
    --disable-gtk-doc-pdf \
    --disable-gtk-doc-html \
    --disable-man-pages 

sed -i 's/http\:\/\/docbook.sourceforge.net\/release\/xsl\/current\/manpages\/docbook.xsl/\/usr\/share\/xml\/docbook\/xsl-stylesheets-1.79.1\/html\/docbook.xsl/' doc/man/Makefile*

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
sudo rm -rf upower

#mate-power-manager
git clone https://github.com/mate-desktop/mate-power-manager
cd mate-power-manager

ACLOCAL_FLAG=/usr/share/aclocal/ CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} sh autogen.sh --prefix=/usr\
    --libdir=/usr/lib64 \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin 
    
sed -i 's/HELP_DIR/#HELP_DIR/' Makefile Makefile.in
sed -i 's/help/#help/' Makefile Makefile.in Makefile.am

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
sudo rm -rf mate-power-manager

#mate-user-share
git clone https://github.com/mate-desktop/mate-user-share
cd mate-user-share

ACLOCAL_FLAG=/usr/share/aclocal/ CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} sh autogen.sh --prefix=/usr \
    --libdir=/usr/lib64 \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin 

sed -i 's/HELP_DIR/#HELP_DIR/' Makefile Makefile.in
sed -i 's/help/#help/' Makefile Makefile.in Makefile.am
sed -i 's/docs/#docs/' Makefile Makefile.in Makefile.am

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
sudo rm -rf mate-user-share
    
#python-caja
git clone https://github.com/mate-desktop/python-caja
cd python-caja

ACLOCAL_FLAG=/usr/share/aclocal/ CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} sh autogen.sh --prefix=/usr \
    --libdir=/usr/lib64 \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin 

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
sudo rm -rf python-caja
    
#engrampa
git clone https://github.com/mate-desktop/engrampa
cd engrampa

ACLOCAL_FLAG=/usr/share/aclocal/ CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} sh autogen.sh --prefix=/usr \
    --libdir=/usr/lib64 \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin 
    
sed -i 's/HELP_DIR/#HELP_DIR/' Makefile Makefile.in
sed -i 's/help/#help/' Makefile Makefile.in Makefile.am

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

sudo mkdir /usr/share/engrampa
sudo cp -rv data/* /usr/share/engrampa/

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
sudo rm -rf engrampa

#eom
git clone https://github.com/mate-desktop/eom
cd eom

ACLOCAL_FLAG=/usr/share/aclocal/ CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} sh autogen.sh --prefix=/usr \
    --libdir=/usr/lib64 \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin 

sed -i 's/HELP_DIR/#HELP_DIR/' Makefile Makefile.in
sed -i 's/help/#help/' Makefile Makefile.in Makefile.am

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

sudo mkdir /usr/share/eom
sudo cp -rv data/* /usr/share/eom/

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
sudo rm -rf eom

#mate-calc
git clone https://github.com/mate-desktop/mate-calc
cd mate-calc

ACLOCAL_FLAG=/usr/share/aclocal/ CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} sh autogen.sh --prefix=/usr \
    --libdir=/usr/lib64 \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin 

sed -i 's/HELP_DIR/#HELP_DIR/' Makefile Makefile.in
sed -i 's/help/#help/' Makefile Makefile.in Makefile.am

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

sudo mkdir /usr/share/mate-calc
sudo cp -rv data/* /usr/share/mate-calc/

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
sudo rm -rf mate-calc

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

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
sudo rm -rf openjpeg

#poppler-glib (PDF support for atril)
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

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
sudo rm -rf poppler

#atril
git clone https://github.com/mate-desktop/atril
cd atril

ACLOCAL_FLAG=/usr/share/aclocal/ CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} sh autogen.sh --prefix=/usr \
    --libdir=/usr/lib64 \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin 

sed -i 's/HELP_DIR/#HELP_DIR/' Makefile Makefile.in
sed -i 's/help/#help/' Makefile Makefile.in Makefile.am

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

sudo mkdir /usr/share/atril
sudo cp -rv data/* /usr/share/atril

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
sudo rm -rf atril

#Brisk-Menu
git clone https://github.com/solus-project/brisk-menu 
cd brisk-menu

ACLOCAL_FLAG=/usr/local/share \
CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} autoreconf

ACLOCAL_FLAG=/usr/local/share \
CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} sh autogen.sh --prefix=/usr \
            --sysconfdir=/etc     \
            --libdir=/usr/lib64   

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

sudo glib-compile-schemas /usr/share/glib-2.0/schemas/
gsettings set com.solus-project.brisk-menu hot-key 'Super_L'
sudo gsettings set com.solus-project.brisk-menu hot-key 'Super_L'

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
sudo rm -rf brisk-menu
