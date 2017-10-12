#!/bin/bash

function checkBuiltPackage () {
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

export CLFS=/
export CLFSSOURCES=/sources
export MAKEFLAGS="-j$(nproc)"
export BUILD32="-m32"
export BUILD64="-m64"
export CLFS_TARGET32="i686-pc-linux-gnu"

#Let's continue
#Final system is seperated into several parts 
#to make bugfixing and maintenance easier

cd ${CLFSSOURCES}

#M4
mkdir m4 && tar xf m4-*.tar.* -C m4 --strip-components 1
cd m4

CC="gcc ${BUILD64}" ./configure \
    --prefix=/usr

make
make check
checkBuiltPackage 
make install
cd ${CLFSSOURCES} 
checkBuiltPackage 
rm -rf m4

#GMP 32-bit
mkdir gmp && tar xf gmp-*.tar.* -C gmp --strip-components 1
cd gmp

CC="gcc -isystem /usr/include ${BUILD32}" \
CXX="g++ -isystem /usr/include ${BUILD32}" \
LDFLAGS="-Wl,-rpath-link,/usr/lib:/lib ${BUILD32}" \
  ABI=32 ./configure \
    --prefix=/usr \
    --enable-cxx

make
make check

checkBuiltPackage 

make install
mv -v /usr/include/gmp{,-32}.h

cd ${CLFSSOURCES} 
checkBuiltPackage 
rm -rf gmp

#GMP 64-bit
mkdir gmp && tar xf gmp-*.tar.* -C gmp --strip-components 1
cd gmp

CC="gcc -isystem /usr/include ${BUILD64}" \
CXX="g++ -isystem /usr/include ${BUILD64}" \
LDFLAGS="-Wl,-rpath-link,/usr/lib64:/lib64 ${BUILD64}" \
./configure \
    --prefix=/usr \
    --libdir=/usr/lib64 \
    --enable-cxx \
    --docdir=/usr/share/doc/gmp-6.1.2

make && make html
make check
checkBuiltPackage 

make install && make install-html

mv -v /usr/include/gmp{,-64}.h

cat > /usr/include/gmp.h << "EOF"
/* gmp.h - Stub Header  */
#ifndef __STUB__GMP_H__
#define __STUB__GMP_H__

#if defined(__x86_64__) || \
    defined(__sparc64__) || \
    defined(__arch64__) || \
    defined(__powerpc64__) || \
    defined (__s390x__)
# include "gmp-64.h"
#else
# include "gmp-32.h"
#endif

#endif /* __STUB__GMP_H__ */
EOF

cd ${CLFSSOURCES} 
checkBuiltPackage 
rm -rf gmp

#MPFR 32-bit
mkdir mpfr && tar xf mpfr-*.tar.* -C mpfr --strip-components 1
cd mpfr
patch -Np1 -i ../mpfr-3.1.5-fixes-1.patch

CC="gcc -isystem /usr/include ${BUILD32}" \
    LDFLAGS="-Wl,-rpath-link,/usr/lib:/lib ${BUILD32}" \
./configure \
    --prefix=/usr \
    --libdir=/usr/lib \
    --with-gmp=/usr/lib \
    --host=${CLFS_TARGET32} \
    --docdir=/usr/share/doc/mpfr-3.1.5

make && make html
make check
checkBuiltPackage 

make install && make install-html

cd ${CLFSSOURCES} 
checkBuiltPackage 
rm -rf mpfr

#MPFR 64-bit
mkdir mpfr && tar xf mpfr-*.tar.* -C mpfr --strip-components 1
cd mpfr
patch -Np1 -i ../mpfr-3.1.5-fixes-1.patch

CC="gcc -isystem /usr/include ${BUILD64}" \
    LDFLAGS="-Wl,-rpath-link,/usr/lib64:/lib64 ${BUILD64}" \
./configure \
    --prefix=/usr \
    --libdir=/usr/lib64 \
    --with-gmp=/usr/lib64\
    --docdir=/usr/share/doc/mpfr-3.1.5

make && make html
make check
checkBuiltPackage 

make install && make install-html

cd ${CLFSSOURCES} 
checkBuiltPackage 
rm -rf mpfr

#MPC 32-bit
mkdir mpc && tar xf mpc-*.tar.* -C mpc --strip-components 1
cd mpc

CC="gcc -isystem /usr/include ${BUILD32}" \
LDFLAGS="-Wl,-rpath-link,/usr/lib:/lib ${BUILD32}" \
./configure \
    --prefix=/usr \
    --libdir=/usr/lib \
    --with-gmp=/usr/lib \
    --with-mpfr=/usr/lib \
    --host=${CLFS_TARGET32}

make
make check
checkBuiltPackage 
make install

cd ${CLFSSOURCES} 
checkBuiltPackage 
rm -rf mpc

#MPC 64-bit
mkdir mpc && tar xf mpc-*.tar.* -C mpc --strip-components 1
cd mpc

CC="gcc -isystem /usr/include ${BUILD64}" \
LDFLAGS="-Wl,-rpath-link,/usr/lib64:/lib64 ${BUILD64}" \
./configure \
    --prefix=/usr \
    --libdir=/usr/lib64 \
    --with-gmp=/usr/lib64 \
    --with-mpfr=/usr/lib64 \
    --docdir=/usr/share/doc/mpc-1.0.3

make && make html
make check
checkBuiltPackage 
make install && make install-html

cd ${CLFSSOURCES} 
checkBuiltPackage 
rm -rf mpc

#ISL 32-bit
mkdir isl && tar xf isl-*.tar.* -C isl --strip-components 1
cd isl

CC="gcc -isystem /usr/include ${BUILD32}" \
LDFLAGS="-Wl,-rpath-link,/usr/lib:/lib ${BUILD32}" \
./configure \
    --prefix=/usr \
    --libdir=/usr/lib \
    --with-gmp-prefix=/usr/lib \
    --host=${CLFS_TARGET32}

make
make check
checkBuiltPackage 
make install

mkdir -pv /usr/share/gdb/auto-load/usr/lib
mv -v /usr/lib/libisl*gdb.py /usr/share/gdb/auto-load/usr/lib

cd ${CLFSSOURCES} 
#checkBuiltPackage 
rm -rf isl

#ISL 64-bit
mkdir isl && tar xf isl-*.tar.* -C isl --strip-components 1
cd isl

CC="gcc -isystem /usr/include ${BUILD64}" \
LDFLAGS="-Wl,-rpath-link,/usr/lib64:/lib64 ${BUILD64}" \
./configure \
    --prefix=/usr \
    --with-gmp-prefix=/usr/lib64 \
    --libdir=/usr/lib64

make
make check
checkBuiltPackage 
make install

mkdir -pv /usr/share/gdb/auto-load/usr/lib64
mv -v /usr/lib64/*gdb.py /usr/share/gdb/auto-load/usr/lib64

cd ${CLFSSOURCES} 
checkBuiltPackage 
rm -rf isl

#Zlib 32-bit
mkdir zlib && tar xf zlib-*.tar.* -C zlib --strip-components 1
cd zlib

CC="gcc -isystem /usr/include ${BUILD32}" \
CXX="g++ -isystem /usr/include ${BUILD32}" \
LDFLAGS="-Wl,-rpath-link,/usr/lib:/lib ${BUILD32}" \
./configure \
    --prefix=/usr

make
make check
checkBuiltPackage 
make install

mv -v /usr/lib/libz.so.* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libz.so) /usr/lib/libz.so

cd ${CLFSSOURCES}
checkBuiltPackage 
rm -rf zlib

#Zlib 64-bit
mkdir zlib && tar xf zlib-*.tar.* -C zlib --strip-components 1
cd zlib

CC="gcc -isystem /usr/include ${BUILD64}" \
CXX="g++ -isystem /usr/include ${BUILD64}" \
LDFLAGS="-Wl,-rpath-link,/usr/lib64:/lib64 ${BUILD64}" \
./configure \
    --prefix=/usr \
    --libdir=/usr/lib64

make
make check
checkBuiltPackage 
make install

mv -v /usr/lib64/libz.so.* /lib64
ln -sfv ../../lib64/$(readlink /usr/lib64/libz.so) /usr/lib64/libz.so

mkdir -pv /usr/share/doc/zlib-1.2.11
cp -rv doc/* examples /usr/share/doc/zlib-1.2.11

cd ${CLFSSOURCES}
checkBuiltPackage 
rm -rf zlib

#Flex 32-bit
mkdir flex && tar xf flex-*.tar.* -C flex --strip-components 1
cd flex

CC="gcc ${BUILD32}" ./configure \
    --prefix=/usr \
    --docdir=/usr/share/doc/flex-2.6.4

make
make install

cd ${CLFSSOURCES}
checkBuiltPackage 
rm -rf flex

#Flex 64-bit
mkdir flex && tar xf flex-*.tar.* -C flex --strip-components 1
cd flex

CC="gcc ${BUILD64}" ./configure \
    --prefix=/usr \
    --libdir=/usr/lib64 \
    --docdir=/usr/share/doc/flex-2.6.4

make
make check
checkBuiltPackage 
make install

ln -sv flex /usr/bin/lex

cd ${CLFSSOURCES}
checkBuiltPackage 
rm -rf flex

#Bison 32-bit
mkdir bison && tar xf bison-*.tar.* -C bison --strip-components 1
cd bison

CC="gcc ${BUILD32}" CXX="g++ ${BUILD32}" \
./configure \
    --prefix=/usr \
    --docdir=/usr/share/doc/bison-3.0.4

make
make check
checkBuiltPackage 
make install

cd ${CLFSSOURCES}
checkBuiltPackage 
rm -rf bison

#Bison 64-bit
mkdir bison && tar xf bison-*.tar.* -C bison --strip-components 1
cd bison

CC="gcc ${BUILD64}" \
CXX="g++ ${BUILD64}" \
./configure \
    --prefix=/usr \
    --libdir=/usr/lib64 \
    --docdir=/usr/share/doc/bison-3.0.4 &&
make
make check
checkBuiltPackage 
make install

cd ${CLFSSOURCES}
checkBuiltPackage 
rm -rf bison

#Binutils
mkdir binutils && tar xf binutils-*.tar.* -C binutils --strip-components 1
cd binutils

expect -c "spawn ls"
checkBuiltPackage 

mkdir -v ../binutils-build
cd ../binutils-build

CC="gcc -isystem /usr/include ${BUILD64}" \
LDFLAGS="-Wl,-rpath-link,/usr/lib64:/lib64:/usr/lib:/lib ${BUILD64}" \
../binutils/configure \
    --prefix=/usr \
    --enable-shared \
    --enable-64-bit-bfd \
    --libdir=/usr/lib64 \
    --enable-gold=yes \
    --enable-plugins \
    --with-system-zlib \
    --enable-threads

make tooldir=/usr
make check
checkBuiltPackage 
make tooldir=/usr install

cd ${CLFSSOURCES} 
checkBuiltPackage 
rm -rf binutils
rm -rf binutils-build

#GCC
mkdir gcc && tar xf gcc-*.tar.* -C gcc --strip-components 1
cd gcc

sed -i 's@\./fixinc\.sh@-c true@' gcc/Makefile.in

mkdir -v ../gcc-build
cd ../gcc-build

SED=sed CC="gcc -isystem /usr/include ${BUILD64}" \
CXX="g++ -isystem /usr/include ${BUILD64}" \
LDFLAGS="-Wl,-rpath-link,/usr/lib64:/lib64:/usr/lib:/lib" \
../gcc/configure \
    --prefix=/usr \
    --libdir=/usr/lib64 \
    --libexecdir=/usr/lib64 \
    --enable-languages=c,c++ \
    --with-system-zlib \
    --with-mpfr=/usr/lib64 \
    --with-gmp=/usr/lib64 \
    --with-mpc=/usr/lib64 \
    --with-isl=/usr/lib64 \
    --enable-install-libiberty \
    --disable-bootstrap

make
ulimit -s 32768
make -k check
../gcc/contrib/test_summary
checkBuiltPackage 

make install
ln -sv ../usr/bin/cpp /lib
mv -v /usr/lib/libstdc++*gdb.py /usr/share/gdb/auto-load/usr/lib
mv -v /usr/lib64/libstdc++*gdb.py /usr/share/gdb/auto-load/usr/lib64

cd ${CLFSSOURCES} 
checkBuiltPackage 
rm -rf gcc
rm -rf gcc-build

#Creating a multiarch wrapper
cat > multiarch_wrapper.c << "EOF"
#define _GNU_SOURCE

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/sysmacros.h>
#include <sys/wait.h>
#include <unistd.h>

#ifndef DEF_SUFFIX
#  define DEF_SUFFIX "64"
#endif

int main(int argc, char **argv)
{
  char *filename;
  char *suffix;

  if(!(suffix = getenv("USE_ARCH")))
    if(!(suffix = getenv("BUILDENV")))
      suffix = DEF_SUFFIX;

  if (asprintf(&filename, "%s-%s", argv[0], suffix) < 0) {
    perror(argv[0]);
    return -1;
  }

  int status = EXIT_FAILURE;
  pid_t pid = fork();

  if (pid == 0) {
    execvp(filename, argv);
    perror(filename);
  } else if (pid < 0) {
    perror(argv[0]);
  } else {
    if (waitpid(pid, &status, 0) != pid) {
      status = EXIT_FAILURE;
      perror(argv[0]);
    } else {
      status = WEXITSTATUS(status);
    }
  }

  free(filename);

  return status;
}
EOF

gcc ${BUILD64} multiarch_wrapper.c -o /usr/bin/multiarch_wrapper
checkBuiltPackage 

echo 'echo "32bit Version"' > test-32
echo 'echo "64bit Version"' > test-64
chmod -v 755 test-32 test-64
ln -sv /usr/bin/multiarch_wrapper test

checkBuiltPackage 

USE_ARCH=32 ./test
USE_ARCH=64 ./test

checkBuiltPackage 

rm -v multiarch_wrapper.c test{,-32,-64}

cd ${CLFSSOURCES}

echo " "
echo "Run script #6c next"
echo " "

sh ${CLFS}/clfs_6c_final_system_RASRC.sh

