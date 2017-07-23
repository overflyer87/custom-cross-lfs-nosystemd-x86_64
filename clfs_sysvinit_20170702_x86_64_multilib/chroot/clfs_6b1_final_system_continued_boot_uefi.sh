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

#Install packages needed for UEFI-Boot if we had a
#System without any bootloader installed at all
#I choose goofiboot a fork of gummiboot

#Mount efi boot partition
echo ""
echo "Let's check if your efivars are mounted or not"
ls /sys/firmware/efi

#checkBuiltPackage

echo ""
echo "Alright let's mount the boot partition /dev/sda1 to /boot/efi"
mkdir -pv /boot/efi
mount -vt vfat /dev/sda1 /boot/efi

#checkBuiltPackage

cd ${CLFSSOURCES}

#===================================================
#All our kernel files later need to go to /boot/efi
#===================================================
#Useful manuals that show how to do UEFI-Boot
#and how to configure the Kernel
#http://www.linuxfromscratch.org/~krejzi/basic-kernel.txt 
#http://www.linuxfromscratch.org/hints/downloads/files/lfs-uefi-20170207.txt
#===================================================


#libpng 32-bit
mkdir libpng && tar xf libpng-*.tar.* -C libpng --strip-components 1
cd libpng

gzip -cd ../libpng-1.6.29-apng.patch.gz | patch -p0

PKG_CONFIG_PATH="${PKG_CONFIG_PATH32}" \
USE_ARCH=32 \
LIBS=-lpthread CC="gcc ${BUILD32}" ./configure \
--prefix=/usr \
--disable-static \
--libdir=/usr/lib

PREFIX=/usr LIBDIR=/usr/lib make
PREFIX=/usr LIBDIR=/usr/lib make install

mv -v /usr/bin/libpng12-config{,-32} 
ln -sfv libpng12-config-32 /usr/bin/libpng-config-32
ln -sfv multiarch_wrapper /usr/bin/libpng12-config 
ln -sfv multiarch_wrapper /usr/bin/libpng-config

cd ${CLFSSOURCES} 
#checkBuiltPackage
rm -rf libpng

#libpng 64-bit
mkdir libpng && tar xf libpng-*.tar.* -C libpng --strip-components 1
cd libpng

gzip -cd ../libpng-1.6.29-apng.patch.gz | patch -p0

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
USE_ARCH=64 \
LIBS=-lpthread CC="gcc ${BUILD64}" ./configure \
--prefix=/usr \
--disable-static \
--libdir=/usr/lib64 &&

PREFIX=/usr LIBDIR=/usr/lib64 make
PREFIX=/usr LIBDIR=/usr/lib64 make install

mv -v /usr/bin/libpng12-config{,-64}
ln -sfv libpng12-config-64 /usr/bin/libpng-config-64
ln -sfv multiarch_wrapper /usr/bin/libpng-config
ln -sfv multiarch_wrapper /usr/bin/libpng12-config
mkdir -v /usr/share/doc/libpng-1.6.29 
cp -v README libpng-manual.txt /usr/share/doc/libpng-1.6.29

cd ${CLFSSOURCES} 
#checkBuiltPackage
rm -rf libpng

#which
mkdir which && tar xf which-*.tar.* -C which --strip-components 1
cd which

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
USE_ARCH=64 \
CC="gcc ${BUILD64}" ./configure --prefix=/usr  \
    libdir=/usr/lib64

PREFIX=/usr LIBDIR=/usr/lib64 make
PREFIX=/usr LIBDIR=/usr/lib64 make install

cd ${CLFSSOURCES} 
#checkBuiltPackage
rm -rf which

#freeype 32-bit
mkdir freetype && tar xf freetype-*.tar.* -C freetype --strip-components 1
cd freetype

sed -ri "s:.*(AUX_MODULES.*valid):\1:" modules.cfg

sed -r "s:.*(#.*SUBPIXEL_RENDERING) .*:\1:" \
    -i include/freetype/config/ftoption.h 

sed -i -r 's:.*(#.*BYTE.*) .*:\1:' include/freetype/config/ftoption.h

PKG_CONFIG_PATH="${PKG_CONFIG_PATH32}" \
USE_ARCH=32 \
CC="gcc ${BUILD32}" ./configure \
--prefix=/usr \
--disable-static \
--libdir=/usr/lib

PREFIX=/usr LIBDIR=/usr/lib make
PREFIX=/usr LIBDIR=/usr/lib make install

mv -v /usr/bin/freetype-config{,-32}

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
PREFIX=/usr LIBDIR=/usr/lib64 make install
mv -v /usr/bin/freetype-config{,-64}
ln -sf multiarch_wrapper /usr/bin/freetype-config
install -v -m755 -d /usr/share/doc/freetype-2.4.12
cp -v -R docs/* /usr/share/doc/freetype-2.4.12

install -v -m755 -d /usr/share/doc/freetype-2.8
cp -v -R docs/*     /usr/share/doc/freetype-2.8


cd ${CLFSSOURCES} 
#checkBuiltPackage
rm -rf freetype

#harfbuzz 32-bit
mkdir harfbuzz && tar xf harfbuzz-*.tar.* -C harfbuzz --strip-components 1
cd harfbuzz

LIBDIR=/usr/lib USE_ARCH=32 PKG_CONFIG_PATH="${PKG_CONFIG_PATH32}" \
CXX="g++ ${BUILD32}" CC="gcc ${BUILD32}" \
./configure --prefix=/usr --libdir=/usr/lib
PREFIX=/usr LIBDIR=/usr/lib make 
PREFIX=/usr LIBDIR=/usr/lib make install

cd ${CLFSSOURCES} 
#checkBuiltPackage
rm -rf harfbuzz

#harfbuzz 64-bit
mkdir harfbuzz && tar xf harfbuzz-*.tar.* -C harfbuzz --strip-components 1
cd harfbuzz

LIBDIR=/usr/lib64 USE_ARCH=64 PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
CXX="g++ ${BUILD64}" CC="gcc ${BUILD64}" \
./configure --prefix=/usr --libdir=/usr/lib64
PREFIX=/usr LIBDIR=/usr/lib64 make 
PREFIX=/usr LIBDIR=/usr/lib64 make install

cd ${CLFSSOURCES} 
#checkBuiltPackage
rm -rf harfbuzz

#freeype 32-bit
mkdir freetype && tar xf freetype-*.tar.* -C freetype --strip-components 1
cd freetype

sed -ri "s:.*(AUX_MODULES.*valid):\1:" modules.cfg

sed -r "s:.*(#.*SUBPIXEL_RENDERING) .*:\1:" \
    -i include/freetype/config/ftoption.h 

sed -i -r 's:.*(#.*BYTE.*) .*:\1:' include/freetype/config/ftoption.h

PKG_CONFIG_PATH="${PKG_CONFIG_PATH32}" \
USE_ARCH=32 \
CC="gcc ${BUILD32}" ./configure \
--prefix=/usr \
--disable-static \
--libdir=/usr/lib

PREFIX=/usr LIBDIR=/usr/lib make
PREFIX=/usr LIBDIR=/usr/lib make install
mv -v /usr/bin/freetype-config{,-32}


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
PREFIX=/usr LIBDIR=/usr/lib64 make install

mv -v /usr/bin/freetype-config{,-64}
ln -sf multiarch_wrapper /usr/bin/freetype-config
install -v -m755 -d /usr/share/doc/freetype-2.4.12
cp -v -R docs/* /usr/share/doc/freetype-2.4.12

install -v -m755 -d /usr/share/doc/freetype-2.8
cp -v -R docs/*     /usr/share/doc/freetype-2.8

cd ${CLFSSOURCES} 
#checkBuiltPackage
rm -rf freetype

#popt 64-bit
mkdir popt && tar xf popt-*.tar.* -C popt --strip-components 1
cd popt

USE_ARCH=64 CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
    PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
    ./configure --prefix=/usr \
    --libdir=/usr/lib64 &&
PREFIX=/usr usrlibdir=/usr/lib6 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} make

sed -i "s@\(^libdir='\).*@\1/usr/lib64'@g" libpopt.la
sed -i "s@\(^libdir='\).*@\1/usr/lib64'@g" .libs/libpopt.lai
make usrlibdir=/usr/lib64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} install

mv popt.pc /usr/lib64/pkgconfig

cd ${CLFSSOURCES} 
#checkBuiltPackage
rm -rf popt


#popt 32-bit
mkdir popt && tar xf popt-*.tar.* -C popt --strip-components 1
cd popt

USE_ARCH=32 CC="gcc ${BUILD32}" CXX="g++ ${BUILD32}" \
    PKG_CONFIG_PATH="${PKG_CONFIG_PATH32}" \
    ./configure --prefix=/usr --libdir=/usr/lib &&
make

sed -i "s@\(^libdir='\).*@\1/usr/lib'@g" libpopt.la &&
sed -i "s@\(^libdir='\).*@\1/usr/lib'@g" .libs/libpopt.lai &&
make usrlibdir=/usr/lib install

mv popt.pc /usr/lib/pkgconfig

cd ${CLFSSOURCES} 
#checkBuiltPackage
rm -rf popt

#dosfstools
mkdir dosfstools && tar xf dosfstools-*.tar.* -C dosfstools --strip-components 1
cd dosfstools

CC="gcc ${BUILD64}" PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} \
USE_ARCH=64 \
./configure --prefix=/usr --libdir=/usr/lib64 \
    --sbindir=/usr/bin \
    --mandir=/usr/share/man \
    --docdir=/usr/share/doc

PREFIX=/usr LIBDIR=/usr/lib64 SBINDIR=/usr/bin MANDIR=/usr/share/man \
DOCDIR=/usr/share/doc make
PREFIX=/usr LIBDIR=/usr/lib64 SBINDIR=/usr/bin MANDIR=/usr/share/man \
DOCDIR=/usr/share/doc make install


cd ${CLFSSOURCES} 
#checkBuiltPackage
rm -rf dosfstools

PKG_CONFIG_PATH=""

#efivar
mkdir efivar && tar xf efivar-*.tar.* -C efivar --strip-components 1
cd efivar

export PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}"
PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}"
cp -p Make.defaults Make.defaults.dist
sed 's|-02|-0s|g' -i Make.defaults
cp src/test/Makefile src/test/Makefile.dist
sed 's|-rpath=$(TOPDIR)/src/|-rpath=$(libdir|g)' -i src/test/Makefile
PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}"
make LIBDIR=/usr/lib64 bindir=/usr/bin mandir=/usr/share/man \
    includedir=/usr/include V=1 -j1
make LIBDIR=/usr/lib64 bindir=/usr/bin mandir=/usr/share/man \
    includedir=/usr/include V=1 -j1 DESTDIR="${pkgdir}/" install
cd src/test
make tester
install -v -D -m0755 tester /usr/bin/efivar-tester

cd ${CLFSSOURCES} 
#checkBuiltPackage
rm -rf efivar

#efibootmgr
mkdir efibootmgr && tar xf efibootmgr-*.tar.* -C efibootmgr --strip-components 1
cd efibootmgr

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" EFIDIR=/boot/efi \
make USE_ARCH=64 LIBDIR=/usr/lib64 \
    bindir=/usr/bin mandir=/usr/share/man \
    CC="gcc ${BUILD64}" CXX="g++"${BUILD64} \
    includedir=/usr/include

install -v -D -m0755 src/efibootmgr /usr/sbin/efibootmgr
install -v -D -m0644 src/efibootmgr.8 \
    /usr/share/man/man8/efibootmgr.8
install -v -D -m0644 src/efibootdump.8 \
    /usr/share/man/man8/efibootdump.8


cd ${CLFSSOURCES} 
#checkBuiltPackage
rm -rf efibootmgr

#gnu-efi
mkdir gnuefi && tar xf gnu-efi-*.tar.* -C gnuefi --strip-components 1
cd gnuefi

sed -i "s#-Werror##g" Make.defaults
ARCH=x86_64 make PREFIX=/usr LIBDIR=/usr/lib64
ARCH=x86_64 make PREFIX=/usr LIBDIR=/usr/lib64 install


cd ${CLFSSOURCES} 
#checkBuiltPackage
rm -rf gnuefi

#unicode font

mkdir -pv /usr/share/fonts/unifont
gunzip -c ${CLFSSOURCES}/unifont-9.0.06.pcf.gz > \
    /usr/share/fonts/unifont/unifont.pcf

cd ${CLFSSOURCES}

#goofiboot
mkdir goofiboot && tar xf goofiboot-*.tar.* -C goofiboot --strip-components 1
cd goofiboot

sh autogen.sh
PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
USE_ARCH=64 CC="gcc ${BUILD64}" \
CXX="g++ ${BUILD64}"  \
./configure --prefix=/usr \
    --libdir=/usr/lib64 \
    --includedir=/usr/include \
    --sbindir=/usr/bin

sed -i ':a;$!{N;ba};s/.*#include[^\n]*/&\n#include <sys\/sysmacros.h>/' \
    src/setup/setup.c

PREFIX=/usr LIBDIR=/usr/lib64 make
PREFIX=/usr LIBDIR=/usr/lib64 make install
goofiboot --path=/boot/efi install 

fs_uuid=$(blkid -o value -s PARTUUID /dev/sda4)

cat > /boot/efi/loader/entries/clfs-uefi.conf << "EOF"
title   Cross Linux from Scratch
linux   /vmlinuz-clfs-4.12.3
initrd  /intel-ucode.img
EOF

cd /boot/efi/loader/entries/
echo options root=PARTUUID=`echo $fs_uuid` rw >> clfs-uefi.conf

cd ${CLFSSOURCES} 
#checkBuiltPackage
rm -rf goofiboot

#Exiting....
#Next script will: Strip Debugging symbols

echo " "
echo "UEFI bootloader goofiboot has been installed.."
echo "Exit, chroot back in with Script #7"
echo "Execute Script #8 to strip debugging symbols"
echo "IF YOU WANT TO. IT IS OPTIONAL!"
echo "Otherwise skip Script #8 after you chrooted back in"
echo "and execute Script #9 instead"
echo " "

exit
exit
exit
