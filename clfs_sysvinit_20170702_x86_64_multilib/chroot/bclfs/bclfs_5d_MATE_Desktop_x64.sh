
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

#libgtop 
wget http://ftp.gnome.org/pub/gnome/sources/libgtop/2.36/libgtop-2.36.0.tar.xz -O \
    libgtop-2.36.0.tar.xz

mkdir libgtop && tar xf libgtop-*.tar.* -C libgtop --strip-components 1
cd libgtop

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" USE_ARCH=64 \
PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
    --disable-static \
    --libdir=/usr/lib64
    
make PREFIX=/usr LIBDIR=/usr/lib64
as_root make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}
checkBuiltPackage
rm -rf libgtop

#mate-utils
wget https://github.com/mate-desktop/mate-utils/archive/v1.18.2.tar.gz -O \
    mate-utils-1.18.2.tar.gz    
    
mkdir mateutils && tar xf mate-utils-*.tar.* -C mateutils --strip-components 1
cd mateutils

cp -rv /usr/share/aclocal/*.m4 m4/

CPPFLAGS="-I/usr/include" LDFLAGS="-L/usr/lib64"  \
PYTHON="/usr/bin/python2" PYTHONPATH="/usr/lib64/python2.7" \
PYTHONHOME="/usr/lib64/python2.7" PYTHON_INCLUDES="/usr/include/python2.7" \
ACLOCAL_FLAG="/usr/share/aclocal/" LIBSOUP_LIBS=/usr/lib64   \
ACLOCAL_FLAG=/usr/share/aclocal/ CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} sh autogen.sh --prefix=/usr\
    --libdir=/usr/lib64 \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin --disable-gtk-doc &&
    
#Deactivate building of baobab because it will fail
#Because itstool will throw error
#Babobab can show size of directory trees in percentage
#Let's see later if this tool was essential...hope not
sed -i 's/baobab/#baobab' Makefile*
   
PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make LIBDIR=/usr/lib64 PREFIX=/usr
as_root make LIBDIR=/usr/lib64 PREFIX=/usr install

cd ${CLFSSOURCES}
checkBuiltPackage
rm -rf mateutils

#PCRE2
wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre2-10.23.tar.bz2 -O \
    pcre2-10.23.tar.bz2

mkdir pcre2 && tar xf pcre2-*.tar.* -C pcre2 --strip-components 1
cd pcre2


CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" USE_ARCH=64 \
PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
     --docdir=/usr/share/doc/pcre2-10.23 \
            --enable-unicode                    \
            --enable-pcre2-16                   \
            --enable-pcre2-32                   \
            --enable-pcre2grep-libz             \
            --enable-pcre2grep-libbz2           \
            --enable-pcre2test-libreadline      \
            --disable-static  \
            --libdir=/usr/lib64 &&
            
PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make LIBDIR=/usr/lib64 PREFIX=/usr
as_root make LIBDIR=/usr/lib64 PREFIX=/usr install
     
cd ${CLFSSOURCES}
checkBuiltPackage
rm -rf pcre2

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
as_root make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}
checkBuiltPackage
rm -rf vte

#mate-terminal
wget https://github.com/mate-desktop/mate-terminal/archive/v1.18.1.tar.gz -O \
    mate-terminal-1.18.1.tar.gz
    
mkdir mateterm && tar xf mate-terminal-*.tar.* -C mateterm --strip-components 1
cd mateterm

cp -rv /usr/share/aclocal/*.m4 m4/

CPPFLAGS="-I/usr/include" LDFLAGS="-L/usr/lib64"  \
PYTHON="/usr/bin/python2" PYTHONPATH="/usr/lib64/python2.7" \
PYTHONHOME="/usr/lib64/python2.7" PYTHON_INCLUDES="/usr/include/python2.7" \
ACLOCAL_FLAG="/usr/share/aclocal/" LIBSOUP_LIBS=/usr/lib64   \
ACLOCAL_FLAG=/usr/share/aclocal/ CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} sh autogen.sh --prefix=/usr\
    --libdir=/usr/lib64 \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin --disable-gtk-doc &&

sed -i 's/HELP_DIR/#HELP_DIR/' Makefile Makefile.in
sed -i 's/help/#help/' Makefile Makefile.in Makefile.am
  
PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make LIBDIR=/usr/lib64 PREFIX=/usr
as_root make LIBDIR=/usr/lib64 PREFIX=/usr install

cd ${CLFSSOURCES}
checkBuiltPackage
rm -rf mateterm

#iso-codes
wget https://pkg-isocodes.alioth.debian.org/downloads/iso-codes-3.75.tar.xz
    iso-codes-3.75.tar.xz

mkdir iso-codes && tar xf iso-codes-*.tar.* -C iso-codes --strip-components 1
cd iso-codes

sed -i '/^LN_S/s/s/sfvn/' */Makefile

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" USE_ARCH=64 \
PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr --libdir=/usr/lib64

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make LIBDIR=/usr/lib64 PREFIX=/usr
as_root make LIBDIR=/usr/lib64 PREFIX=/usr install

cd ${CLFSSOURCES}
checkBuiltPackage
rm -rf iso-codes

#libxklavier
wget http://pkgs.fedoraproject.org/repo/pkgs/libxklavier/libxklavier-5.4.tar.bz2/13af74dcb6011ecedf1e3ed122bd31fa/libxklavier-5.4.tar.bz2 -O \
    libxklavier-5.4.tar.bz2

mkdir libxklavier && tar xf libxklavier-*.tar.* -C libxklavier --strip-components 1
cd libxklavier
    
CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" USE_ARCH=64 \
PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr --libdir=/usr/lib64 \
    --disable-static

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make LIBDIR=/usr/lib64 PREFIX=/usr
as_root make LIBDIR=/usr/lib64 PREFIX=/usr install

cd ${CLFSSOURCES}
checkBuiltPackage
rm -rf libxklavier

#libmatekbd
wget https://github.com/mate-desktop/libmatekbd/archive/v1.18.2.tar.gz -O \
    libmatekbd-1.18.2.tar.gz

mkdir libmatekbd && tar xf libmatekbd-*.tar.* -C libmatekbd --strip-components 1
cd libmatekbd

cp -rv /usr/share/aclocal/*.m4 m4/

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} sh autogen.sh --prefix=/usr\
    --libdir=/usr/lib64 \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin --disable-gtk-doc \
    --disable-static --enable-shared &&

sed -i 's/HELP_DIR/#HELP_DIR/' Makefile Makefile.in
sed -i 's/help/#help/' Makefile Makefile.in Makefile.am
  
PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make LIBDIR=/usr/lib64 PREFIX=/usr
as_root make LIBDIR=/usr/lib64 PREFIX=/usr install


cd ${CLFSSOURCES}
checkBuiltPackage
rm -rf libxklavier

