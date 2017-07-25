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
mkdir gnomekeyring && tar xf gnome-keyring-*.tar.* -C gnome-keyring --strip-components
cd gnome-keyring

wget http://ftp.gnome.org/pub/gnome/sources/gnome-keyring/3.20/gnome-keyring-3.20.1.tar.xz
    gnome-keyring-3.20.1.tar.xz
    
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
rm -rf gnomekeyring

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
   --datadir=/usr/share/doc --disable-docbook-docs

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
as_root cp libsoup-2.4.pc ${PKG_CONFIG_PATH64}

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf libsoup

#libmateweather
wget https://github.com/mate-desktop/libmateweather/archive/v1.19.1.tar.gz -O \
    libmateweather-v1.19.1.tar.gz

mkdir libmateweather && tar xf libmateweather-*.tar.* -C libmateweather --strip-components 1
cd libmateweather

 LIBSOUP_LIBS=/usr/lib64 \
  ACLOCAL_FLAG=/usr/share/aclocal/ CC="gcc ${BUILD64}" \
  CXX="g++ ${BUILD64}" USE_ARCH=64 \
   PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} sh autogen.sh --prefix=/usr \
   --libdir=/usr/lib64 --sysconfdir=/etc --disable-static \
   --localstatedir=/var --bindir=/usr/bin --sbindir=/usr/sbin \
   --datadir=/usr/share/doc --disable-docbook-docs

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make LIBDIR=/usr/lib64 PREFIX=/usr
as_root make LIBDIR=/usr/lib64 PREFIX=/usr install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf libmateweather

#libwnk
wget https://github.com/GNOME/libwnck/archive/3.24.0.tar.gz -O \
    libwnck-3.24.0.tar.gz

mkdir libwnck && tar xf libwnck-*.tar.* -C libwnck --strip-components 1
cd libwnck

CC="gcc ${BUILD64}" \
  CXX="g++ ${BUILD64}" USE_ARCH=64 \
   PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
   --libdir=/usr/lib64 --disable-static 

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make LIBDIR=/usr/lib64 PREFIX=/usr
as_root make LIBDIR=/usr/lib64 PREFIX=/usr install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf libwnck
