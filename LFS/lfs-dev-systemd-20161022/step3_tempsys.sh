#!/bin/bash
function checkBuiltPackage {
  echo "Is everything fine?: [Y/N]"
    while read -n1 -r -p "[Y/N]   " && [[ $REPLY != q ]]; do
      case $REPLY in
        Y)  break 1;;
        N)  echo "$EXIT"
            echo "Fix it!"
            exit 1;;
        *)  echo " Try again. Type y or n";;
      esac
    done
}

function commonBuildRoutine {

./configure --prefix=/tools && make && make check && make install

}

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

echo
echo -e "With what speed do you want to build? make supports parallel compiling. Enter the maximum number of cores or threads you have. Usually 1-8: \c"
read numberofthreads
export MAKEFLAGS="j${numberofthreads}"

echo
echo $MAKEFLAGS
echo

echo "Is the MAKEFLAGS value j<yourinputvalue> ?: [Y/N]"
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

cd $LFS/sources

mkdir binutils && tar -xf binutils-*.tar.* -C binutils --strip-components 1
cd ${LFS}/sources/binutils

../configure --prefix=/tools            \
             --with-sysroot=$LFS        \
             --with-lib-path=/tools/lib \
             --target=$LFS_TGT          \
             --disable-nls              \
             --disable-werror

make

case $(uname -m) in
  x86_64) mkdir -v /tools/lib && ln -sv lib /tools/lib64 ;;
esac

make install

cd $LFS/sources
rm -r bintuils

mkdir gcc && tar -xf gcc -*.tar.* -C gcc  --strip-components 1
cd ${LFS}/sources/gcc

mkdir mpfr && tar -xf ../mpfr -*.tar.* -C mpfr --strip-components 1
mkdir gmp && tar -xf ../gmp -*.tar.* -C gmp --strip-components 1
mkdir mpc && tar -xf ../mpc -*.tar.* -C mpc --strip-components 1

for file in \
 $(find gcc/config -name linux64.h -o -name linux.h -o -name sysv4.h)
do
  cp -uv $file{,.orig}
  sed -e 's@/lib\(64\)\?\(32\)\?/ld@/tools&@g' \
      -e 's@/usr@/tools@g' $file.orig > $file
  echo '
#undef STANDARD_STARTFILE_PREFIX_1
#undef STANDARD_STARTFILE_PREFIX_2
#define STANDARD_STARTFILE_PREFIX_1 "/tools/lib/"
#define STANDARD_STARTFILE_PREFIX_2 ""' >> $file
  touch $file.orig
done

mkdir -v build
cd       build

../configure                                       \
    --target=$LFS_TGT                              \
    --prefix=/tools                                \
    --with-glibc-version=2.11                      \
    --with-sysroot=$LFS                            \
    --with-newlib                                  \
    --without-headers                              \
    --with-local-prefix=/tools                     \
    --with-native-system-header-dir=/tools/include \
    --disable-nls                                  \
    --disable-shared                               \
    --disable-multilib                             \
    --disable-decimal-float                        \
    --disable-threads                              \
    --disable-libatomic                            \
    --disable-libgomp                              \
    --disable-libmpx                               \
    --disable-libquadmath                          \
    --disable-libssp                               \
    --disable-libvtv                               \
    --disable-libstdcxx                            \
    --enable-languages=c,c++

make && make install

cd $LFS/sources
rm -r gcc


mkdir linux && tar -xf linux-*.tar.* -C linux  --strip-components 1
cd ${LFS}/sources/linux

make mrproper

make INSTALL_HDR_PATH=dest headers_install
cp -rv dest/include/* /tools/include

cd $LFS/sources
rm -r linux


mkdir glibc && tar -xf glibc-*.tar.* -C glibc  --strip-components 1
cd ${LFS}/sources/glibc

mkdir -v build
cd       build

../configure                             \
      --prefix=/tools                    \
      --host=$LFS_TGT                    \
      --build=$(../scripts/config.guess) \
      --enable-kernel=2.6.32             \
      --with-headers=/tools/include      \
      libc_cv_forced_unwind=yes          \
      libc_cv_c_cleanup=yes

make && make install

echo 'int main(){}' > dummy.c
$LFS_TGT-gcc dummy.c
readelf -l a.out | grep ': /tools'

echo
echo "Does the output say [Requesting program interpreter: /tools/lib/ld-linux.so.2]?: [Y/N]"
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

rm -v dummy.c a.out

cd $LFS/sources
rm -r glibc


mkdir gcc && tar -xf gcc -*.tar.* -C gcc --strip-components 1
cd ${LFS}/sources/gcc

mkdir -v build
cd       build

../libstdc++-v3/configure           \
    --host=$LFS_TGT                 \
    --prefix=/tools                 \
    --disable-multilib              \
    --disable-nls                   \
    --disable-libstdcxx-threads     \
    --disable-libstdcxx-pch         \
    --with-gxx-include-dir=/tools/$LFS_TGT/include/c++/6.2.0
    
make && make install

cd $LFS/sources
rm -r gcc 


mkdir binutils && tar -xf binutils-*.tar.* -C binutils --strip-components 1
cd ${LFS}/sources/binutils

mkdir -v build
cd       build

CC=$LFS_TGT-gcc                \
AR=$LFS_TGT-ar                 \
RANLIB=$LFS_TGT-ranlib         \
../configure                   \
    --prefix=/tools            \
    --disable-nls              \
    --disable-werror           \
    --with-lib-path=/tools/lib \
    --with-sysroot

make && make install

make -C ld clean
make -C ld LIB_PATH=/usr/lib:/lib
cp -v ld/ld-new /tools/bin

cd $LFS/sources
rm -r binutils


mkdir gcc && tar -xf gcc-*.tar.* -C gcc --strip-components 1
cd ${LFS}/sources/gcc

cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
  `dirname $($LFS_TGT-gcc -print-libgcc-file-name)`/include-fixed/limits.h

for file in \
 $(find gcc/config -name linux64.h -o -name linux.h -o -name sysv4.h)
do
  cp -uv $file{,.orig}
  sed -e 's@/lib\(64\)\?\(32\)\?/ld@/tools&@g' \
      -e 's@/usr@/tools@g' $file.orig > $file
  echo '
#undef STANDARD_STARTFILE_PREFIX_1
#undef STANDARD_STARTFILE_PREFIX_2
#define STANDARD_STARTFILE_PREFIX_1 "/tools/lib/"
#define STANDARD_STARTFILE_PREFIX_2 ""' >> $file
  touch $file.orig
done

mkdir mpfr && tar -xf ../mpfr-*.tar.* -C mpfr --strip-components 1
mkdir gmp && tar -xf ../gmp-*.tar.* -C gmp --strip-components 1
mkdir mpc && tar -xf ../mpc-*.tar.* -C mpc --strip-components 1

mkdir -v build
cd       build

CC=$LFS_TGT-gcc                                    \
CXX=$LFS_TGT-g++                                   \
AR=$LFS_TGT-ar                                     \
RANLIB=$LFS_TGT-ranlib                             \
../configure                                       \
    --prefix=/tools                                \
    --with-local-prefix=/tools                     \
    --with-native-system-header-dir=/tools/include \
    --enable-languages=c,c++                       \
    --disable-libstdcxx-pch                        \
    --disable-multilib                             \
    --disable-bootstrap                            \
    --disable-libgomp

make && make install

ln -sv gcc /tools/bin/cc

echo 'int main(){}' > dummy.c
cc dummy.c
readelf -l a.out | grep ': /tools'


echo
echo "Does the output say [Requesting program interpreter: /tools/lib/ld-linux.so.2]?: [Y/N]"
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

rm -v dummy.c a.out

cd $LFS/sources
rm -r gcc


mkdir tcl-core && tar -xf tcl-core-*.tar.* -C tcl-core  --strip-components 1
cd ${LFS}/sources/tcl-core 

cd unix
./configure --prefix=/tools
make
TZ=UTC make test
make install
chmod -v u+w /tools/lib/libtcl8.6.so
make install-private-headers
ln -sv tclsh8.6 /tools/bin/tclsh

cd $LFS/sources
rm -r tcl-core


mkdir expect && tar -xf expect-*.tar.* -C expect --strip-components 1
cd ${LFS}/sources/expect

cp -v configure{,.orig}
sed 's:/usr/local/bin:/bin:' configure.orig > configure

./configure --prefix=/tools       \
            --with-tcl=/tools/lib \
            --with-tclinclude=/tools/include

make && make test && make SCRIPTS="" install

cd $LFS/sources
rm -r expect


mkdir dejagnu && tar -xf dejagnu-*.tar.* -C dejagnu  --strip-components 1
cd ${LFS}/sources/dejagnu 

commonBuildRoutine

cd $LFS/sources
rm -r dejagnu

mkdir check && tar -xf check-*.tar.* -C check  --strip-components 1
cd ${LFS}/sources/check 

PKG_CONFIG= ./configure --prefix=/tools
make && make check && make install

cd $LFS/sources
rm -r check


mkdir ncurses && tar -xf ncurses-*.tar.* -C ncurses  --strip-components 1
cd ${LFS}/sources/ncurses

sed -i s/mawk// configure

./configure --prefix=/tools \
            --with-shared   \
            --without-debug \
            --without-ada   \
            --enable-widec  \
            --enable-overwrite
            
make && make install

cd $LFS/sources
rm -r ncurses

mkdir bash && tar -xf bash-*.tar.* -C bash  --strip-components 1
cd ${LFS}/sources/bash

./configure --prefix=/tools --without-bash-malloc
make && make tests && make install
ln -sv bash /tools/bin/sh

cd $LFS/sources
rm -r bash


mkdir bzip2 && tar -xf bzip2-*.tar.* -C bzip2  --strip-components 1
cd ${LFS}/sources/bzip2

make && make PREFIX=/tools install

cd $LFS/sources
rm -r bzip2


mkdir coreutils && tar -xf coreutils-*.tar.* -C coreutils  --strip-components 1
cd ${LFS}/sources/coreutils

./configure --prefix=/tools --enable-install-program=hostname
make && make RUN_EXPENSIVE_TESTS=yes check && make install

cd $LFS/sources
rm -r coreutils


mkdir diffutils && tar -xf diffutils-*.tar.* -C diffutils  --strip-components 1
cd ${LFS}/sources/diffutils

commonBuildRoutine

cd $LFS/sources
rm -r diffutils


mkdir file && tar -xf file-*.tar.* -C file  --strip-components 1
cd ${LFS}/sources/file

commonBuildRoutine

cd $LFS/sources
rm -r file



mkdir findutils && tar -xf findutils-*.tar.* -C findutils  --strip-components 1
cd ${LFS}/sources/findutils

commonBuildRoutine

cd $LFS/sources
rm -r findutils



mkdir gawk && tar -xf gawk-*.tar.* -C gawk  --strip-components 1
cd ${LFS}/sources/gawk

commonBuildRoutine

cd $LFS/sources
rm -r gawk


mkdir gettext && tar -xf gettext-*.tar.* -C gettext  --strip-components 1
cd ${LFS}/sources/gettext

cd gettext-tools
EMACS="no" ./configure --prefix=/tools --disable-shared

make -C gnulib-lib
make -C intl pluralx.c
make -C src msgfmt
make -C src msgmerge
make -C src xgettext

cp -v src/{msgfmt,msgmerge,xgettext} /tools/bin


cd $LFS/sources
rm -r gettext


mkdir grep && tar -xf grep-*.tar.* -C grep  --strip-components 1
cd ${LFS}/sources/grep

commonBuildRoutine

cd $LFS/sources
rm -r grep


mkdir gzip && tar -xf gzip-*.tar.* -C gzip  --strip-components 1
cd ${LFS}/sources/gzip

commonBuildRoutine

cd $LFS/sources
rm -r gzip


mkdir m4 && tar -xf m4-*.tar.* -C m4  --strip-components 1
cd ${LFS}/sources/m4

commonBuildRoutine

cd $LFS/sources
rm -r m4


mkdir make && tar -xf make-*.tar.* -C make  --strip-components 1
cd ${LFS}/sources/make

./configure --prefix=/tools --without-guile
make && make check && make install

cd $LFS/sources
rm -r make


mkdir patch && tar -xf patch-*.tar.* -C patch  --strip-components 1
cd ${LFS}/sources/patch

commonBuildRoutine

cd $LFS/sources
rm -r patch


mkdir perl && tar -xf perl-*.tar.* -C perl  --strip-components 1
cd ${LFS}/sources/perl
sh Configure -des -Dprefix=/tools -Dlibs=-lm

make

cp -v perl cpan/podlators/scripts/pod2man /tools/bin
mkdir -pv /tools/lib/perl5/5.24.0
cp -Rv lib/* /tools/lib/perl5/5.24.0

cd $LFS/sources
rm -r perl


mkdir sed && tar -xf sed-*.tar.* -C sed  --strip-components 1
cd ${LFS}/sources/sed

commonBuildRoutine

cd $LFS/sources
rm -r sed


mkdir tar && tar -xf tar-*.tar.* -C tar  --strip-components 1
cd ${LFS}/sources/tar

commonBuildRoutine

cd $LFS/sources
rm -r tar


mkdir texinfo && tar -xf texinfo-*.tar.* -C texinfo  --strip-components 1
cd ${LFS}/sources/texinfo

commonBuildRoutine

cd $LFS/sources
rm -r texinfo


mkdir util-linux && tar -xf util-linux-*.tar.* -C util-linux  --strip-components 1
cd ${LFS}/sources/util-linux

./configure --prefix=/tools                   \
            --without-python                  \
            --disable-makeinstall-chown       \
            --without-systemdsystemunitdir    \
            --enable-libmount-force-mountinfo \
            PKG_CONFIG=""

make && make install

cd $LFS/sources
rm -r util-linux


mkdir xz && tar -xf xz-*.tar.* -C xz  --strip-components 1
cd ${LFS}/sources/xz

commonBuildRoutine

cd $LFS/sources
rm -r xz

#Stripping ch5.35
strip --strip-debug /tools/lib/*
/usr/bin/strip --strip-unneeded /tools/{,s}bin/*
rm -rf /tools/{,share}/{info,man,doc}







