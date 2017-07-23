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
MAKEFLAGS=j8
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

#Cracklib 64-bit
mkdir cracklib && tar xf cracklib-*.tar.* -C cracklib --strip-components 1
cd cracklib

sed -i '/skipping/d' util/packer.c

CC="gcc ${BUILD64}" USE_ARCH=64 ./configure --prefix=/usr \
  --libdir=/usr/lib64 --disable-static --with-default-dict=/lib/cracklib/pw_dict &&
sed -i 's@prefix}/lib@&64@g' dicts/Makefile doc/Makefile lib/Makefile \
     m4/Makefile Makefile python/Makefile util/Makefile &&
     
make PREFIX=/usr LIBDIR=/usr/lib64

mv -v /usr/lib64/libcrack.so.* /lib64
ln -sfv ../../lib64/$(readlink /usr/lib64/libcrack.so) /usr/lib64/libcrack.so

install -v -m644 -D    ../cracklib-words-2.9.6.gz \
                         /usr/share/dict/cracklib-words.gz     &&

gunzip -v                /usr/share/dict/cracklib-words.gz     &&
ln -v -sf cracklib-words /usr/share/dict/words                 &&
echo $(hostname) >>      /usr/share/dict/cracklib-extra-words  &&
install -v -m755 -d      /lib64/cracklib                         &&

create-cracklib-dict     /usr/share/dict/cracklib-words \
                         /usr/share/dict/cracklib-extra-words
                         
make test

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf cracklib

#Linux-PAM 64-bit
mkdir linuxpam && tar xf Linux-PAM-1.3.0.tar.* -C linuxpam --strip-components 1
cd linuxpam

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf linuxpam

#Shadow
mkdir shadow && tar xf shadow-*.tar.* -C shadow --strip-components 1
cd shadow

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf shadow

#Sudo
mkdir sudo && tar xf sudo-*.tar.* -C sudo --strip-components 1
cd sudo 

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf sudo 

