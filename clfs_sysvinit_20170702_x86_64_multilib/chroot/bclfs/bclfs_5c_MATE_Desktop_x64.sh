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
#THat should suffice

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" 
USE_ARCH=64 
CXX="g++ ${BUILD64}" 
CC="gcc ${BUILD64}"

export PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" 
export USE_ARCH=64 
export CXX="g++ ${BUILD64}" 
export CC="gcc ${BUILD64}"

#We left off installing mate-desktop
#Now we continue ligpgerror

#libgpg-error
wget ftp://ftp.gnupg.org/gcrypt/libgpg-error/libgpg-error-1.27.tar.bz2 -O \
    libgpg-error-1.27.tar.bz2
    
mkdir libgpgerror && tar xf libgpg-error-*.tar.* -C libgpgerror --strip-components 1
cd libgpgerror

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure --prefix=/usr --libdir=/usr/lib64
PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}"  make LIBDIR=/usr/lib64 PREFIX=/usr
as_root make LIBDIR=/usr/lib64 PREFIX=/usr install

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

as_root make LIBDIR=/usr/lib64 PREFIX=/usr install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -r libgcrypt

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

as_root make LIBDIR=/usr/lib64 PREFIX=/usr install

cd ${CLFSSOURCES}/xc/mate
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

as_root make LIBDIR=/usr/lib64 PREFIX=/usr install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -r p11-kit

#libassuan
wget ftp://ftp.gnupg.org/gcrypt/libassuan/libassuan-2.4.3.tar.bz2 -O \
    libassuan-2.4.3.tar.bz2
    
mkdir libassuan && tar xf libassuan-*.tar.* -C libassuan --strip-components 1
cd libassuan

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure --prefix=/usr \
    --libdir=/usr/lib64 \
    --disable-static
    
PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}"  make LIBDIR=/usr/lib64 PREFIX=/usr
make check
checkBuiltPackage

as_root make LIBDIR=/usr/lib64 PREFIX=/usr install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -r libksba

#libksba
wget ftp://ftp.gnupg.org/gcrypt/libksba/libksba-1.3.5.tar.bz2 -O \
    libksba-1.3.5.tar.bz2
    
mkdir libksba && tar xf libksba-*.tar.* -C libksba --strip-components 1
cd libksba

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure --prefix=/usr \
    --libdir=/usr/lib64 \
    --disable-static
    
PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make LIBDIR=/usr/lib64 PREFIX=/usr
make check
checkBuiltPackage

as_root make LIBDIR=/usr/lib64 PREFIX=/usr install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -r libksba

#npth
wget ftp://ftp.gnupg.org/gcrypt/npth/npth-1.5.tar.bz2 -O \
    npth-1.5.tar.bz2

mkdir npth && tar xf npth-*.tar.* -C npth --strip-components 1
cd npth

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure --prefix=/usr \
    --libdir=/usr/lib64 \
    --disable-static
    
PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make LIBDIR=/usr/lib64 PREFIX=/usr
make check
checkBuiltPackage

as_root make LIBDIR=/usr/lib64 PREFIX=/usr install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -r npth

#pinentry
wget ftp://ftp.gnupg.org/gcrypt/pinentry/pinentry-1.0.0.tar.bz2 -O \
    pinentry-1.0.0.tar.bz2

mkdir pinentry && tar xf pinentry-*.tar.* -C pinentry --strip-components 1
cd pinentry

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure --prefix=/usr \
    --libdir=/usr/lib64 \
    --disable-static
    
PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make LIBDIR=/usr/lib64 PREFIX=/usr

as_root make LIBDIR=/usr/lib64 PREFIX=/usr install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -r pinentry

#GCR
wget http://ftp.gnome.org/pub/gnome/sources/gcr/3.20/gcr-3.20.0.tar.xz -O \
    gcr-3.20.0.tar.xz
    
mkdir gcr && tar xf gcr-*.tar.* -C gcr --strip-components 1
cd gcr

sed -i -r 's:"(/desktop):"/org/gnome\1:' schema/*.xml

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure --prefix=/usr \
    --libdir=/usr/lib64 \
    --disable-static \
    --sysconfdir=/etc
 
PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make LIBDIR=/usr/lib64 PREFIX=/usr
make -k check
checkBuiltPackage

as_root make LIBDIR=/usr/lib64 PREFIX=/usr install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -r gcr

#gnome-keyring
wget http://ftp.gnome.org/pub/gnome/sources/gnome-keyring/3.20/gnome-keyring-3.20.1.tar.xz -O \
    gnome-keyring-3.20.1.tar.xz

mkdir gnome-keyring && tar xf gnome-keyring-*.tar.* -C gnome-keyring --strip-components 1
cd gnome-keyring
    
PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure --prefix=/usr \
    --libdir=/usr/lib64 \
    --disable-static \
    --sysconfdir=/etc \
    --with-pam-dir=/lib64/security
    
#Let's fix an annoying problem with docbook.xsl
#Delete all lines in Makefile and docs/Makefile.am
#Where docbook.xsl download URL
#is assigned to XSLTPROC_XSL
#Instead export it in this script
#and assign it the hardcoded path of anything containing html/docbook.xsl on you system
#It is most likely to be found somewhere in /usr/share/xml ...
#Also for paranoia reasons put the value assignment to XSLTPROC_XSL in front of the make command
#This method was tested to work!!!!!!

export XSLTPROC_XSL=/usr/share/xml/docbook/xsl-stylesheets-1.79.1/html/docbook.xsl

sed -i 's/XSLTPROC_XSL = \\//' Makefile docs/Makefile.am
sed -i 's/http\:\/\/docbook.sourceforge.net\/release\/xsl\/current\/manpages\/docbook.xsl//' Makefile docs/Makefile.am

XSLTPROC_XSL=/usr/share/xml/docbook/xsl-stylesheets-1.79.1/html/docbook.xsl \
PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make LIBDIR=/usr/lib64 PREFIX=/usr

make check
checkBuiltPackage

as_root make LIBDIR=/usr/lib64 PREFIX=/usr install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf gnome-keyring

#dbus-glib
wget http://dbus.freedesktop.org/releases/dbus-glib/dbus-glib-0.108.tar.gz -O \
    dbus-glib-0.108.tar.gz

mkdir dbus-glib && tar xf dbus-glib-*.tar.* -C dbus-glib --strip-components 1
cd dbus-glib

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure --prefix=/usr \
            --sysconfdir=/etc \
            --libdir=/usr/lib64 \
            --disable-static &&
            
make PREFIX=/usr LIBDIR=/usr/lib4
as_root make PREFIX=/usr LIBDIR=/usr/lib4 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf dbus-glib

#mate-session-manager
wget https://github.com/mate-desktop/mate-session-manager/archive/v1.19.0.tar.gz -O \
  mate-session-manager-1.19.0.tar.gz

mkdir mate-session-manager && tar xf mate-session-manager-*.tar.* -C mate-session-manager --strip-components 1
cd mate-session-manager

ACLOCAL_FLAG=/usr/share/aclocal/ CC="gcc ${BUILD64}" \
  CXX="g++ ${BUILD64}" USE_ARCH=64 \
   PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} sh autogen.sh --prefix=/usr \
   --libdir=/usr/lib64 --sysconfdir=/etc --disable-static \
   --localstatedir=/var --bindir=/usr/bin --sbindir=/usr/sbin \
   --disable-docbook-docs

#Fix the same docbook.xsl problem
#That occured when building gnome-keyring

export XSLTPROC_XSL=/usr/share/xml/docbook/xsl-stylesheets-1.79.1/html/docbook.xsl

sed -i 's/http\:\/\/docbook.sourceforge.net\/release\/xsl\/current\/manpages\/docbook.xsl/\/usr\/share\/xml\/docbook\/xsl-stylesheets-1.79.1\/html\/docbook.xsl/' doc/man/Makefile*

XSLTPROC_XSL=/usr/share/xml/docbook/xsl-stylesheets-1.79.1/html/docbook.xsl \
PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make LIBDIR=/usr/lib64 PREFIX=/usr

as_root make LIBDIR=/usr/lib64 PREFIX=/usr install

cd egg
as_root make LIBDIR=/usr/lib64 PREFIX=/usr install
cd ../data
as_root make LIBDIR=/usr/lib64 PREFIX=/usr install
cd ../m4
as_root make LIBDIR=/usr/lib64 PREFIX=/usr install
cd ../po
as_root make LIBDIR=/usr/lib64 PREFIX=/usr install
cd ../capplet
as_root make LIBDIR=/usr/lib64 PREFIX=/usr install
cd ../tools
as_root make LIBDIR=/usr/lib64 PREFIX=/usr install
cd ../mate-session
as_root make LIBDIR=/usr/lib64 PREFIX=/usr install
cd ..

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf mate-session-manager

#nettle
wget https://ftp.gnu.org/gnu/nettle/nettle-3.3.tar.gz -O \
    nettle-3.3.tar.gz

mkdir nettle && tar xf nettle-*.tar.* -C nettle --strip-components 1
cd nettle

CC="gcc ${BUILD64}" \
  CXX="g++ ${BUILD64}" USE_ARCH=64 \
   PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
   --libdir=/usr/lib64 --disable-static 
   
PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make LIBDIR=/usr/lib64 PREFIX=/usr
make check
checkBuiltPackage

as_root make LIBDIR=/usr/lib64 PREFIX=/usr install
as_root chmod   -v   755 /usr/lib64/lib{hogweed,nettle}.so &&
as_root install -v -m755 -d /usr/share/doc/nettle-3.3 &&
as_root install -v -m644 nettle.html /usr/share/doc/nettle-3.3

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf nettle

#GnuTLS
wget https://www.gnupg.org/ftp/gcrypt/gnutls/v3.5/gnutls-3.5.14.tar.xz -O \
    gnutls-3.5.14.tar.xz
    
mkdir gnutls && tar xf gnutls-*.tar.* -C gnutls --strip-components 1
cd gnutls

CC="gcc ${BUILD64}" \
  CXX="g++ ${BUILD64}" USE_ARCH=64 \
   PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
   --libdir=/usr/lib64 --disable-static \
   --with-default-trust-store-pkcs11="pkcs11:" \
   --with-default-trust-store-file=/etc/ssl/ca-bundle.crt \
   --disable-gtk-doc \
   --enable-openssl-compatibility \
   --with-included-unistring
   
PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make LIBDIR=/usr/lib64 PREFIX=/usr
make check
checkBuiltPackage

as_root make LIBDIR=/usr/lib64 PREFIX=/usr install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf gnutls

#gsettings-desktop-schemas
wget http://ftp.gnome.org/pub/gnome/sources/gsettings-desktop-schemas/3.24/gsettings-desktop-schemas-3.24.0.tar.xz -O \
    gsettings-desktop-schemas-3.24.0.tar.xz
    
mkdir gsetdeskschemas && tar xf gsettings-desktop-schemas-*.tar.* -C gsetdeskschemas --strip-components 1
cd gsetdeskschemas

sed -i -r 's:"(/system):"/org/gnome\1:g' schemas/*.i

CC="gcc ${BUILD64}" \
  CXX="g++ ${BUILD64}" USE_ARCH=64 \
   PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
   --libdir=/usr/lib64 --disable-static 

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make LIBDIR=/usr/lib64 PREFIX=/usr
as_root make LIBDIR=/usr/lib64 PREFIX=/usr install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf gsetdeskschemas

#libarchive
wget http://www.libarchive.org/downloads/libarchive-3.3.2.tar.gz -O \
    libarchive-3.3.2.tar.gz

mkdir libarchive && tar xf libarchive-*.tar.* -C libarchive --strip-components 1
cd libarchive

CC="gcc ${BUILD64}" \
  CXX="g++ ${BUILD64}" USE_ARCH=64 \
   PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
   --libdir=/usr/lib64 --disable-static 

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make LIBDIR=/usr/lib64 PREFIX=/usr
as_root make LIBDIR=/usr/lib64 PREFIX=/usr install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf libarchive

#CMake
wget http://www.cmake.org/files/v3.8/cmake-3.8.2.tar.gz -O \
    cmake-3.8.2.tar.gz

mkdir cmake && tar xf cmake-*.tar.* -C cmake --strip-components 1
cd cmake

sed -i '/CMAKE_USE_LIBUV 1/s/1/0/' CMakeLists.txt     &&
#sed -i '/"lib64"/s/64//' Modules/GNUInstallDirs.cmake &&

CC="gcc ${BUILD64}" \
  CXX="g++ ${BUILD64}" USE_ARCH=64 \
   PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./bootstrap --prefix=/usr \
            --system-libs        \
            --mandir=/share/man  \
            --no-system-jsoncpp  \
            --no-system-librhash \
            --docdir=/share/doc/cmake-3.8.2 

bin/ctest -O cmake-3.8.2-test.log
checkBuiltPackage

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make LIBDIR=/usr/lib64 PREFIX=/usr
as_root make LIBDIR=/usr/lib64 PREFIX=/usr install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf cmake

#libproxy
wget https://github.com/libproxy/libproxy/archive/0.4.15.tar.gz -O \
    libproxy-0.4.15.tar.gz

mkdir libproxy && tar xf libproxy-*.tar.* -C libproxy --strip-components 1
cd libproxy

CC="gcc ${BUILD64}" \
  CXX="g++ ${BUILD64}" USE_ARCH=64 \
   PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} sh autogen.sh --prefix=/usr \
   --libdir=/usr/lib64 --disable-static 

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make LIBDIR=/usr/lib64 PREFIX=/usr
as_root make LIBDIR=/usr/lib64 PREFIX=/usr install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf libproxy

#glib-networking
wget ftp://ftp.gnome.org/pub/gnome/sources/glib-networking/2.50/glib-networking-2.50.0.tar.xz -O \
    glib-networking-2.50.0.tar.xz

mkdir glibnet && tar xf glib-networking-*.tar.* -C glibnet --strip-components 1
cd glibnet

CC="gcc ${BUILD64}" \
  CXX="g++ ${BUILD64}" USE_ARCH=64 \
   PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
   --libdir=/usr/lib64 --disable-static \
   --without-ca-certificates 

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make LIBDIR=/usr/lib64 PREFIX=/usr
make -k check 
checkBuiltPackage

as_root make LIBDIR=/usr/lib64 PREFIX=/usr install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf glibnet

#libsoup
wget http://ftp.gnome.org/pub/gnome/sources/libsoup/2.58/libsoup-2.58.1.tar.xz -O \
    libsoup-2.58.1.tar.xz

mkdir libsoup && tar xf libsoup-*.tar.* -C libsoup --strip-components 1
cd libsoup

CC="gcc ${BUILD64}" \
  CXX="g++ ${BUILD64}" USE_ARCH=64 \
   PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
   --libdir=/usr/lib64 --disable-static 

as_root ln -sfv /usr/bin/python3 /usr/bin/python

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make LIBDIR=/usr/lib64 PREFIX=/usr
make check 
checkBuiltPackage

as_root make LIBDIR=/usr/lib64 PREFIX=/usr install
as_root unlink /usr/bin/python
as_root ldconfig

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf libsoup

#libmateweather
wget https://github.com/mate-desktop/libmateweather/archive/v1.19.1.tar.gz -O \
    libmateweather-v1.19.1.tar.gz

mkdir libmateweather && tar xf libmateweather-*.tar.* -C libmateweather --strip-components 1
cd libmateweather

  ACLOCAL_FLAG=/usr/share/aclocal/ CC="gcc ${BUILD64}" \
  CXX="g++ ${BUILD64}" USE_ARCH=64 \
   PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} sh autogen.sh --prefix=/usr \
   --libdir=/usr/lib64 --sysconfdir=/etc --disable-static \
   --localstatedir=/var --bindir=/usr/bin --sbindir=/usr/sbin \
   --enable-dependency-tracking

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make LIBDIR=/usr/lib64 PREFIX=/usr
as_root make LIBDIR=/usr/lib64 PREFIX=/usr install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf libmateweather

#libwnk
wget http://ftp.gnome.org/pub/gnome/sources/libwnck/3.24/libwnck-3.24.0.tar.xz -O \
    libwnck-3.24.0.tar.gz

mkdir libwnck && tar xf libwnck-*.tar.* -C libwnck --strip-components 1
cd libwnck

CC="gcc ${BUILD64}"   CXX="g++ ${BUILD64}" USE_ARCH=64    \
  PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr    \
  --libdir=/usr/lib64 --sysconfdir=/etc --disable-static    \
  --localstatedir=/var --bindir=/usr/bin \
  --sbindir=/usr/sbin --datadir=/usr/share/doc \
  --with-x --enable-tools \
  --enable-dependency-tracking \
  --disable-gtk-doc --x-libraries=/usr/lib64 \
  --x-includes=/usr/include/X11/ --enable-introspection=yes \
  --enable-shared --enable-startup-notification \
  --includedir=/usr/include/  
  
PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make LIBDIR=/usr/lib64 PREFIX=/usr
as_root make LIBDIR=/usr/lib64 PREFIX=/usr install
  
cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf libwnck

#Python2.7.6 64-bit
wget https://www.python.org/ftp/python/2.7.13/Python-2.7.13.tar.xz -O \
  Python-2.7.13.tar.xz
  
wget https://www.python.org/ftp/python/doc/2.7.13/python-2.7.13-docs-html.tar.bz2 -O \
  python-2.7.13-docs-html.tar.bz2
  
mkdir Python-2 && tar xf Python-2.7.13.tar.* -C Python-2 --strip-components 1
cd Python-2

cp ${CLFSSOURCES}/python2713-lib64-patch.patch ${CLFSSOURCES}/xc/mate/Python-2

patch -Np0 -i python2713-lib64-patch.patch

USE_ARCH=64 PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" LDFLAGS="-L/usr/lib64" ./configure \
            --prefix=/usr       \
            --enable-shared     \
            --with-system-expat \
            --with-system-ffi   \
            --enable-unicode=ucs4 \
            --libdir=/usr/lib64 &&

make LIBDIR=/usr/lib64 PREFIX=/usr 
as_root make LIBDIR=/usr/lib64 PREFIX=/usr install

as_root chmod -v 755 /usr/lib64/libpython2.7.so.1.0

as_root mv -v /usr/bin/python{,-64} &&
as_root mv -v /usr/bin/python2{,-64} &&
as_root mv -v /usr/bin/python2.7{,-64} &&
as_root ln -sfv python2.7-64 /usr/bin/python2-64 &&
as_root ln -sfv python2-64 /usr/bin/python-64 &&
as_root ln -sfv multiarch_wrapper /usr/bin/python &&
as_root ln -sfv multiarch_wrapper /usr/bin/python2 &&
as_root ln -sfv multiarch_wrapper /usr/bin/python2.7 &&
#Deactivate renaming header according to cblfs
#mate-menu will not find since Python.h includes pyconfig.h not pyconfig-64.h
#as_root mv -v /usr/include/python2.7/pyconfig{,-64}.h

as_root install -v -dm755 /usr/share/doc/python-2.7.13 &&

tar --strip-components=1                     \
    --no-same-owner                          \
    --directory /usr/share/doc/python-2.7.13 \
    -xvf ../python-2.7.*.tar.* &&

as_root find /usr/share/doc/python-2.7.13 -type d -exec chmod 0755 {} \; &&
as_root find /usr/share/doc/python-2.7.13 -type f -exec chmod 0644 {} \;
            
cd ${CLFSSOURCES}
checkBuiltPackage
rm -rf Python-2


#mate-menus
wget https://github.com/mate-desktop/mate-menus/archive/v1.18.0.tar.gz -O \
    mate-menus-1.18.0.tar.gz
    
mkdir mate-menus && tar xf mate-menus-*.tar.* -C mate-menus --strip-components 1
cd mate-menus

LIBSOUP_LIBS=/usr/lib64 \
  ACLOCAL_FLAG=/usr/share/aclocal/ CC="gcc ${BUILD64}" \
  CXX="g++ ${BUILD64}" USE_ARCH=64 \
   PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} sh autogen.sh --prefix=/usr \
   --libdir=/usr/lib64 --sysconfdir=/etc --disable-static \
   --localstatedir=/var --bindir=/usr/bin --sbindir=/usr/sbin \

#YOU NEED PYTHON 2.7 FOR PYTHON BINDING!!!

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make LIBDIR=/usr/lib64 PREFIX=/usr
as_root make LIBDIR=/usr/lib64 PREFIX=/usr install
  
cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf mate-menus

#notification-daemon
wget http://ftp.gnome.org/pub/gnome/sources/notification-daemon/3.20/notification-daemon-3.20.0.tar.xz -O \
    notification-daemon-3.20.0.tar.xz

mkdir notificationdaemon && tar xf notification-daemon-*.tar.* -C notificationdaemon --strip-components 1
cd notificationdaemon

CC="gcc ${BUILD64}" \
  CXX="g++ ${BUILD64}" USE_ARCH=64 \
   PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
   --libdir=/usr/lib64 --disable-static 

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make LIBDIR=/usr/lib64 PREFIX=/usr
as_root make LIBDIR=/usr/lib64 PREFIX=/usr install

pgrep -l notification-da &&
notify-send -i info Information "Hi ${USER}, This is a Test"

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf notificationdaemon

#Zip 
wget http://downloads.sourceforge.net/infozip/zip30.tar.gz -O \
    zip30.tar.gz

mkdir zip && tar xf zip*.tar.* -C zip --strip-components 1
cd zip

sed -i 's/CC = cc#/CC = gcc#/' unix/Makefile

CC="gcc ${BUILD64}" \
PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make PREFIX=/usr LIBDIR=/usr/lib64 -f unix/Makefile generic_gcc
as_root make PREFIX=/usr MANDIR=/usr/share/man/man1 LIBDIR=/usr/lib64 -f unix/Makefile install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf zip

#autoconf2.13
wget http://ftp.gnu.org/gnu/autoconf/autoconf-2.13.tar.gz -O \
    autoconf-2.13.tar.gz

wget http://www.linuxfromscratch.org/patches/blfs/svn/autoconf-2.13-consolidated_fixes-1.patch -O \
    Autoconf-2.13-consolidated_fixes-1.patch

mkdir autoconf && tar xf autoconf-*.tar.* -C autoconf --strip-components 1
cd autoconf

patch -Np1 -i ../Autoconf-2.13-consolidated_fixes-1.patch

mv -v autoconf.texi autoconf213.texi                      &&
rm -v autoconf.info       &&

CC="gcc ${BUILD64}" \
  CXX="g++ ${BUILD64}" USE_ARCH=64 \
   PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
   --libdir=/usr/lib64 --disable-static --program-suffix=2.13 

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make LIBDIR=/usr/lib64 PREFIX=/usr
as_root make LIBDIR=/usr/lib64 PREFIX=/usr install

as_root install -v -m644 autoconf213.info /usr/share/info &&
as_root install-info --info-dir=/usr/share/info autoconf213.info

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf autoconf

#Uncommenting mozjs, polkit+git+mozjs and modemmanager
#Mozjs fails compiling, cannot get it to detect python right
#Either says python environment is not sane or if python2.7
#module _collections not foun
#however python2 works fine and imports the module
#
##js38
#wget https://ftp.osuosl.org/pub/blfs/conglomeration/mozjs/mozjs-38.2.1.rc0.tar.bz2 -O \
#    mozjs-38.2.1.rc0.tar.bz2
#
#mkdir mozjs && tar xf mozjs*.tar.* -C mozjs --strip-components 1
#cd mozjs
#
#cd js/src &&
#autoconf2.13 &&
#
#CC="gcc ${BUILD64}" \
#  CXX="g++ ${BUILD64}" USE_ARCH=64 \
#  PYTHON=/usr/bin/python2-64 \
#  PYTHONPATH=/usr/lib64/python2.7 \
#  PYTHONHOME=/usr/lib64/python2.7 ./configure --prefix=/usr \
#    --with-intl-api     \
#    --libdir=/usr/lib64 \
#    --with-system-zlib  \
#    --with-system-ffi   \
#    --with-system-nspr  \
#    --with-system-icu   \
#    --enable-threadsafe \
#    --enable-readline   
#
#PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make LIBDIR=/usr/lib64 PREFIX=/usr
#as_root make LIBDIR=/usr/lib64 PREFIX=/usr install
#
#as_root pushd /usr/include/mozjs-38 &&
#for link in `find . -type l`; do
#    header=`readlink $link`
#    as_root rm -f $link
#    as_root cp -pv $header $link
#    as_root chmod 644 $link
#done &&
#as_root popd
#
#cd ${CLFSSOURCES}/xc/mate
#checkBuiltPackage
#rm -rf mozjs
#
##Polkit-0.113+git_2919920+js38 
#

#libqmi (recommended for ModemManager)
wget http://www.freedesktop.org/software/libqmi/libqmi-1.18.0.tar.xz -O \
    libqmi-1.18.0.tar.xz

mkdir libqmi && tar xf libqmi-*.tar.* -C libqmi --strip-components 1
cd libqmi

CC="gcc ${BUILD64}" \
  CXX="g++ ${BUILD64}" USE_ARCH=64 \
   PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr  \
            --libdir=/usr/lib64 \
            --sysconfdir=/etc    \
            --disable-static

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make LIBDIR=/usr/lib64 PREFIX=/usr
as_root make LIBDIR=/usr/lib64 PREFIX=/usr install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf libqmi

#libmbim (recommended for ModemManager)
wget http://www.freedesktop.org/software/libmbim/libmbim-1.14.0.tar.xz -O \
    libmbim-1.14.0.tar.xz

mkdir libmbim && tar xf libmbim-*.tar.* -C libmbim --strip-components 1
cd libmbim

CC="gcc ${BUILD64}" \
  CXX="g++ ${BUILD64}" USE_ARCH=64 \
   PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr  \
            --libdir=/usr/lib64 \
            --sysconfdir=/etc    \
            --disable-static

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make LIBDIR=/usr/lib64 PREFIX=/usr
as_root make LIBDIR=/usr/lib64 PREFIX=/usr install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf libmbim

#ModemManager
wget http://www.freedesktop.org/software/ModemManager/ModemManager-1.6.8.tar.xz -O \
    ModemManager-1.6.8.tar.xz

mkdir ModemManager && tar xf ModemManager-*.tar.* -C ModemManager --strip-components 1
cd ModemManager

CC="gcc ${BUILD64}" \
  CXX="g++ ${BUILD64}" USE_ARCH=64 \
   PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr  \
            --libdir=/usr/lib64 \
            --sysconfdir=/etc    \
            --localstatedir=/var \
            --enable-more-warnings=no \
            --disable-static  \
            --disable-gtk-doc

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make LIBDIR=/usr/lib64 PREFIX=/usr
as_root make LIBDIR=/usr/lib64 PREFIX=/usr install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf ModemManager

#libdaemon
wget http://0pointer.de/lennart/projects/libdaemon/libdaemon-0.14.tar.gz -O \
    libdaemon-0.14.tar.gz

mkdir libdaemon && tar xf libdaemon-*.tar.* -C libdaemon --strip-components 1
cd libdaemon

CC="gcc ${BUILD64}" \
  CXX="g++ ${BUILD64}" USE_ARCH=64 \
  PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
  --libdir=/usr/lib64 --disable-static

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make LIBDIR=/usr/lib64 PREFIX=/usr
as_root make docdir=/usr/share/doc/libdaemon-0.14 LIBDIR=/usr/lib64 PREFIX=/usr install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf libdaemon

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
as_root make LIBDIR=/usr/lib64 PREFIX=/usr install

cat > ~/.gtkrc-2.0 << "EOF"
include "/usr/share/themes/Glider/gtk-2.0/gtkrc"
gtk-icon-theme-name = "hicolor"
EOF

cat > /etc/gtk-2.0/gtkrc << "EOF"
include "/usr/share/themes/Clearlooks/gtk-2.0/gtkrc"
gtk-icon-theme-name = "elementary"
EOF

ldconfig

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf gtk2


#libglade
wget http://ftp.gnome.org/pub/gnome/sources/libglade/2.6/libglade-2.6.4.tar.bz2 -O \
    libglade-2.6.4.tar.bz2

mkdir libglade && tar xf libglade-*.tar.* -C libglade --strip-components 1
cd libglade

sed -i '/DG_DISABLE_DEPRECATED/d' glade/Makefile.in 

CC="gcc ${BUILD64}" \
  CXX="g++ ${BUILD64}" USE_ARCH=64 \
  PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
  --libdir=/usr/lib64 --disable-static

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make LIBDIR=/usr/lib64 PREFIX=/usr
as_root make LIBDIR=/usr/lib64 PREFIX=/usr install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf libglade

#PyCairo2
wget https://github.com/pygobject/pycairo/releases/download/v1.14.0/pycairo-1.14.0.tar.gz -O \
    pycairo-1.14.0.tar.gz

mkdir pycairo && tar xf pycairo-*.tar.* -C pycairo --strip-components 1
cd pycairo

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} LIBDIR=/usr/lib64 PREFIX=/usr python2 setup.py build  
PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} LIBDIR=/usr/lib64 PREFIX=/usr as_root python2 setup.py install --optimize=1
PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} LIBDIR=/usr/lib64 PREFIX=/usr python3 setup.py build
as_root PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} LIBDIR=/usr/lib64 PREFIX=/usr python3 setup.py install --optimize=1

as_root mv /usr/lib/pkgconfig/pycairo.pc /usr/lib64/pkgconfig/pycairo.pc
as_root mv /usr/lib/pkgconfig/py3cairo.pc /usr/lib64/pkgconfig/py3cairo.pc

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf pycairo

#PyGObject2
wget http://ftp.gnome.org/pub/gnome/sources/pygobject/2.28/pygobject-2.28.6.tar.xz -O \
    pygobject-2.28.6.tar.xz

wget http://www.linuxfromscratch.org/patches/blfs/svn/Pygobject-2.28.6-fixes-1.patch -O \
    Pygobject-2.28.6-fixes-1.patch

mkdir pygobject && tar xf pygobject-2*.tar.* -C pygobject --strip-components 1
cd pygobject

patch -Np1 -i ../Pygobject-2.28.6-fixes-1.patch

CC="gcc ${BUILD64}" \
  CXX="g++ ${BUILD64}" USE_ARCH=64 \
  PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
  --libdir=/usr/lib64 --disable-introspection --disable-docs

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make LIBDIR=/usr/lib64 PREFIX=/usr
as_root make LIBDIR=/usr/lib64 PREFIX=/usr install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf pygobject

#PyGObject3
wget http://ftp.gnome.org/pub/gnome/sources/pygobject/3.24/pygobject-3.24.1.tar.xz -O \
    pygobject-3.24.1.tar.xz

mkdir pygobject3 && tar xf pygobject-3*.tar.* -C pygobject3 --strip-components 1
cd pygobject3

mkdir python2 &&
pushd python2 &&

CC="gcc ${BUILD64}" \
  CXX="g++ ${BUILD64}" USE_ARCH=64 \
  PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ../configure --prefix=/usr \
    --with-python=/usr/bin/python2-64 --libdir=/usr/lib64 &&
make PREFIX=/usr LIBDIR=/usr/lib64 &&
popd

as_root make PREFIX=/usr LIBDIR=/usr/lib64 -C python2 install

cd ..

mkdir python3 &&
pushd python3 &&

CC="gcc ${BUILD64}" \
  CXX="g++ ${BUILD64}" USE_ARCH=64 \
  PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ../configure --prefix=/usr \
    --with-python=/usr/bin/python3 --libdir=/usr/lib64 &&
make PREFIX=/usr LIBDIR=/usr/lib64 &&
popd

as_root make PREFIX=/usr LIBDIR=/usr/lib64 -C python3 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf pygobject3

#DbusPy
wget http://dbus.freedesktop.org/releases/dbus-python/dbus-python-1.2.4.tar.gz -O \
    dbus-python-1.2.4.tar.gz

mkdir dbus-python && tar xf dbus-python-*.tar.* -C dbus-python --strip-components 1
cd dbus-python

mkdir python2 &&
pushd python2 &&
PYTHON=/usr/bin/python2     \
 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ../configure --prefix=/usr \
 --libdir=/usr/lib64 --docdir=/usr/share/doc/dbus-python-1.2.4 &&
make PREFIX=/usr LIBDIR=/usr/lib64 &&
popd

as_root make PREFIX=/usr LIBDIR=/usr/lib64 -C python 2 install

mkdir python3 &&
pushd python3 &&
PYTHON=/usr/bin/python3 \
PKG_CONFIG_PATH=${PKG_CONFIG_PATH64}  ../configure --prefix=/usr --libdir=/usr/lib64 &&
make PREFIX=/usr LIBDIR=/usr/lib64 &&
popd

as_root make PREFIX=/usr LIBDIR=/usr/lib64 -C python3 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf dbus-python

#Avahi
wget https://github.com/lathiat/avahi/releases/download/v0.7/avahi-0.7.tar.gz -O \
    avahi-0.7.tar.gz

mkdir avahi && tar xf avahi-*.tar.* -C avahi --strip-components 1
cd avahi

wget https://github.com/lathiat/avahi/releases/download/v0.7/avahi-0.7.tar.gz -O \
    avahi-0.7.tar.gz

as_root groupadd -fg 84 avahi 
as_root useradd -c "Avahi Daemon Owner" -d /var/run/avahi-daemon -u 84 \
        -g avahi -s /bin/false avahi

as_root groupadd -fg 86 netdev

CC="gcc ${BUILD64}" \
  CXX="g++ ${BUILD64}" USE_ARCH=64 \
  PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
            --sysconfdir=/etc    \
            --localstatedir=/var \
            --libdir=/usr/lib64  \
            --disable-static     \
            --disable-mono       \
            --disable-monodoc    \
            --disable-qt3        \
            --disable-qt4        \
            --disable-qt5        \
            --enable-core-docs   \
            --with-distro=none   \
            --with-systemdsystemunitdir=no \
            --enable-python \
            --enable-gtk3   \
            --enable-gtk2 

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make LIBDIR=/usr/lib64 PREFIX=/usr
as_root make LIBDIR=/usr/lib64 PREFIX=/usr install

cd ${CLFSSOURCES}/bootscripts
as_root make install-avahi

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf avahi

cd ${CLFSSOURCES}
wget http://anduin.linuxfromscratch.org/BLFS/blfs-bootscripts/blfs-bootscripts-20170611.tar.xz -O \
    blfs-bootscripts-20170611.tar.xz
    
mkdir blfs-bootscripts && tar xf blfs-bootscripts-*.tar.* -C blfs-bootscripts --strip-components 1
cd blfs-bootscripts

as_root make install-avahi
cd ${CLFSSOURCES}/xc/mate

#GeoCLue
wget http://www.freedesktop.org/software/geoclue/releases/2.4/geoclue-2.4.7.tar.xz -O \
    geoclue-2.4.7.tar.xz

mkdir geoclue && tar xf geoclue-*.tar.* -C geoclue --strip-components 1
cd geoclue

CC="gcc ${BUILD64}" \
  CXX="g++ ${BUILD64}" USE_ARCH=64 \
  PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
  --sysconfdir=/etc --libdir=/usr/lib64 --disable-modem-gps-source \
  --disable-3g-source

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make LIBDIR=/usr/lib64 PREFIX=/usr
as_root make LIBDIR=/usr/lib64 PREFIX=/usr install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf geoclue

#Aspell
wget https://ftp.gnu.org/gnu/aspell/aspell-0.60.6.1.tar.gz -O \
    aspell-0.60.6.1.tar.gz

mkdir aspell && tar xf aspell-*.tar.* -C aspell --strip-components 1
cd aspell

sed -i '/ top.do_check ==/s/top.do_check/*&/' modules/filter/tex.cpp &&
sed -i '/word ==/s/word/*&/'                  prog/check_funs.cpp

CC="gcc ${BUILD64}" \
  CXX="g++ ${BUILD64}" USE_ARCH=64 \
  PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
  --libdir=/usr/lib64

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make LIBDIR=/usr/lib64 PREFIX=/usr
as_root make LIBDIR=/usr/lib64 PREFIX=/usr install

as_root ln -svfn aspell-0.60 /usr/lib64/aspell 
as_root install -v -m755 -d /usr/share/doc/aspell-0.60.6.1/aspell{,-dev}.html

as_root install -v -m644 manual/aspell.html/* \
    /usr/share/doc/aspell-0.60.6.1/aspell.html

as_root install -v -m644 manual/aspell-dev.html/* \
    /usr/share/doc/aspell-0.60.6.1/aspell-dev.html

as_root install -v -m 755 scripts/ispell /usr/bin/
as_root install -v -m 755 scripts/spell /usr/bin/

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf aspell

#enchant
wget http://www.abisource.com/downloads/enchant/1.6.0/enchant-1.6.0.tar.gz -O \
    enchant-1.6.0.tar.gz
    
mkdir enchant && tar xf enchant-*.tar.* -C enchant --strip-components 1
cd enchant

CC="gcc ${BUILD64}" \
  CXX="g++ ${BUILD64}" USE_ARCH=64 \
  PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
  --libdir=/usr/lib64

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make LIBDIR=/usr/lib64 PREFIX=/usr
as_root make LIBDIR=/usr/lib64 PREFIX=/usr install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf enchant

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
as_root make LIBDIR=/usr/lib64 PREFIX=/usr install

cd ${CLFSSOURCES}/xc/mate
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
as_root make LIBDIR=/usr/lib64 PREFIX=/usr install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf libwebp

#Ruby
wget http://cache.ruby-lang.org/pub/ruby/2.4/ruby-2.4.1.tar.xz -O \
    ruby-2.4.1.tar.xz 

mkdir ruby && tar xf ruby-*.tar.* -C ruby --strip-components 1
cd ruby

CC="gcc ${BUILD64}" \
  CXX="g++ ${BUILD64}" USE_ARCH=64 \
  PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
  --libdir=/usr/lib64 \
  --enable-shared \
  --docdir=/usr/share/doc/ruby-2.4.1
  
PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make LIBDIR=/usr/lib64 PREFIX=/usr
as_root make LIBDIR=/usr/lib64 PREFIX=/usr install 

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf ruby

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
as_root make LIBDIR=/usr/lib64 PREFIX=/usr install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf libnotify

#Hyphen
wget https://netix.dl.sourceforge.net/project/hunspell/Hyphen/2.8/hyphen-2.8.8.tar.gz -O \
    hyphen-2.8.8.tar.gz

mkdir hyphen && tar xf hyphen-*.tar.* -C hyphen --strip-components 1
cd hyphen

CC="gcc ${BUILD64}" \
  CXX="g++ ${BUILD64}" USE_ARCH=64 \
   PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
   --libdir=/usr/lib64 --disable-static 

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make LIBDIR=/usr/lib64 PREFIX=/usr
as_root make LIBDIR=/usr/lib64 PREFIX=/usr install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf hyphen

#WebKitGTK
wget http://webkitgtk.org/releases/webkitgtk-2.16.5.tar.xz -O \
    webkitgtk-2.16.5.tar.xz

mkdir webkitgtk && tar xf webkitgtk-*.tar.* -C webkitgtk --strip-components 1
cd webkitgtk

sed -i 's/unsigned short/char16_t/'            \
       Source/JavaScriptCore/API/JSStringRef.h \
       Source/WebKit2/Shared/API/c/WKString.h 

sed -i '/stdbool.h/ a#include <uchar.h>' \
       Source/JavaScriptCore/API/JSBase.h
       
mkdir -vp build
cd        build

LIBS_PATH=-L./usr/lib64 INC_PATH=-I./usr/include/ \
      LD_LIB_PATH=/usr/lib64 LD_LIBRARY_PATH=/usr/lib64 \
      CFLAGS=-Wno-expansion-to-defined  \
      CXXFLAGS=-Wno-expansion-to-defined \
      CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
      USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} \
      LIBRARY_PATH=/usr/lib64 cmake -DCMAKE_BUILD_TYPE=Release  \
      -DCMAKE_INSTALL_PREFIX=/usr \
      -DCMAKE_SKIP_RPATH=ON       \
      -DPORT=GTK                  \
      -DLIB_INSTALL_DIR=/usr/lib64  \
      -DUSE_LIBHYPHEN=ON         \
      -DENABLE_MINIBROWSER=ON     \
      -Wno-dev .. &&

LIBS_PATH=-L./usr/lib64 INC_PATH=-I./usr/include/ \
      LD_LIB_PATH=/usr/lib64 LD_LIBRARY_PATH=/usr/lib64 \
      CFLAGS=-Wno-expansion-to-defined  \
      CXXFLAGS=-Wno-expansion-to-defined \
      CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
      USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} \
      LIBRARY_PATH=/usr/lib64 cmake -DCMAKE_BUILD_TYPE=Release make PREFIX=/usr LIBDIR=/usr/lib64
      

LIBS_PATH=-L./usr/lib64 INC_PATH=-I./usr/include/ \
      LD_LIB_PATH=/usr/lib64 LD_LIBRARY_PATH=/usr/lib64 \
      CFLAGS=-Wno-expansion-to-defined  \
      CXXFLAGS=-Wno-expansion-to-defined \
      CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
      USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} \
      LIBRARY_PATH=/usr/lib64 cmake -DCMAKE_BUILD_TYPE=Release as_root make PREFIX=/usr LIBDIR=/usr/lib64 install
            
cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf webkitgtk

#yelp-xsl
wget http://ftp.gnome.org/pub/gnome/sources/yelp-xsl/3.20/yelp-xsl-3.20.1.tar.xz -O \
    yelp-xsl-3.20.1.tar.xz

mkdir yelp-xsl && tar xf yelp-xsl-*.tar.* -C yelp-xsl --strip-components 1
cd yelp-xsl

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure --prefix=/usr --libdir=/usr/lib64

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make LIBDIR=/usr/lib64 PREFIX=/usr
as_root make LIBDIR=/usr/lib64 PREFIX=/usr install


as_root install -vdm755 /usr/share/gtk-doc/html/webkit{2,dom}gtk-4.0 &&
as_root install -vm644  ../Documentation/webkit2gtk-4.0/html/*   \
                /usr/share/gtk-doc/html/webkit2gtk-4.0       &&
as_root install -vm644  ../Documentation/webkitdomgtk-4.0/html/* \
                /usr/share/gtk-doc/html/webkitdomgtk-4.0

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf yelp-xsl

#Yelp
wget ftp://ftp.gnome.org/pub/gnome/sources/yelp/3.22/yelp-3.22.0.tar.xz -O \
    Yelp-3.22.0.tar.xz

mkdir yelp && tar xf Yelp-*.tar.* -C yelp --strip-components 1
cd yelp

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure --prefix=/usr \
  --libdir=/usr/lib64 \
  --disable-static \
  --disable-gtk-doc

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make LIBDIR=/usr/lib64 PREFIX=/usr
as_root make LIBDIR=/usr/lib64 PREFIX=/usr install
as_root update-desktop-database
as_root libtool --finish /usr/lib64/yelp/web-extensions
as_root libtool --finish /usr/lib64/
ldconfig

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf yelp

#yelp-tools
wget https://github.com/GNOME/yelp-tools/archive/3.18.0.tar.gz -O \
    yelp-tools-3.18.0.tar.gz

mkdir yelp-tools && tar xf yelp-tools-*.tar.* -C yelp-tools --strip-components 1
cd yelp-tools

ACLOCAL_FLAG=/usr/share/aclocal/ CC="gcc ${BUILD64}" \
  CXX="g++ ${BUILD64}" USE_ARCH=64 \
   PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} sh autogen.sh --prefix=/usr \
   --libdir=/usr/lib64 --sysconfdir=/etc \
   --localstatedir=/var --bindir=/usr/bin --sbindir=/usr/sbin 

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make LIBDIR=/usr/lib64 PREFIX=/usr
as_root make LIBDIR=/usr/lib64 PREFIX=/usr install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf yelp

#mate-panel
wget https://github.com/mate-desktop/mate-panel/archive/v1.19.2.tar.gz -O \
    mate-panel-1.19.2.tar.gz
    
mkdir mate-panel && tar xf mate-panel-*.tar.* -C mate-panel --strip-components 1
cd mate-panel

LIBSOUP_LIBS=/usr/lib64 \
  ACLOCAL_FLAG=/usr/share/aclocal/ CC="gcc ${BUILD64}" \
  CXX="g++ ${BUILD64}" USE_ARCH=64 \
   PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} sh autogen.sh --prefix=/usr \
   --libdir=/usr/lib64 --sysconfdir=/etc \
   --localstatedir=/var --bindir=/usr/bin --sbindir=/usr/sbin 
   
PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make LIBDIR=/usr/lib64 PREFIX=/usr
as_root make LIBDIR=/usr/lib64 PREFIX=/usr install
  
cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf mate-panel
