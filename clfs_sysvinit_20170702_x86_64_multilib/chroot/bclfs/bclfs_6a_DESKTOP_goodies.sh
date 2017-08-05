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

sudo cat >> /etc/bluetooth/main.conf << "EOF"
[Policy]
AutoEnable=true
EOF

sudo cat > /etc/udev/ruled.d/10-local.rules << "EOF"
# Set bluetooth power up
ACTION=="add", KERNEL=="hci[0-9]*", RUN+="/usr/bin/hciconfig %k up"
EOF


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
	--disable-static \
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

make -C tools install_dmsetup_dynamic 
make -C udev  install                 
make -C libdm install

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
    --enable-shared
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

sudo pushd tests
   sudo ./fsck-tests.sh
   sudo ./mkfs-tests.sh
   sudo ./convert-tests.sh
   sudo ./misc-tests.sh
   sudo ./cli-tests.sh
   sudo ./fuzz-tests.sh
sudo popd

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
    --libdir=/lib64 \
	--disable-static \
	--enable-compat185 \
    --enable-dbm       \
    --disable-static   \
    --enable-cxx 

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/lib64

sudo make docdir=/usr/share/doc/db-6.2.32 PREFIX=/usr LIBDIR=/lib64 install

sudo chown -v -R root:root                \
      /usr/bin/db_*                          \
      /usr/include/db{,_185,_cxx}.h          \
      /usr/lib/libdb*.{so,la}                \
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

makeinfo --html            -o doc/html      doc/cpio.texi &&
makeinfo --html --no-split -o doc/cpio.html doc/cpio.texi &&
makeinfo --plaintext       -o doc/cpio.txt  doc/cpio.texi

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
    --disable-polkit    
    
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

sudo cat > /etc/pam.d/cups << "EOF"
# Begin /etc/pam.d/cups

auth    include system-auth
account include system-account
session include system-session

# End /etc/pam.d/cups
EOF

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

#JAVA 8
wget http://anduin.linuxfromscratch.org/BLFS/OpenJDK/OpenJDK-1.8.0.141/OpenJDK-1.8.0.141-x86_64-bin.tar.xz -O \
	OpenJDK-1.8.0.141-x86_64-bin.tar.xz

wget http://hg.openjdk.java.net/jdk8u/jdk8u/archive/jdk8u141-b15.tar.bz2 -O \
	jdk8u141-b15.tar.bz2

mkdir OpenJDK && tar xf OpenJDK-*.tar.* -C OpenJDK --strip-components 1
cd OpenJDK

sudo install -vdm755 /opt/OpenJDK-1.8.0.141-bin &&
sudo mv -v * /opt/OpenJDK-1.8.0.141-bin         &&
sudo chown -R root:root /opt/OpenJDK-1.8.0.141-bin
sudo ln -sfn OpenJDK-1.8.0.141-bin /opt/jdk

sudo cat > /etc/profile.d/openjdk.sh << "EOF"
# Begin /etc/profile.d/openjdk.sh

# Set JAVA_HOME directory
JAVA_HOME=/opt/jdk

# Adjust PATH
pathappend $JAVA_HOME/bin

# Add to MANPATH
pathappend $JAVA_HOME/man MANPATH

# Auto Java CLASSPATH: Copy jar files to, or create symlinks in, the
# /usr/share/java directory. Note that having gcj jars with OpenJDK 8
# may lead to errors.

AUTO_CLASSPATH_DIR=/usr/share/java

pathprepend . CLASSPATH

for dir in `find ${AUTO_CLASSPATH_DIR} -type d 2>/dev/null`; do
    pathappend $dir CLASSPATH
done

for jar in `find ${AUTO_CLASSPATH_DIR} -name "*.jar" 2>/dev/null`; do
    pathappend $jar CLASSPATH
done

export JAVA_HOME
unset AUTO_CLASSPATH_DIR dir jar

# End /etc/profile.d/openjdk.sh
EOF

sudo cat >> /etc/man_db.conf << "EOF" &&
# Begin Java addition
MANDATORY_MANPATH     /opt/jdk/man
MANPATH_MAP           /opt/jdk/bin     /opt/jdk/man
MANDB_MAP             /opt/jdk/man     /var/cache/man/jdk
# End Java addition
EOF

sudo mkdir -p /var/cache/man
sudo mandb -c /opt/jdk/man

cd ..

mkdir jdk8 && tar xf jdk8*.tar.* -C jdk8 --strip-components 1
cd jdk8

mv ../OpenJDK .

cat > subprojects.md5 << EOF &&
4061c0f2dc553cf92847e4a39a03ea4e  corba.tar.bz2
269a0fde90b9ab5ca19fa82bdb3d6485  hotspot.tar.bz2
a1dfcd15119dd10db6e91dc2019f14e7  jaxp.tar.bz2
16f904d990cb6a3c84ebb81bd6bea1e7  jaxws.tar.bz2
4fb652cdd6fee5f2873b00404e9a01f3  langtools.tar.bz2
c4a99c9c5293bb5c174366664843c8ce  jdk.tar.bz2
c2f06cd8d6e90f3dcc57bec53f419afe  nashorn.tar.bz2
EOF

for subproject in corba hotspot jaxp jaxws langtools jdk nashorn; do
  wget -c http://hg.openjdk.java.net/jdk8u/jdk8u/${subproject}/archive/jdk8u141-b15.tar.bz2 \
       -O ${subproject}.tar.bz2
done &&

md5sum -c subprojects.md5 &&

for subproject in corba hotspot jaxp jaxws langtools jdk nashorn; do
  mkdir -pv ${subproject} &&
  tar -xf ${subproject}.tar.bz2 --strip-components=1 -C ${subproject}
done

unset JAVA_HOME               

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} sh ./configure --prefix=/usr  \
   --with-update-version=141  \
   --libdir=/usr/lib64        \
   --with-build-number=b15    \
   --with-milestone=BLFS      \
   --enable-unlimited-crypto  \
   --with-zlib=system         \
   --with-giflib=system       \
   --with-extra-cflags="-std=c++98 -Wno-error -fno-delete-null-pointer-checks -fno-lifetime-dse" \
   --with-extra-cxxflags="-std=c++98 -fno-delete-null-pointer-checks -fno-lifetime-dse" \
   --with-boot-jdk=/opt/jdk

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} make PREFIX=/usr \
	LIBDIR=/usr/lib64 DEBUG_BINARIES=true SCTP_WERROR= all JOBS=4 
find build/*/images/j2sdk-image -iname \*.diz -delete

sudo cp -RT build/*/images/j2sdk-image /opt/OpenJDK-1.8.0.141 &&
sudo chown -R root:root /opt/OpenJDK-1.8.0.141
sudo ln -v -nsf OpenJDK-1.8.0.141 /opt/jdk

sudo mkdir -pv /usr/share/applications 

sudo cat > /usr/share/applications/openjdk-8-policytool.desktop << "EOF" 
[Desktop Entry]
Name=OpenJDK Java Policy Tool
Name[pt_BR]=OpenJDK Java - Ferramenta de Política
Comment=OpenJDK Java Policy Tool
Comment[pt_BR]=OpenJDK Java - Ferramenta de Política
Exec=/opt/jdk/bin/policytool
Terminal=false
Type=Application
Icon=javaws
Categories=Settings;
EOF

sudo install -v -Dm0644 javaws.png /usr/share/pixmaps/javaws.png

sudo install -vdm755 /etc/ssl/local &&
wget https://hg.mozilla.org/releases/mozilla-release/raw-file/default/security/nss/lib/ckfw/builtins/certdata.txt
wget http://www.cacert.org/certs/root.crt 
sudo openssl x509 -in root.crt -text -fingerprint -setalias "CAcert Class 1 root" \
        -addtrust serverAuth -addtrust emailProtection -addtrust codeSigning \
        > /etc/ssl/local/CAcert_Class_1_root.pem
wget http://www.cacert.org/certs/root.crt

sudo /usr/sbin/make-ca.sh
sudo ln -sfv /etc/ssl/java/cacerts /opt/jdk/jre/lib/security/cacerts

cd /opt/jdk
bin/keytool -list -keystore /etc/ssl/java/cacerts

#just pess enter there is no password

#Oracle JDK8
#install -d /etc/.java/.systemPrefs
#install -d /usr/lib64/jvm/java-8-jdk/bin
#install -d /usr/lib64/mozilla/plugins
#install -d /usr/share/licenses/java8jdk
#rm    db/bin/*.bat
#rm    db/3RDPARTY
#rm    db/LICENSE
#rm -r jre/lib/desktop/icons/HighContrast/
#rm -r jre/lib/desktop/icons/HighContrastInverse/
#rm -r jre/lib/desktop/icons/LowContrast/
#rm    jre/lib/fontconfig.*.bfc
#rm    jre/lib/fontconfig.*.properties.src
#rm -r jre/plugin/
#rm    jre/*.txt
#rm    jre/COPYRIGHT
#rm    jre/LICENSE
#rm    jre/README
#rm    man/ja
#sudo cp -rv * /usr/lib64/jvm/java-8-jdk/
#sudo cd /usr/lib64/jvm/java-8-jdk/
#sudo for i in $(ls jre/bin/); do
#        ln -sf "jre/bin/$i" "bin/$i"
#done
#
#sudo sed -e "s|Exec=|Exec=/usr/lib64/jvm/java-8-jdk/jre/bin/|" \
#        -e "s|.png|-jdk8.png|" \
#   -i jre/lib/desktop/applications/*
#
#sudo cp -rv jre/lib/desktop/* /usr/share/
#sudo install -m644 jre/lib/desktop/applications/*.desktop /usr/share/applications/
#
#sudo install -m644 -d /etc/java-jdk8
#sudo cp -rv jre/lib/* /etc/java-jdk8
#sudo rm -rf jre/lib/* 
#sudo ln -sfv /etc/* /usr/lib64/jvm/java-8-jdk/jre/lib/
#sudo ln -sfv jre/lib/amd64/libnpjp2.so /usr/lib64/mozilla/plugins/libnpjp2-jdk8.so
#sudo ln -sfv /etc/ssl/certs/java/cacerts jre/lib/security/cacerts
#
#sudo for i in $(find man/ -type f); do
#        mv "$i" "${i/.1}-jdk8.1"
#done
#
#sudo mv man/ja_JP.UTF-8/ man/ja
#sudo cp -rv man /usr/share
#sudo rm -r man
#sudo mkdir /usr/share/licenses/java-jdk8
#sudo mv db/NOTICE COPYRIGHT LICENSE *.txt /usr/share/licenses/java-jdk8
#
#"Installing Java Cryptography Extension (JCE) Unlimited Strength Jurisdiction Policy Files..."
#    # Replace default "strong", but limited, cryptography to get an "unlimited strength" one for
#    # things like 256-bit AES. Enabled by default in OpenJDK:
#    # - http://suhothayan.blogspot.com/2012/05/how-to-install-java-cryptography.html
#    # - http://www.eyrie.org/~eagle/notes/debian/jce-policy.html
#    install -m644 "$srcdir"/UnlimitedJCEPolicyJDK$_major/*.jar jre/lib/security/
#    install -Dm644 "$srcdir"/UnlimitedJCEPolicyJDK$_major/README.txt \
#                   "$pkgdir"/usr/share/doc/$pkgname/README_-_Java_JCE_Unlimited_Strength.txt
#
#export lineAwk=(awk '/permission/{a=NR}; END{print a}' /etc/java-jdk8/security/java.policy)
#lineAwk=(awk '/permission/{a=NR}; END{print a}' /etc/java-jdk8/security/java.policy) 
#
#sudo sed "$lineAwk a\\\\n \
#        // (AUR) Allow unsigned applets to read system clipboard, see:\n \
#        // - https://blogs.oracle.com/kyle/entry/copy_and_paste_in_java\n \
#        // - http://slightlyrandombrokenthoughts.blogspot.com/2011/03/oracle-java-applet-clipboard-injection.html\n \
#        permission java.awt.AWTPermission \"accessClipboard\";" \
#    -i /etc/java-jdk8/security/java.policy




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

sudo cat > /etc/fuse.conf << "EOF"
# Set the maximum number of FUSE mounts allowed to non-root users.
# The default is 1000.
#
#mount_max = 1000

# Allow non-root users to specify the 'allow_other' or 'allow_root'
# mount options.
#
#user_allow_other
EOF

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

#UDisks (will NOT WORK without polkit)
wget https://github.com/storaged-project/udisks/releases/download/udisks-2.7.1/udisks-2.7.1.tar.bz2 -O \
	udisks-2.7.1.tar.bz2

mkdir udisks && tar xf udisks-*.tar.* -C udisks --strip-components 1
cd udisks	

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
	--libdir=/usr/lib64 \
	--libexecdir=/usr/lib64 \
	--disable-static    \
	--sysconfdir=/etc    \
    --localstatedir=/var \
    --disable-gtk-doc \
    --disable-gtk-doc-pdf \
    --disable-gtk-doc-html \
    --disable-man \
    --enable-shared \
    --disable-dependency-tracking \
    --enable-btrfs \
    --enable-lvm2 \
    --enable-lvmcache \
    --disable-tests

echo "#DELETE ALL TESTS AND LINES WITRH POLKITN IN IT TO MAKE THIS WORK"
nano makefile

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
echo "This Package will fail because Polkit is unavailable in this version of CLFS"
echo "The Problem is that mozjs38 wont compile due to insane Python 2.7 environment"
echo "I made a special version of udisks where I completely removed polkit"
echo "This might be dangerous AF and it might destroy data or something"
echo "I take no responsibility for ANY damage done if you use it!!!"
echo "decide for yourself"
rm -rf udisks

#Gvfs
wget http://ftp.gnome.org/pub/gnome/sources/gvfs/1.32/gvfs-1.32.1.tar.xz
	gvfs-1.32.1.tar.xz 
#You need to recompile udev with this patch in order
#For Gvfs to support gphoto2
wget https://sourceforge.net/p/gphoto/patches/_discuss/thread/9180a667/9902/attachment/libgphoto2.udev-136.patch -O \
	libgphoto2.udev-136.patch

mkdir gvfs && tar xf gvfs-*.tar.* -C gvfs --strip-components 1
cd gvfs

LD_LIB_PATH="/usr/lib64" LIBRARY_PATH="/usr/lib64" CPPFLAGS="-I/usr/include" \
LD_LIBRARY_PATH="/usr/lib64" CC="gcc ${BUILD64} -L/usr/lib64 -lacl" \
CXX="g++ ${BUILD64} -lacl" USE_ARCH=64 \
PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
	--libdir=/usr/lib64 \
	--disable-static    \
	--sysconfdir=/etc    \
    --disable-gtk-doc \
    --disable-gtk-doc-pdf \
    --disable-gtk-doc-html \
    --disable-libsystemd-login \
    --disable-admin \
    --disable-gphoto2 \
    --disable-documentation
    
sudo ln -sfv /usr/lib64/libacl.so /lib64/
sudo ln -sfv /usr/lib64/libattr.so /lib64/
    
LD_LIB_PATH="/usr/lib64" LIBRARY_PATH="/usr/lib64" CPPFLAGS="-I/usr/include" \
LD_LIBRARY_PATH="/usr/lib64" CC="gcc ${BUILD64} -L/usr/lib64 -lacl" \
CXX="g++ ${BUILD64} -lacl" USE_ARCH=64 \
PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf gvfs

#libevent
wget https://github.com/libevent/libevent/releases/download/release-2.1.8-stable/libevent-2.1.8-stable.tar.gz -O \
	libevent-2.1.8-stable.tar.gz

mkdir libevent && tar xf libevent-*.tar.* -C libevent --strip-components 1
cd libevent

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
	--libdir=/usr/lib64 \
	--disable-static    \
	--sysconfdir=/etc    

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf libevent

#MariaDB
wget https://downloads.mariadb.org/interstitial/mariadb-10.2.7/source/mariadb-10.2.7.tar.gz
	mariadb-10.2.7.tar.gz

mkdir mariadb && tar xf mariadb-*.tar.* -C mariadb --strip-components 1
cd mariadb

sudo groupadd -g 40 mysql &&
sudo useradd -c "MySQL Server" -d /srv/mysql -g mysql -s /bin/false -u 40 mysql

sed -i "s@data/test@\${INSTALL_MYSQLTESTDIR}@g" sql/CMakeLists.txt &&
sed -i '/void..coc_malloc/{s/char ./&x/; s/int/& y/}' mysys_ssl/openssl.c &&

mkdir build 
cd build    

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} cmake -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=/usr                     \
      -LIBRARY_OUTPUT_PATH=/usr/lib64               \
      -DINSTALL_DOCDIR=share/doc/mariadb-10.2.7       \
      -DINSTALL_DOCREADMEDIR=share/doc/mariadb-10.2.7 \
      -DINSTALL_MANDIR=share/man                      \
      -DINSTALL_MYSQLSHAREDIR=share/mysql             \
      -DINSTALL_MYSQLTESTDIR=share/mysql/test         \
      -DINSTALL_PLUGINDIR=lib/mysql/plugin            \
      -DINSTALL_SBINDIR=sbin                          \
      -DINSTALL_SCRIPTDIR=bin                         \
      -DINSTALL_SQLBENCHDIR=share/mysql/bench         \
      -DINSTALL_SUPPORTFILESDIR=share/mysql           \
      -DMYSQL_DATADIR=/srv/mysql                      \
      -DMYSQL_UNIX_ADDR=/run/mysqld/mysqld.sock       \
      -DWITH_EXTRA_CHARSETS=complex                   \
      -DWITH_EMBEDDED_SERVER=ON                       \
      -DSKIP_TESTS=ON                                 \
      -DTOKUDB_OK=0                                   \
      ..
      
PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

sudo install -v -dm 755 /etc/mysql &&
sudo cat > /etc/mysql/my.cnf << "EOF"
# Begin /etc/mysql/my.cnf

# The following options will be passed to all MySQL clients
[client]
#password       = your_password
port            = 3306
socket          = /run/mysqld/mysqld.sock

# The MySQL server
[mysqld]
port            = 3306
socket          = /run/mysqld/mysqld.sock
datadir         = /srv/mysql
skip-external-locking
key_buffer_size = 16M
max_allowed_packet = 1M
sort_buffer_size = 512K
net_buffer_length = 16K
myisam_sort_buffer_size = 8M

# Don't listen on a TCP/IP port at all.
skip-networking

# required unique id between 1 and 2^32 - 1
server-id       = 1

# Uncomment the following if you are using BDB tables
#bdb_cache_size = 4M
#bdb_max_lock = 10000

# InnoDB tables are now used by default
innodb_data_home_dir = /srv/mysql
innodb_log_group_home_dir = /srv/mysql
# All the innodb_xxx values below are the default ones:
innodb_data_file_path = ibdata1:12M:autoextend
# You can set .._buffer_pool_size up to 50 - 80 %
# of RAM but beware of setting memory usage too high
innodb_buffer_pool_size = 128M
innodb_log_file_size = 48M
innodb_log_buffer_size = 16M
innodb_flush_log_at_trx_commit = 1
innodb_lock_wait_timeout = 50

[mysqldump]
quick
max_allowed_packet = 16M

[mysql]
no-auto-rehash
# Remove the next comment character if you are not familiar with SQL
#safe-updates

[isamchk]
key_buffer = 20M
sort_buffer_size = 20M
read_buffer = 2M
write_buffer = 2M

[myisamchk]
key_buffer_size = 20M
sort_buffer_size = 20M
read_buffer = 2M
write_buffer = 2M

[mysqlhotcopy]
interactive-timeout

# End /etc/mysql/my.cnf
EOF

sudo mysql_install_db --basedir=/usr --datadir=/srv/mysql --user=mysql &&
sudo chown -R mysql:mysql /srv/mysql

sudo install -v -m755 -o mysql -g mysql -d /run/mysqld &&
sudo mysqld_safe --user=mysql 2>&1 >/dev/null &

sudo mysqladmin -u root password

sudo mysqladmin -p shutdown

cd${CLFSSOURCES}/blfs-bootscripts
sudo make install-mysql

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf mariadb

#libsigc++
wget http://ftp.gnome.org/pub/gnome/sources/libsigc++/2.10/libsigc++-2.10.0.tar.xz -O \
	libsigc++-2.10.0.tar.xz

mkdir libsigcpp && tar xf libsigc++-*.tar.* -C libsigcpp --strip-components 1
cd libsigcpp

sed -e '/^libdocdir =/ s/$(book_name)/libsigc++-2.10.0/' -i docs/Makefile.in

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
	--libdir=/usr/lib64 \
	--disable-static    

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

make check
checkBuiltPackage

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf libsigcpp

#Glibmm
wget http://ftp.gnome.org/pub/gnome/sources/glibmm/2.52/glibmm-2.52.0.tar.xz -O \
	glibmm-2.52.0.tar.xz
	
mkdir glibmm && tar xf glibmm-*.tar.* -C glibmm --strip-components 1
cd glibmm

sed -e '/^libdocdir =/ s/$(book_name)/glibmm-2.52.0/' \
    -i docs/Makefile.in

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
	--libdir=/usr/lib64 \
	--disable-static    

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

make check
checkBuiltPackage

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf glibmm

#Atkmm
wget http://ftp.gnome.org/pub/gnome/sources/atkmm/2.24/atkmm-2.24.2.tar.xz -O \
	atkmm-2.24.2.tar.xz

mkdir atkmm && tar xf atkmm-*.tar.* -C atkmm --strip-components 1
cd atkmm

sed -e '/^libdocdir =/ s/$(book_name)/atkmm-2.24.2/' \
    -i doc/Makefile.in

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
	--libdir=/usr/lib64 \
	--disable-static    

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

make check
checkBuiltPackage

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf atkmm

#Cairomm
wget http://cairographics.org/releases/cairomm-1.12.2.tar.gz -O \
	cairomm-1.12.2.tar.gz

mkdir cairomm && tar xf cairomm-*.tar.* -C cairomm --strip-components 1
cd cairomm

sed -e '/^libdocdir =/ s/$(book_name)/cairomm-1.12.2/' \
    -i docs/Makefile.in

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
	--libdir=/usr/lib64 \
	--disable-static    

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

make check
checkBuiltPackage

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf cairomm

#Pangomm
wget http://ftp.gnome.org/pub/gnome/sources/pangomm/2.40/pangomm-2.40.1.tar.xz -O \
	pangomm-2.40.1.tar.xz

mkdir pangomm && tar xf pangomm-*.tar.* -C pangomm --strip-components 1
cd pangomm

sed -e '/^libdocdir =/ s/$(book_name)/pangomm-2.40.1/' \
    -i docs/Makefile.in

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
	--libdir=/usr/lib64 \
	--disable-static    

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

make check
checkBuiltPackage

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf pangomm

#Gtkmm3
wget http://ftp.gnome.org/pub/gnome/sources/gtkmm/3.22/gtkmm-3.22.1.tar.xz -O \
	gtkmm-3.22.1.tar.xz

mkdir gtkmm && tar xf gtkmm-3*.tar.* -C gtkmm --strip-components 1
cd gtkmm

sed -e '/^libdocdir =/ s/$(book_name)/gtkmm-3.22.1/' \
    -i docs/Makefile.in

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
	--libdir=/usr/lib64 \
	--disable-static    

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

make check
checkBuiltPackage

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf gtkmm

#gtkmm2
wget http://ftp.gnome.org/pub/gnome/sources/gtkmm/2.24/gtkmm-2.24.5.tar.xz -O \
	gtkmm-2.24.5.tar.xz

mkdir gtkmm-2 && tar xf gtkmm-2*.tar.* -C gtkmm-2 --strip-components 1
cd gtkmm-2

sed -e '/^libdocdir =/ s/$(book_name)/gtkmm-3.22.1/' \
    -i docs/Makefile.in

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
	--libdir=/usr/lib64 \
	--disable-static    

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

make check
checkBuiltPackage

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf gtkmm-2

#xmlto
wget http://anduin.linuxfromscratch.org/BLFS/xmlto/xmlto-0.0.28.tar.bz2 -O \
	xmlto-0.0.28.tar.bz2

mkdir xmlto && tar xf xmlto-*.tar.* -C xmlto --strip-components 1
cd xmlto

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
LINKS="/usr/bin/links" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
	--libdir=/usr/lib64 \

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf xmlto

#xdg-su
wget https://github.com/tarakbumba/xdg-su/archive/xdg-su-1.2.3.tar.gz -O \
	xdg-su-1.2.3.tar.gz

mkdir xdg-su && tar xf xdg-su-*.tar.* -C xdg-su --strip-components 1
cd xdg-su

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
	--libdir=/usr/lib64 
	
sed -i 's/http\:\/\/www\.oasis\-open\.org\/docbook\/xml\/4.1.2\/docbookx.dtd/\/usr\/share\/yelp\/dtd\/docbookx.dtd/' scripts/desc/xdg-su.xml
sed -i 's/\/usr\/bin\/xmlto/\/usr\/bin\/xmlto -vv --skip-validation --noclean --searchpath=\/usr\/share\/xml\/docbook\/xsl-stylesheets-1.79.1\/html/' scripts/Makefile
sed -i 's/http\:\/\/docbook.sourceforge.net\/release\/xsl\/current\/manpages\/docbook.xsl/\/usr\/share\/xml\/docbook\/xsl-stylesheets-1.79.1\/manpages\/docbook\.xsl/' scripts/desc/xdg-su.xml

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64
sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf xdg-su

#libgksu
wget http://people.debian.org/~kov/gksu/libgksu-2.0.12.tar.gz -O \
	libgksu-2.0.12.tar.gz

mkdir libgksu && tar xf libgksu-*.tar.* -C libgksu --strip-components 1
cd libgksu

LD_LIB_PATH="/usr/lib64" LD_LIBRARY_PATH=/usr/lib64/ \
LIBRARY_PATH="/usr/lib64/" \
PKG_CONFIG_PATH=/usr/lib64/pkgconfig \
CC="gcc -m64 -lglib-2.0 -lgtk-x11-2.0" USE_ARCH=64 \
CXX="g++ ${BUILD64} -lglib-2.0 -lgtk-x11" ./configure --prefix=/usr \
	--libdir=/usr/lib64 \
	--disable-static  \
	--disable-gtk-doc \
	--without-html-dir

echo "#first fix the 8 spaces infront of the if in line 732. make it a TAB!"
nano -c Makefile

LD_LIB_PATH="/usr/lib64" LD_LIBRARY_PATH=/usr/lib64/ \
LIBRARY_PATH="/usr/lib64/" \
PKG_CONFIG_PATH=/usr/lib64/pkgconfig \
CC="gcc -m64 -lglib-2.0 -lgtk-x11-2.0" USE_ARCH=64 \
CXX="g++ ${BUILD64} -lglib-2.0 -lgtk-x11" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

sudo mv libgksu/gksu-run-helper /usr/bin/
#sudo mv libgksu/test-gksu /usr/bin/
sudo mv libgksu/gksu-properties /usr/bin/

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf libgksu

#gksu
wget https://people.debian.org/~kov/gksu/gksu-2.0.2.tar.gz -O \
	gksu-2.0.2.tar.gz

mkdir gksu && tar xf gksu-*.tar.* -C gksu --strip-components 1
cd gksu

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
	--libdir=/usr/lib64 \
	--disable-static    \
	--disable-gtk-doc   \
	--without-html-dir \
	--disable-nautilus-extension

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

make check
checkBuiltPackage

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf gksu

#Gparted
wget http://downloads.sourceforge.net/gparted/gparted-0.28.1.tar.gz -O \
	gparted-0.28.1.tar.gz
	
mkdir gparted && tar xf gparted-*.tar.* -C gparted --strip-components 1
cd gparted

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
	--libdir=/usr/lib64 \
	--disable-doc \
	--disable-static \
	--enable-libparted-dmraid

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf gparted

#libtirpc
wget http://downloads.sourceforge.net/project/libtirpc/libtirpc/1.0.1/libtirpc-1.0.1.tar.bz2 -O \
	libtirpc-1.0.1.tar.bz2

mkdir libtirpc && tar xf libtirpc-*.tar.* -C libtirpc --strip-components 1
cd libtirpc

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
	--libdir=/usr/lib64 \
	--sysconfdir=/etc \
	--disable-static \
	--disable-gssapi

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install
sudo mv -v /usr/lib64/libtirpc.so.* /lib64
sudo ln -sfv ../../lib64/libtirpc.so.3.0.0 /usr/lib64/libtirpc.so

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf libtirpc

#Parse::Yapp-1.2
wget http://www.cpan.org/authors/id/W/WB/WBRASWELL/Parse-Yapp-1.2.tar.gz -O \
	Parse-Yapp-1.2.tar.gz
	
mkdir Parse-Yapp && tar xf Parse-Yapp-*.tar.* -C Parse-Yapp --strip-components 1
cd Parse-Yapp

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} perl-64 Makefile.PL PREFIX=/usr 
CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} make PREFIX=/usr LIBDIR=/usr/lib64
make test
checkBuiltPackage

sudo make install PREFIX=/usr LIBDIR=/usr/lib64

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf Parse-Yapp

#PyCrypto
wget https://pypi.python.org/packages/60/db/645aa9af249f059cc3a368b118de33889219e0362141e75d4eaf6f80f163/pycrypto-2.6.1.tar.gz -O \
	pycrypto-2.6.1.tar.gz

mkdir pycrypto && tar xf pycrypto-*.tar.* -C pycrypto --strip-components 1
cd pycrypto

sudo python2-64 setup.py build 
sudo python2-64 setup.py install --verbose --prefix=/usr/lib64 --install-lib=/usr/lib64/python2.7/site-packages --optimize=1
sudo python3.6 setup.py build
sudo python3 setup.py install --verbose --prefix=/usr/lib64 --install-lib=/usr/lib64/python3.6/site-packages --optimize=1

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf pycrypto

#Cyrus SASL
wget ftp://ftp.cyrusimap.org/cyrus-sasl/cyrus-sasl-2.1.26.tar.gz -O \
	cyrus-sasl-2.1.26.tar.gz

wget http://www.linuxfromscratch.org/patches/blfs/svn/cyrus-sasl-2.1.26-fixes-3.patch -O \
 Cyrus-sasl-2.1.26-fixes-3.patch
 
wget http://www.linuxfromscratch.org/patches/blfs/svn/cyrus-sasl-2.1.26-openssl-1.1.0-1.patch -O \
	Cyrus-Sasl-2.1.26-openssl-1.1.0-1.patch

mkdir cyrus && tar xf cyrus-*.tar.* -C cyrus --strip-components 1
cd cyrus

patch -Np1 -i ../Cyrus-sasl-2.1.26-fixes-3.patch
patch -Np1 -i ../Cyrus-Sasl-2.1.26-openssl-1.1.0-1.patch

autoreconf -fi

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" ./configure --prefix=/usr \
            --sysconfdir=/etc    \
            --enable-auth-sasldb \
            --with-dbpath=/var/lib/sasl/sasldb2 \
            --with-saslauthd=/var/run/saslauthd \
            --libdir=/usr/lib64
            
PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo install -v -dm755 /usr/share/doc/cyrus-sasl-2.1.26
sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/blfs-bootscripts
sudo make install-saslauthd

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf cyrus

#openLDAP
wget ftp://ftp.openldap.org/pub/OpenLDAP/openldap-release/openldap-2.4.45.tgz -O \
	openldap-2.4.45.tgz

wget http://www.linuxfromscratch.org/patches/blfs/svn/openldap-2.4.45-consolidated-1.patch -O \
	Openldap-2.4.45-consolidated-1.patch

mkdir openldap && tar xf openldap-*.tgz -C openldap --strip-components 1
cd openldap

sudo groupadd -g 83 ldap 
sudo useradd  -c "OpenLDAP Daemon Owner" \
         -d /var/lib/openldap -u 83 \
         -g ldap -s /bin/false ldap

patch -Np1 -i ../Openldap-2.4.45-consolidated-1.patch
autoreconf

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr  \
            --sysconfdir=/etc     \
            --localstatedir=/var  \
            --libdir=/usr/lib64   \
            --libexecdir=/usr/lib64 \
            --disable-static      \
            --disable-debug       \
            --with-tls=openssl    \
            --with-cyrus-sasl     \
            --enable-dynamic      \
            --enable-crypt        \
            --enable-spasswd      \
            --enable-slapd        \
            --enable-modules      \
            --enable-rlookups     \
            --enable-backends=mod \
            --disable-ndb         \
            --disable-sql         \
            --disable-shell       \
            --disable-bdb         \
            --disable-hdb         \
            --enable-overlays=mod 

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make depend PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

sudo install -v -dm700 -o ldap -g ldap /var/lib64/openldap    

sudo install -v -dm700 -o ldap -g ldap /etc/openldap/slapd.d
sudo chmod   -v    640     /etc/openldap/slapd.{conf,ldif}  
sudo chown   -v  root:ldap /etc/openldap/slapd.{conf,ldif}  

cd ${CLFSSOURCES}/blfs-bootscripts
sudo make install-slapd

sudo /etc/rc.d/init.d/slapd start
sudo ldapsearch -x -b '' -s base '(objectclass=*)' namingContexts

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf openldap

#Samba
wget https://download.samba.org/pub/samba/stable/samba-4.6.6.tar.gz -O \
	samba-4.6.6.tar.gz

mkdir samba && tar xf samba-*.tar.* -C samba --strip-components 1
cd samba

echo "^samba4.rpc.echo.*on.*ncacn_np.*with.*object.*nt4_dc" >> selftest/knownfail

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr  \
            --sysconfdir=/etc     \
            --localstatedir=/var  \
            --libdir=/usr/lib64   \
            --with-piddir=/run/samba           \
   			--with-pammodulesdir=/lib64/security \
    		--enable-fhs                       \
    		--without-ad-dc                    \
    		--without-systemd                  \
    		--enable-selftest     \
    		--without-ldap        \
    		--without-ads

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

sudo mv -v /usr/lib64/libnss_win{s,bind}.so*   /lib64                      
sudo ln -v -sf ../../lib64/libnss_winbind.so.2 /usr/lib64/libnss_winbind.so 
sudo ln -v -sf ../../lib64/libnss_wins.so.2    /usr/lib64/libnss_wins.so    

sudo install -v -m644    examples/smb.conf.default /etc/samba 

sudo mkdir -pv /etc/openldap/schema                        

sudo install -v -m644    examples/LDAP/README              \
                    /etc/openldap/schema/README.LDAP  

sudo install -v -m644    examples/LDAP/samba*              \
                    /etc/openldap/schema              

sudo install -v -m755    examples/LDAP/{get*,ol*} \
                    /etc/openldap/schema

sudo ln -v -sf /usr/bin/smbspool /usr/lib/cups/backend/smb
sudo cat > /etc/samba/smb.con << "EOF"
[global]
workgroup = WORKGROUP
dos charset = cp850
unix charset = UTF-8
EOF

sudo groupadd -g 99 nogroup &&
sudo useradd -c "Unprivileged Nobody" -d /dev/null -g nogroup \
    -s /bin/false -u 99 nobody


cd ${CLFSSOURCES}/blfs-bootscripts
sudo make install-samba
sudo make install-winbindd
sudo /etc/rc.d/init.d/samba start
sudo /etc/rc.d/init.d/winbind start

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf samba

#libndp
wget http://libndp.org/files/libndp-1.6.tar.gz -O \
	libndp-1.6.tar.gz
	
mkdir libndp && tar xf libndp-*.tar.* -C libndp --strip-components 1
cd libndp

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr  \
            --sysconfdir=/etc     \
            --localstatedir=/var  \
            --libdir=/usr/lib64   \
            --disable-static

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf libndp

#libnl
wget https://github.com/thom311/libnl/releases/download/libnl3_3_0/libnl-3.3.0.tar.gz -O \
	libnl-3.3.0.tar.gz

mkdir libnl && tar xf libnl-*.tar.* -C libndp --strip-components 1
cd libnl

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr  \
            --sysconfdir=/etc     \
            --localstatedir=/var  \
            --libdir=/usr/lib64   \
            --disable-static

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf libnl

#ConsoleKit
#elogind
wget https://github.com/wingo/elogind/archive/v219.12.tar.gz -O \
	elogind-219.12.tar.gz

mkdir elogind && tar xf elogind-*.tar.* -C elogind --strip-components 1
cd elogind

autoreconf -fi 
intltoolize --force 

CPPFLAGS="-I/usr/include" LD_LIBRARY_PATH="/usr/lib64" \
LD_LIB_PATH="/usr/lib64" LIBRARY_PATH="/usr/lib64" \
CC="gcc ${BUILD64} -lrt" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr  \
            --sysconfdir=/etc     \
            --localstatedir=/var  \
            --libdir=/usr/lib64   \
            --disable-static      \
            --libexecdir=/usr/lib64   \
            --enable-split-usr \
            --disable-gtk-doc \
            --disable-tests   \
            --disable-gtk-pdf \
            --disable-gtk-html \
            --enable-pam \
            --with-pamlibdir=/lib64/security \
            --with-pamconfdir=/etc/pam.d \
            --disable-static \
            --enable-shared \
            --disable-manpages

CPPFLAGS="-I/usr/include" LD_LIBRARY_PATH="/usr/lib64" \
LD_LIB_PATH="/usr/lib64" LIBRARY_PATH="/usr/lib64" \
PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64} -lrt" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install
sudo mkdir -pv /run/systemd
sudo chmod 755 /run/systemd

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf elogind

#Iptables
wget http://www.netfilter.org/projects/iptables/files/iptables-1.6.1.tar.bz2 -O \
	iptables-1.6.1.tar.bz2

mkdir iptables && tar xf iptables-*.tar.* -C iptables --strip-components 1
cd iptables

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr  \
            --sysconfdir=/etc     \
            --localstatedir=/var  \
            --libdir=/lib64       \
            --sbindir=/sbin       \
            --enable-libipq       \
            --disable-nftables    \
            --with-xtlibdir=/lib64/xtables

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install
sudo ln -sfv ../../sbin/xtables-multi /usr/bin/iptables-xml


for file in ip4tc ip6tc ipq iptc xtables
do
  sudo mv -v /usr/lib64/lib${file}.so.* /lib64 &&
  sudo ln -sfv ../../lib64/$(readlink /usr/lib64/lib${file}.so) /usr/lib64/lib${file}.so
done

cd ${CLFSSOURCES}/blfs-bootscripts
sudo make install-iptables

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf iptables

#slang
wget http://www.jedsoft.org/releases/slang/slang-2.3.1.tar.bz2 -O 
	slang-2.3.1.tar.bz2

mkdir slang && tar xf slang-*.tar.* -C slang --strip-components 1
cd slang

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr  \
            --sysconfdir=/etc     \
            --with-readline=gnu  \
            --libdir=/usr/lib64
            
PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make -j1 PREFIX=/usr LIBDIR=/usr/lib64

sudo make -j1 PREFIX=/usr LIBDIR=/usr/lib64 install_doc_dir=/usr/share/doc/slang-2.3.1   \
     SLSH_DOC_DIR=/usr/share/doc/slang-2.3.1/slsh install-all

sudo chmod -v 755 /usr/lib64/libslang.so.2.3.1 
sudo chmod -v 755 /usr/lib64/slang/v2/modules/*.so

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf slang

#newt
wget https://releases.pagure.org/newt/newt-0.52.20.tar.gz -O \
	newt-0.52.20.tar.gz  

mkdir newt && tar xf newt-*.tar.* -C newt --strip-components 1
cd newt

sed -e 's/^LIBNEWT =/#&/' \
    -e '/install -m 644 $(LIBNEWT)/ s/^/#/' \
    -e 's/$(LIBNEWT)/$(LIBNEWTSONAME)/g' \
    -i Makefile.in                
    
CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr  \
            --sysconfdir=/etc     \
            --libdir=/usr/lib64   \
            --with-gpm-support

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf newt

#NetworkManager
wget http://ftp.gnome.org/pub/gnome/sources/NetworkManager/1.8/NetworkManager-1.8.0.tar.xz -O \
	NetworkManager-1.8.0.tar.xz

mkdir NetworkManager && tar xf NetworkManager-*.tar.* -C NetworkManager --strip-components 1
cd NetworkManager

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr  \
            --sysconfdir=/etc     \
            --libdir=/usr/lib64   
			--localstatedir=/var           \
            --with-nmtui                   \
            --disable-ppp                  \
            --disable-json-validation      \
            --with-systemdsystemunitdir=no \
            --without-systemd \
            --disable-systemd \
            --disable-gtk-doc \
            --disable-manpages \
            --disable-gtk-doc-pdf \
            --disable-gtk-doc-html

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

sudo cat >> /etc/NetworkManager/NetworkManager.conf << "EOF"
[main]
plugins=keyfile
EOF

sudo groupadd -fg 86 netdev 
sudo /usr/sbin/usermod -a -G netdev overflyer

sudo cat > /usr/share/polkit-1/rules.d/org.freedesktop.NetworkManager.rules << "EOF"
polkit.addRule(function(action, subject) {
    if (action.id.indexOf("org.freedesktop.NetworkManager.") == 0 && subject.isInGroup("netdev")) {
        return polkit.Result.YES;
    }
});
EOF

cd ${CLFSSOURCES}/blfs-bootscripts
sudo make install-networkmanager
sudo /etc/rc.d/init.d/networkmanager start

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf NetworkManager
