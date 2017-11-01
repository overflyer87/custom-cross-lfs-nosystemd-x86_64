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
#wget http://pkgs.fedoraproject.org/rpms/python3/raw/master/f/00102-lib64.patch -O \
#python360-multilib2.patch
  
#wget https://docs.python.org/3.6/archives/python-3.6.3-docs-html.tar.bz2 -O \
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
python3 setup.py install --verbose --prefix=/usr/lib64 --install-lib=/usr/lib64/python3.6/site-packages --optimize=1


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
    --prefix=/usr

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
    ./configure --prefix=/usr && 

make && make install

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
    --libdir=/usr/lib64 && 

make && make install

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf libestr

#Libee 32-bit
mkdir libee && tar xf libee-*.tar.* -C libee --strip-components 1
cd libee

PKG_CONFIG_PATH="${PKG_CONFIG_PATH32}" \
    CC="gcc ${BUILD32}" \
    USE_ARCH=32 \
    ./configure --prefix=/usr && 

make -j1 && make -j1 install

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
    --libdir=/usr/lib64 && 

make -j1 && make -j1 install

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf libee


#Rsyslog
mkdir rsyslog && tar xf rsyslog-*.tar.* -C rsyslog --strip-components 1
cd rsyslog

CC="gcc ${BUILD64}" \
    PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
    USE_ARCH=64 \
    ./configure --prefix=/usr \
    --libdir=/usr/lib64 && 

make
make check
checkBuiltPackage
make install

install -dv /etc/rsyslog.d

cat > /etc/rsyslog.conf << "EOF"
# Begin /etc/rsyslog.conf

# CLFS configuration of rsyslog. For more info use man rsyslog.conf

#######################################################################
# Rsyslog Modules

# Support for Local System Logging
$ModLoad imuxsock.so

# Support for Kernel Logging
$ModLoad imklog.so

#######################################################################
# Global Options

# Use traditional timestamp format.
$ActionFileDefaultTemplate RSYSLOG_TraditionalFileFormat

# Set the default permissions for all log files.
$FileOwner root
$FileGroup root
$FileCreateMode 0640
$DirCreateMode 0755

# Provides UDP reception
$ModLoad imudp
$UDPServerRun 514

# Disable Repeating of Entries
$RepeatedMsgReduction on

#######################################################################
# Include Rsyslog Config Snippets

$IncludeConfig /etc/rsyslog.d/*.conf

#######################################################################
# Standard Log Files

auth,authpriv.*                 /var/log/auth.log
*.*;auth,authpriv.none          -/var/log/syslog
daemon.*                        -/var/log/daemon.log
kern.*                          -/var/log/kern.log
lpr.*                           -/var/log/lpr.log
mail.*                          -/var/log/mail.log
user.*                          -/var/log/user.log

# Catch All Logs
*.=debug;\
        auth,authpriv.none;\
        news.none;mail.none     -/var/log/debug
*.=info;*.=notice;*.=warn;\
        auth,authpriv.none;\
        cron,daemon.none;\
        mail,news.none          -/var/log/messages

# Emergencies are shown to everyone
*.emerg                         *

# End /etc/rsyslog.conf
EOF

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf rsyslog

#Sysvinit
mkdir sysvinit && tar xf sysvinit-*.tar.* -C sysvinit --strip-components 1
cd sysvinit

patch -Np1 -i ../sysvinit-2.88dsf-consolidated-1.patch

sed -i -e 's/\ sulogin[^ ]*//' -e 's/pidof\.8//' -e '/ln .*pidof/d' \
    -e '/utmpdump/d' -e '/mountpoint/d' -e '/mesg/d' src/Makefile

make -C src clobber
make -C src CC="gcc ${BUILD64}"

make -C src install

cat > /etc/inittab << "EOF"
# Begin /etc/inittab

id:3:initdefault:

si::sysinit:/etc/rc.d/init.d/rc sysinit

l0:0:wait:/etc/rc.d/init.d/rc 0
l1:S1:wait:/etc/rc.d/init.d/rc 1
l2:2:wait:/etc/rc.d/init.d/rc 2
l3:3:wait:/etc/rc.d/init.d/rc 3
l4:4:wait:/etc/rc.d/init.d/rc 4
l5:5:wait:/etc/rc.d/init.d/rc 5
l6:6:wait:/etc/rc.d/init.d/rc 6

ca:12345:ctrlaltdel:/sbin/shutdown -t1 -a -r now

su:S016:once:/sbin/sulogin

EOF

cat >> /etc/inittab << "EOF"
1:2345:respawn:/sbin/agetty --noclear -I '\033(K' tty1 9600
2:2345:respawn:/sbin/agetty --noclear -I '\033(K' tty2 9600
3:2345:respawn:/sbin/agetty --noclear -I '\033(K' tty3 9600
4:2345:respawn:/sbin/agetty --noclear -I '\033(K' tty4 9600
5:2345:respawn:/sbin/agetty --noclear -I '\033(K' tty5 9600
6:2345:respawn:/sbin/agetty --noclear -I '\033(K' tty6 9600

EOF

cat >> /etc/inittab << "EOF"
c0:12345:respawn:/sbin/agetty --noclear 115200 ttyS0 vt100

EOF

cat >> /etc/inittab << "EOF"
# End /etc/inittab
EOF

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf sysvinit

echo " "
echo "#6d1 with sysvinit was installed. Now run #6e as last script for final system..."
echo "Next execute script #7.1 for UEFI boot."
echo " "

exit
