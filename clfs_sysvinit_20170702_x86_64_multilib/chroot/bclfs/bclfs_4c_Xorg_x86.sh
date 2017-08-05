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
CLFS_TARGET32="i686-pc-linux-gnu"
PKG_CONFIG_PATH32=/usr/lib/pkgconfig
PKG_CONFIG_PATH=/usr/lib/pkgconfig
ACLOCAL="aclocal -I $XORG_PREFIX/share/aclocal"

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
export CLFS_TARGET32="i686-pc-linux-gnu"
export PKG_CONFIG_PATH32=/usr/lib/pkgconfig
export PKG_CONFIG_PATH=/usr/lib/pkgconfig
export ACLOCAL="aclocal -I $XORG_PREFIX/share/aclocal"

cd ${CLFSSOURCES}
cd ${CLFSSOURCES/xc}

export XORG_PREFIX="/usr"
export XORG_CONFIG32="--prefix=$XORG_PREFIX --sysconfdir=/etc --localstatedir=/var \
  --libdir=$XORG_PREFIX/lib"
  
XORG_CONFIG32="--prefix=$XORG_PREFIX --sysconfdir=/etc --localstatedir=/var \
  --libdir=$XORG_PREFIX/lib"

#Add this point you COULD install Linux-PAM
#If you did not already
#Uncomment Apps because I think it is more likely you want 32-bit libraries

#Xorg Apps
#cat > app-7.md5 << "EOF"
#25dab02f8e40d5b71ce29a07dc901b8c  iceauth-1.0.7.tar.bz2
#c4a3664e08e5a47c120ff9263ee2f20c  luit-1.1.1.tar.bz2
#18c429148c96c2079edda922a2b67632  mkfontdir-1.0.7.tar.bz2
#9bdd6ebfa62b1bbd474906ac86a40fd8  mkfontscale-1.1.2.tar.bz2
#e475167a892b589da23edf8edf8c942d  sessreg-1.1.1.tar.bz2
#2c47a1b8e268df73963c4eb2316b1a89  setxkbmap-1.3.1.tar.bz2
#3a93d9f0859de5d8b65a68a125d48f6a  smproxy-1.0.6.tar.bz2
#f0b24e4d8beb622a419e8431e1c03cd7  x11perf-1.6.0.tar.bz2
#f3f76cb10f69b571c43893ea6a634aa4  xauth-1.0.10.tar.bz2
#0066f23f69ca3ef62dcaeb74a87fdc48  xbacklight-1.2.1.tar.bz2
#9956d751ea3ae4538c3ebd07f70736a0  xcmsdb-1.0.5.tar.bz2
#b58a87e6cd7145c70346adad551dba48  xcursorgen-1.0.6.tar.bz2
#8809037bd48599af55dad81c508b6b39  xdpyinfo-1.3.2.tar.bz2
#fceddaeb08e32e027d12a71490665866  xdriinfo-1.0.5.tar.bz2
#249bdde90f01c0d861af52dc8fec379e  xev-1.2.2.tar.bz2
#90b4305157c2b966d5180e2ee61262be  xgamma-1.0.6.tar.bz2
#f5d490738b148cb7f2fe760f40f92516  xhost-1.0.7.tar.bz2
#6a889412eff2e3c1c6bb19146f6fe84c  xinput-1.6.2.tar.bz2
#cc22b232bc78a303371983e1b48794ab  xkbcomp-1.4.0.tar.bz2
#c747faf1f78f5a5962419f8bdd066501  xkbevd-1.1.4.tar.bz2
#502b14843f610af977dffc6cbf2102d5  xkbutils-1.0.4.tar.bz2
#0ae6bc2a8d3af68e9c76b1a6ca5f7a78  xkill-1.0.4.tar.bz2
#5dcb6e6c4b28c8d7aeb45257f5a72a7d  xlsatoms-1.1.2.tar.bz2
#9fbf6b174a5138a61738a42e707ad8f5  xlsclients-1.1.3.tar.bz2
#2dd5ae46fa18abc9331bc26250a25005  xmessage-1.0.4.tar.bz2
#723f02d3a5f98450554556205f0a9497  xmodmap-1.0.9.tar.bz2
#6101f04731ffd40803df80eca274ec4b  xpr-1.0.4.tar.bz2
#fae3d2fda07684027a643ca783d595cc  xprop-1.2.2.tar.bz2
#ebffac98021b8f1dc71da0c1918e9b57  xrandr-1.5.0.tar.bz2
#b54c7e3e53b4f332d41ed435433fbda0  xrdb-1.1.0.tar.bz2
#a896382bc53ef3e149eaf9b13bc81d42  xrefresh-1.0.5.tar.bz2
#dcd227388b57487d543cab2fd7a602d7  xset-1.2.3.tar.bz2
#7211b31ec70631829ebae9460999aa0b  xsetroot-1.1.1.tar.bz2
#558360176b718dee3c39bc0648c0d10c  xvinfo-1.1.3.tar.bz2
#6b5d48464c5f366e91efd08b62b12d94  xwd-1.0.6.tar.bz2
#b777bafb674555e48fd8437618270931  xwininfo-1.1.3.tar.bz2
#3025b152b4f13fdffd0c46d0be587be6  xwud-1.0.4.tar.bz2
#EOF
#
#mkdir app
#cd app
#
#grep -v '^#' ../app-7.md5 | awk '{print $2}' | wget -i- -c \
#    -B https://www.x.org/pub/individual/app/ &&
#md5sum -c ../app-7.md5
#
#PKG_CONFIG_PATH="${PKG_CONFIG_PATH32}" \
#USE_ARCH=32 CC="gcc ${BUILD32}" CXX="g++ ${BUILD32}"
#
#for package in $(grep -v '^#' ../app-7.md5 | awk '{print $2}')
#do
#  packagedir=${package%.tar.bz2}
#  tar -xf $package
#  pushd $packagedir
#     case $packagedir in
#       luit-[0-9]* )
#         sed -i -e "/D_XOPEN/s/5/6/" configure
#       ;;
#esac
#
#    ./configure $XORG_CONFIG32
#     make PREFIX=/usr LIBDIR=/usr/lib
#     as_root make PREFIX=/usr LIBDIR=/usr/lib install
#  popd
#  rm -rf $packagedir
#done
#as_root rm -f $XORG_PREFIX/bin/xkeystone

export PKG_CONFIG_PATH="${PKG_CONFIG_PATH32}"

cd ${CLFSSOURCES}/xc

#xcursor-themes 32-bit
wget https://www.x.org/pub/individual/data/xcursor-themes-1.0.4.tar.bz2 -O \
  xcursor-themes-1.0.4.tar.bz2 
  
mkdir xcursor-themes && tar xf xcursor-themes-*.tar.* -C xcursor-themes --strip-components 1
cd xcursor-themes

buildSingleXLib32

cd ${CLFSSOURCES}/xc
checkBuiltPackage
rm -rf xcursor-themes

#Xorg Fonts
cat > font-7.md5 << "EOF"
23756dab809f9ec5011bb27fb2c3c7d6  font-util-1.3.1.tar.bz2
0f2d6546d514c5cc4ecf78a60657a5c1  encodings-1.0.4.tar.bz2
6d25f64796fef34b53b439c2e9efa562  font-alias-1.0.3.tar.bz2
fcf24554c348df3c689b91596d7f9971  font-adobe-utopia-type1-1.0.4.tar.bz2
e8ca58ea0d3726b94fe9f2c17344be60  font-bh-ttf-1.0.3.tar.bz2
53ed9a42388b7ebb689bdfc374f96a22  font-bh-type1-1.0.3.tar.bz2
bfb2593d2102585f45daa960f43cb3c4  font-ibm-type1-1.0.3.tar.bz2
6306c808f7d7e7d660dfb3859f9091d2  font-misc-ethiopic-1.0.3.tar.bz2
3eeb3fb44690b477d510bbd8f86cf5aa  font-xfree86-type1-1.0.4.tar.bz2
EOF

mkdir font
cd font

grep -v '^#' ../font-7.md5 | awk '{print $2}' | wget -i- -c \
    -B https://www.x.org/pub/individual/font/ &&
md5sum -c ../font-7.md5

export PKG_CONFIG_PATH="${PKG_CONFIG_PATH32}"

for package in $(grep -v '^#' ../font-7.md5 | awk '{print $2}')
do
  packagedir=${package%.tar.bz2}
  tar -xf $package
  pushd $packagedir
  
  PKG_CONFIG_PATH="${PKG_CONFIG_PATH32}" \
  USE_ARCH=32 CC="gcc ${BUILD32}" \
  CXX="g++ ${BUILD32}" ./configure $XORG_CONFIG32 &&
  make PREFIX=/usr 
  as_root make PREFIX=/usr install
  popd
  as_root rm -rf $packagedir
done

cd ${CLFSSOURCES}/xc
cd ${CLFSSOURCES}

#XML::Parser (Perl module) 32-bit
wget http://cpan.metacpan.org/authors/id/T/TO/TODDR/XML-Parser-2.44.tar.gz -O \
  XML-Parser-2.44.tar.gz

mkdir xmlparser && tar xf XML-Parser-*.tar.* -C xmlparser --strip-components 1
cd xmlparser

USE_ARCH=32 PKG_CONFIG_PATH="${PKG_CONFIG_PATH32}" \
CC="gcc ${BUILD32}" CXX="g++ ${BUILD32}" perl Makefile.PL

make PREFIX=/usr LIBDIR=/usr/lib

make PREFIX=/usr LIBDIR=/usr/lib test
checkBuiltPackage
as_root make PREFIX=/usr LIBDIR=/usr/lib install

cd ${CLFSSOURCES}
checkBuiltPackage
rm -rf xmlparser

#intltool 32-bit
wget https://launchpad.net/intltool/trunk/0.51.0/+download/intltool-0.51.0.tar.gz -O \
  intltool-0.51.0.tar.gz

mkdir intltool && tar xf intltool-*.tar.* -C intltool --strip-components 1
cd intltool

patch -Np1 -i ../intltool-0.51.0-perl-5.22-compatibility.patch

USE_ARCH=32 PKG_CONFIG_PATH="${PKG_CONFIG_PATH32}" \
CC="gcc ${BUILD32}" CXX="g++ ${BUILD32}" ./configure --prefix=/usr \
  --libdir=/usr/lib

make PREFIX=/usr LIBDIR=/usr/lib

make PREFIX=/usr LIBDIR=/usr/lib check
checkBuiltPackage
as_root make PREFIX=/usr LIBDIR=/usr/lib install


cd ${CLFSSOURCES}
checkBuiltPackage
rm -rf intltool

#XKeyboardConfig 32-bit
wget http://xorg.freedesktop.org/archive/individual/data/xkeyboard-config/xkeyboard-config-2.21.tar.bz2 -O \
  xkeyboard-config-2.21.tar.bz2

mkdir xkeyboard-config && tar xf xkeyboard-config-*.tar.* -C xkeyboard-config --strip-components 1
cd xkeyboard-config

#REMEMBER
#Escape all { or }
#In intltool-update
#When there is a regex ${<something>}
#Lines 1065, 1222-1226, 1993-1996

nano /usr/bin/intltool-update

PKG_CONFIG_PATH="${PKG_CONFIG_PATH32}" \
USE_ARCH=32 CC="gcc ${BUILD32}" \
CXX="g++ ${BUILD32}" ./configure $XORG_CONFIG32 \
    --with-xkb-rules-symlink=xorg &&
    
make PREFIX=/usr LIBDIR=/usr/lib
as_root make PREFIX=/usr LIBDIR=/usr/lib install

cd ${CLFSSOURCES}/xc
checkBuiltPackage
rm -rf xkeyboard-config

#libepoxy 32-bit
wget https://github.com/anholt/libepoxy/releases/download/1.4.3/libepoxy-1.4.3.tar.xz -O \
  libepoxy-1.4.3.tar.xz

mkdir libepoxy && tar xf libepoxy-*.tar.* -C libepoxy --strip-components 1
cd libepoxy

PKG_CONFIG_PATH="${PKG_CONFIG_PATH32}" \
USE_ARCH=32 CC="gcc ${BUILD32}"  \
CXX="g++ ${BUILD32}" ./configure --prefix=/usr \
    --libdir=/usr/lib &&
make PREFIX=/usr LIBDIR=/usr/lib
as_root make PREFIX=/usr LIBDIR=/usr/lib install

cd ${CLFSSOURCES}/xc
checkBuiltPackage
rm -rf libepoxy

#Pixman 32-bit
wget http://cairographics.org/releases/pixman-0.34.0.tar.gz -O \
  pixman-0.34.0.tar.gz

mkdir pixman && tar xf pixman-*.tar.* -C pixman --strip-components 1
cd pixman

PKG_CONFIG_PATH="${PKG_CONFIG_PATH32}" \
USE_ARCH=32 CC="gcc ${BUILD32}" \
CXX="g++ ${BUILD32}" ./configure --prefix=/usr \
  --disable-static \
  --libdir=/usr/lib &&
  
make PREFIX=/usr LIBDIR=/usr/lib
as_root make PREFIX=/usr LIBDIR=/usr/lib install

cd ${CLFSSOURCES}/xc
checkBuiltPackage
rm -rf pixman

#Xorg Server 32-bit
wget https://www.x.org/pub/individual/xserver/xorg-server-1.19.3.tar.bz2 -O \
  xorg-server-1.19.3.tar.bz2 

wget http://www.linuxfromscratch.org/patches/blfs/svn/xorg-server-1.19.3-add_prime_support-1.patch -O \
  Xorg-server-1.19.3-add_prime_support-1.patch
  
mkdir xorg-server && tar xf xorg-server-*.tar.* -C xorg-server --strip-components 1
cd xorg-server

patch -Np1 -i ../xorg-server-1.19.3-add_prime_support-1.patch

PKG_CONFIG_PATH="${PKG_CONFIG_PATH32}" \
USE_ARCH=32 CC="gcc ${BUILD32}" \ 
CXX="g++ ${BUILD32}" ./configure $XORG_CONFIG32 \
           --enable-glamor          \
           --enable-install-setuid  \
           --enable-suid-wrapper    \
           --disable-systemd-logind \
           --with-xkb-output=/var/lib/xkb
           
make PREFIX=/usr LIBDIR=/usr/lib
ldconfig
make check
make PREFIX=/usr LIBDIR=/usr/lib install
mkdir -pv /etc/X11/xorg.conf.d

cat >> /etc/sysconfig/createfiles << "EOF"
/tmp/.ICE-unix dir 1777 root root
/tmp/.X11-unix dir 1777 root root
EOF

cd ${CLFSSOURCES}/xc
checkBuiltPackage
rm -rf xorg-server

#Xorg Drivers
#http://www.linuxfromscratch.org/blfs/view/svn/x/x7driver.html
#Check there if you want synaptips, wacom, nouveau, Intel or AMD drivers!

cd ${CLFSSOURCES}

#pcituils 32-bit
wget https://www.kernel.org/pub/software/utils/pciutils/pciutils-3.5.5.tar.xz -O \
  pciutils-3.5.5.tar.xz

mkdir pciutils && tar xf pciutils-*.tar.* -C pciutils --strip-components 1
cd pciutils

PKG_CONFIG_PATH="${PKG_CONFIG_PATH32}" \
USE_ARCH=32 CC="gcc ${BUILD32}" \ 
CXX="g++ ${BUILD32}" \
make PREFIX=/usr                \
     SHAREDIR=/usr/share/hwdata \
     LIBDIR=/usr/lib            \
     SHARED=yes

as_root make PREFIX=/usr        \
     SHAREDIR=/usr/share/hwdata \
     LIBDIR=/usr/lib            \
     SHARED=yes                 \
     install install-lib        &&

as_root chmod -v 755 /usr/lib/libpci.so

cd ${CLFSSOURCES}
checkBuiltPackage
rm -rf xorg-server

cd ${CLFSSOURCES}/xc

#libevdev 32-bit
wget http://www.freedesktop.org/software/libevdev/libevdev-1.5.7.tar.xz -O \
  libevdev-1.5.7.tar.xz

mkdir libevdev && tar xf libevdev-*.tar.* -C libevdev --strip-components 1
cd libevdev

buildSingleXLib32

cd ${CLFSSOURCES}/xc
checkBuiltPackage
rm -rf libevdev

#Xorg Evdev Driver 32-bit
wget https://www.x.org/pub/individual/driver/xf86-input-evdev-2.10.5.tar.bz2 -O \
  xf86-input-evdev-2.10.5.tar.bz2
  
mkdir xf86-input-evdev && tar xf xf86-input-evdev-*.tar.* -C xf86-input-evdev --strip-components 1
cd xf86-input-evdev

buildSingleXLib32

cd ${CLFSSOURCES}
checkBuiltPackage
rm -rf xf86-input-evdev

#mtdev 32-bit
wget http://bitmath.org/code/mtdev/mtdev-1.1.5.tar.bz2 -O \
  mtdev-1.1.5.tar.bz2
  
mkdir mtdev && tar xf mtdev-*.tar.* -C mtdev --strip-components 1
cd mtdev

PKG_CONFIG_PATH="${PKG_CONFIG_PATH32}" \
USE_ARCH=32 CC="gcc ${BUILD32}" \
CXX="g++ ${BUILD32}" ./configure --prefix=/usr \
  --disable-static \
  --libdir=/usr/lib
  
make PREFIX=/usr LIBDIR=/usr/lib
as_root make PREFIX=/usr LIBDIR=/usr/lib install

cd ${CLFSSOURCES}/xc
checkBuiltPackage
rm -rf mtdev

#libinput 32-bit
wget http://www.freedesktop.org/software/libinput/libinput-1.8.0.tar.xz -O \
  libinput-1.8.0.tar.xz

mkdir libinput && tar xf libinput-*.tar.* -C libinput --strip-components 1
cd libinput

PKG_CONFIG_PATH="${PKG_CONFIG_PATH32}" \
USE_ARCH=32 \
CC="gcc ${BUILD32}" \
CXX="g++ ${BUILD32}" ./configure $XORG_CONFIG32 \
            --disable-libwacom      \
            --disable-debug-gui     \
            --disable-tests         \
            --libdir=/usr/lib       \
            --disable-documentation \
            --with-udev-dir=/lib/udev && 
            
make PREFIX=/usr LIBDIR=/usr/lib
as_root make PREFIX=/usr LIBDIR=/usr/lib install

cd ${CLFSSOURCES}/xc
checkBuiltPackage
rm -rf libinput

#Xorg Fbdev Driver 32-bit
wget https://www.x.org/pub/individual/driver/xf86-video-fbdev-0.4.4.tar.bz2 -O \
  xf86-video-fbdev-0.4.4.tar.bz2
  
mkdir xf86vidfbdev && tar xf xf86-video-fbdev-*.tar.* -C xf86vidfbdev --strip-components 1
cd xf86vidfbdev

buildSingleXLib32

cd ${CLFSSOURCES}/xc
checkBuiltPackage
rm -rf xf86vidfbdev

#THE PROPRIETARY NVIDIA DRIVER INSTALLATION CAN BE FOUND IN THE X64 SCRIPT

#I uncommented the applications, because I find it most likely
#that on a multilib system you want the 32-bit libraries if needed

##twm 32-bit
#wget https://www.x.org/pub/individual/app/twm-1.0.9.tar.bz2 -O \
#  twm-1.0.9.tar.bz2
#  
#mkdir twm && tar xf twm-*.tar.* -C twm --strip-components 1
#cd twm
#
#sed -i -e '/^rcdir =/s,^\(rcdir = \).*,\1/etc/X11/app-defaults,' src/Makefile.in
#
#buildSingleXLib32
#
#cd ${CLFSSOURCES}/xc
#checkBuiltPackage
#rm -rf twm
#
#USE_ARCH=32 PKG_CONFIG_PATH="${PKG_CONFIG_PATH32}" \
#CC="gcc ${BUILD32}" CXX="g++ ${BUILD32}"
#
#xterm 32-bit
#wget ftp://invisible-island.net/xterm/xterm-330.tgz -O \
#  xterm-330.tgz
#  
#mkdir xterm && tar xf xterm-*.tgz -C xterm --strip-components 1
#cd xterm
#
#sed -i '/v0/{n;s/new:/new:kb=^?:/}' termcap &&
#printf '\tkbs=\\177,\n' >> terminfo &&
#
#USE_ARCH=32 PKG_CONFIG_PATH="${PKG_CONFIG_PATH32}" \
#CC="gcc ${BUILD32}" CXX="g++ ${BUILD32}" \
#TERMINFO=/usr/share/terminfo ./configure $XORG_CONFIG32     \
#    --with-app-defaults=/etc/X11/app-defaults &&
#
#make PREFIX=/usr LIBDIR=/usr/lib
#as_root make PREFIX=/usr LIBDIR=/usr/lib install 
#as_root make PREFIX=/usr LIBDIR=/usr/lib install-ti
#
#as_root cat >> /etc/X11/app-defaults/XTerm << "EOF"
#*VT100*locale: true
#*VT100*faceName: Monospace
#*VT100*faceSize: 10
#*backarrowKeyIsErase: true
#*ptyInitialErase: true
#EOF
#
#cd ${CLFSSOURCES}/xc
#checkBuiltPackage
#rm -rf xterm
#
##xclock 32-bit
#wget https://www.x.org/pub/individual/app/xclock-1.0.7.tar.bz2 -O \
#  xclock-1.0.7.tar.bz2
#
#mkdir xclock && tar xf xclock-*.tar.* -C xclock --strip-components 1
#cd xclock
#
#buildSingleXLib32
#
#cd ${CLFSSOURCES}/xc
#checkBuiltPackage
#rm -rf xclock
#
##xinit 32-bit
#wget https://www.x.org/pub/individual/app/xinit-1.0.7.tar.bz2 -O \
#  xinit-1.0.7.tar.bz2
#
#mkdir xinit && tar xf xinit-*.tar.* -C xinit --strip-components 1
#cd xinit
#
#sed -e '/$serverargs $vtarg/ s/serverargs/: #&/' \
#    -i startx.cpp
#
#USE_ARCH=32 PKG_CONFIG_PATH="${PKG_CONFIG_PATH32}" \
#CC="gcc ${BUILD32}" \
#CXX="g++ ${BUILD32}" ./configure $XORG_CONFIG32 \
#    --with-xinitdir=/etc/X11/app-defaults &&
#    
#make PREFIX=/usr LIBDIR=/usr/lib
#as_root make PREFIX=/usr LIBDIR=/usr/lib install
#as_root ldconfig
#
#cd ${CLFSSOURCES}/xc
#checkBuiltPackage
#rm -rf xinit

#DejaVu Fonts
#These are architecture independent and are installed in the 64-bit version of the script
