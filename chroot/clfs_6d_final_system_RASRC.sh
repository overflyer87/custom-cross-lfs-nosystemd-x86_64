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

#Chapter 10.61 
#Continuing after new Bash login

cd ${CLFSSOURCES}

#Bc
mkdir bc && tar xf bc-*.tar.* -C bc --strip-components 1
cd bc

cat > bc/fix-libmath_h << "EOF"
#! /bin/bash
sed -e '1   s/^/{"/' \
    -e     's/$/",/' \
    -e '2,$ s/^/"/'  \
    -e   '$ d'       \
    -i libmath.h

sed -e '$ s/$/0}/' \
-i libmath.h
EOF

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
CC="gcc ${BUILD64}" \
./configure \
    --prefix=/usr \
    --mandir=/usr/share/man \
    --infodir=/usr/share/info

make
echo "quit" | ./bc/bc -l Test/checklib.b
checkBuiltPackage
make install

cd ${CLFSSOURCES}
checkBuiltPackage
rm -rf bc

#Diffutils
mkdir diffutils && tar xf diffutils-*.tar.* -C diffutils --strip-components 1
cd diffutils

sed -i 's:= @mkdir_p@:= /bin/mkdir -p:' po/Makefile.in.in

CC="gcc ${BUILD64}" \
./configure \
    --prefix=/usr \
    gl_cv_func_getopt_gnu=yes
    
    #Concerning the last line above
    #Needed for version 3.6 with glibc 2.26
    #Probably can be ommited again for later diffutil versions
    #https://patchwork.ozlabs.org/patch/809145/

sed -i 's@\(^#define DEFAULT_EDITOR_PROGRAM \).*@\1"vi"@' lib/config.h

make
make check
checkBuiltPackage
make install

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf diffutils

#File 32-bit
mkdir file && tar xf file-*.tar.* -C file --strip-components 1
cd file

PKG_CONFIG_PATH="${PKG_CONFIG_PATH32}" \
CC="gcc ${BUILD32}" \
./configure \
    --prefix=/usr

make
make check
checkBuiltPackage
make install

cd ${CLFSSOURCES} 
#checkBuiltPackage
rm -rf file

#File 64-bit
mkdir file && tar xf file-*.tar.* -C file --strip-components 1
cd file

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
CC="gcc ${BUILD64}" \
./configure \
    --prefix=/usr \
    --libdir=/usr/lib64

make
make check
checkBuiltPackage
make install

cd ${CLFSSOURCES} 
#checkBuiltPackage
rm -rf file

#Gawk
mkdir gawk && tar xf gawk-*.tar.* -C gawk --strip-components 1
cd gawk

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
CC="gcc ${BUILD64}" ./configure \
    --prefix=/usr \
    --libexecdir=/usr/lib64

make
make check
checkBuiltPackage
make install

mkdir -v /usr/share/doc/gawk-4.1.4
cp -v doc/{awkforai.txt,*.{eps,pdf,jpg}} /usr/share/doc/gawk-4.1.4

cd ${CLFSSOURCES} 
#checkBuiltPackage
rm -rf gawk

#Findutils
mkdir findutils && tar xf findutils-*.tar.* -C findutils --strip-components 1
cd findutils

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
CC="gcc ${BUILD64}" \
./configure \
    --prefix=/usr \
    --libexecdir=/usr/lib64/locate \
    --localstatedir=/var/lib64/locate

make
make check
checkBuiltPackage
make install

cd ${CLFSSOURCES} 
#checkBuiltPackage
rm -rf findutils

#Gettext 32-bit
mkdir gettext && tar xf gettext-*.tar.* -C gettext --strip-components 1
cd gettext

PKG_CONFIG_PATH="${PKG_CONFIG_PATH32}" \
CC="gcc ${BUILD32}" CXX="g++ ${BUILD32}" \
./configure \
    --prefix=/usr \
    --docdir=/usr/share/doc/gettext-0.19.8.1

make
make check
checkBuiltPackage
make install

cd ${CLFSSOURCES} 
#checkBuiltPackage
rm -rf gettext

#Gettext 64-bit
mkdir gettext && tar xf gettext-*.tar.* -C gettext --strip-components 1
cd gettext

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
./configure \
    --prefix=/usr \
    --libdir=/usr/lib64 \
    --docdir=/usr/share/doc/gettext-0.19.8.1

make
make check
checkBuiltPackage
make install

cd ${CLFSSOURCES} 
#checkBuiltPackage
rm -rf gettext

#libffi 32-bit
mkdir libffi && tar xf libffi-*.tar.* -C libffi --strip-components 1
cd libffi

sed -e '/^includesdir/ s/$(libdir).*$/$(includedir)/' \
    -i include/Makefile.in

sed -e '/^includedir/ s/=.*$/=@includedir@/' \
    -e 's/^Cflags: -I${includedir}/Cflags:/' \
    -i libffi.pc.in

USE_ARCH=32 PKG_CONFIG_PATH="${PKG_CONFIG_PATH32}" \
CC="gcc ${BUILD32}" ./configure \
    --prefix=/usr \
	--libdir=/usr/lib \
	--disable-static

make PREFIX=/usr LIBDIR=/usr/lib
make check
checkBuiltPackage
make install

cd ${CLFSSOURCES}
checkBuiltPackage
rm -rf libffi

#libffi 64-bit
mkdir libffi && tar xf libffi-*.tar.* -C libffi --strip-components 1
cd libffi

sed -e '/^includesdir/ s/$(libdir).*$/$(includedir)/' \
    -i include/Makefile.in

sed -e '/^includedir/ s/=.*$/=@includedir@/' \
    -e 's/^Cflags: -I${includedir}/Cflags:/' \
    -i libffi.pc.in

USE_ARCH=64 PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
CC="gcc ${BUILD64}" ./configure \
    --prefix=/usr \
    --libdir=/usr/lib64 \
    --disable-static

make PREFIX=/usr LIBDIR=/usr/lib64
make check
checkBuiltPackage
make install

cd ${CLFSSOURCES}
checkBuiltPackage
rm -rf libffi

#Python 3 64-bit
wget https://www.python.org/ftp/python/3.6.3/Python-3.6.3.tar.xz -O \
  Python-3.6.3.tar.xz

#wget http://pkgs.fedoraproject.org/rpms/python3/raw/master/f/00102-lib64.patch -O \
#python360-multilib2.patch
  
#wget https://docs.python.org/3.6/archives/python-3.6.0-docs-html.tar.bz2 -O \
# python-360-docs.tar.bz2
  
mkdir Python-3 && tar xf Python-3.6*.tar.xz -C Python-3 --strip-components 1
cd Python-3

patch -Np1 -i ../python360-multilib.patch

checkBuiltPackage

############################################################################
#  Let's see later if adding /usr/lib64 to ld.so.conf is really neccessary #
############################################################################

USE_ARCH=64 CXX="/usr/bin/g++ ${BUILD64}" \
    CC="/usr/bin/gcc ${BUILD64}" \
    LD_LIBRARY_PATH=/usr/lib64 \
    LD_LIB_PATH=/usr/lib64 \
    LIBRARY_PATH=/usr/lib64 \
    PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" ./configure \
            --prefix=/usr       \
            --enable-shared     \
            --disable-static    \
            --with-system-expat \
            --with-system-ffi   \
            --libdir=/usr/lib64 \
            --with-custom-platlibdir=/usr/lib64 \
            --with-ensurepip=yes \
            LDFLAGS="-Wl,-rpath /usr/lib64"

LDFLAGS="-Wl,-rpath /usr/lib64" \
LD_LIBRARY_PATH=/usr/lib64 \
LD_LIB_PATH=/usr/lib64 \
LIBRARY_PATH=/usr/lib64 make PREFIX=/usr LIBDIR=/usr/lib64 PLATLIBDIR=/usr/lib64 \
  platlibdir=/usr/lib64

make altinstall PREFIX=/usr LIBDIR=/usr/lib64 PLATLIBDIR=/usr/lib64 \
  platlibdir=/usr/lib64
  
cp -rv /usr/lib/python3.6/ /usr/lib64/
rm -rf /usr/lib/python3.6/

chmod -v 755 /usr/lib64/libpython3.6m.so
chmod -v 755 /usr/lib64/libpython3.so

ln -svf /usr/lib64/libpython3.6m.so /usr/lib64/libpython3.6.so
ln -svf /usr/lib64/libpython3.6m.so.1.0 /usr/lib64/libpython3.6.so.1.0
ln -sfv /usr/bin/python3.6 /usr/bin/python3

cd ${CLFSSOURCES}
checkBuiltPackage
rm -rf Python-3

#Ninja
mkdir ninja && tar xf ninja-*.tar.* -C ninja --strip-components 1
cd ninja

CXX="g++ ${BUILD64}" USE_ARCH=64 CC="gcc ${BUILD64}" PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}"  \
python3 configure.py --bootstrap

CXX="g++ ${BUILD64}" USE_ARCH=64 CC="gcc ${BUILD64}" PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
python3 configure.py
./ninja ninja_test
./ninja_test --gtest_filter=-SubprocessTest.SetWithLots

install -vm755 ninja /usr/bin/
install -vDm644 misc/ninja.vim \
                /usr/share/vim/vim80/syntax/ninja.vim
install -vDm644 misc/bash-completion \
                /usr/share/bash-completion/completions/ninja
install -vDm644 misc/zsh-completion \
                /usr/share/zsh/site-functions/_ninja

cd ${CLFSSOURCES}
checkBuiltPackage
rm -rf ninja

#Meson
mkdir meson && tar xf meson-*.tar.* -C meson --strip-components 1
cd meson

CXX="g++ ${BUILD64}" USE_ARCH=64 CC="gcc ${BUILD64}" PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
python3 setup.py build
python3 setup.py install --verbose --prefix=/usr --install-lib=/usr/lib64/python3.6/site-packages --optimize=1


cd ${CLFSSOURCES}
checkBuiltPackage
rm -rf meson

#Grep
mkdir grep && tar xf grep-*.tar.* -C grep --strip-components 1
cd grep

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
CC="gcc ${BUILD64}" ./configure \
    --prefix=/usr \
    --bindir=/bin

make
make check
checkBuiltPackage
make install

cd ${CLFSSOURCES} 
#checkBuiltPackage
rm -rf grep

#Groff
mkdir groff && tar xf groff-*.tar.* -C groff --strip-components 1
cd groff

USE_ARCH=64 PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
PAGE=A4 CC="gcc ${BUILD64}" \
CXX="g++ ${BUILD64}" ./configure \
    --prefix=/usr \
    --libdir=/usr/lib64

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" make -j1 PREFIX=/usr LIBDIR=/usr/lib64
make install

cd ${CLFSSOURCES}
checkBuiltPackage
rm -rf groff

#Less
mkdir less && tar xf less-*.tar.* -C less --strip-components 1
cd less

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
CC="gcc ${BUILD64}" ./configure \
    --prefix=/usr \
    --sysconfdir=/etc

make
make install
mv -v /usr/bin/less /bin

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf less

#Gzip
mkdir gzip && tar xf gzip-*.tar.* -C gzip --strip-components 1
cd gzip

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
CC="gcc ${BUILD64}" \
./configure \
    --prefix=/usr \
    --bindir=/bin

make
make PERL=perl-64 check
checkBuiltPackage
make install

mv -v /bin/{gzexe,uncompress} /usr/bin
mv -v /bin/z{egrep,cmp,diff,fgrep,force,grep,less,more,new} /usr/bin

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf gzip

#IPUtils
mkdir iputils && tar xf iputils-*.tar.* -C iputils --strip-components 1
cd iputils

patch -Np1 -i ../iputils-s20150815-build-1.patch

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
make CC="gcc ${BUILD64}" USE_CAP=no \
    TARGETS="clockdiff ping rdisc tracepath tracepath6 traceroute6"

install -v -m755 ping /bin
install -v -m755 clockdiff /usr/bin
install -v -m755 rdisc /usr/bin
install -v -m755 tracepath /usr/bin
install -v -m755 trace{path,route}6 /usr/bin
install -v -m644 doc/*.8 /usr/share/man/man8
ln -sv ping /bin/ping4
ln -sv ping /bin/ping6

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf iputils

#Kbd
mkdir kbd && tar xf kbd-*.tar.* -C kbd --strip-components 1
cd kbd

patch -Np1 -i ../kbd-2.0.4-backspace-1.patch

sed -i 's/\(RESIZECONS_PROGS=\)yes/\1no/g' configure
sed -i 's/resizecons.8 //' docs/man/man8/Makefile.in

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
CC="gcc ${BUILD64}" PKG_CONFIG_PATH="/tools/lib64/pkgconfig" \
./configure \
    --prefix=/usr \
    --disable-vlock \
    --enable-optional-progs

make
make check
checkBuiltPackage
make install

mv -v /usr/bin/{dumpkeys,kbd_mode,loadkeys,setfont} /bin

mkdir -v /usr/share/doc/kbd-2.0.4
cp -R -v docs/doc/* /usr/share/doc/kbd-2.0.4

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf kbd

#Libpipeline 32-bit
mkdir libpipeline && tar xf libpipeline-*.tar.* -C libpipeline --strip-components 1
cd libpipeline

PKG_CONFIG_PATH="${PKG_CONFIG_PATH32}" \
USE_ARCH=32 CC="gcc ${BUILD32}" \
./configure \
    --prefix=/usr

make
make install

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf libpipeline

#Libpipeline 64-bit
mkdir libpipeline && tar xf libpipeline-*.tar.* -C libpipeline --strip-components 1
cd libpipeline

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
USE_ARCH=64 CC="gcc ${BUILD64}" \
./configure \
    --prefix=/usr \
    --libdir=/usr/lib64

make
make check
checkBuiltPackage
make install

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf libpipeline

#Man-DB
mkdir man-db && tar xf man-db-*.tar.* -C man-db --strip-components 1
cd man-db

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
USE_ARCH=64 CC="gcc ${BUILD64}" \
./configure \
    --prefix=/usr \
    --libexecdir=/usr/lib64 \
    --docdir=/usr/share/doc/man-db-2.7.6.1 \
    --sysconfdir=/etc \
    --libdir=/usr/lib64 \
    --disable-setuid \
    --enable-cache-owner=bin \
    --with-browser=/usr/bin/lynx \
    --with-vgrind=/usr/bin/vgrind \
    --with-grap=/usr/bin/grap

make
make check
checkBuiltPackage
make install

cd ${CLFSSOURCES} 
#checkBuiltPackage
rm -rf man-db

#Make
mkdir make && tar xf make-*.tar.* -C make --strip-components 1
cd make

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
CC="gcc ${BUILD64}" ./configure \
    --prefix=/usr

make
make check
checkBuiltPackage
make install

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf make

#XZ 32-bit
mkdir xz && tar xf xz-*.tar.* -C xz --strip-components 1
cd xz

PKG_CONFIG_PATH="${PKG_CONFIG_PATH32}" \
CC="gcc ${BUILD32}" ./configure \
    --prefix=/usr \
    --docdir=/usr/share/doc/xz-5.2.3

make
make check
checkBuiltPackage
make install

mv -v /usr/lib/liblzma.so.* /lib
ln -sfv ../../lib/$(readlink /usr/lib/liblzma.so) /usr/lib/liblzma.so

cd ${CLFSSOURCES} 
#checkBuiltPackage
rm -rf xz-utils

#XZ 64-bit
mkdir xz && tar xf xz-*.tar.* -C xz --strip-components 1
cd xz

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
CC="gcc ${BUILD64}" ./configure \
    --prefix=/usr \
    --libdir=/usr/lib64 \
    --docdir=/usr/share/doc/xz-5.2.3

make
make check
checkBuiltPackage
make install

mv -v /usr/bin/{xz,lzma,lzcat,unlzma,unxz,xzcat} /bin

mv -v /usr/lib64/liblzma.so.* /lib64
ln -sfv ../../lib64/$(readlink /usr/lib64/liblzma.so) /usr/lib64/liblzma.so

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf xz-utils

#Kmod 32-bit
mkdir kmod && tar xf kmod-*.tar.* -C kmod --strip-components 1
cd kmod

PKG_CONFIG_PATH="${PKG_CONFIG_PATH32}" \
USE_ARCH=32 CC="gcc ${BUILD32}" \
./configure \
    --prefix=/usr \
    --bindir=/bin \
    --sysconfdir=/etc \
    --with-rootlibdir=/lib \
    --libdir=/usr/lib \
    --with-zlib \
    --with-xz

make
make check
checkBuiltPackage
make install

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf kmod

#Kmod 64-bit
mkdir kmod && tar xf kmod-*.tar.* -C kmod --strip-components 1
cd kmod

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
USE_ARCH=64 CC="gcc ${BUILD64}" \
./configure \
    --prefix=/usr \
    --bindir=/bin \
    --sysconfdir=/etc \
    --with-rootlibdir=/lib64 \
    --libdir=/usr/lib64 \
    --with-zlib \
    --with-xz

make
make check
checkBuiltPackage
make install

ln -sfv kmod /bin/lsmod
for tool in depmod insmod modinfo modprobe rmmod; do
    ln -sfv ../bin/kmod /sbin/${tool}
done

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf kmod

#Patch
mkdir patch && tar xf patch-*.tar.* -C patch --strip-components 1
cd patch

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
USE_ARCH=64 CC="gcc ${BUILD64}" ./configure \
    --prefix=/usr --libdir=/usr/lib64

make
make check
checkBuiltPackage
make install

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf patch

#Psmisc
mkdir psmisc && tar xf psmisc-*.tar.* -C psmisc --strip-components 1
cd psmisc

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
CC="gcc ${BUILD64}" ./configure \
    --prefix=/usr

make
make install

mv -v /usr/bin/fuser /bin
mv -v /usr/bin/killall /bin

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf psmisc


#Libestr 32-bit
mkdir libestr && tar xf libestr-*.tar.* -C libestr --strip-components 1
cd libestr

PKG_CONFIG_PATH="${PKG_CONFIG_PATH32}" \
    CC="gcc ${BUILD32}" \
    USE_ARCH=32 \
    ./configure --prefix=/usr --libdir=/usr/lib

make 
make install

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf libestr

#Libestr 64-bit
mkdir libestr && tar xf libestr-*.tar.* -C libestr --strip-components 1
cd libestr

CC="gcc ${BUILD64}" \
    PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
    USE_ARCH=64 \
    ./configure --prefix=/usr \
    --libdir=/usr/lib64 

make 
make install

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf libestr

#Libee 32-bit
mkdir libee && tar xf libee-*.tar.* -C libee --strip-components 1
cd libee

PKG_CONFIG_PATH="${PKG_CONFIG_PATH32}" \
    CC="gcc ${BUILD32}" \
    USE_ARCH=32 \
    ./configure --prefix=/usr --libdir=/usr/lib

make -j1
make -j1 install

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf libee

#Libee 64-bit
mkdir libee && tar xf libee-*.tar.* -C libee --strip-components 1
cd libee

CC="gcc ${BUILD64}" \
    PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
    USE_ARCH=64 \
    ./configure --prefix=/usr \
    --libdir=/usr/lib64 

make -j1
make -j1 install

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf libee

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
