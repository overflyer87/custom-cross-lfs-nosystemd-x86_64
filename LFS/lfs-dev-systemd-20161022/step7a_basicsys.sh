#!/bin/bash

touch /var/log/{btmp,lastlog,faillog,wtmp}
chgrp -v utmp /var/log/lastlog
chmod -v 664  /var/log/lastlog
chmod -v 600  /var/log/btmp

function commonBuildRoutine() {

./configure --prefix=/tools
make
make check
make install

}

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

echo
echo
echo -e "With what speed do you want to build? make supports parallel compiling. Enter the maximum number of cores or threads you have. Usually 1-8: \c"
read numberofthreads
export MAKEFLAGS="-j ${numberofthreads}"
echo

env

echo
echo "Does your environment look as expected (see book)?: [Y/N]"
while read -n1 -r -p "[Y/N]   " && [[ $REPLY != q ]]; do
  case $REPLY in
    Y) break 1;;
    N) echo "$EXIT"
       echo "Fix it!"
       exit 1;;
    *) echo " Try again. Type y or n";;
  esac
done
echo

cd /sources


make mrproper

make INSTALL_HDR_PATH=dest headers_install
find dest/include \( -name .install -o -name ..install.cmd \) -delete
cp -rv dest/include/* /usr/include

checkBuiltPackage

cd /sources
rm -r linux
echo
mkdir man-pages && tar -xf man-pages-*.tar.* -C man-pages --strip-components 1
cd /sources/man-pages

make install

checkBuiltPackage

cd /sources
rm -r man-pages
echo

mkdir glibc && tar -xf glibc-*.tar.* -C glibc --strip-components 1
cd /sources/glibc

patch -Np1 -i ../glibc-2.24-fhs-1.patch

mkdir -v build
cd       build

../configure --prefix=/usr          \
             --enable-kernel=2.6.32 \
             --enable-obsolete-rpc

make
make check
touch /etc/ld.so.conf
make install

cp -v ../nscd/nscd.conf /etc/nscd.conf
mkdir -pv /var/cache/nscd

install -v -Dm644 ../nscd/nscd.tmpfiles /usr/lib/tmpfiles.d/nscd.conf
install -v -Dm644 ../nscd/nscd.service /lib/systemd/system/nscd.service

mkdir -pv /usr/lib/locale
localedef -i cs_CZ -f UTF-8 cs_CZ.UTF-8
localedef -i de_DE -f ISO-8859-1 de_DE
localedef -i de_DE@euro -f ISO-8859-15 de_DE@euro
localedef -i de_DE -f UTF-8 de_DE.UTF-8
localedef -i en_GB -f UTF-8 en_GB.UTF-8
localedef -i en_HK -f ISO-8859-1 en_HK
localedef -i en_PH -f ISO-8859-1 en_PH
localedef -i en_US -f ISO-8859-1 en_US
localedef -i en_US -f UTF-8 en_US.UTF-8
localedef -i es_MX -f ISO-8859-1 es_MX
localedef -i fa_IR -f UTF-8 fa_IR
localedef -i fr_FR -f ISO-8859-1 fr_FR
localedef -i fr_FR@euro -f ISO-8859-15 fr_FR@euro
localedef -i fr_FR -f UTF-8 fr_FR.UTF-8
localedef -i it_IT -f ISO-8859-1 it_IT
localedef -i it_IT -f UTF-8 it_IT.UTF-8
localedef -i ja_JP -f EUC-JP ja_JP
localedef -i ru_RU -f KOI8-R ru_RU.KOI8-R
localedef -i ru_RU -f UTF-8 ru_RU.UTF-8
localedef -i tr_TR -f UTF-8 tr_TR.UTF-8
localedef -i zh_CN -f GB18030 zh_CN.GB18030

make localedata/install-locales

cat > /etc/nsswitch.conf << "EOF"
# Begin /etc/nsswitch.conf

passwd: files
group: files
shadow: files

hosts: files dns
networks: files

protocols: files
services: files
ethers: files
rpc: files

# End /etc/nsswitch.conf
EOF

tar -xf /sources/tzdata2016f.tar.gz

ZONEINFO=/usr/share/zoneinfo
mkdir -pv $ZONEINFO/{posix,right}

for tz in etcetera southamerica northamerica europe africa antarctica  \
          asia australasia backward pacificnew systemv; do
    zic -L /dev/null   -d $ZONEINFO       -y "sh yearistype.sh" ${tz}
    zic -L /dev/null   -d $ZONEINFO/posix -y "sh yearistype.sh" ${tz}
    zic -L leapseconds -d $ZONEINFO/right -y "sh yearistype.sh" ${tz}
done

cp -v zone.tab zone1970.tab iso3166.tab $ZONEINFO
zic -d $ZONEINFO -p America/New_York
unset ZONEINFO

tzselect

ln -sfv /usr/share/zoneinfo/Europe/Berlin /etc/localtime

cat > /etc/ld.so.conf << "EOF"
# Begin /etc/ld.so.conf
/usr/local/lib
/opt/lib

EOF

cat >> /etc/ld.so.conf << "EOF"
# Add an include directory
include /etc/ld.so.conf.d/*.conf

EOF
mkdir -pv /etc/ld.so.conf.d

checkBuiltPackage

cd /sources
rm -r glibc


mv -v /tools/bin/{ld,ld-old}
mv -v /tools/$(uname -m)-pc-linux-gnu/bin/{ld,ld-old}
mv -v /tools/bin/{ld-new,ld}
ln -sv /tools/bin/ld /tools/$(uname -m)-pc-linux-gnu/bin/ld

gcc -dumpspecs | sed -e 's@/tools@@g'                   \
    -e '/\*startfile_prefix_spec:/{n;s@.*@/usr/lib/ @}' \
    -e '/\*cpp:/{n;s@$@ -isystem /usr/include@}' >      \
    `dirname $(gcc --print-libgcc-file-name)`/specs

echo 'int main(){}' > dummy.c
cc dummy.c -v -Wl,--verbose &> dummy.log
readelf -l a.out | grep ': /lib'

echo "Does the screen output exactly \"[Requesting program interpreter: /lib/ld-linux.so.2]\"?: [Y/N]"
while read -n1 -r -p "[Y/N]   " && [[ $REPLY != q ]]; do
  case $REPLY in
    Y) break 1;;
    N) echo "$EXIT"
       echo "Fix it!"
       exit 1;;
    *) echo " Try again. Type y or n";;
  esac
done
echo
grep -o '/usr/lib.*/crt[1in].*succeeded' dummy.log
echo
grep -B1 '^ /usr/include' dummy.log
echo
grep 'SEARCH.*/usr/lib' dummy.log |sed 's|; |\n|g'
echo
grep "/lib.*/libc.so.6 " dummy.log
echo
grep found dummy.log
echo
echo "Check all the other outputs from grep. Are they OK?: [Y/N]"
while read -n1 -r -p "[Y/N]   " && [[ $REPLY != q ]]; do
  case $REPLY in
    Y) break 1;;
    N) echo "$EXIT"
       echo "Fix it!"
       exit 1;;
    *) echo " Try again. Type y or n";;
  esac
done

rm -v dummy.c a.out dummy.log

cd /sources
rm -r glibc

mkdir zlib && tar -xf zlib-*.tar.* -C zlib --strip-components 1
cd /sources/zlib

./configure --prefix=/usr

make
make check
make install

mv -v /usr/lib/libz.so.* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libz.so) /usr/lib/libz.so

checkBuiltPackage

cd /sources
rm -r zlib
echo

mkdir file && tar -xf file-*.tar.* -C file --strip-components 1
cd /sources/file

commonBuildRoutine
checkBuiltPackage

cd /sources
rm -r file
echo

mkdir binutils && tar -xf binutils-*.tar.* -C binutils --strip-components 1
cd /sources/binutils

expect -c "spawn ls"

echo
echo "Did your screen just prin \"spawn ls\"?: [Y/N]"
while read -n1 -r -p "[Y/N]   " && [[ $REPLY != q ]]; do
  case $REPLY in
    Y) break 1;;
    N) echo "$EXIT"
       echo "Fix it!"
       exit 1;;
    *) echo " Try again. Type y or n";;
  esac
done
echo

mkdir -v build
cd       build

../configure --prefix=/usr   \
             --enable-shared \
             --disable-werror

make tooldir=/usr
make -k check
make tooldir=/usr install

checkBuiltPackage

cd /sources
rm -r binutils
echo

mkdir gmp && tar -xf gmp-*.tar.* -C gmp --strip-components 1
cd /sources/gmp

./configure --prefix=/usr    \
            --enable-cxx     \
            --disable-static \
            --docdir=/usr/share/doc/gmp-6.1.1

make
make html

make check 2>&1 | tee gmp-check-log

awk '/# PASS:/{total+=$3} ; END{print total}' gmp-check-log

make install
make install-html

checkBuiltPackage

cd /sources
rm -r gmp


mkdir mpfr && tar -xf mpfr-*.tar.* -C mpfr --strip-components 1
cd /sources/mpfr

./configure --prefix=/usr        \
            --disable-static     \
            --enable-thread-safe \
            --docdir=/usr/share/doc/mpfr-3.1.4

make
make html
make check
make install
make install-html

checkBuiltPackage

cd /sources
rm -r mpfr


mkdir mpc && tar -xf mpc-*.tar.* -C mpc --strip-components 1
cd /sources/mpc

./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/mpc-1.0.3

make
make html
make check
make install
make install-html

checkBuiltPackage

cd /sources
rm -r mpc


mkdir gcc && tar -xf gcc-*.tar.* -C gcc --strip-components 1
cd /sources/gcc

mkdir -v build
cd       build

SED=sed                               \
../configure --prefix=/usr            \
             --enable-languages=c,c++ \
             --disable-multilib       \
             --disable-bootstrap      \
             --with-system-zlib

make

ulimit -s 32768

make -k check

../contrib/test_summary

make install

ln -sv ../usr/bin/cpp /lib

ln -sv gcc /usr/bin/cc

install -v -dm755 /usr/lib/bfd-plugins
ln -sfv ../../libexec/gcc/$(gcc -dumpmachine)/6.2.0/liblto_plugin.so \
        /usr/lib/bfd-plugins/

echo 'int main(){}' > dummy.c
cc dummy.c -v -Wl,--verbose &> dummy.log
readelf -l a.out | grep ': /lib'

grep -o '/usr/lib.*/crt[1in].*succeeded' dummy.log

grep -B4 '^ /usr/include' dummy.log

grep 'SEARCH.*/usr/lib' dummy.log |sed 's|; |\n|g'

grep "/lib.*/libc.so.6 " dummy.log

grep found dummy.log

rm -v dummy.c a.out dummy.log

mkdir -pv /usr/share/gdb/auto-load/usr/lib
mv -v /usr/lib/*gdb.py /usr/share/gdb/auto-load/usr/lib

checkBuiltPackage

cd /sources
rm -r gcc



cd /sources

mkdir bzip2 && tar -xf bzip2-*.tar.* -C bzip2 --strip-components 1
cd /sources/bzip2

patch -Np1 -i ../bzip2-1.0.6-install_docs-1.patch
sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile
sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" Makefile
make -f Makefile-libbz2_so
make clean
make
make PREFIX=/usr install
cp -v bzip2-shared /bin/bzip2
cp -av libbz2.so* /lib
ln -sv ../../lib/libbz2.so.1.0 /usr/lib/libbz2.so
rm -v /usr/bin/{bunzip2,bzcat,bzip2}
ln -sv bzip2 /bin/bunzip2
ln -sv bzip2 /bin/bzcat

checkBuiltPackage

cd /sources
rm -r bzip2


mkdir pkg-config && tar -xf pkg-config-*.tar.* -C pkg-config --strip-components 1
cd /sources/pkg-config

./configure --prefix=/usr              \
            --with-internal-glib       \
            --disable-compile-warnings \
            --disable-host-tool        \
            --docdir=/usr/share/doc/pkg-config-0.29.1
make
make check
make install

checkBuiltPackage

cd /sources
rm -r pkg-config


mkdir ncurses && tar -xf ncurses-*.tar.* -C ncurses --strip-components 1
cd /sources/ncurses

sed -i '/LIBTOOL_INSTALL/d' c++/Makefile.in

./configure --prefix=/usr           \
            --mandir=/usr/share/man \
            --with-shared           \
            --without-debug         \
            --without-normal        \
            --enable-pc-files       \
            --enable-widec

make
make install

mv -v /usr/lib/libncursesw.so.6* /lib

ln -sfv ../../lib/$(readlink /usr/lib/libncursesw.so) /usr/lib/libncursesw.so

for lib in ncurses form panel menu ; do
    rm -vf                    /usr/lib/lib${lib}.so
    echo "INPUT(-l${lib}w)" > /usr/lib/lib${lib}.so
    ln -sfv ${lib}w.pc        /usr/lib/pkgconfig/${lib}.pc
done

rm -vf                     /usr/lib/libcursesw.so
echo "INPUT(-lncursesw)" > /usr/lib/libcursesw.so
ln -sfv libncurses.so      /usr/lib/libcurses.so

mkdir -v       /usr/share/doc/ncurses-6.0
cp -v -R doc/* /usr/share/doc/ncurses-6.0

checkBuiltPackage

cd /sources
rm -r ncurses


mkdir attr && tar -xf attr-*.tar.* -C attr --strip-components 1
cd /sources/attr

sed -i -e 's|/@pkg_name@|&-@pkg_version@|' include/builddefs.in
sed -i -e "/SUBDIRS/s|man[25]||g" man/Makefile

./configure --prefix=/usr \
            --disable-static

make
make -j1 tests root-tests
make install install-dev install-lib
chmod -v 755 /usr/lib/libattr.so
mv -v /usr/lib/libattr.so.* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libattr.so) /usr/lib/libattr.so

checkBuiltPackage

cd /sources
rm -r attr

mkdir acl && tar -xf acl-*.tar.* -C acl --strip-components 1
cd /sources/acl

sed -i -e 's|/@pkg_name@|&-@pkg_version@|' include/builddefs.in
sed -i "s:| sed.*::g" test/{sbits-restore,cp,misc}.test
sed -i -e "/TABS-1;/a if (x > (TABS-1)) x = (TABS-1);" \
    libacl/__acl_to_any_text.c

./configure --prefix=/usr    \
            --disable-static \
            --libexecdir=/usr/lib

make
make install install-dev install-lib
chmod -v 755 /usr/lib/libacl.so
mv -v /usr/lib/libacl.so.* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libacl.so) /usr/lib/libacl.so

checkBuiltPackage

cd /sources
rm -r acl


mkdir libcap && tar -xf libcap-*.tar.* -C libcap --strip-components 1
cd /sources/libcap

sed -i '/install.*STALIBNAME/d' libcap/Makefile
make
make RAISE_SETFCAP=no prefix=/usr install
chmod -v 755 /usr/lib/libcap.so
mv -v /usr/lib/libcap.so.* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libcap.so) /usr/lib/libcap.so

checkBuiltPackage

cd /sources
rm -r libcap


mkdir sed && tar -xf sed-*.tar.* -C sed --strip-components 1
cd /sources/sed

./configure --prefix=/usr --bindir=/bin --htmldir=/usr/share/doc/sed-4.2.2

make
make html

make check

make install
make -C doc install-html

checkBuiltPackage

cd /sources
rm -r sed


mkdir cracklib && tar -xf cracklib-*.tar.* -C cracklib --strip-components 1
cd /sources/cracklib

sed -i '/skipping/d' util/packer.c &&

./configure --prefix=/usr    \
            --disable-static \
            --with-default-dict=/lib/cracklib/pw_dict &&
make

make install                      &&
mv -v /usr/lib/libcrack.so.* /lib &&
ln -sfv ../../lib/$(readlink /usr/lib/libcrack.so) /usr/lib/libcrack.so

install -v -m644 -D    ../cracklib-words-2.9.6.gz \
                         /usr/share/dict/cracklib-words.gz     &&

gunzip -v                /usr/share/dict/cracklib-words.gz     &&
ln -v -sf cracklib-words /usr/share/dict/words                 &&
echo $(hostname) >>      /usr/share/dict/cracklib-extra-words  &&
install -v -m755 -d      /lib/cracklib                         &&

create-cracklib-dict     /usr/share/dict/cracklib-words \
                         /usr/share/dict/cracklib-extra-words

make test

checkBuiltPackage

cd /sources
rm -r cracklib

#mkdir Linux-PAM-1.3.0 && tar -xf Linux-PAM-1.3.0.tar.* -C Linux-PAM-1.3.0 --strip-components 1
#cd /sources/Linux-PAM-1.3.0
#
#./configure --prefix=/usr                    \
#            --sysconfdir=/etc                \
#            --libdir=/usr/lib                \
#            --disable-regenerate-docu        \
#            --enable-securedir=/lib/security \
#            --docdir=/usr/share/doc/Linux-PAM-1.3.0 &&
#make
#
#install -v -m755 -d /etc/pam.d &&
#
#tar -xf ../Linux-PAM-1.2.0-docs.tar.bz2 --strip-components=1
#
#cat > /etc/pam.d/other << "EOF"
##auth     required       pam_deny.so
##account  required       pam_deny.so
##password required       pam_deny.so
##session  required       pam_deny.so
#EOF
#
#make check
#
#rm -fv /etc/pam.d/*
#
#make install &&
#chmod -v 4755 /sbin/unix_chkpwd &&
#
#for file in pam pam_misc pamc
#do
#mv -v /usr/lib/lib${file}.so.* /lib &&
#  ln -sfv ../../lib/$(readlink /usr/lib/lib${file}.so) /usr/lib/lib${file}.so
#done

#cat > /etc/pam.d/other << "EOF"
## Begin /etc/pam.d/other
#
#auth            required        pam_unix.so     nullok
#account         required        pam_unix.so
#session         required        pam_unix.so
#password        required        pam_unix.so     nullok
#
## End /etc/pam.d/other
#EOF

#cat > /etc/pam.d/system-account << "EOF"
## Begin /etc/pam.d/system-account
#
#account   required    pam_unix.so
#
## End /etc/pam.d/system-account
#EOF
#
#cat > /etc/pam.d/system-auth << "EOF"
## Begin /etc/pam.d/system-auth
#
#auth      required    pam_unix.so
#
## End /etc/pam.d/system-auth
#EOF
#
#cat > /etc/pam.d/system-session << "EOF"
## Begin /etc/pam.d/system-session
#
#session   required    pam_unix.so
#
## End /etc/pam.d/system-session
#EOF

#cat > /etc/pam.d/system-password << "EOF"
## Begin /etc/pam.d/system-password
#
## check new passwords for strength (man pam_cracklib)
#password  required    pam_cracklib.so   type=Linux retry=3 difok=5 \
#                                        difignore=23 minlen=9 dcredit=1 \
#                                        ucredit=1 lcredit=1 ocredit=1 \
#                                        dictpath=/lib/cracklib/pw_dict
## use sha512 hash for encryption, use shadow, and use the
## authentication token (chosen password) set by pam_cracklib
## above (or any previous modules)
#password  required    pam_unix.so       sha512 shadow use_authtok
#
## End /etc/pam.d/system-password
#EOF
#
#cat > /etc/pam.d/other << "EOF"
## Begin /etc/pam.d/other
#
#auth        required        pam_warn.so
#auth        required        pam_deny.so
#account     required        pam_warn.so
#account     required        pam_deny.so
#password    required        pam_warn.so
#password    required        pam_deny.so
#session     required        pam_warn.so
#session     required        pam_deny.so
#
## End /etc/pam.d/other
#EOF
#
#checkBuiltPackage
#
#cd /sources
#rm -r Linux-PAM-1.3.0


mkdir shadow && tar -xf shadow-*.tar.* -C shadow --strip-components 1
cd /sources/shadow

sed -i 's/groups$(EXEEXT) //' src/Makefile.in
find man -name Makefile.in -exec sed -i 's/groups\.1 / /'   {} \;
find man -name Makefile.in -exec sed -i 's/getspnam\.3 / /' {} \;
find man -name Makefile.in -exec sed -i 's/passwd\.5 / /'   {} \;

sed -i -e 's@#ENCRYPT_METHOD DES@ENCRYPT_METHOD SHA512@' \
       -e 's@/var/spool/mail@/var/mail@' etc/login.defs
sed -i 's@DICTPATH.*@DICTPATH\t/lib/cracklib/pw_dict@' etc/login.defs
sed -i 's/1000/999/' etc/useradd

./configure --sysconfdir=/etc --with-group-name-max-length=32 --with-libcrack --with-pam --with-pam-login

make
make install
mv -v /usr/bin/passwd /bin
pwconv
grpconv

sed -i 's/yes/no/' /etc/default/useradd

passwd root

checkBuiltPackage

cd /sources
rm -r shadow

#
#mkdir sudo && tar -xf sudo-*.tar.* -C sudo --strip-components 1
#cd /sources/sudo
#
#./configure --prefix=/usr              \
#            --libexecdir=/usr/lib      \
#            --with-secure-path         \
#            --with-all-insults         \
#            --with-env-editor          \
#            --docdir=/usr/share/doc/sudo-1.8.18 \
#            --with-passprompt="[sudo] password for %p" &&
#make
#
#make install &&
#ln -sfv libsudo_util.so.0.0.0 /usr/lib/sudo/libsudo_util.so.0
#
#checkBuiltPackage
#
#cd /sources
#rm -r sudo
#
mkdir psmisc && tar -xf psmisc-*.tar.* -C psmisc --strip-components 1
cd /sources/psmisc

commonBuildRoutine
mv -v /usr/bin/fuser   /bin
mv -v /usr/bin/killall /bin

checkBuiltPackage

cd /sources
rm -r psmisc

mkdir iana-etc && tar -xf iana-etc-*.tar.* -C iana-etc --strip-components 1
cd /sources/iana-etc

make && make install
checkBuiltPackage

cd /sources
rm -r iana-etc


mkdir m4 && tar -xf m4-*.tar.* -C m4 --strip-components 1
cd /sources/m4

commonBuildRoutine
checkBuiltPackage

cd /sources
rm -r m4


mkdir bison && tar -xf bison-*.tar.* -C bison --strip-components 1
cd /sources/bison

./configure --prefix=/usr --docdir=/usr/share/doc/bison-3.0.4
make
make install
checkBuiltPackage

cd /sources
rm -r bison


mkdir flex && tar -xf flex-*.tar.* -C flex --strip-components 1
cd /sources/flex

./configure --prefix=/usr --docdir=/usr/share/doc/flex-2.6.1
make
make check
make install
ln -sv flex /usr/bin/lex

checkBuiltPackage

cd /sources
rm -r flex


mkdir -v grep && tar -xf grep-*.tar.* -C grep --strip-components 1
cd /sources/grep

./configure --prefix=/usr --bindir=/bin
make
make check
make install

checkBuiltPackage


cd /sources
rm -r grep


mkdir -v readline && tar -xf readline-*.tar.* -C readline --strip-components 1
cd /sources/readline

sed -i '/MV.*old/d' Makefile.in
sed -i '/{OLDSUFF}/c:' support/shlib-install

./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/readline-7.0

make SHLIB_LIBS=-lncurses

make SHLIB_LIBS=-lncurses install

mv -v /usr/lib/lib{readline,history}.so.* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libreadline.so) /usr/lib/libreadline.so
ln -sfv ../../lib/$(readlink /usr/lib/libhistory.so ) /usr/lib/libhistory.so

install -v -m644 doc/*.{ps,pdf,html,dvi} /usr/share/doc/readline-7.0

cd /sources
rm -r readline


mkdir -v bash && tar -xf bash-*.tar.* -C bash --strip-components 1
cd /sources/bash

./configure --prefix=/usr                       \
            --docdir=/usr/share/doc/bash-4.4 \
            --without-bash-malloc               \
            --with-installed-readline

make

chown -Rv nobody .

su nobody -s /bin/bash -c "PATH=$PATH make tests"

make install
mv -vf /usr/bin/bash /bin
checkBuiltPackage

cd /sources
rm -r bash

exec /bin/bash --login +h
