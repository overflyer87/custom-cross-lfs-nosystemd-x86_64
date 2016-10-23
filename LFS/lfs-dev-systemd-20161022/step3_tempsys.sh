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

./configure --prefix=/tools && make && make install

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


mkdir $package && tar -xf $package-*.tar.* -C $package  --strip-components 1
cd ${LFS}/sources/$package 

commonBuildRoutine

cd $LFS/sources
rm -r $package 
