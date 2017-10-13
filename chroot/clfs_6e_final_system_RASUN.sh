#!/bin/bash

function checkBuiltPackage() {
echo " "
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
echo " "
}

#Building the final CLFS System
CLFS=/
CLFSSOURCES=/sources
MAKEFLAGS="-j$(nproc)"
BUILD32="-m32"
BUILD64="-m64"
CLFS_TARGET32="i686-pc-linux-gnu"
PKG_CONFIG_PATH32=/usr/lib/pkgconfig
PKG_CONFIG_PATH64=/usr/lib64/pkgconfig

export CLFS=/
export CLFSSOURCES=/sources
export MAKEFLAGS="-j$(nproc)"
export BUILD32="-m32"
export BUILD64="-m64"
export CLFS_TARGET32="i686-pc-linux-gnu"
export PKG_CONFIG_PATH32=/usr/lib/pkgconfig
export PKG_CONFIG_PATH64=/usr/lib64/pkgconfig

#Tar
mkdir tar && tar xf tar-*.tar.* -C tar --strip-components 1
cd tar

FORCE_UNSAFE_CONFIGURE=1 CC="gcc ${BUILD64}" \
    PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
    USE_ARCH=64 \
    ./configure \
    --prefix=/usr \
    --libdir=/usr/lib64 \
    --bindir=/bin \
    --libexecdir=/usr/sbin &&

make
make check
checkBuiltPackage
make install
make -C doc install-html docdir=/usr/share/doc/tar-1.29

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf tar

#Texinfo
mkdir texinfo && tar xf texinfo-*.tar.* -C texinfo --strip-components 1
cd texinfo

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
    USE_ARCH=64 \
    PERL=/usr/bin/perl-64 \
    CC="gcc ${BUILD64}" \
    ./configure \
    --prefix=/usr \
    gl_cv_func_getopt_gnu=yes
    
       
    #Concerning the last line above
    #Needed for version 3.6 with glibc 2.26
    #Probably can be ommited again for later diffutil versions
    #https://patchwork.ozlabs.org/patch/809145/
    
make 
checkBuiltPackage
make install

make TEXMF=/usr/share/texmf install-tex

cd ${CLFSSOURCES} 
#checkBuiltPackage
rm -rf texinfo

#Gperf 32-bit
#Added because eudev 3.2.2 needs it!
mkdir gperf && tar xf gperf-*.tar.* -C gperf --strip-components 1
cd gperf

PKG_CONFIG_PATH="${PKG_CONFIG_PATH32}" \
USE_ARCH=32 GCC="gcc ${BUILD32}"\
    CXX="g++ ${BUILD32}" \
    ./configure --prefix=/usr \
    --docdir=/usr/share/doc/gperf-3.0.4 \
    --libdir=/usr/lib &&

PREFIX=/usr LIBDIR=/usr/lib make
PREFIX=/usr LIBDIR=/usr/lib make install

install -m644 -v doc/gperf.{dvi,ps,pdf} \
                 /usr/share/doc/gperf-3.0.4 &&

pushd /usr/share/info &&
rm -v dir &&
for FILENAME in *; do
    install-info $FILENAME dir 2>/dev/null
done &&
popd

cd ${CLFSSOURCES}
checkBuiltPackage
rm -rf gperf

#Eudev 32-bit
mkdir eudev && tar xf eudev-*.tar.* -C eudev --strip-components 1
cd eudev

PKG_CONFIG_PATH="${PKG_CONFIG_PATH32}" \
USE_ARCH=32 \
CC="gcc ${BUILD32}" ./configure --prefix=/usr --sysconfdir=/etc \
    --with-rootprefix="" --libexecdir=/lib --enable-split-usr \
    --libdir=/usr/lib --with-rootlibdir=/lib --sbindir=/sbin --bindir=/sbin \
    --enable-rule_generator --disable-introspection --disable-keymap \
    --disable-gudev --disable-gtk-doc-html --enable-libkmod

make
make check
checkBuiltPackage
make install

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf eudev

#Gperf 64-bit
#Added because eudev 3.2.2 needs it!
mkdir gperf && tar xf gperf-*.tar.* -C gperf --strip-components 1
cd gperf

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
USE_ARCH=64 GCC="gcc ${BUILD64}"\
    CXX="g++ ${BUILD64}" \
    ./configure --prefix=/usr \
    --docdir=/usr/share/doc/gperf-3.0.4 \
    --libdir=/usr/lib64 &&

PREFIX=/usr LIBDIR=/usr/lib64 make
PREFIX=/usr LIBDIR=/usr/lib64 make install

cd ${CLFSSOURCES}
checkBuiltPackage
rm -rf gperf

#Eudev 64-bit
mkdir eudev && tar xf eudev-*.tar.* -C eudev --strip-components 1
cd eudev

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
USE_ARCH=64 \
CC="gcc ${BUILD64}" ./configure --prefix=/usr --sysconfdir=/etc \
    --with-rootprefix="" --libexecdir=/lib64 --libdir=/usr/lib64 \
    --with-rootlibdir=/lib64 --sbindir=/sbin --bindir=/sbin \
    --enable-split-usr --enable-rule_generator --disable-introspection \
    --disable-keymap --disable-gudev --disable-gtk-doc-html \
    --with-firmware-path=/lib/firmware --enable-libkmod

make && make check
checkBuiltPackage
make install
install -dv /lib/firmware

echo "# dummy, so that network is once again on eth*" \
> /etc/udev/rules.d/80-net-name-slot.rules

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf eudev

#Util-linux 64 Bit
mkdir util-linux && tar xf util-linux-*.tar.* -C util-linux --strip-components 1
cd util-linux

mkdir -pv /var/lib/hwclock

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
USE_ARCH=64 \
CC="gcc ${BUILD64}" ./configure \
    ADJTIME_PATH=/var/lib/hwclock/adjtime \
    --libdir=/lib64 \
    --enable-write \
    --disable-chfn-chsh \
    --disable-login \
    --disable-nologin \
    --disable-su \
    --disable-setpriv \
    --disable-runuser \
    --docdir=/usr/share/doc/util-linux-2.29.2

make 

chown -Rv nobody . &&
su nobody -s /bin/bash -c "PATH=$PATH make -k check"
checkBuiltPackage

make install
mv -v /usr/bin/logger /bin

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf util-linux

#Vim
mkdir vim && tar xf vim-*.tar.* -C vim --strip-components 1
cd vim

patch -Np1 -i ../vim-8.0-branch_update-1.patch

echo '#define SYS_VIMRC_FILE "/etc/vimrc"' >> src/feature.h

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
./configure \
    --prefix=/usr

make
#make test
checkBuiltPackage
make -j1 install

ln -sv vim /usr/bin/vi

ln -sv ../vim/vim0597/doc /usr/share/doc/vim-8.0

cat > /etc/vimrc << "EOF"
" Begin /etc/vimrc

set nocompatible
set backspace=2
set ruler
syntax on
if (&term == "iterm") || (&term == "putty")
  set background=dark
endif

" End /etc/vimrc
EOF

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf vim

#Nano
mkdir nano && tar xf nano-*.tar.* -C nano --strip-components 1
cd nano

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
CC="gcc ${BUILD64}" ./configure \
    --prefix=/usr \
    --libdir=/tools/lib64

make && make install

cat > /etc/nanorc << "EOF"
set autoindent
set const
set fill 72
set historylog
set multibuffer
set nohelp
set regexp
set smooth
set suspend
EOF

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf nano
#Exiting....


echo " "
echo "Next execute script #7.1 for UEFI boot. Legacy boot option will maybe never follow. Low priority!"
echo " "

exit
