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

#Variables
CLFS=/mnt/clfs
CLFSUSER=clfs
CLFSHOME=${CLFS}/home
CLFSSOURCES=${CLFS}/sources
CLFSTOOLS=${CLFS}/tools
CLFSCROSSTOOLS=${CLFS}/cross-tools
CLFS_HOST=$(echo ${MACHTYPE} | sed -e 's/-[^-]*/-cross/')
CLFS_TARGET="x86_64-unknown-linux-gnu"
CLFS_TARGET32="i686-pc-linux-gnu"
BUILD32="-m32"
BUILD64="-m64"
MAKEFLAGS="-j$(nproc)"

export CLFS=/mnt/clfs
export CLFSHOME=/mnt/clfs/home
export CLFSSOURCES=/mnt/clfs/sources
export CLFSTOOLS=/mnt/clfs/tools
export CLFSCROSSTOOLS=/mnt/clfs/cross-tools
export CLFSUSER=clfs
export CLFS_HOST=$(echo ${MACHTYPE} | sed -e 's/-[^-]*/-cross/')
export CLFS_TARGET="x86_64-unknown-linux-gnu"
export CLFS_TARGET32="i686-pc-linux-gnu"
export BUILD32="-m32"
export BUILD64="-m64"
export MAKEFLAGS="-j$(nproc)"

echo " "
echo "Lets start building the Cross Compile Tools"
echo "Chapter 5.1 to 5.15"
echo " "

echo "First check your environment setup"
echo "Are all essential variables there"
echo "With the right values as described on"
echo "http://clfs.org/view/sysvinit/x86_64/final-preps/settingenvironment.html"
echo "and"
echo "http://clfs.org/view/sysvinit/x86_64/final-preps/variables.html"

echo " "
env
echo " "

checkBuiltPackage

echo " "

#Build Cross-Compile Tools
cd ${CLFSSOURCES}

#File
mkdir file && tar xf file-*.tar.* -C file --strip-components 1
cd file
./configure --prefix=/cross-tools && make && make install
cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf file

#Linux headers
mkdir linux && tar xf linux-*.tar.* -C linux --strip-components 1
cd linux
make mrproper
make ARCH=x86_64 headers_check
make ARCH=x86_64 INSTALL_HDR_PATH=/tools headers_install

cd ${CLFSSOURCES} 
checkBuiltPackage 
rm -rf linux

#M4
mkdir m4 && tar xf m4-*.tar.* -C m4 --strip-components 1
cd m4
./configure --prefix=/cross-tools && make && make install

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf m4

#Ncurses
mkdir ncurses && tar xf ncurses-*.tar.* -C ncurses --strip-components 1
cd ncurses
./configure --prefix=/cross-tools --without-debug 
make -C include 
make -C progs tic
install -v -m755 progs/tic /cross-tools/bin

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf ncurses

#Pkg-config
mkdir pkg-config && tar xf pkg-config-*.tar.* -C pkg-config --strip-components 1
cd pkg-config
./configure --prefix=/cross-tools \
    --host=${CLFS_TARGET} \
    --with-pc-path=/tools/lib64/pkgconfig:/tools/share/pkgconfig &&
make && make install
cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf pkg-config

#GMP
mkdir gmp && tar xf gmp-*.tar.* -C gmp --strip-components 1
cd gmp
./configure --prefix=/cross-tools \
    --enable-cxx \
    --disable-static
make && make install
cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf gmp

#MPFR
mkdir mpfr && tar xf mpfr-*.tar.* -C mpfr --strip-components 1
cd mpfr
patch -Np1 -i ../mpfr-3.1.5-fixes-1.patch
LDFLAGS="-Wl,-rpath,/cross-tools/lib" ./configure \
    --prefix=/cross-tools \
    --with-gmp=/cross-tools \
    --disable-static
make && make install
cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf mpfr

#MPC
mkdir mpc && tar xf mpc-*.tar.* -C mpc --strip-components 1
cd mpc
LDFLAGS="-Wl,-rpath,/cross-tools/lib" ./configure \
    --prefix=/cross-tools \
    --with-gmp=/cross-tools \
	--with-mpfr=/cross-tools \
    --disable-static
make && make install
cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf mpc

#ISL
mkdir isl && tar xf isl-*.tar.* -C isl --strip-components 1
cd isl
LDFLAGS="-Wl,-rpath,/cross-tools/lib" ./configure \
    --prefix=/cross-tools \
    --disable-static \
    --with-gmp-prefix=/cross-tools
make && make install
cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf isl

#Cross binutils
mkdir binutils && tar xf binutils-*.tar.* -C binutils --strip-components 1
cd binutils
mkdir -v ../binutils-build
cd ../binutils-build

AR=ar AS=as \
../binutils/configure \
    --prefix=/cross-tools \
    --host=${CLFS_HOST} \
    --target=${CLFS_TARGET} \
    --with-sysroot=${CLFS} \
    --with-lib-path=/tools/lib:/tools/lib64 \
    --disable-nls \
    --disable-static \
    --enable-64-bit-bfd \
    --enable-gold=yes \
    --enable-plugins \
    --enable-threads \
    --disable-werror

make && make install

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf binutils
rm -rf binutils-build

#GCC Static
mkdir gcc && tar xf gcc-*.tar.* -C gcc --strip-components 1
cd gcc
patch -Np1 -i ../gcc-7.1.0-specs-1.patch
echo -en '\n#undef STANDARD_STARTFILE_PREFIX_1\n#define STANDARD_STARTFILE_PREFIX_1 "/tools/lib/"\n' >> gcc/config/linux.h
echo -en '\n#undef STANDARD_STARTFILE_PREFIX_2\n#define STANDARD_STARTFILE_PREFIX_2 ""\n' >> gcc/config/linux.h
touch /tools/include/limits.h

mkdir -v ../gcc-build
cd ../gcc-build

AR=ar \
LDFLAGS="-Wl,-rpath,/cross-tools/lib" \
../gcc/configure \
    --prefix=/cross-tools \
    --build=${CLFS_HOST} \
    --host=${CLFS_HOST} \
    --target=${CLFS_TARGET} \
    --with-sysroot=${CLFS} \
    --with-local-prefix=/tools \
    --with-native-system-header-dir=/tools/include \
    --disable-shared \
    --with-mpfr=/cross-tools \
    --with-gmp=/cross-tools \
    --with-mpc=/cross-tools \
    --without-headers \
    --with-newlib \
    --disable-decimal-float \
    --disable-libgomp \
    --disable-libssp \
    --disable-libatomic \
    --disable-libitm \
    --disable-libsanitizer \
    --disable-libquadmath \
    --disable-libvtv \
    --disable-libcilkrts \
    --disable-libstdc++-v3 \
    --disable-threads \
    --with-isl=/cross-tools \
    --enable-languages=c \
    --with-glibc-version=2.25

make all-gcc all-target-libgcc
make install-gcc install-target-libgcc

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf gcc
rm -rf gcc-build

#Glibc 32-bit
mkdir glibc && tar xf glibc-*.tar.* -C glibc --strip-components 1
cd glibc

mkdir -v ../glibc-build
cd ../glibc-build

BUILD_CC="gcc" CC="${CLFS_TARGET}-gcc ${BUILD32}" \
AR="${CLFS_TARGET}-ar" RANLIB="${CLFS_TARGET}-ranlib" \
../glibc/configure \
    --prefix=/tools \
    --host=${CLFS_TARGET32} \
    --build=${CLFS_HOST} \
    --enable-kernel=3.12.0 \
    --with-binutils=/cross-tools/bin \
    --with-headers=/tools/include \
    --enable-obsolete-rpc

make && make install

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf glibc
rm -rf glibc-build

#Glibc 64-bit
mkdir glibc && tar xf glibc-*.tar.* -C glibc --strip-components 1
cd glibc

mkdir -v ../glibc-build
cd ../glibc-build

echo "libc_cv_slibdir=/tools/lib64" >> config.cache

BUILD_CC="gcc" CC="${CLFS_TARGET}-gcc ${BUILD64}" \
AR="${CLFS_TARGET}-ar" RANLIB="${CLFS_TARGET}-ranlib" \
../glibc/configure \
    --prefix=/tools \
    --host=${CLFS_TARGET} \
    --build=${CLFS_HOST} \
    --libdir=/tools/lib64 \
    --enable-kernel=3.12.0 \
    --with-binutils=/cross-tools/bin \
    --with-headers=/tools/include \
    --enable-obsolete-rpc \
    --cache-file=config.cache

make && make install

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf glibc
rm -rf glibc-build

#GCC Final
mkdir gcc && tar xf gcc-*.tar.* -C gcc --strip-components 1
cd gcc
patch -Np1 -i ../gcc-7.1.0-specs-1.patch
echo -en '\n#undef STANDARD_STARTFILE_PREFIX_1\n#define STANDARD_STARTFILE_PREFIX_1 "/tools/lib/"\n' >> gcc/config/linux.h
echo -en '\n#undef STANDARD_STARTFILE_PREFIX_2\n#define STANDARD_STARTFILE_PREFIX_2 ""\n' >> gcc/config/linux.h
mkdir -v ../gcc-build
cd ../gcc-build

AR=ar \
LDFLAGS="-Wl,-rpath,/cross-tools/lib" \
../gcc/configure \
    --prefix=/cross-tools \
    --build=${CLFS_HOST} \
    --target=${CLFS_TARGET} \
    --host=${CLFS_HOST} \
    --with-sysroot=${CLFS} \
    --with-local-prefix=/tools \
    --with-native-system-header-dir=/tools/include \
    --disable-static \
    --enable-languages=c,c++ \
    --with-mpc=/cross-tools \
    --with-mpfr=/cross-tools \
    --with-gmp=/cross-tools \
    --with-isl=/cross-tools

make AS_FOR_TARGET="${CLFS_TARGET}-as" \
    LD_FOR_TARGET="${CLFS_TARGET}-ld"
    
make install
cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf gcc
rm -rf gcc-build

echo " "
echo "Cross compile tools are finished"
echo "If there were no errors continue"
echo "With Script #3"
echo " "

cd ~
sh clfs_3_temp_sys_RACU.sh

