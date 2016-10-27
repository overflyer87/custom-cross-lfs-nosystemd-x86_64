#!/bin/bash

#Build final system step2

function commonBuildRoutine() {

./configure --prefix=/usr && make && make check && make install

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

cd /sources

mkdir bc && tar -xf bc-*.tar.* -C bc --strip-components 1
cd /sources/bc

patch -Np1 -i ../bc-1.06.95-memory_leak-1.patch

./configure --prefix=/usr           \
            --with-readline         \
            --mandir=/usr/share/man \
            --infodir=/usr/share/info

make
echo "quit" | ./bc/bc -l Test/checklib.b
make install

checkBuiltPackage

cd /sources
rm -r bc


mkdir libtool && tar -xf libtool-*.tar.* -C libtool --strip-components 1
cd /sources/libtool

commonBuildRoutine
checkBuiltPackage

cd /sources
rm -r libtool


mkdir gdbm && tar -xf gdbm-*.tar.* -C gdbm --strip-components 1
cd /sources/gdbm

./configure --prefix=/usr \
            --disable-static \
            --enable-libgdbm-compat
make
make check
make install
checkBuiltPackage

cd /sources
rm -r gdbm


mkdir gperf && tar -xf gperf-*.tar.* -C gperf --strip-components 1
cd /sources/gperf

./configure --prefix=/usr --docdir=/usr/share/doc/gperf-3.0.4
make
make -j1 check
make install
checkBuiltPackage

cd /sources
rm -r gperf


mkdir expat && tar -xf expat-*.tar.* -C expat --strip-components 1
cd /sources/expat

./configure --prefix=/usr --disable-static

make

make check

make install

install -v -dm755 /usr/share/doc/expat-2.2.0
install -v -m644 doc/*.{html,png,css} /usr/share/doc/expat-2.2.0
checkBuiltPackage

cd /sources
rm -r expat


mkdir inetutils && tar -xf inetutils-*.tar.* -C inetutils --strip-components 1
cd /sources/inetutils

./configure --prefix=/usr        \
            --localstatedir=/var \
            --disable-logger     \
            --disable-whois      \
            --disable-rcp        \
            --disable-rexec      \
            --disable-rlogin     \
            --disable-rsh        \
            --disable-servers

make && make check
make install

mv -v /usr/bin/{hostname,ping,ping6,traceroute} /bin
mv -v /usr/bin/ifconfig /sbin
checkBuiltPackage

cd /sources
rm -r inetutils


mkdir perl && tar -xf perl-*.tar.* -C perl --strip-components 1
cd /sources/perl

echo "127.0.0.1 localhost $(hostname)" > /etc/hosts

export BUILD_ZLIB=False
export BUILD_BZIP2=0

sh Configure -des -Dprefix=/usr                 \
                  -Dvendorprefix=/usr           \
                  -Dman1dir=/usr/share/man/man1 \
                  -Dman3dir=/usr/share/man/man3 \
                  -Dpager="/usr/bin/less -isR"  \
                  -Duseshrplib

make

make -k test

make install
unset BUILD_ZLIB BUILD_BZIP2


checkBuiltPackage

cd /sources
rm -r perl


mkdir xmlparser && tar -xf XML-Parser-*.tar.* -C xmlparser --strip-components 1
cd /sources/xmlparser

perl Makefile.PL && make && make test && make install
checkBuiltPackage

cd /sources
rm -r xmlparser


mkdir intltool && tar -xf intltool-*.tar.* -C intltool --strip-components 1
cd /sources/intltool

sed -i 's:\\\${:\\\$\\{:' intltool-update.in
./configure --prefix=/usr
make && make check
make install
install -v -Dm644 doc/I18N-HOWTO /usr/share/doc/intltool-0.51.0/I18N-HOWTO
checkBuiltPackage

cd /sources
rm -r intltool



mkdir autoconf && tar -xf autoconf-*.tar.* -C autoconf --strip-components 1
cd /sources/autoconf

commonBuildRoutine
checkBuiltPackage

cd /sources
rm -r autoconf


mkdir automake && tar -xf automake-*.tar.* -C automake --strip-components 1
cd /sources/automake

sed -i 's:/\\\${:/\\\$\\{:' bin/automake.in

./configure --prefix=/usr --docdir=/usr/share/doc/automake-1.15

make

sed -i "s:./configure:LEXLIB=/usr/lib/libfl.a &:" t/lex-{clean,depend}-cxx.sh
make -j4 check

make install

checkBuiltPackage
cd /sources
rm -r automake


mkdir -v xz && tar -xf xz-*.tar.* -C xz --strip-components 1
cd /sources/xz

sed -e '/mf\.buffer = NULL/a next->coder->mf.size = 0;' \
     -i src/liblzma/lz/lz_encoder.c

./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/xz-5.2.2

make

make check

make install
mv -v   /usr/bin/{lzma,unlzma,lzcat,xz,unxz,xzcat} /bin
mv -v /usr/lib/liblzma.so.* /lib
ln -svf ../../lib/$(readlink /usr/lib/liblzma.so) /usr/lib/liblzma.so
checkBuiltPackage

cd /sources
rm -r xz


mkdir -v kmod && tar -xf kmod-*.tar.* -C kmod --strip-components 1
cd /sources/kmod


./configure --prefix=/usr          \
            --bindir=/bin          \
            --sysconfdir=/etc      \
            --with-rootlibdir=/lib \
            --with-xz              \
            --with-zlib

make && make install

for target in depmod insmod lsmod modinfo modprobe rmmod; do
  ln -sfv ../bin/kmod /sbin/$target
done

ln -sfv kmod /bin/lsmod
checkBuiltPackage

cd /sources
rm -r kmod



mkdir -v gettext && tar -xf gettext-*.tar.* -C gettext --strip-components 1
cd /sources/gettext

./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/gettext-0.19.8.1

make

make check

make install
chmod -v 0755 /usr/lib/preloadable_libintl.so

checkBuiltPackage
cd /sources
rm -r gettext


mkdir -v systemd && tar -xf systemd-*.tar.* -C systemd --strip-components 1
cd /sources/systemd

sed -i "s:blkid/::" $(grep -rl "blkid/blkid.h")

sed -e 's@test/udev-test.pl @@'  \
    -e 's@test-copy$(EXEEXT) @@' \
    -i Makefile.in

patch -Np1 -i ../systemd-231-security_fix-1.patch

cat > config.cache << "EOF"
KILL=/bin/kill
MOUNT_PATH=/bin/mount
UMOUNT_PATH=/bin/umount
HAVE_BLKID=1
BLKID_LIBS="-lblkid"
BLKID_CFLAGS="-I/tools/include/blkid"
HAVE_LIBMOUNT=1
MOUNT_LIBS="-lmount"
MOUNT_CFLAGS="-I/tools/include/libmount"
cc_cv_CFLAGS__flto=no
XSLTPROC="/usr/bin/xsltproc"
EOF

./configure --prefix=/usr            \
            --sysconfdir=/etc        \
            --localstatedir=/var     \
            --config-cache           \
            --with-rootprefix=       \
            --with-rootlibdir=/lib   \
            --enable-split-usr       \
            --disable-firstboot      \
            --disable-ldconfig       \
            --disable-sysusers       \
            --without-python         \
            --with-default-dnssec=no \
            --docdir=/usr/share/doc/systemd-231

make LIBRARY_PATH=/tools/lib

make LD_LIBRARY_PATH=/tools/lib install

mv -v /usr/lib/libnss_{myhostname,mymachines,resolve}.so.2 /lib

rm -rfv /usr/lib/rpm

for tool in runlevel reboot shutdown poweroff halt telinit; do
     ln -sfv ../bin/systemctl /sbin/${tool}
done
ln -sfv ../lib/systemd/systemd /sbin/init

systemd-machine-id-setup

rm -fv /etc/resolv.conf
ln -s ../lib/systemd/resolv.conf /etc/resolv.conf

sed -i "s:minix:ext4:g" src/test/test-path-util.c
make LD_LIBRARY_PATH=/tools/lib -k check

checkBuiltPackage
cd /sources
rm -r systemd


mkdir -v procps-ng && tar -xf procps-ng-*.tar.* -C procps-ng --strip-components 1
cd /sources/procps-ng

./configure --prefix=/usr                            \
            --exec-prefix=                           \
            --libdir=/usr/lib                        \
            --docdir=/usr/share/doc/procps-ng-3.3.12 \
            --disable-static                         \
            --disable-kill                           \
            --with-systemd

make

sed -i -r 's|(pmap_initname)\\\$|\1|' testsuite/pmap.test/pmap.exp
make check

make install

mv -v /usr/lib/libprocps.so.* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libprocps.so) /usr/lib/libprocps.so

cd /sources
rm -r procps-ng


mkdir -v e2fsprogs && tar -xf e2fsprogs-*.tar.* -C e2fsprogs --strip-components 1
cd /sources/e2fsprogs

mkdir -v build
cd build

LIBS=-L/tools/lib                    \
CFLAGS=-I/tools/include              \
PKG_CONFIG_PATH=/tools/lib/pkgconfig \
../configure --prefix=/usr           \
             --bindir=/bin           \
             --with-root-prefix=""   \
             --enable-elf-shlibs     \
             --disable-libblkid      \
             --disable-libuuid       \
             --disable-uuidd         \
             --disable-fsck

make

ln -sfv /tools/lib/lib{blk,uu}id.so.1 lib
make LD_LIBRARY_PATH=/tools/lib check

make install

make install-libs

chmod -v u+w /usr/lib/{libcom_err,libe2p,libext2fs,libss}.a

gunzip -v /usr/share/info/libext2fs.info.gz
install-info --dir-file=/usr/share/info/dir /usr/share/info/libext2fs.info

makeinfo -o      doc/com_err.info ../lib/et/com_err.texinfo
install -v -m644 doc/com_err.info /usr/share/info
install-info --dir-file=/usr/share/info/dir /usr/share/info/com_err.info

cd /sources
rm -r e2fsprogs



mkdir -v coreutils && tar -xf coreutils-*.tar.* -C coreutils --strip-components 1
cd /sources/coreutils

patch -Np1 -i ../coreutils-8.25-i18n-2.patch

FORCE_UNSAFE_CONFIGURE=1 ./configure \
            --prefix=/usr            \
            --enable-no-install-program=kill,uptime

FORCE_UNSAFE_CONFIGURE=1 make

make NON_ROOT_USERNAME=nobody check-root

echo "dummy:x:1000:nobody" >> /etc/group

chown -Rv nobody . 

su nobody -s /bin/bash \
          -c "PATH=$PATH make RUN_EXPENSIVE_TESTS=yes check"

sed -i '/dummy/d' /etc/group

make install

mv -v /usr/bin/{cat,chgrp,chmod,chown,cp,date,dd,df,echo} /bin
mv -v /usr/bin/{false,ln,ls,mkdir,mknod,mv,pwd,rm} /bin
mv -v /usr/bin/{rmdir,stty,sync,true,uname} /bin
mv -v /usr/bin/chroot /usr/sbin
mv -v /usr/share/man/man1/chroot.1 /usr/share/man/man8/chroot.8
sed -i s/\"1\"/\"8\"/1 /usr/share/man/man8/chroot.8

mv -v /usr/bin/{head,sleep,nice,test,[} /bin



cd /sources
rm -r coreutils


mkdir -v diffutils && tar -xf diffutils-*.tar.* -C diffutils --strip-components 1
cd /sources/diffutils

sed -i 's:= @mkdir_p@:= /bin/mkdir -p:' po/Makefile.in.in
commonBuildRoutine
checkBuiltPackage

cd /sources
rm -r diffutils


mkdir -v gawk && tar -xf gawk-*.tar.* -C gawk --strip-components 1
cd /sources/gawk

commonBuildRoutine
mkdir -v /usr/share/doc/gawk-4.1.4
cp    -v doc/{awkforai.txt,*.{eps,pdf,jpg}} /usr/share/doc/gawk-4.1.4
checkBuiltPackage

cd /sources
rm -r gawk



mkdir -v findutils && tar -xf findutils-*.tar.* -C findutils --strip-components 1
cd /sources/findutils

./configure --prefix=/usr --localstatedir=/var/lib/locate

make

make check

make install

mv -v /usr/bin/find /bin
sed -i 's|find:=${BINDIR}|find:=/bin|' /usr/bin/updatedb

checkBuiltPackage

cd /sources
rm -r findutils

mkdir -v groff && tar -xf groff-*.tar.* -C groff --strip-components 1
cd /sources/groff

PAGE=A4 ./configure --prefix=/usr
make
make install

checkBuiltPackage
cd /sources
rm -r groff

#I wont use grub because I will use my host's grub and efi partition
#./configure --prefix=/usr          \
#            --sbindir=/sbin        \
#            --sysconfdir=/etc      \
#            --disable-efiemu       \
#            --disable-werror#ß
#
#make
#
#make install
#Continue regularly with 'less'


mkdir -v less && tar -xf less-*.tar.* -C less --strip-components 1
cd /sources/less

./configure --prefix=/usr --sysconfdir=/etc
make
make install

checkBuiltPackage
cd /sources
rm -r less


mkdir -v gzip && tar -xf gzip-*.tar.* -C gzip --strip-components 1
cd /sources/gzip

commonBuildRoutine
checkBuiltPackage
mv -v /usr/bin/gzip /bin

cd /sources
rm -r gzip


mkdir -v iproute2 && tar -xf iproute2-*.tar.* -C iproute2 --strip-components 1
cd /sources/iproute2

sed -i /ARPD/d Makefile
sed -i 's/arpd.8//' man/man8/Makefile
rm -v doc/arpd.sgml
sed -i 's/m_ipt.o//' tc/Makefile
make
make DOCDIR=/usr/share/doc/iproute2-4.7.0 install
checkBuiltPackage

cd /sources
rm -r iproute2


mkdir -v kbd && tar -xf kbd-*.tar.* -C kbd --strip-components 1
cd /sources/kbd

patch -Np1 -i ../kbd-2.0.3-backspace-1.patch
sed -i 's/\(RESIZECONS_PROGS=\)yes/\1no/g' configure
sed -i 's/resizecons.8 //' docs/man/man8/Makefile.in
PKG_CONFIG_PATH=/tools/lib/pkgconfig ./configure --prefix=/usr --disable-vlock
make
make check
make install
mkdir -v       /usr/share/doc/kbd-2.0.3
cp -R -v docs/doc/* /usr/share/doc/kbd-2.0.3
checkBuiltPackage

cd /sources
rm -r kbd


mkdir -v libpipeline && tar -xf libpipeline-*.tar.* -C libpipeline --strip-components 1
cd /sources/libpipeline

PKG_CONFIG_PATH=/tools/lib/pkgconfig ./configure --prefix=/usr

make
make check
make install

checkBuiltPackage
cd /sources
rm -r libpipeline


mkdir -v make && tar -xf make-*.tar.* -C make --strip-components 1
cd /sources/make

commonBuildRoutine
checkBuiltPackage

cd /sources
rm -r make


mkdir -v patch && tar -xf patch-*.tar.* -C patch --strip-components 1
cd /sources/patch

commonBuildRoutine
checkBuiltPackage

cd /sources
rm -r patch

mkdir -v dbus && tar -xf dbus-*.tar.* -C dbus --strip-components 1
cd /sources/dbus

 ./configure --prefix=/usr                       \
              --sysconfdir=/etc                   \
              --localstatedir=/var                \
              --disable-static                    \
              --disable-doxygen-docs              \
              --disable-xml-docs                  \
              --docdir=/usr/share/doc/dbus-1.10.10 \
              --with-console-auth-dir=/run/console

make
make install
mv -v /usr/lib/libdbus-1.so.* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libdbus-1.so) /usr/lib/libdbus-1.so

ln -sfv /etc/machine-id /var/lib/dbus

checkBuiltPackage
cd /sources
rm -r dbus


mkdir -v util-linux && tar -xf util-linux-*.tar.* -C util-linux --strip-components 1
cd /sources/util-linux

mkdir -pv /var/lib/hwclock

./configure ADJTIME_PATH=/var/lib/hwclock/adjtime   \
            --docdir=/usr/share/doc/util-linux-2.28.2 \
            --disable-chfn-chsh  \
            --disable-login      \
            --disable-nologin    \
            --disable-su         \
            --disable-setpriv    \
            --disable-runuser    \
            --disable-pylibmount \
            --disable-static     \
            --without-python     \
            --enable-libmount-force-mountinfo

make
make install
checkBuiltPackage

cd /sources
rm -r util-linux


mkdir -v man-db && tar -xf mandb-*.tar.* -C man-db --strip-components 1
cd /sources/mandb

./configure --prefix=/usr                        \
            --docdir=/usr/share/doc/man-db-2.7.5 \
            --sysconfdir=/etc                    \
            --disable-setuid                     \
            --with-browser=/usr/bin/lynx         \
            --with-vgrind=/usr/bin/vgrind        \
            --with-grap=/usr/bin/grap

make && make check && make install

sed -i "s:man root:root root:g" /usr/lib/tmpfiles.d/man-db.conf

cd /sources
rm -r man-db

mkdir -v tar && tar -xf tar-*.tar.* -C sed --strip-components 1
cd /sources/tar

FORCE_UNSAFE_CONFIGURE=1  \
./configure --prefix=/usr \
            --bindir=/bin

make
make check
make install
make -C doc install-html docdir=/usr/share/doc/tar-1.29

checkBuiltPackage

cd /sources
rm -r tar


mkdir -v texinfo && tar -xf texinfo-*.tar.* -C texinfo --strip-components 1
cd /sources/texinfo

./configure --prefix=/usr --disable-static
make
make check
make install
make TEXMF=/usr/share/texmf install-tex
pushd /usr/share/info
rm -v dir
for f in *
  do install-info $f dir 2>/dev/null
done
popd

checkBuiltPackage

cd /sources
rm -r texinfo


mkdir -v vim && tar -xf vim-*.tar.* -C vim --strip-components 1
cd /sources/vim

echo '#define SYS_VIMRC_FILE "/etc/vimrc"' >> src/feature.h

./configure --prefix=/usr
make
make -j1 test
make install

ln -sv vim /usr/bin/vi
for L in  /usr/share/man/{,*/}man1/vim.1; do
    ln -sv vim.1 $(dirname $L)/vi.1
done

ln -sv ../vim/vim80/doc /usr/share/doc/vim-8.0

cat > /etc/vimrc << "EOF"
" Begin /etc/vimrc
set nocompatible
set backspace=2
syntax on
if (&term == "iterm") || (&term == "putty")
  set background=dark
endif
" End /etc/vimrc
EOF


checkBuiltPackage
cd /sources
rm -r vim

logout
exit
