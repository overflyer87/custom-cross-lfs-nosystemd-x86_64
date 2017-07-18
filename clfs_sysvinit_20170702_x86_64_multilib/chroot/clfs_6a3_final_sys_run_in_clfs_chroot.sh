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

#Let's continue
#Final system is seperated into several parts 
#to make bugfixing and maintenance easier

cd ${CLFSSOURCES}

#Attr 32-bit
mkdir attr && tar xf attr-*.tar.* -C attr --strip-components 1
cd attr

sed -i -e "/SUBDIRS/s|man[25]||g" man/Makefile
sed -i -e 's|/@pkg_name@|&-@pkg_version@|' include/builddefs.in

CC="gcc ${BUILD32}" \
./configure \
    --prefix=/usr \
    --libdir=/lib \
    --libexecdir=/usr/lib

make PREFIX=/usr LIBDIR=/lib
make -j1 tests root-tests
#checkBuiltPackage
make PREFIX=/usr LIBDIR=/lib install install-dev install-lib

ln -sfv ../../lib/$(readlink /lib/libattr.so) /usr/lib/libattr.so
rm -v /lib/libattr.so
chmod 755 -v /lib/libattr.so.1.1.0

cd ${CLFSSOURCES} 
#checkBuiltPackage
rm -rf attr

#Attr 64-bit
mkdir attr && tar xf attr-*.tar.* -C attr --strip-components 1
cd attr

sed -i -e "/SUBDIRS/s|man[25]||g" man/Makefile
sed -i -e 's|/@pkg_name@|&-@pkg_version@|' include/builddefs.in

CC="gcc ${BUILD64}" \
./configure \
    --prefix=/usr \
    --libdir=/lib64 \
    --libexecdir=/usr/lib64

make PREFIX=/usr LIBDIR=/lib64
#make -j1 tests root-tests
#checkBuiltPackage
make  PREFIX=/usr LIBDIR=/lib64 install install-dev install-lib

ln -sfv ../../lib64/$(readlink /lib64/libattr.so) /usr/lib64/libattr.so
rm -v /lib64/libattr.so
chmod 755 -v /lib64/libattr.so.1.1.0

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf attr

#Acl 32-bit
mkdir acl && tar xf acl-*.tar.* -C acl --strip-components 1
cd acl

sed -i -e 's|/@pkg_name@|&-@pkg_version@|' include/builddefs.in
sed -i "s:| sed.*::g" test/{sbits-restore,cp,misc}.test

CC="gcc ${BUILD32}" \
./configure \
    --prefix=/usr \
    --libdir=/lib \
    --libexecdir=/usr/lib

make PREFIX=/usr LIBDIR=/lib
#make tests
checkBuiltPackage
make PREFIX=/usr LIBDIR=/lib install install-dev install-lib

ln -sfv ../../lib/$(readlink /lib/libacl.so) /usr/lib/libacl.so
rm -v /lib/libacl.so
chmod 755 -v /lib/libacl.so.1.1.0

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf acl

#Acl 64-bit
mkdir acl && tar xf acl-*.tar.* -C acl --strip-components 1
cd acl

sed -i -e 's|/@pkg_name@|&-@pkg_version@|' include/builddefs.in
sed -i "s:| sed.*::g" test/{sbits-restore,cp,misc}.test

CC="gcc ${BUILD64}" \
./configure \
    --prefix=/usr \
    --libdir=/lib64 \
    --libexecdir=/usr/lib64

make PREFIX=/usr LIBDIR=/lib64
#make tests
checkBuiltPackage
make PREFIX=/usr LIBDIR=/lib64 install install-dev install-lib

ln -sfv ../../lib64/$(readlink /lib64/libacl.so) /usr/lib64/libacl.so
rm -v /lib64/libacl.so
chmod 755 -v /lib64/libacl.so.1.1.0

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf acl

#Libcap 32-bit
mkdir libcap && tar xf libcap-*.tar.* -C libcap --strip-components 1
cd libcap

make CC="gcc ${BUILD32}"

make RAISE_SETFCAP=no lib=lib install
chmod -v 755 /lib/libcap.so.2.25
ln -sfv ../../lib/$(readlink /lib/libcap.so) /usr/lib/libcap.so
rm -v /lib/libcap.so
mv -v /lib/libcap.a /usr/lib

cd ${CLFSSOURCES} 
#checkBuiltPackage
rm -rf libcap

#Libcap 64-bit
mkdir libcap && tar xf libcap-*.tar.* -C libcap --strip-components 1
cd libcap

make CC="gcc ${BUILD64}"

make lib=lib64 install
chmod -v 755 /lib64/libcap.so.2.25
ln -sfv ../../lib64/$(readlink /lib64/libcap.so) /usr/lib64/libcap.so
rm -v /lib64/libcap.so
mv -v /lib64/libcap.a /usr/lib64

cd ${CLFSSOURCES} 
#checkBuiltPackage
rm -rf libcap

#Sed
mkdir sed && tar xf sed-*.tar.* -C sed --strip-components 1
cd sed

CC="gcc ${BUILD64}" ./configure \
    --prefix=/usr \
    --bindir=/bin \
    --docdir=/usr/share/doc/sed-4.4

make && make-html
#make check
#checkBuiltPackage

make install && make install-html-am

cd ${CLFSSOURCES} 
#checkBuiltPackage
rm -rf sed

#Pkg-config
mkdir pkg-config && tar xf pkg-config-*.tar.* -C pkg-config --strip-components 1
cd pkg-config

USE_ARCH=64 CXX="g++ ${BUILD64}" CC="gcc ${BUILD64}" ./configure \
    --prefix=/usr \
    --docdir=/usr/share/doc/pkg-config-0.28-1 \
    --with-pc-path=/usr/share/pkgconfig \
    --libdir=/usr/lib64 \


make
#make check
#checkBuiltPackage
make install

export PKG_CONFIG_PATH32="/usr/lib/pkgconfig"
export PKG_CONFIG_PATH64="/usr/lib64/pkgconfig"

cat >> /root/.bash_profile << EOF
export PKG_CONFIG_PATH32="${PKG_CONFIG_PATH32}"
export PKG_CONFIG_PATH64="${PKG_CONFIG_PATH64}"
EOF

PKG_CONFIG_PATH32="/usr/lib/pkgconfig"
PKG_CONFIG_PATH64="/usr/lib64/pkgconfig"

cd ${CLFSSOURCES} 
#checkBuiltPackage
rm -rf pkg-config

#Ncurses 32-bit
mkdir ncurses && tar xf ncurses-*.tar.* -C ncurses --strip-components 1
cd ncurses

PKG_CONFIG_PATH=${PKG_CONFIG_PATH32} \
CC="gcc ${BUILD32}" CXX="g++ ${BUILD32}" \
./configure \
    --prefix=/usr \
    --libdir=/usr/lib \
    --with-shared \
    --without-debug \
    --enable-widec \
    --enable-pc-files

make
make install
mv -v /usr/bin/ncursesw6-config{,-32}
mv -v /usr/lib/libncursesw.so.* /lib
ln -svf ../../lib/$(readlink /usr/lib/libncursesw.so) /usr/lib/libncursesw.so

for lib in ncurses form panel menu ; do
        echo "INPUT(-l${lib}w)" > /usr/lib/lib${lib}.so
        ln -sfv lib${lib}w.a /usr/lib/lib${lib}.a
done

ln -sfv libncurses++w.a /usr/lib/libncurses++.a
ln -sfv ncursesw6-config-32 /usr/bin/ncurses6-config-32

cd ${CLFSSOURCES} 
#checkBuiltPackage
rm -rf ncurses

#Ncurses 64-bit
mkdir ncurses && tar xf ncurses-*.tar.* -C ncurses --strip-components 1
cd ncurses

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} \
CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" ./configure \
    --prefix=/usr \
    --libdir=/usr/lib64 \
    --with-shared \
    --without-debug \
    --enable-widec \
    --enable-pc-files \
    --with-pkg-config-libdir=/usr/lib64/pkgconfig

make
make install

mv -v /usr/bin/ncursesw6-config{,-64}
ln -svf multiarch_wrapper /usr/bin/ncursesw6-config
mv -v /usr/lib64/libncursesw.so.* /lib64
ln -svf ../../lib64/$(readlink /usr/lib64/libncursesw.so) /usr/lib64/libncursesw.so

for lib in ncurses form panel menu ; do
        echo "INPUT(-l${lib}w)" > /usr/lib64/lib${lib}.so
        ln -sfv lib${lib}w.a /usr/lib64/lib${lib}.a
done

ln -sfv libncurses++w.a /usr/lib64/libncurses++.a
ln -sfv ncursesw6-config-64 /usr/bin/ncurses6-config-64
ln -sfv ncursesw6-config /usr/bin/ncurses6-config

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf ncurses

#Shadow
mkdir shadow && tar xf shadow-*.tar.* -C shadow --strip-components 1
cd shadow

sed -i 's@\(DICTPATH.\).*@\1/lib/cracklib/pw_dict@' etc/login.defs

sed -i src/Makefile.in \
  -e 's/groups$(EXEEXT) //'
find man -name Makefile.in -exec sed -i \
  -e 's/man1\/groups\.1 //' \
  -e 's/man3\/getspnam\.3 //' \
  -e 's/man5\/passwd\.5 //' '{}' \;

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} \
CC="gcc ${BUILD64}" CXX="${BUILD64}" ./configure \
    --sysconfdir=/etc \
    --with-group-name-max-length=32 \
    --with-libcrack \
    --without-libpam

make PREFIX=/usr LIBDIR=/usr/lib64
make  PREFIX=/usr LIBDIR=/usr/lib64 install

sed -i /etc/login.defs \
    -e 's@#\(ENCRYPT_METHOD \).*@\1SHA512@' \
    -e 's@/var/spool/mail@/var/mail@'

mv -v /usr/bin/passwd /bin

touch /var/log/{fail,last}log
chgrp -v utmp /var/log/{fail,last}log
chmod -v 664 /var/log/{fail,last}log

pwconv
grpconv
passwd root

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf shadow

#Util-linux 32-bit
mkdir util-linux && tar xf util-linux-*.tar.* -C util-linux --strip-components 1
cd util-linux

PKG_CONFIG_PATH="${PKG_CONFIG_PATH32}" \
CC="gcc ${BUILD32}" ./configure \
    ADJTIME_PATH=/var/lib/hwclock/adjtime \
    --libdir=/lib \
    --enable-write \
    --disable-chfn-chsh \
    --disable-login \
    --disable-nologin \
    --disable-su \
    --disable-setpriv \
    --disable-runuser \
    --docdir=/usr/share/doc/util-linux-2.29.2

make
#chown -Rv nobody .
#su nobody -s /bin/bash -c "PATH=$PATH make -k check"
#checkBuiltPackage

make install

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf util-linux

#Util-linux 64-bit Pass 1
mkdir util-linux && tar xf util-linux-*.tar.* -C util-linux --strip-components 1
cd util-linux

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
./configure ADJTIME_PATH=/var/lib/hwclock/adjtime \
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
make install

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf util-linux

#Procps-ng 32-bit
mkdir procpsng && tar xf procps-ng-*.tar.* -C procpsng --strip-components 1
cd procpsng

PKG_CONFIG_PATH="${PKG_CONFIG_PATH32}" \
CC="gcc ${BUILD32}" ./configure \
    --prefix=/usr \
    --exec-prefix= \
    --libdir=/usr/lib \
    --docdir=/usr/share/doc/procps-ng-3.3.12 \
    --disable-kill

make
sed -i -r 's|(pmap_initname)\\\$|\1|' testsuite/pmap.test/pmap.exp
#make check
checkBuiltPackage
make install

mv -v /usr/lib/libprocps.so.* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libprocps.so) /usr/lib/libprocps.so

cd ${CLFSSOURCES} 
#checkBuiltPackage
rm -rf procpsng

#Procps-ng 64-bit
mkdir procpsng && tar xf procps-ng-*.tar.* -C procpsng --strip-components 1
cd procpsng

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
CC="gcc ${BUILD64}" ./configure \
    --prefix=/usr \
    --exec-prefix= \
    --libdir=/usr/lib64 \
    --docdir=/usr/share/doc/procps-ng-3.3.12 \
    --disable-kill

make
sed -i -r 's|(pmap_initname)\\\$|\1|' testsuite/pmap.test/pmap.exp
#make check
checkBuiltPackage
make install

mv -v /usr/lib64/libprocps.so.* /lib64
ln -sfv ../../lib64/$(readlink /usr/lib64/libprocps.so) /usr/lib64/libprocps.so.so

cd ${CLFSSOURCES} 
#checkBuiltPackage
rm -rf procpsng

#E2fsprogs 32-bit
mkdir e2fsprogs && tar xf e2fsprogs-*.tar.* -C e2fsprogs --strip-components 1
cd e2fsprogs

mkdir -v build
cd build

PKG_CONFIG_PATH="${PKG_CONFIG_PATH32}" \
CC="gcc ${BUILD32}" \
../configure \
    --prefix=/usr \
    --bindir=/bin \
    --with-root-prefix="" \
    --enable-elf-shlibs \
    --disable-libblkid \
    --disable-libuuid \
    --disable-fsck \
    --disable-uuidd

make libs
make install-libs

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf e2fsprogs

#E2fsprogs 64-bit
mkdir e2fsprogs && tar xf e2fsprogs-*.tar.* -C e2fsprogs --strip-components 1
cd e2fsprogs

sed -i '/libdir.*=.*\/lib/s@/lib@/lib64@g' configure

mkdir -v build
cd build

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
CC="gcc ${BUILD64}" \
../configure \
    --prefix=/usr \
    --bindir=/bin \
    --with-root-prefix="" \
    --enable-elf-shlibs \
    --disable-libblkid \
    --disable-libuuid \
    --disable-fsck \
    --disable-uuidd

make
#make check
checkBuiltPackage

make install
make install-libs

cd ${CLFSSOURCES} 
#checkBuiltPackage
rm -rf e2fsprogs

#Coreutils
mkdir coreutils && tar xf coreutils-*.tar.* -C coreutils --strip-components 1
cd coreutils

patch -Np1 -i ../coreutils-8.27-uname-1.patch

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
FORCE_UNSAFE_CONFIGURE=1 \
CC="gcc ${BUILD64}" \
./configure \
    --prefix=/usr \
    --enable-no-install-program=kill,uptime \
    --enable-install-program=hostname

make
#make NON_ROOT_USERNAME=nobody check-root
#echo "dummy:x:1000:nobody" >> /etc/group
#chown -Rv nobody .

su nobody -s /bin/bash \
    -c "PATH=$PATH make RUN_EXPENSIVE_TESTS=yes -k check || true"

sed -i '/dummy/d' /etc/group

checkBuiltPackage
make install

mv -v /usr/bin/{cat,chgrp,chmod,chown,cp,date} /bin
mv -v /usr/bin/{dd,df,echo,false,hostname,ln,ls,mkdir,mknod} /bin
mv -v /usr/bin/{mv,pwd,rm,rmdir,stty,true,uname} /bin
mv -v /usr/bin/chroot /usr/sbin

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf coreutils

#Iana-etc
mkdir iana-etc && tar xf iana-etc-*.tar.* -C iana-etc --strip-components 1
cd iana-etc

xzcat ../iana-etc-2.30-numbers_update-20140202-2.patch.xz | patch -Np1 -i -

make PREFIX=/usr LIBDIR=/usr/lib64
make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf iana-etc

#Libtool 32-bit
mkdir libtool && tar xf libtool-*.tar.* -C libtool --strip-components 1
cd libtool

echo "lt_cv_sys_dlsearch_path='/lib /usr/lib /usr/local/lib /opt/lib'" > config.cache

PKG_CONFIG_PATH="${PKG_CONFIG_PATH32}" \
CC="gcc ${BUILD32}" ./configure \
    --prefix=/usr \
    --cache-file=config.cache

#make LDEMULATION=elf_i386 check
#checkBuiltPackage

make install
mv -v /usr/bin/libtool{,-32}

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf libtool

#Libtool 64-bit
mkdir libtool && tar xf libtool-*.tar.* -C libtool --strip-components 1
cd libtool

echo "lt_cv_sys_dlsearch_path='/lib64 /usr/lib64 /usr/local/lib64 /opt/lib64'" > config.cache

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
CC="gcc ${BUILD64}" ./configure \
    --prefix=/usr \
    --libdir=/usr/lib64 \
    --cache-file=config.cache

make
#make check
#checkBuiltPackage
make install

mv -v /usr/bin/libtool{,-64}
ln -sv multiarch_wrapper /usr/bin/libtool

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf libtool

#IPRoute2 32-bit
mkdir iproute && tar xf iproute2-*.tar.* -C iproute --strip-components 1
cd iproute

sed -i '/ARPD/d' Makefile
sed -i 's/arpd.8//' man/man8/Makefile
sed -i '/tc-simple/s@tc-skbmod.8 @@' man/man8/Makefile
rm -v doc/arpd.sgml

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}"

make CC="gcc ${BUILD64}" LIBDIR=/usr/lib64

make LIBDIR=/usr/lib64 \
    DOCDIR=/usr/share/doc/iproute2-4.9.0 install

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf iproute

#Bzip2 32-bit
mkdir bzip2 && tar xf bzip2-*.tar.* -C bzip2 --strip-components 1
cd bzip2

sed -i -e 's:ln -s -f $(PREFIX)/bin/:ln -s :' Makefile
sed -i 's@X)/man@X)/share/man@g' ./Makefile
PKG_CONFIG_PATH="${PKG_CONFIG_PATH32}"
make -f Makefile-libbz2_so CC="gcc ${BUILD32}" CXX="g++ ${BUILD32}"
make clean
make CC="gcc ${BUILD32}" CXX="g++ ${BUILD32}" libbz2.a
#make CC="gcc ${BUILD32}" CXX="g++ ${BUILD32}" check
#checkBuiltPackage

cp -v libbz2.a /usr/lib
cp -av libbz2.so* /lib
ln -sv ../../lib/libbz2.so.1.0 /usr/lib/libbz2.so


cd ${CLFSSOURCES} 
#checkBuiltPackage
rm -rf bzip2

#Bzip2 64-bit
mkdir bzip2 && tar xf bzip2-*.tar.* -C bzip2 --strip-components 1
cd bzip2

sed -i -e 's:ln -s -f $(PREFIX)/bin/:ln -s :' Makefile
sed -i 's@X)/man@X)/share/man@g' ./Makefile
sed -i 's@/lib\(/\| \|$\)@/lib64\1@g' Makefile
PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}"
make -f Makefile-libbz2_so CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}"
make clean
make CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}"
make CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" PREFIX=/usr install

cp -v bzip2-shared /bin/bzip2
cp -av libbz2.so* /lib64
ln -sv ../../lib64/libbz2.so.1.0 /usr/lib64/libbz2.so
rm -v /usr/bin/{bunzip2,bzcat,bzip2}
ln -sv bzip2 /bin/bunzip2
ln -sv bzip2 /bin/bzcat

cd ${CLFSSOURCES} 
#checkBuiltPackage
rm -rf bzip2

#GDBM 32-bit
mkdir gdbm && tar xf gdbm-*.tar.* -C gdbm --strip-components 1
cd gdbm

PKG_CONFIG_PATH="${PKG_CONFIG_PATH32}" \
CC="gcc ${BUILD32}" \
./configure \
    --prefix=/usr \
    --enable-libgdbm-compat

make
#make check
#checkBuiltPackage
make install

cd ${CLFSSOURCES} 
#checkBuiltPackage
rm -rf gdbm

#GDBM 64-bit
mkdir gdbm && tar xf gdbm-*.tar.* -C gdbm --strip-components 1
cd gdbm

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
CC="gcc ${BUILD64}" \
./configure \
    --prefix=/usr \
    --enable-libgdbm-compat \
    --libdir=/usr/lib64

make
#make check
#checkBuiltPackage
make install

cd ${CLFSSOURCES} 
#checkBuiltPackage
rm -rf gdbm

#Perl 32-bit
mkdir perl && tar xf perl-*.tar.* -C perl --strip-components 1
cd perl

export BUILD_ZLIB=False
export BUILD_BZIP2=0

echo "127.0.0.1 localhost $(hostname)" > /etc/hosts

PKG_CONFIG_PATH="${PKG_CONFIG_PATH32}" \
./configure.gnu \
    --prefix=/usr \
    -Dvendorprefix=/usr \
    -Dman1dir=/usr/share/man/man1 \
    -Dman3dir=/usr/share/man/man3 \
    -Dpager="/bin/less -isR" \
    -Dcc="gcc ${BUILD32}" \
    -Dusethreads \
    -Duseshrplib

make
#make test
#checkBuiltPackage
make install
unset BUILD_ZLIB BUILD_BZIP2

mv -v /usr/bin/perl{,-32}
mv -v /usr/bin/perl5.26.0{,-32}

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf perl

#Perl 64-bit
mkdir perl && tar xf perl-*.tar.* -C perl --strip-components 1
cd perl

sed -i -e '/^BUILD_ZLIB/s/True/False/' \
       -e '/^INCLUDE/s,\./zlib-src,/usr/include,' \
       -e '/^LIB/s,\./zlib-src,/usr/lib64,' \
       cpan/Compress-Raw-Zlib/config.in

patch -Np1 -i ../perl-5.26.0-Configure_multilib-1.patch

echo 'installstyle="lib64/perl5"' >> hints/linux.sh

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
./configure.gnu \
    --prefix=/usr \
    -Dvendorprefix=/usr \
    -Dman1dir=/usr/share/man/man1 \
    -Dman3dir=/usr/share/man/man3 \
    -Dpager="/bin/less -isR" \
    -Dlibpth="/usr/local/lib64 /lib64 /usr/lib64" \
    -Dcc="gcc ${BUILD64}" \
    -Dusethreads \
    -Duseshrplib

make
#make test
#checkBuiltPackage
make install
unset BUILD_ZLIB BUILD_BZIP2

mv -v /usr/bin/perl{,-64}
mv -v /usr/bin/perl5.26.0{,-64}

ln -sv multiarch_wrapper /usr/bin/perl
ln -sv multiarch_wrapper /usr/bin/perl5.26.0

cd ${CLFSSOURCES} 
#checkBuiltPackage
rm -rf perl

#Readline 32-bit
mkdir readline && tar xf readline-*.tar.* -C readline --strip-components 1
cd readline

patch -Np1 -i ../readline-7.0-branch_update-1.patch

sed -i '/MV.*old/d' Makefile.in
sed -i '/{OLDSUFF}/c:' support/shlib-install

PKG_CONFIG_PATH="${PKG_CONFIG_PATH32}" \
CC="gcc ${BUILD32}" CXX="g++ ${BUILD32}" \
./configure \
    --prefix=/usr \
    --libdir=/lib \
    --docdir=/usr/share/doc/readline-7.0

make SHLIB_LIBS=-lncurses
make SHLIB_LIBS=-lncurses htmldir=/usr/share/doc/readline-7.0 install
mv -v /lib/lib{readline,history}.a /usr/lib
ln -svf ../../lib/$(readlink /lib/libreadline.so) /usr/lib/libreadline.so
ln -svf ../../lib/$(readlink /lib/libhistory.so) /usr/lib/libhistory.so
rm -v /lib/lib{readline,history}.so

cd ${CLFSSOURCES} 
#checkBuiltPackage
rm -rf readline

#Readline 64-bit
mkdir readline && tar xf readline-*.tar.* -C readline --strip-components 1
cd readline

patch -Np1 -i ../readline-7.0-branch_update-1.patch

sed -i '/MV.*old/d' Makefile.in
sed -i '/{OLDSUFF}/c:' support/shlib-install

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
./configure \
    --prefix=/usr \
    --libdir=/lib64 \
    --docdir=/usr/share/doc/readline-7.0

make SHLIB_LIBS=-lncurses
make SHLIB_LIBS=-lncurses htmldir=/usr/share/doc/readline-7.0 install
mv -v /lib64/lib{readline,history}.a /usr/lib64
ln -svf ../../lib64/$(readlink /lib64/libreadline.so) /usr/lib64/libreadline.so
ln -svf ../../lib64/$(readlink /lib64/libhistory.so) /usr/lib64/libhistory.so
rm -v /lib64/lib{readline,history}.so

cd ${CLFSSOURCES} 
#checkBuiltPackage
rm -rf readline

#Autoconf
mkdir autoconf && tar xf autoconf-*.tar.* -C autoconf --strip-components 1
cd autoconf

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
CC="gcc ${BUILD64}" \
./configure \
    --prefix=/usr

make
#make check VERBOSE=yes
#checkBuiltPackage
make install

cd ${CLFSSOURCES} 
#checkBuiltPackage
rm -rf autoconf

#Automake
mkdir automake && tar xf automake-*.tar.* -C automake --strip-components 1
cd automake

patch -Np1 -i ../automake-1.15-perl_5_26-1.patch

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
CC="gcc ${BUILD64}" \
./configure \
    --prefix=/usr \
    --docdir=/usr/share/doc/automake-1.15

make
#make check
#checkBuiltPackage
make install

cd ${CLFSSOURCES} 
#checkBuiltPackage
rm -rf automake

#Bash
mkdir bash && tar xf bash-*.tar.* -C bash --strip-components 1
cd bash

patch -Np1 -i ../bash-4.4-branch_update-1.patch

sed -i "/ac_cv_rl_libdir/s@/lib@&64@" configure

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
./configure \
    --prefix=/usr \
    --without-bash-malloc \
    --with-installed-readline \
    --docdir=/usr/share/doc/bash-4.4

make
#make tests
checkBuiltPackage
make install
mv -v /usr/bin/bash /bin

echo " "
echo "If everything went fine I will now login"
echo "using our new native bash shell!"
echo "If you noticed errors, cancel and recompile"
echo " "

cd ${CLFSSOURCES}

#checkBuiltPackage
rm -rf bash

exec /bin/bash --login +h
