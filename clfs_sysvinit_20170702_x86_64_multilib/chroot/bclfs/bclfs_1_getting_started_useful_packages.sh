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
export MAKEFLAGS="-j$(nproc)"
export BUILD32="-m32"
export BUILD64="-m64"
export CLFS_TARGET32="i686-pc-linux-gnu"
export PKG_CONFIG_PATH32=/usr/lib/pkgconfig
export PKG_CONFIG_PATH64=/usr/lib64/pkgconfig

#=================
#YOUR SYSTEM STANDS AND BOOTS UP?
#NOW THEN, let's install some useful packages
#to make further progress easier
#=================

cd ${CLFSSOURCES}

#OpenSSL 32-bit
mkdir openssl && tar xf openssl-*.tar.* -C openssl --strip-components 1
cd openssl

PKG_CONFIG_PATH=${PKG_CONFIG_PATH32} USE_ARCH=32 make CC="gcc ${BUILD32}" 

./Configure linux-x86 \
  --openssldir=/etc/ssl \
  --prefix=/usr \
  --libdir=/lib \
  shared \
  zlib-dynamic
  
PKG_CONFIG_PATH=${PKG_CONFIG_PATH32} \
USE_ARCH=32 make CC="gcc ${BUILD32}" PREFIX=/usr LIBDIR=/lib

sed -i 's# libcrypto.a##;s# libssl.a##;/INSTALL_LIBS/s#libcrypto.a##' Makefile

make PREFIX=/usr LIBDIR=/lib install

cd ${CLFSSOURCES}
checkBuiltPackage
rm -rf openssl

#OpenSSL 64-bit
mkdir openssl && tar xf openssl-*.tar.* -C openssl --strip-components 1
cd openssl

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} USE_ARCH=64 make CC="gcc ${BUILD64}" 

./Configure linux-x86_64 \
  --openssldir=/etc/ssl \
  --prefix=/usr \
  --libdir=/lib64 \
  shared \
  zlib-dynamic
  
PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} \
USE_ARCH=64 make PREFIX=/usr LIBDIR=/lib64 CC="gcc ${BUILD64}" 

sed -i 's# libcrypto.a##;s# libssl.a##;/INSTALL_LIBS/s#libcrypto.a##' Makefile

make PREFIX=/usr LIBDIR=/lib64 install 

cd ${CLFSSOURCES}
checkBuiltPackage
rm -rf openssl

#Install CA Certificates
cd ${CLFSSOURCES}

install -vdm755 /etc/ssl/local &&
openssl x509 -in root.crt -text -fingerprint -setalias "CAcert Class 1 root" \
        -addtrust serverAuth -addtrust emailProtection -addtrust codeSigning \
        > /etc/ssl/local/CAcert_Class_1_root.pem
install -vm755 make-ca.sh-20170514 /usr/sbin/make-ca.sh
/usr/sbin/make-ca.sh

#Wget
mkdir wget && tar xf wget-*.tar.* -C wget --strip-components 1
cd wget 

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
CC="gcc ${BUILD64}" ./configure --prefix=/usr \
  --sysconfdir=/etc \
  --libdir=/usr/lib64 \
  --with-ssl=openssl

PREFIX=/usr LIBDIR=/usr/lib64 make
PREFIX=/usr LIBDIR=/usr/lib64 make install

cd ${CLFSSOURCES}
checkBuiltPackage
rm -rf wget

#Curl
wget https://curl.haxx.se/download/curl-7.54.1.tar.lzma -O \
  curl-7.54.1.tar.lzma
  
mkdir curl && tar xf curl-*.tar.* -C curl --strip-components 1
cd curl

CC="gcc ${BUILD64}" USE_ARCH=64 PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" 

  ./configure --prefix=/usr \
  --libdir=/usr/lib64 \
  --disable-static \
  --enable-threaded-resolver \
  --with-ca-path=/etc/ssl/certs \
  --with-ca-bundle=/etc/ssl/ca-bundle.crt

PREFIX=/usr LIBDIR=/usr/lib64 make
PREFIX=/usr LIBDIR=/usr/lib64 make install

find docs \( -name Makefile\* \
          -o -name \*.1       \
          -o -name \*.3 \)    \
          -exec rm {} \;      &&
install -v -d -m755 /usr/share/doc/curl-7.54.1 &&
cp -v -R docs/*     /usr/share/doc/curl-7.54.1

cd ${CLFSSOURCES}
checkBuiltPackage
rm -rf curl

#Git
wget https://www.kernel.org/pub/software/scm/git/git-2.13.3.tar.xz -O \
  git-2.13.3.tar.xz
  
mkdir git && tar xf git-*.tar.* -C git --strip-components 1
cd git

USE_ARCH=64 PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
CC="gcc ${BUILD64}" ./configure --prefix=/usr \
   --libexecdir=/usr/lib64 \
   --sysconfdir=/etc  \
   --with-gitconfig=/etc/gitconfig

PREFIX=/usr LIBDIR=/usr/lib64 make
PREFIX=/usr LIBDIR=/usr/lib64 make install

cd ${CLFSSOURCES}
checkBuiltPackage
rm -rf git

#openSSH
mkdir openssh && tar xf openssh-7.5p1.tar.gz -C openssh --strip-components 1
cd openssh

install  -v -m700 -d /var/lib/sshd &&
chown    -v root:sys /var/lib/sshd &&

groupadd -g 50 sshd        &&
useradd  -c 'sshd PrivSep' \
         -d /var/lib/sshd  \
         -g sshd           \
         -s /bin/false     \
         -u 50 sshd

patch -Np1 -i ../openssh-7.5p1-openssl-1.1.0-1.patch &&

CC="gcc ${BUILD64}" USE_ARCH=64 PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
CXX="g++ ${BUILD64}" 

./configure --prefix=/usr                     \
            --sysconfdir=/etc/ssh             \
            --libdir=/usr/lib64               \
            --with-md5-passwords              \
            --with-privsep-path=/var/lib/sshd &&

PREFIX=/usr LIBDIR=/usr/lib64 make
PREFIX=/usr LIBDIR=/usr/lib64 make install

install -v -m755    contrib/ssh-copy-id /usr/bin     &&

install -v -m644    contrib/ssh-copy-id.1 \
                    /usr/share/man/man1              &&
install -v -m755 -d /usr/share/doc/openssh-7.5p1     &&
install -v -m644    INSTALL LICENCE OVERVIEW README* \
                    /usr/share/doc/openssh-7.5p1
                    
cd ${CLFSSOURCES}/bootscripts

echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
make install-sshd
/etc/rc.d/init.d/sshd start

cd ${CLFSSOURCES}
checkBuiltPackage
rm -rf openssh

#gptfdisk
wget http://downloads.sourceforge.net/project/gptfdisk/gptfdisk/1.0.1/gptfdisk-1.0.1.tar.gz -O \
  gptfdisk-1.0.1.tar.gz

wget http://www.linuxfromscratch.org/patches/blfs/svn/gptfdisk-1.0.1-convenience-1.patch -O \
  GPTfdisk-1.0.1-convenience-1.patch 

mkdir gptfdisk && tar xf gptfdisk-*.tar.* -C gptfdisk --strip-components 1
cd gptfdisk

patch -Np1 -i ../GPTfdisk-1.0.1-convenience-1.patch
make PREFIX=/usr LIBDIR=/usr/lib64 POPT=1
make PREFIX=/usr LIBDIR=/usr/lib64 POPT=1 install

cd ${CLFSSOURCES}
checkBuiltPackage
rm -rf gptfdisk

#Lynx
wget http://invisible-mirror.net/archives/lynx/tarballs/lynx2.8.8rel.2.tar.bz2 -O \
  lynx2.8.8rel.2.tar.bz2

wget http://www.linuxfromscratch.org/patches/blfs/svn/lynx-2.8.8rel.2-openssl_1.1.0-1.patch -O \
  lynx-2.8.8rel.2-openssl_1.1.0-1.patch
  
mkdir lynx && tar xf lynx*.tar.* -C lynx --strip-components 1
cd lynx

patch -p1 -i ../lynx-2.8.8rel.2-openssl_1.1.0-1.patch

./configure --prefix=/usr          \
            --sysconfdir=/etc/lynx \
            --libdir=/usr/lib64    \
            --datadir=/usr/share/doc/lynx-2.8.8rel.2 \
            --with-zlib            \
            --with-bzlib           \
            --with-ssl             \
            --with-screen=ncursesw \
            --enable-locale-charset &&
            
PREFIX=/usr LIBDIR=/usr/lib64 make
PREFIX=/usr LIBDIR=/usr/lib64 make install-full
chgrp -v -R root /usr/share/doc/lynx-2.8.8rel.2/lynx_doc

sed -e '/#LOCALE/     a LOCALE_CHARSET:TRUE'     \
    -i /etc/lynx/lynx.cfg

sed -e '/#DEFAULT_ED/ a DEFAULT_EDITOR:vi'       \
    -i /etc/lynx/lynx.cfg

sed -e '/#PERSIST/    a PERSISTENT_COOKIES:TRUE' \
    -i /etc/lynx/lynx.cfg


cd ${CLFSSOURCES}
checkBuiltPackage
rm -rf lynx
