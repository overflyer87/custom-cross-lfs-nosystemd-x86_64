#!/bin/bash

function checkBuiltPackage() {
echo ""
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
echo ""
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

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" 
USE_ARCH=64 
CXX="g++ ${BUILD64}" 
CC="gcc ${BUILD64}"

export PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" 
export USE_ARCH=64 
export CXX="g++ ${BUILD64}" 
export CC="gcc ${BUILD64}"

#alsa-lib
wget ftp://ftp.alsa-project.org/pub/lib/alsa-lib-1.1.4.1.tar.bz2 -O \
    alsa-lib-1.1.4.1.tar.bz2

mkdir alsa-lib && tar xf alsa-lib-*.tar.* -C alsa-lib --strip-components 1
cd alsa-lib

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure --prefix=/usr \
   --libdir=/usr/lib64 
   
sed -i 's/self\-\>ob_type/Py\_TYPE\(self\)/' modules/mixer/simple/python.c

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make PREFIX=/usr LIBDIR=/usr/lib64
make check
checkBuiltPackae

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

sudo install -v -d -m755 /usr/share/doc/alsa-lib-1.1.4.1/html/search &&
sudo install -v -m644 doc/doxygen/html/*.* \
                /usr/share/doc/alsa-lib-1.1.4.1/html 


sudo bash -c 'cat > /etc/asound.conf << "EOF"
pcm.!default {
  type hw
  card 0
}
ctl.!default {
  type hw           
  card 0
}
EOF'

sudo bash -c 'cat > /usr/share/alsa/alsa.conf << "EOF"
pcm.!default {
  type hw
  card 0
}
ctl.!default {
  type hw           
  card 0
}
EOF'

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf alsa-lib

#alsa-utils
wget ftp://ftp.alsa-project.org/pub/plugins/alsa-plugins-1.1.4.tar.bz2 -O \
  alsa-plugins-1.1.4.tar.bz2

mkdir alsa-plugins && tar xf alsa-plugins-*.tar.* -C alsa-plugins --strip-components 1
cd alsa-plugins

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure --prefix=/usr \
   --libdir=/usr/lib64 

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make PREFIX=/usr LIBDIR=/usr/lib64
sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf alsa-plugins

#alsa-utils
wget ftp://ftp.alsa-project.org/pub/utils/alsa-utils-1.1.4.tar.bz2 -O \
  alsa-utils-1.1.4.tar.bz2  

mkdir alsa-utils && tar xf alsa-utils-*.tar.* -C alsa-utils --strip-components 1
cd alsa-utils

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure --prefix=/usr \
   --libdir=/usr/lib64 \
   --disable-alsaconf \
   --disable-bat   \
   --with-curses=ncursesw \
   --with-systemdsystemunitdir=no
   
#Remove all signs of Manpage install in Makefile* and alsactl/Makefile*

nano alsactl/Makefile

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make PREFIX=/usr LIBDIR=/usr/lib64
sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

sudo alsactl -L store
usermod -a -G audio overflyer

cd ${CLFSSOURCES}/blfs-bootscripts
sudo make install-alsa

sudo /etc/rc.d/init.d/alsa/start

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf alsa-utils

#alsa-tools
wget ftp://ftp.alsa-project.org/pub/tools/alsa-tools-1.1.3.tar.bz2 -O \
  alsa-tools-1.1.3.tar.bz2 

mkdir alsa-tools && tar xf alsa-tools-*.tar.* -C alsa-tools --strip-components 1
cd alsa-tools

rm -rf qlo10k1 Makefile gitcompile

for tool in *
do
  case $tool in
    seq )
      tool_dir=seq/sbiload
    ;;
    * )
      tool_dir=$tool
    ;;
  esac

  pushd $tool_dir
    PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure --prefix=/usr \
      --libdir=/usr/lib64
    PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
    make PREFIX=/usr LIBDIR=/usr/lib64
    sudo make PREFIX=/usr LIBDIR=/usr/lib64 install
    sudo ldconfig
  popd

done
unset tool tool_dir

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf alsa-tools


#alsa-firmware
wget ftp://ftp.alsa-project.org/pub/firmware/alsa-firmware-1.0.29.tar.bz2 -O \
  alsa-firmware-1.0.29.tar.bz2
  
mkdir alsa-firmware && tar xf alsa-firmware-*.tar.* -C alsa-firmware --strip-components 1
cd alsa-firmware

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure --prefix=/usr \
   --libdir=/usr/lib64 

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make PREFIX=/usr LIBDIR=/usr/lib64
sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf alsa-firmware

#alsa-oss
wget ftp://ftp.alsa-project.org/pub/oss-lib/alsa-oss-1.0.28.tar.bz2 -O \
  alsa-oss-1.0.28.tar.bz2
  
mkdir alsa-oss && tar xf alsa-oss-*.tar.* -C alsa-oss --strip-components 1
cd alsa-oss

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure --prefix=/usr \
   --libdir=/usr/lib64 --disable-static

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make PREFIX=/usr LIBDIR=/usr/lib64
sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf alsa-oss


#PulseAudio
wget http://freedesktop.org/software/pulseaudio/releases/pulseaudio-10.0.tar.xz -O \
    pulseaudio-10.0.tar.xz    

mkdir pulseaudio && tar xf pulseaudio-*.tar.* -C pulseaudio --strip-components 1
cd pulseaudio

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" USE_ARCH=64 \
PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
            --disable-static \
            --libdir=/usr/lib64 \
            --localstatedir=/var \
            --disable-bluez4     \
            --disable-rpath \
            --disable-systemd-daemon \
            --disable-systemd-login \
            --disable-systemd-journal \
            --enable-bluez5

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make LIBDIR=/usr/lib64 PREFIX=/usr

make check
checkBuiltPackage

sudo make LIBDIR=/usr/lib64 PREFIX=/usr install    

sudo rm /etc/dbus-1/system.d/pulseaudio-system.conf
sudo install -dm755 /etc/pulse
sudo cp -v src/default.pa /etc/pulse
sudo sed -i '/load-module module-console-kit/s/^/#/' /etc/pulse/default.pa

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf pulseaudio
