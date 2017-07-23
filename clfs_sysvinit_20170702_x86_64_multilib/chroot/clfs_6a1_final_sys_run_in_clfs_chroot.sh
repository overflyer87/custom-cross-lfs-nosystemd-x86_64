#!/bin/bash

function checkBuiltPackage () {

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

#Chapter 9
#Starting with test suite packages

cd ${CLFSSOURCES}

#Tcl
mkdir tcl && tar xf tcl-*.tar.* -C tcl --strip-components 1
cd tcl
cd unix

CC="gcc ${BUILD64}" ./configure \
    --prefix=/tools \
    --libdir=/tools/lib64

make
make install 
make install-private-headers
ln -sv tclsh8.6 /tools/bin/tclsh

cd ${CLFSSOURCES}
#checkBuiltPackage 
rm -rf tcl

#Expect
mkdir expect && tar xf expect*.tar.* -C expect --strip-components 1
cd expect

CC="gcc ${BUILD64}" \
./configure \
    --prefix=/tools \
    --with-tcl=/tools/lib64 \
    --with-tclinclude=/tools/include \
    --libdir=/tools/lib64

make
make SCRIPTS="" install

cd ${CLFSSOURCES}
#checkBuiltPackage 
rm -rf expect

#DejaGNU
mkdir dejagnu && tar xf dejagnu-*.tar.* -C dejagnu --strip-components 1
cd dejagnu

./configure \
    --prefix=/tools

make install

cd ${CLFSSOURCES}
#checkBuiltPackage 
rm -rf dejagnu

#Chapter 10
#Installing the basic system software

cd ${CLFSSOURCES}

#Starting with Chapter 10.4 
#Temporary-Perl
mkdir perl && tar xf perl-*.tar.* -C perl --strip-components 1
cd perl
sed -i 's@/usr/include@/tools/include@g' ext/Errno/Errno_pm.PL

./configure.gnu \
    --prefix=/tools \
    -Dcc="gcc ${BUILD32}"

make
make install
ln -sfv /tools/bin/perl /usr/bin

cd ${CLFSSOURCES}
#checkBuiltPackage 
rm -rf perl

#Linux headers
mkdir linux && tar xf linux-*.tar.* -C linux --strip-components 1
cd linux

make mrproper
make headers_check
make INSTALL_HDR_PATH=/usr headers_install
find /usr/include -name .install -or -name ..install.cmd | xargs rm -fv

cd ${CLFSSOURCES}
#checkBuiltPackage  
rm -rf linux

#Man Pages
mkdir man-pages && tar xf man-pages-*.tar.* -C man-pages --strip-components 1
cd man-pages

make install

cd ${CLFSSOURCES}
#checkBuiltPackage 
rm -rf man-pages

#Glibc 32-bit
mkdir glibc && tar xf glibc-*.tar.* -C glibc --strip-components 1
cd glibc

LINKER=$(readelf -l /tools/bin/bash | sed -n 's@.*interpret.*/tools\(.*\)]$@\1@p')
sed -i "s|libs -o|libs -L/usr/lib -Wl,-dynamic-linker=${LINKER} -o|" \
  scripts/test-installation.pl
  
unset LINKER

mkdir -v ../glibc-build
cd ../glibc-build

CC="gcc ${BUILD32}" CXX="g++ ${BUILD32}" \
../glibc/configure \
    --prefix=/usr \
    --enable-kernel=3.12.0 \
    --libexecdir=/usr/lib/glibc \
    --host=${CLFS_TARGET32} \
    --enable-stack-protector=strong \
    --enable-obsolete-rpc

make
sed -i '/cross-compiling/s@ifeq@ifneq@g' ../glibc/localedata/Makefile
#make check
touch /etc/ld.so.conf
make install
rm -v /usr/include/rpcsvc/*.x

cd ${CLFSSOURCES} 
#checkBuiltPackage 
rm -rf glibc
rm -rf glibc-build 

#Glibc 64-bit
mkdir glibc && tar xf glibc-*.tar.* -C glibc --strip-components 1
cd glibc

LINKER=$(readelf -l /tools/bin/bash | sed -n 's@.*interpret.*/tools\(.*\)]$@\1@p')
sed -i "s|libs -o|libs -L/usr/lib64 -Wl,-dynamic-linker=${LINKER} -o|" \
  scripts/test-installation.pl
unset LINKER

mkdir -v ../glibc-build
cd ../glibc-build

echo "libc_cv_slibdir=/lib64" >> config.cache

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
../glibc/configure \
    --prefix=/usr \
    --enable-kernel=3.12.0 \
    --libexecdir=/usr/lib64/glibc \
    --libdir=/usr/lib64 \
    --enable-obsolete-rpc \
    --enable-stack-protector=strong \
    --cache-file=config.cache

make 
#make check

#checkBuiltPackage 

make install &&
rm -v /usr/include/rpcsvc/*.x

cp -v ../glibc/nscd/nscd.conf /etc/nscd.conf
mkdir -pv /var/cache/nscd

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

tar -xf ../tzdata2017b.tar.gz

ZONEINFO=/usr/share/zoneinfo
mkdir -pv $ZONEINFO/{posix,right}

for tz in etcetera southamerica northamerica europe africa antarctica \
          asia australasia backward pacificnew systemv; do
    zic -L /dev/null   -d $ZONEINFO       -y "sh yearistype.sh" ${tz}
    zic -L /dev/null   -d $ZONEINFO/posix -y "sh yearistype.sh" ${tz}
    zic -L leapseconds -d $ZONEINFO/right -y "sh yearistype.sh" ${tz}
done

cp -v zone.tab zone1970.tab iso3166.tab $ZONEINFO
zic -d $ZONEINFO -p America/New_York
unset ZONEINFO

#tzselect

cp -v /usr/share/zoneinfo/Europe/Berlin \
    /etc/localtime

cat > /etc/ld.so.conf << "EOF"
# Begin /etc/ld.so.conf

/usr/local/lib
/usr/local/lib64
/opt/lib
/opt/lib64

# End /etc/ld.so.conf
EOF

cd ${CLFSSOURCES} 
#checkBuiltPackage 
rm -rf glibc
rm -rf glibc-build 

#Adjusting the toolchain
gcc -dumpspecs | \
perl -p -e 's@/tools/lib/ld@/lib/ld@g;' \
     -e 's@/tools/lib64/ld@/lib64/ld@g;' \
     -e 's@\*startfile_prefix_spec:\n@$_/usr/lib/ @g;' > \
     $(dirname $(gcc --print-libgcc-file-name))/specs

echo 'int main(){}' > dummy.c
gcc ${BUILD32} dummy.c
readelf -l a.out | grep ': /lib'

#checkBuiltPackage 

echo 'main(){}' > dummy.c
gcc ${BUILD64} dummy.c
readelf -l a.out | grep ': /lib'

rm -v dummy.c a.out

cd ${CLFSSOURCES}

echo " "
echo "After adjusting it is a good point to take a breath..."
echo "Smaller scripts makes seeing errors easier for you"
echo "and maintenance easier for me ;)"
echo "Execute script 6a2 next!"
echo " "

sh ${CLFS}/clfs_6a2_final_sys_run_in_clfs_chroot.sh
















