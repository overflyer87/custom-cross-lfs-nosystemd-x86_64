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
export MAKEFLAGS=j8
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
    
PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

as_root make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf gnome-common

#zenity
wget https://github.com/GNOME/zenity/archive/ZENITY_3_24_2.tar.gz -O \
    zenity-3.24.2.tar.gz
 
mkdir zenity && tar xf zenity-*.tar.* -C zenity --strip-components 1
cd zenity
 
ACLOCAL_FLAG=/usr/share/aclocal/ CC="gcc ${BUILD64}" CXX="g++ ${BUILD64groupadd -fg 27 polkitd &&
useradd -c "PolicyKit Daemon Owner" -d /etc/polkit-1 -u 27 \
        -g polkitd -s /bin/false polkitd
}" \
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

as_root make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf zenity

#marco
wget https://github.com/mate-desktop/marco/archive/v1.19.0.tar.gz -O \
    marco-1.19.0.tar.gz
    
mkdir marco && tar xf marco-*.tar.* -C marco --strip-components 1
cd marco

ACLOCAL_FLAG=/usr/share/aclocal/ CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} sh autogen.sh --prefix=/usr\
    --libdir=/usr/lib64 \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin 

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

as_root make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf marco

#mate-control-center
wget https://github.com/mate-desktop/mate-control-center/archive/v1.19.0.tar.gz -O \
    mate-control-center-1.19.0.tar.gz
    
mkdir matecc && tar xf mate-control-center-*.tar.* -C matecc --strip-components 1
cd matecc

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

as_root make PREFIX=/usr LIBDIR=/usr/lib64 install

as_root mkdir /usr/share/mate-control-center
as_root cp -rv data/* /usr/share/mate-control-center

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf matecc

#mate-notification-daemon
wget https://github.com/mate-desktop/mate-notification-daemon/archive/v1.18.0.tar.gz -O \
    mate-notification-daemon-1.18.0.tar.gz
    
mkdir matend && tar xf mate-notification-daemon-*.tar.* -C matend --strip-components 1
cd matend

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

as_root make PREFIX=/usr LIBDIR=/usr/lib64 install

as_root mkdir /usr/share/mate-notification-daemon
as_root cp -rv data/* /usr/share/mate-notification-daemon

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf matend

##mozjs38
#wget https://ftp.osuosl.org/pub/blfs/conglomeration/mozjs/mozjs-38.2.1.rc0.tar.bz2 -O \
#    mozjs-38.2.1.rc0.tar.bz2
#
#wget http://www.linuxfromscratch.org/patches/blfs/svn/js38-38.2.1-upstream_fixes-2.patch -O \
#    js38-38.2.1-upstream_fixes-2.patch
#
#mkdir mozjs && tar xvjf mozjs-38*.tar.* -C mozjs --strip-components 1
#cd mozjs
#
#patch -Np1 -i ../js38-38.2.1-upstream_fixes-2.patch
#
#cd js/src && autoconf2.13
#
#as_root cp /usr/bin/python* _virtualenv/bin/
#
#CPPFLAGS="-I/usr/include" LDFLAGS="-L/usr/lib64"  \
#PYTHON="/usr/bin/python2" PYTHONPATH="/usr/lib64/python2.7" \
#PYTHONHOME="/usr/lib64/python2.7" PYTHON_INCLUDES="/usr/include/python2.7" \
#CC="gcc ${BUILD64}" USE_ARCH=64 \
#CXX="g++ ${BUILD64}" \
#PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
#    --with-intl-api     \
#            --with-system-zlib  \
#            --with-system-ffi   \
#            --with-system-nspr  \
#            --with-system-icu   \
#            --enable-threadsafe \
#            --enable-readline  \
#            --libdir=/usr/lib64
#            
#PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
#CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64
#
#as_root make PREFIX=/usr LIBDIR=/usr/lib64 install
#
#cd ${CLFSSOURCES}/xc/mate
#checkBuiltPackage
#rm -rf mozjs
#
##polkit+js88+git (blfs special package)
#wget http://anduin.linuxfromscratch.org/BLFS/polkit/polkit-0.113+git_2919920+js38.tar.xz -O \
#    polkit-0.113+git_2919920+js38.tar.xz
#
#mkdir polkitjsgit && tar xf polkit-0.113+git_2919920+js38.tar.* -C polkitjsgit --strip-components 1
#cd polkitjsgit
#
#as_root groupadd -fg 27 polkitd &&
#as_root useradd -c "PolicyKit Daemon Owner" -d /etc/polkit-1 -u 27 \
#        -g polkitd -s /bin/false polkitd
#
#CC="gcc ${BUILD64}" USE_ARCH=64 \
#CXX="g++ ${BUILD64}" \
#PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
#    --libdir=/usr/lib64 \
#    --sysconfdir=/etc \
#    --localstatedir=/var             \
#    --disable-static                 \
#    --enable-libsystemd-login=no     \
#    --with-authfw=shadow 
#
#PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
#CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64
#
#as_root make PREFIX=/usr LIBDIR=/usr/lib64 install
#
#as_root cat > /etc/pam.d/polkit-1 << "EOF"
## Begin /etc/pam.d/polkit-1
#
#auth     include        system-auth
#account  include        system-account
#password include        system-password
#session  include        system-session
#
## End /etc/pam.d/polkit-1
#EOF
#
#cd ${CLFSSOURCES}/xc/mate
#checkBuiltPackage
#rm -rf polkitjsgit
#
##polkit-gnome
#wget http://ftp.gnome.org/pub/gnome/sources/polkit-gnome/0.105/polkit-gnome-0.105.tar.xz -O \
#    polkit-gnome-0.105.tar.xz
#
#mkdir polkit-gnome && tar xf polkit-gnome-*.tar.* -C polkit-gnome --strip-components 1
#cd polkit-gnome
#
#CC="gcc ${BUILD64}" USE_ARCH=64 CXX="g++ ${BUILD64}" \
#PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
#    --libdir=/usr/lib64 \
#    --sysconfdir=/etc \
#    --disable-static
#
#PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
#CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64
#
#as_root make PREFIX=/usr LIBDIR=/usr/lib64 install
#
#cd ${CLFSSOURCES}/xc/mate
#checkBuiltPackage
#rm -rf polkit-gnome
#
##accountsservice
#wget https://www.freedesktop.org/software/accountsservice/accountsservice-0.6.45.tar.xz -O \
#    accountsservice-0.6.45.tar.xz
#   
#mkdir accountsservice && tar xf accountsservice-*.tar.* -C accountsservice --strip-components 1
#cd accountsservice
#
#CC="gcc ${BUILD64}" USE_ARCH=64 CXX="g++ ${BUILD64}" \
#PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
#    --libdir=/usr/lib64 \
#    --sysconfdir=/etc \
#    --disable-static
#
#PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
#CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64
#
#as_root make PREFIX=/usr LIBDIR=/usr/lib64 install#
#
#cd ${CLFSSOURCES}/xc/mate
#checkBuiltPackage
#rm -rf accountsservice
#
##mate-polkit
#
#
#
#
#
#

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
as_root make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf glib

#caja
wget https://github.com/mate-desktop/caja/archive/v1.19.0.tar.gz -O \
    caja-1.19.0.tar.gz
    
mkdir caja && tar xf caja-*.tar.* -C caja --strip-components 1
cd caja

ACLOCAL_FLAG=/usr/share/aclocal/ CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} sh autogen.sh --prefix=/usr\
    --libdir=/usr/lib64 \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin 

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

as_root make PREFIX=/usr LIBDIR=/usr/lib64 install

as_root mkdir /usr/share/caja
as_root cp -rv data/* /usr/share/caja

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf caja

#caja-extensions
wget https://github.com/mate-desktop/caja-extensions/archive/v1.18.1.tar.gz -O \
    caja-extensions-1.18.1.tar.gz

mkdir caja-extensions && tar xf caja-extensions-*.tar.* -C caja-extensions --strip-components 1
cd caja-extensions

ACLOCAL_FLAG=/usr/share/aclocal/ CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} sh autogen.sh --prefix=/usr\
    --libdir=/usr/lib64 \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin 

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

as_root make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf caja-extensions

#mate-applets
wget https://github.com/mate-desktop/mate-applets/archive/v1.19.0.tar.gz -O \
    mate-applets-1.19.0.tar.gz

mkdir mate-applets && tar xf mate-applets-*.tar.* -C mate-applets --strip-components 1
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

as_root make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf mate-applets

#mate-themes
wget https://github.com/mate-desktop/mate-themes/archive/v3.22.13.tar.gz -O \
    mate-themes-3.22.13.tar.gz

mkdir mate-themes && tar xf mate-themes-*.tar.* -C mate-themes --strip-components 1
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

as_root make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf mate-themes

#Start X at login
cat >> /home/overflyer/.bash_profile << "EOF"
if [ -z "$DISPLAY" ] && [ -n "$XDG_VTNR" ] && [ "$XDG_VTNR" -eq 1 ]; then
  exec startx
fi
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

as_root make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf gtksourceview

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

as_root make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf libpeas


#pluma
wget https://github.com/mate-desktop/pluma/archive/v1.19.1.tar.gz -O \
    pluma-1.19.1.tar.gz
    
mkdir pluma && tar xf pluma-*.tar.* -C pluma --strip-components 1
cd pluma

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

as_root make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf pluma

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

as_root make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf upower

#mate-power-manager
wget https://github.com/mate-desktop/mate-power-manager/archive/v1.18.0.tar.gz -O \
    mate-power-manager-1.18.0.tar.gz
    
mkdir matepm && tar xf mate-power-manager-*.tar.* -C matepm --strip-components 1
cd matepm

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

as_root make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf matepm

#mate-user-share
wget https://github.com/mate-desktop/mate-power-manager/archive/v1.18.0.tar.gz -O \
    mate-user-share-1.18.0.tar.gz
    
mkdir mate-user-share && tar xf mate-user-share-*.tar.* -C mate-user-share --strip-components 1
cd mate-user-share

ACLOCAL_FLAG=/usr/share/aclocal/ CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} sh autogen.sh --prefix=/usr\
    --libdir=/usr/lib64 \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin 

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

as_root make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf mate-user-share
    
#python-caja
wget https://github.com/mate-desktop/python-caja/archive/v1.18.1.tar.gz -O \
    python-caja-1.18.1.tar.gz

mkdir python-caja && tar xf python-caja-*.tar.* -C python-caja --strip-components 1
cd python-caja

ACLOCAL_FLAG=/usr/share/aclocal/ CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} sh autogen.sh --prefix=/usr\
    --libdir=/usr/lib64 \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin 

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

as_root make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf python-caja
    
#engrampa
wget https://github.com/mate-desktop/engrampa/archive/v1.19.0.tar.gz -O \
    engrampa-1.19.0.tar.gz

mkdir engrampa && tar xf engrampa-*.tar.* -C engrampa --strip-components 1
cd engrampa

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

as_root make PREFIX=/usr LIBDIR=/usr/lib64 install

as_root mkdir /usr/share/engrampa
as_root cp -rv data/* /usr/share/engrampa/

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf engrampa

#eom
wget https://github.com/mate-desktop/eom/archive/v1.19.0.tar.gz -O \
    eom-1.19.0.tar.gz
    
mkdir eom && tar xf eom-*.tar.* -C eom --strip-components 1
cd eom

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

as_root make PREFIX=/usr LIBDIR=/usr/lib64 install

as_root mkdir /usr/share/eom
as_root cp -rv data/* /usr/share/eom/

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf eom

#mate-calc
wget https://github.com/mate-desktop/mate-calc/archive/v1.18.0.tar.gz -O \
    mate-calc-1.18.0.tar.gz

mkdir mate-calc && tar xf mate-calc-*.tar.* -C mate-calc --strip-components 1
cd mate-calc

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

as_root make PREFIX=/usr LIBDIR=/usr/lib64 install

as_root mkdir /usr/share/mate-calc
as_root cp -rv data/* /usr/share/mate-calc/

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf mate-calc

#OpenJPEG
wget http://downloads.sourceforge.net/openjpeg.mirror/openjpeg-1.5.2.tar.gz -O \
    openjpeg-1.5.2.tar.gz
    
mkdir openjpeg && tar xf openjpeg-*.tar.* -C openjpeg --strip-components 1
cd openjpeg

autoreconf -f -i

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr\
    --libdir=/usr/lib64 \
    --sysconfdir=/etc \
    --disable-static

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

as_root make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf openjpeg

#poppler-glib (PDF support for atril)
wget http://poppler.freedesktop.org/poppler-0.56.0.tar.xz -O \
    poppler-0.56.0.tar.xz
    
wget http://poppler.freedesktop.org/poppler-data-0.4.7.tar.gz -O \
    Poppler-data-0.4.7.tar.gz

mkdir poppler && tar xf poppler-*.tar.* -C poppler --strip-components 1
cd poppler

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr\
    --libdir=/usr/lib64 \
    --sysconfdir=/etc \
    --disable-static            \
    --enable-build-type=release \
    --enable-cmyk               \
    --enable-xpdf-headers       \
    --with-testdatadir=$PWD/testfile

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

as_root make PREFIX=/usr LIBDIR=/usr/lib64 install

mkdir poppler-data
tar -xf ../Poppler-data-*.tar.gz -C poppler-data --strip-components 1 
cd poppler-data

as_root make LIBDIR=/usr/lib64 prefix=/usr install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf poppler

#atril
wget https://github.com/mate-desktop/atril/archive/v1.19.0.tar.gz -O \
    atril-1.19.0.tar.gz

mkdir atril && tar xf atril-*.tar.* -C atril --strip-components 1
cd atril

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

as_root make PREFIX=/usr LIBDIR=/usr/lib64 install

as_root mkdir /usr/share/atril
as_root cp -rv data/* /usr/share/atril

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf eom


