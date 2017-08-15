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

#gtksourceview3
wget http://ftp.gnome.org/pub/gnome/sources/gtksourceview/3.24/gtksourceview-3.24.3.tar.xz -O \
    gtksourceview-3.24.3.tar.xz

mkdir gtksourceview && tar xf gtksourceview-*.tar.* -C gtksourceview --strip-components 1
cd gtksourceview

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr\
    --libdir=/usr/lib64 \
	--disable-gtk-doc
    
PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf gtksourceview

#PyGObject
wget http://ftp.gnome.org/pub/gnome/sources/pygobject/3.24/pygobject-3.24.1.tar.xz -O \
		pygobject-3.24.1.tar.xz

mkdir pygobject && tar xf pygobject-*.tar.* -C pygobject --strip-components 1
cd pygobject

mkdir python2 
pushd python2 
CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ../configure --prefix=/usr \
	--with-python=/usr/bin/python2-64 \
	--libdir=/usr/lib64 

sed -i 's/lib6464/lib64/' Makefile
sudo make install

make 
popd

mkdir python3 
pushd python3 
CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ../configure --prefix=/usr \
	--with-python=/usr/bin/python3.6 \
	--libdir=/usr/lib64

sed -i 's/lib6464/lib64/' Makefile
sudo make install
sudo cp /usr/lib/python2.7 /usr/lib64/
sudo rm -rf /usr/lib/python2.7

make 
popd

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf pygobject

#libpeas
wget ftp://ftp.gnome.org/pub/gnome/sources/libpeas/1.20/libpeas-1.20.0.tar.xz -O \
		libpeas-1.20.0.tar.xz

mkdir libpeas && tar xf libpeas-*.tar.* -C libpeas --strip-components 1
cd libpeas

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr\
    --libdir=/usr/lib64 \
	--disable-gtk-doc
    
PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf libpeas

#gnome-bluetooth
wget http://ftp.gnome.org/pub/GNOME/core/3.24/3.24.2/sources/gnome-bluetooth-3.20.1.tar.xz -O \
		gnome-bluetooth-3.20.1.tar.xz

mkdir gnome-bluetooth && tar xf gnome-bluetooth-*.tar.* -C gnome-bluetooth --strip-components 1
cd gnome-bluetooth

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr\
    --libdir=/usr/lib64 \
	--disable-gtk-doc \
    --sysconfdir=/etc
    
PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf gnome-bluetooth

#blueman
git clone https://github.com/blueman-project/blueman
cd blueman

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} sh autogen.sh --prefix=/usr\
    --libdir=/usr/lib64 \
	--disable-gtk-doc \
    --sysconfdir=/etc
    
PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf blueman

gsettings set org.blueman.plugins.powermanager auto-power-on true
sudo gsettings set org.blueman.plugins.powermanager auto-power-on true

sudo bash -c 'cat >> /etc/bluetooth/main.conf << "EOF"
[Policy]
AutoEnable=true
EOF'

sudo bash -c 'cat > /etc/udev/ruled.d/10-local.rules << "EOF"
# Set bluetooth power up
ACTION=="add", KERNEL=="hci[0-9]*", RUN+="/usr/bin/hciconfig %k up"
EOF'


#blueberry
wget https://github.com/linuxmint/blueberry/archive/1.1.15.tar.gz -O \
	blueberry-1.1.15.tar.gz

mkdir blueberry && tar xf blueberry-*.tar.* -C blueberry --strip-components 1
cd blueberry

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} make PREFIX=/usr \
	LIBDIR=/usr/lib64

sed -i 's/lib/lib64/' /usr/bin/blueberry/*

sudo cp -rv etc/* etc/
sudo cp -rv usr/* usr/

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf blueman

#htop
wget https://github.com/hishamhm/htop/archive/2.0.2.tar.gz -O \
	htop-2.0.2.tar.gz

mkdir htop && tar xf htop-*.tar.* -C htop --strip-components 1
cd htop

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} sh autogen.sh --prefix=/usr\
    --libdir=/usr/lib64 \
	--disable-gtk-doc 

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr\
    --libdir=/usr/lib64 \
	--disable-gtk-doc 

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf htop

#Boost
wget https://dl.bintray.com/boostorg/release/1.64.0/source//boost_1_64_0.tar.bz2 -O \
	boost_1_64_0.tar.bz2

mkdir boost && tar xf boost_*.tar.* -C boost --strip-components 1
cd boost

sed -e '/using python/ s@;@: /usr/include/python${PYTHON_VERSION/3*/${PYTHON_VERSION}m} ;@' \
    -i bootstrap.sh

./bootstrap.sh --prefix=/usr --libdir=/usr/lib64 --with-python=python3 &&
./b2 stage threading=multi link=shared

sudo ./b2 install threading=multi link=shared

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf boost

#Exempi
wget http://libopenraw.freedesktop.org/download/exempi-2.4.2.tar.bz2 -O \
	exempi-2.4.2.tar.bz2

mkdir exempi && tar xf exempi-*.tar.* -C exempi --strip-components 1
cd exempi

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr\
    --libdir=/usr/lib64 \
	--disable-static

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install


cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf exempi

#libexif
wget http://downloads.sourceforge.net/libexif/libexif-0.6.21.tar.bz2 -O \
	libexif-0.6.21.tar.bz2

mkdir libexif && tar xf libexif-*.tar.* -C libexif --strip-components 1
cd libexif

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr\
    --libdir=/usr/lib64 \
    --with-doc-dir=/usr/share/doc/libexif-0.6.21 \
	--disable-static

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf libexif

#libatasmart
wget http://0pointer.de/public/libatasmart-0.19.tar.xz -O \
	libatasmart-0.19.tar.xz

mkdir libatasmart && tar xf libatasmart-*.tar.* -C libatasmart --strip-components 1
cd libatasmart

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr\
    --libdir=/usr/lib64 \
    --with-doc-dir=/usr/share/doc/libexif-0.6.21 \
	--disable-static

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install


cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf libatasmart

#libbytesize
wget http://github.com/storaged-project/libbytesize/archive/libbytesize-0.10.tar.gz -O \
	libbytesize-0.10.tar.gz

mkdir libbytesize && tar xf libbytesize-*.tar.* -C libbytesize --strip-components 1
cd libbytesize

sh autogen.sh

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr\
    --libdir=/usr/lib64 \
	--disable-static

sed -i 's/docs/#docs/' Makefile*

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf libbytesize

#LVM2
wget ftp://sources.redhat.com/pub/lvm2/releases/LVM2.2.02.171.tgz -O \
	LVM2.2.02.171.tgz

mkdir LVM2 && tar xf LVM2*.tgz -C LVM2 --strip-components 1
cd LVM2

SAVEPATH=$PATH PATH=$PATH:/sbin:/usr/sbin \
CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr\
	--libdir=/usr/lib64 \
	--disable-static    \
    	--exec-prefix=      \
    	--enable-applib     \
    	--enable-cmdlib     \
    	--enable-pkgconfig  \
    	--enable-udev_sync
    
PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

PATH=$SAVEPATH                 
unset SAVEPATH

export PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin

sudo make -C tools install_dmsetup_dynamic 
sudo make -C udev  install                 
sudo make -C libdm install

sudo mv /usr/lib/pkgconfig/devmapper.pc ${PKG_CONFIG_PATH64}/
sudo sudo mv /usr/lib/libdevmapper.so /usr/lib64/

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf LVM2

#GPGME
wget ftp://ftp.gnupg.org/gcrypt/gpgme/gpgme-1.9.0.tar.bz2 -O \
	gpgme-1.9.0.tar.bz2

mkdir gpgme && tar xf gpgme-*.tar.* -C gpgme --strip-components 1
cd gpgme

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr\
    --libdir=/usr/lib64 \
	--disable-static

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf gpgme

#SWIG
wget http://downloads.sourceforge.net/swig/swig-3.0.12.tar.gz -O \
	swig-3.0.12.tar.gz

mkdir swig && tar xf swig-*.tar.* -C swig --strip-components 1
cd swig

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr\
    --libdir=/usr/lib64 \
	--disable-static \
	--without-clisp   \
    --without-maximum-compile-warnings

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

sudo cp -rv  /usr/lib/python2.7/ /usr/lib64/

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf swig

#cryptsetup
wget https://www.kernel.org/pub/linux/utils/cryptsetup/v1.7/cryptsetup-1.7.5.tar.xz -O \
	cryptsetup-1.7.5.tar.xz

mkdir cryptsetup && tar xf cryptsetup-*.tar.* -C cryptsetup --strip-components 1
cd cryptsetup

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr\
    --libdir=/usr/lib64 \
	--disable-static

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf cryptsetup

#volume_key
wget https://releases.pagure.org/volume_key/volume_key-0.3.9.tar.xz -O \
	volume_key-0.3.9.tar.xz

mkdir volume_key && tar xf volume_key-*.tar.* -C volume_key --strip-components 1
cd volume_key

sed -i '/config.h/d' lib/libvolume_key.h
autoreconf -fiv

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr\
	--libdir=/usr/lib64 \
	--disable-static

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf volume_key

#parted
wget http://ftp.gnu.org/gnu/parted/parted-3.2.tar.xz -O \
	parted-3.2.tar.xz

#wget http://www.linuxfromscratch.org/patches/blfs/svn/parted-3.2-devmapper-1.patch -O \
#	Parted-3.2-devmapper-1.patch

mkdir parted && tar xf parted-*.tar.* -C parted --strip-components 1
cd parted

#patch -Np1 -i ../Parted-3.2-devmapper-1.patch

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr\
	--libdir=/usr/lib64 \
	--disable-static

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf parted

#dmraid
wget http://people.redhat.com/~heinzm/sw/dmraid/src/dmraid-current.tar.bz2 -O \
	dmraid-current.tar.bz2

mkdir dmraid && tar xf dmraid-*.tar.* -C dmraid --strip-components 3
cd dmraid

sudo cp -rv include/dmraid /usr/inlude/

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf dmraid

#mdadm
wget http://www.kernel.org/pub/linux/utils/raid/mdadm/mdadm-4.0.tar.xz -O \
	mdadm-4.0.tar.xz

mkdir mdadm && tar xf mdadm-*.tar.* -C mdadm --strip-components 1
cd mdadm

#Fix for GCC 7.1
sed 's@-Werror@@' -i Makefile

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf mdadm

#libblockdev
wget https://github.com/storaged-project/libblockdev/archive/2.11-1.tar.gz -O \
	libblockdev-2.11-1.tar.gz

mkdir libblockdev && tar xf libblockdev-*.tar.* -C libblockdev --strip-components 1
cd libblockdev

sh autogen.sh

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr\
	--libdir=/usr/lib64 \
	--disable-static \
	--without-dm

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sed -i 's/docs/#docs/' Makefile*

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf libblockdev

#LZO
wget http://www.oberhumer.com/opensource/lzo/download/lzo-2.10.tar.gz -O \
	lzo-2.10.tar.gz

mkdir lzo && tar xf lzo-*.tar.* -C lzo --strip-components 1
cd lzo

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr\
	--libdir=/usr/lib64 \
	--disable-static \
	--enable-shared \
	--docdir=/usr/share/doc/lzo-2.10

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf lzo

#btrfs-progs
wget https://www.kernel.org/pub/linux/kernel/people/kdave/btrfs-progs/btrfs-progs-v4.12.tar.xz -O \
	btrfs-progs-v4.12.tar.xz

mkdir btrfs-progs && tar xf btrfs-progs-*.tar.* -C btrfs-progs --strip-components 1
cd btrfs-progs

sed -i '1,100 s/\.gz//g' Documentation/Makefile.in

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr\
	--libdir=/lib64 \
	--disable-static \
	--disable-documentation

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/lib64

mv tests/fuzz-tests/003-multi-check-unmounted/test.sh{,.broken}    &&
mv tests/fuzz-tests/004-simple-dump-tree/test.sh{,.broken}         &&
mv tests/fuzz-tests/007-simple-super-recover/test.sh{,.broken}     &&
mv tests/fuzz-tests/009-simple-zero-log/test.sh{,.broken}          &&
mv tests/misc-tests/019-receive-clones-on-munted-subvol/test.sh{,.broken}

pushd tests
   sudo ./fsck-tests.sh
   sudo ./mkfs-tests.sh
   sudo ./convert-tests.sh
   sudo ./misc-tests.sh
   sudo ./cli-tests.sh
   sudo ./fuzz-tests.sh
popd

sudo make PREFIX=/usr LIBDIR=/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf btrfs-progs

#BerkeleyDB
wget http://download.oracle.com/berkeley-db/db-6.2.32.tar.gz -O \
	db-6.2.32.tar.gz

mkdir db && tar xf db-*.tar.* -C db --strip-components 1
cd db
cd build_unix

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ../dist/configure --prefix=/usr\
    --libdir=/lib64    \
    --disable-static   \
    --enable-compat185 \
    --enable-dbm       \
    --disable-static   \
    --enable-cxx 

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/lib64

sudo make docdir=/usr/share/doc/db-6.2.32 PREFIX=/usr LIBDIR=/lib64 install

sudo chown -v -R root:root                \
      /usr/bin/db_*                       \
      /usr/include/db{,_185,_cxx}.h       \
      /usr/lib/libdb*.{so,la}             \
      /usr/share/doc/db-6.2.32

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf db

#cpio
wget http://ftp.gnu.org/pub/gnu/cpio/cpio-2.12.tar.bz2 -O \
	cpio-2.12.tar.bz2

mkdir cpio && tar xf cpio-*.tar.* -C cpio --strip-components 1
cd cpio

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
            --bindir=/bin \
            --enable-mt   \
            --with-rmt=/usr/libexec/rmt \
			--libdir=/usr/lib64

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/lib64

sudo make PREFIX=/usr LIBDIR=/lib64 install

sudo makeinfo --html            -o doc/html      doc/cpio.texi &&
sudo makeinfo --html --no-split -o doc/cpio.html doc/cpio.texi &&
sudo makeinfo --plaintext       -o doc/cpio.txt  doc/cpio.texi

sudo install -v -m755 -d /usr/share/doc/cpio-2.12/html &&
sudo install -v -m644    doc/html/* \
                    /usr/share/doc/cpio-2.12/html &&
sudo install -v -m644    doc/cpio.{html,txt} \
                    /usr/share/doc/cpio-2.12

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf cpio

#xdg-utils
#wget http://portland.freedesktop.org/download/xdg-utils-1.1.2.tar.gz -O \
#	xdg-utils-1.1.2.tar.gz
#	
#mkdir xdg-utils && tar xf xdg-utils-*.tar.* -C xdg-utils --strip-components 1
#cd xdg-utils
#	
#CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
#USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
#	--libdir=/usr/lib64 \
#	--mandir=/usr/share/man
#
#PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
#CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64
#
#sed -i 's/href=\"http\:\/\/docbook\.sourceforge\.net\/release\/xsl\/current\/manpages\/docbook\.xsl\"/\/usr\/share\/xml\/#docbook\/xsl-stylesheets-1.79.1\/html\/docbook.xsl/' scripts/desc/*.xml
#sed -i 's/http\:\/\/www\.oasis\-open\.org\/docbook\/xml\/4\.1\.2\/docbookx\.dtd/\/usr\/share\/yelp\/dtd\/docbookx.dtd/'
#
#sudo make PREFIX=/usr LIBDIR=/usr/lib64 install
#
#cd ${CLFSSOURCES}/xc/mate
#checkBuiltPackage
#rm -rf xdg-utils

#colord
wget http://www.freedesktop.org/software/colord/releases/colord-1.2.12.tar.xz -O \
	colord-1.2.12.tar.xz

mkdir colord && tar xf colord-*.tar.* -C colord --strip-components 1
cd colord

sudo groupadd -g 71 colord &&
sudo useradd -c "Color Daemon Owner" -d /var/lib/colord -u 71 \
        -g colord -s /bin/false colord

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
    --libdir=/usr/lib64 \
    --sysconfdir=/etc            \
    --localstatedir=/var         \
    --with-daemon-user=colord    \
    --enable-vala                \
    --enable-systemd-login=no    \
    --disable-argyllcms-sensor   \
    --disable-bash-completion    \
    --disable-static             \
    --with-systemdsystemunitdir=no \
    --disable-gtk-doc \
    --disable-sane \
    --disable-docbook-utils \
    --disable-gtk-doc-pdf \
    --disable-gtk-doc-html \

#As of 2017-08-04 Polkit should be working
#I found out how to compile js17 and polkit 0113
#From the LFS 7.6-stable as of to day series
#polkit+js38 merges LFS package WILL NOT WORK FOR ME
#Because the combination of Python 2.7 installed in non-standard
#/usr/lib64 and Mozillas fuicking retared virtualenv 
#is just as bad as the fucking devil itself -.-'
#If polkit still wont wirk use --disable-polkit flag

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf colord

#cups
wget https://github.com/apple/cups/releases/download/v2.2.4/cups-2.2.4-source.tar.gz -O \
	cups-2.2.4-source.tar.gz

mkdir cups && tar xf cups-*.tar.* -C cups --strip-components 1
cd cups

sudo useradd -c "Print Service User" -d /var/spool/cups -g lp -s /bin/false -u 9 lp
sudo groupadd -g 19 lpadmin
sudo usermod -a -G lpadmin overflyer

#if xdg-utils is not install run this sed command
sed -i 's#@CUPS_HTMLVIEW@#firefox#' desktop/cups.desktop.in

sed -i '2062,2069d' cups/dest.c

sed -i 's:444:644:' Makedefs.in                                     &&
sed -i '/MAN.EXT/s:.gz::' configure config-scripts/cups-manpages.m4 &&
sed -i '/LIBGCRYPTCONFIG/d' config-scripts/cups-ssl.m4              &&

aclocal  -I config-scripts &&
autoconf -I config-scripts &&

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
    --libdir=/usr/lib64 \
    --disable-systemd            \
    --with-rcdir=/tmp/cupsinit   \
    --with-system-groups=lpadmin \
    --with-docdir=/usr/share/cups/doc-2.2.4

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

sudo mkdir /etc/cups
sudo rm -rf /tmp/cupsinit
sudo ln -svnf ../cups/doc-2.2.4 /usr/share/doc/cups-2.2.4
sudo echo "ServerName /var/run/cups/cups.sock" > /etc/cups/client.conf
sudo gtk-update-icon-cache

sudo bash -c 'cat > /etc/pam.d/cups << "EOF"
# Begin /etc/pam.d/cups

auth    include system-auth
account include system-account
session include system-session

# End /etc/pam.d/cups
EOF'

cd ${CLFSSOURCES/}/blfs-bootscripts
sudo make install-cups
sudo sed -i 's/log_info_msg/echo/' /etc/rc.d/init.d/*
sudo sed -i 's/lib/lib64/' /etc/rc.d/init.d/*
sudo sed -i 's/loadproc\(\)/start_daemon\(\)/' /etc/rc.d/init.d/functions

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf cups

#gif_lib
wget http://downloads.sourceforge.net/giflib/giflib-5.1.4.tar.bz2 -O \
	giflib-5.1.4.tar.bz2

mkdir giflib && tar xf giflib-*.tar.* -C giflib --strip-components 1
cd giflib

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
	--disable-static \
	--libdir=/usr/lib64

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf giflib

#Fuse3
wget https://github.com/libfuse/libfuse/releases/download/fuse-3.1.0/fuse-3.1.0.tar.gz -O \
	fuse-3.1.0.tar.gz

wget http://www.linuxfromscratch.org/patches/blfs/svn/fuse-3.1.0-upstream_fix-1.patch -O \
	Fuse-3.1.0-upstream_fix-1.patch
	
mkdir fuse && tar xf fuse-*.tar.* -C fuse --strip-components 1
cd fuse

patch -Np1 -i ../Fuse-3.1.0-upstream_fix-1.patch

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
	--libdir=/usr/lib64 \
	--disable-static \
    --exec-prefix=/  \
    --with-pkgconfigdir=/usr/lib64/pkgconfig \
    INIT_D_PATH=/tmp/init.d 

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install
sudo rm -v /lib64/libfuse3.{so,la}                 
sudo ln -sfv ../../lib/libfuse3.so.3 /usr/lib64/libfuse3.so
sudo rm -rf  /tmp/init.d
sudo install -v -m755 -d /usr/share/doc/fuse-3.1.0 &&
sudo install -v -m644    doc/{README.NFS,kernel.txt} \
                    /usr/share/doc/fuse-3.1.0
sudo cp -Rv doc/html /usr/share/doc/fuse-3.1.0

sudo bash -c 'cat > /etc/fuse.conf << "EOF"
# Set the maximum number of FUSE mounts allowed to non-root users.
# The default is 1000.
#
#mount_max = 1000

# Allow non-root users to specify the 'allow_other' or 'allow_root'
# mount options.
#
#user_allow_other
EOF'

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf fuse

#NTFS-3g
wget https://tuxera.com/opensource/ntfs-3g_ntfsprogs-2017.3.23.tgz -O \
	ntfs-3g_ntfsprogs-2017.3.23.tgz
	
mkdir ntfs && tar xf ntfs-3g_ntfsprogs-*.tgz -C ntfs --strip-components 1
cd ntfs	

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
	--libdir=/usr/lib64 \
	--disable-static \
    --with-fuse=internal

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install
sudo ln -sv ../bin/ntfs-3g /sbin/mount.ntfs &&
sudo ln -sv ntfs-3g.8 /usr/share/man/man8/mount.ntfs.8
sudo chmod -v 4755 /bin/ntfs-3g

#If you need to make a usb stick with NTFS writable
#chmod -v 777 /mnt/<usb>

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf ntfs

#libidn-1.33
wget  http://ftp.gnu.org/gnu/libidn/libidn-1.33.tar.gz -O \
	libidn-1.33.tar.gz

mkdir libidn && tar xf libidn-*.tar.* -C libidn --strip-components 1
cd libidn	

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
	--libdir=/usr/lib64 \
	--disable-static 

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf libidn

#whois
wget http://ftp.debian.org/debian/pool/main/w/whois/whois_5.2.17.tar.xz -O \
	whois_5.2.17.tar.xz

mkdir whois && tar xf whois_*.tar.* -C whois --strip-components 1
cd whois	

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" HAVE_LIBIDN=1 make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install-whois
sudo make PREFIX=/usr LIBDIR=/usr/lib64 install-pos

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf whois

##UDisks (unsafe custom no-polkit version!!!)
#
#mkdir udisks && tar xf #add unsafe no-polkit tar from CLFSSOURCES here# -C udisks --strip-components 1
#cd udisks	
#
#CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
#USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
#	--libdir=/usr/lib64 \
#	--libexecdir=/usr/lib64 \
#     --disable-static    \
#    --sysconfdir=/etc    \
#    --localstatedir=/var \
#    --disable-gtk-doc \
#    --disable-gtk-doc-pdf \
#    --disable-gtk-doc-html \
#    --disable-man \
#    --enable-shared \
#    --disable-dependency-tracking \
#    --enable-btrfs \
#    --enable-lvm2 \
#    --enable-lvmcache \
#    --disable-tests
#
#echo "#DELETE ALL TESTS AND LINES WITRH POLKITN IN IT TO MAKE THIS WORK"
#nano makefile
#
#PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
#CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64
#
#sudo make PREFIX=/usr LIBDIR=/usr/lib64 install
#
#cd ${CLFSSOURCES}/xc/mate
#checkBuiltPackage
#echo "This Package will fail because Polkit is unavailable in this version of CLFS"
#echo "The Problem is that mozjs38 wont compile due to insane Python 2.7 environment"
#echo "I made a special version of udisks where I completely removed polkit"
#echo "This might be dangerous AF and it might destroy data or something"
#echo "I take no responsibility for ANY damage done if you use it!!!"
#echo "decide for yourself"
#rm -rf udisks

#UDisks
wget https://github.com/storaged-project/udisks/releases/download/udisks-2.7.1/udisks-2.7.1.tar.bz2 -O \
	udisks-2.7.1.tar.bz2

mkdir udisks && tar xf udisks-*.tar.* -C udisks --strip-components 1
cd udisks	

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
    --libdir=/usr/lib64	\
    --libexecdir=/usr/lib64 \
    --disable-static    \
    --sysconfdir=/etc	\
    --localstatedir=/var \
    --disable-gtk-doc	\
    --disable-gtk-doc-pdf \
    --disable-gtk-doc-html \
    --disable-man 	\
    --enable-shared 	\
    --enable-btrfs 	\
    --enable-lvm2 	\
    --enable-lvmcache	\
    --enable-polkit	\
    --disable-tests

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage

