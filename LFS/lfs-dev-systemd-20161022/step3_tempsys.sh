#!/bin/bash

cho
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

