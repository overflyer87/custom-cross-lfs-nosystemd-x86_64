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

#Variables
CLFS=/mnt/clfs
CLFSUSER=clfs
CLFSHOME=${CLFS}/home
CLFSSOURCES=${CLFS}/sources
CLFSTOOLS=${CLFS}/tools
CLFSCROSSTOOLS=${CLFS}/cross-tools
CLFSFILESYSTEM=ext4
CLFSROOTDEV=/dev/sda4
CLFSHOMEDEV=/dev/sda5
CLFS_HOST=$(echo ${MACHTYPE} | sed -e 's/-[^-]*/-cross/')
CLFS_TARGET="x86_64-unknown-linux-gnu"
CLFS_TARGET32="i686-pc-linux-gnu"
BUILD32="-m32"
BUILD64="-m64"
MAKEFLAGS="-j$(nproc)"
HOME=${HOME}
TERM=${TERM}
PS1='\u:\w\$ '
LC_ALL=POSIX
PATH=/cross-tools/bin:/bin:/usr/bin

export CLFS=/mnt/clfs
export CLFSHOME=/mnt/clfs/home
export FILESYSTEM=ext4
export CLFSROOTDEV=/dev/sda4
export CLFSHOMEDEV=/dev/sda5
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
export HOME=${HOME}
export TERM=${TERM}
export PS1='\u:\w\$ '
export LC_ALL=POSIX
export PATH=/cross-tools/bin:/bin:/usr/bin

#Start building tools
#Export new variables to do that
CC="${CLFS_TARGET}-gcc ${BUILD64}"
CXX="${CLFS_TARGET}-g++ ${BUILD64}"
AR="${CLFS_TARGET}-ar"
AS="${CLFS_TARGET}-as"
RANLIB="${CLFS_TARGET}-ranlib"
LD="${CLFS_TARGET}-ld"
STRIP="${CLFS_TARGET}-strip"

export CC="${CLFS_TARGET}-gcc ${BUILD64}"
export CXX="${CLFS_TARGET}-g++ ${BUILD64}"
export AR="${CLFS_TARGET}-ar"
export AS="${CLFS_TARGET}-as"
export RANLIB="${CLFS_TARGET}-ranlib"
export LD="${CLFS_TARGET}-ld"
export STRIP="${CLFS_TARGET}-strip"

echo export CC=\""${CC}\"" >> ~/.bashrc
echo export CXX=\""${CXX}\"" >> ~/.bashrc
echo export AR=\""${AR}\"" >> ~/.bashrc
echo export AS=\""${AS}\"" >> ~/.bashrc
echo export RANLIB=\""${RANLIB}\"" >> ~/.bashrc
echo export LD=\""${LD}\"" >> ~/.bashrc
echo export STRIP=\""${STRIP}\"" >> ~/.bashrc

echo " "
echo "Lets start building the Temporary System"
echo "Chapter 6.1 to 6.29"
echo " "

echo "First check your environment setup"
echo "Are all essential variables there"
echo "With the right values as described on"
echo "http://clfs.org/view/sysvinit/x86_64/temp-system/variables.html"
echo " "

env

echo " "

checkBuiltPackage 

cd ${CLFSSOURCES}

#GMP
mkdir gmp && tar xf gmp-*.tar.* -C gmp --strip-components 1
cd gmp

CC_FOR_BUILD=gcc \
./configure \
    --prefix=/tools \
    --build=${CLFS_HOST} \
    --host=${CLFS_TARGET} \
    --libdir=/tools/lib64 \
    --enable-cxx

make && make install
cd ${CLFSSOURCES} 
checkBuiltPackage 
rm -rf gmp

#MPFR
mkdir mpfr && tar xf mpfr-*.tar.* -C mpfr --strip-components 1
cd mpfr
patch -Np1 -i ../mpfr-3.1.5-fixes-1.patch

./configure \
    --prefix=/tools \
    --build=${CLFS_HOST} \
    --host=${CLFS_TARGET} \
    --libdir=/tools/lib64

make && make install
cd ${CLFSSOURCES} 
checkBuiltPackage 
rm -rf mpfr

#MPC
mkdir mpc && tar xf mpc-*.tar.* -C mpc --strip-components 1
cd mpc

./configure \
    --prefix=/tools \
    --build=${CLFS_HOST} \
    --host=${CLFS_TARGET} \
    --libdir=/tools/lib64

make && make install
cd ${CLFSSOURCES} 
checkBuiltPackage 
rm -rf mpc

#ISL
mkdir isl && tar xf isl-*.tar.* -C isl --strip-components 1
cd isl

./configure \
    --prefix=/tools \
    --build=${CLFS_HOST} \
    --host=${CLFS_TARGET} \
    --libdir=/tools/lib64

make && make install
cd ${CLFSSOURCES} 
checkBuiltPackage 
rm -rf isl

#Zlib
mkdir zlib && tar xf zlib-*tar.* -C zlib --strip-components 1
cd zlib

./configure \
    --prefix=/tools \
    --libdir=/tools/lib64

make && make install

cd ${CLFSSOURCES}
checkBuiltPackage 
rm -rf zlib

#Binutils
mkdir binutils && tar xf binutils-*.tar.* -C binutils --strip-components 1
cd binutils

mkdir -v ../binutils-build
cd ../binutils-build

../binutils/configure \
    --prefix=/tools \
    --libdir=/tools/lib64 \
    --with-lib-path=/tools/lib64:/tools/lib \
    --build=${CLFS_HOST} \
    --host=${CLFS_TARGET} \
    --target=${CLFS_TARGET} \
    --disable-nls \
    --enable-shared \
    --enable-64-bit-bfd \
    --enable-gold=yes \
    --enable-plugins \
    --with-system-zlib \
    --enable-threads

make && make install
cd ${CLFSSOURCES} 
checkBuiltPackage 
rm -rf binutils
rm -rf binutils-build

#GCC
mkdir gcc && tar xf gcc-*.tar.* -C gcc --strip-components 1
cd gcc

patch -Np1 -i ../gcc-7.1.0-specs-1.patch

echo -en '\n#undef STANDARD_STARTFILE_PREFIX_1\n#define STANDARD_STARTFILE_PREFIX_1 "/tools/lib/"\n' >> gcc/config/linux.h
echo -en '\n#undef STANDARD_STARTFILE_PREFIX_2\n#define STANDARD_STARTFILE_PREFIX_2 ""\n' >> gcc/config/linux.h

cp -v gcc/Makefile.in{,.orig}
sed 's@\./fixinc\.sh@-c true@' gcc/Makefile.in.orig > gcc/Makefile.in

mkdir -v ../gcc-build
cd ../gcc-build

../gcc/configure \
    --prefix=/tools \
    --libdir=/tools/lib64 \
    --build=${CLFS_HOST} \
    --host=${CLFS_TARGET} \
    --target=${CLFS_TARGET} \
    --with-local-prefix=/tools \
    --enable-languages=c,c++ \
    --with-system-zlib \
    --with-native-system-header-dir=/tools/include \
    --disable-libssp \
    --enable-install-libiberty

make AS_FOR_TARGET="${AS}" \
    LD_FOR_TARGET="${LD}"

make install

cd ${CLFSSOURCES} 
checkBuiltPackage 
rm -rf gcc
rm -rf gcc-build

#Ncurses
mkdir ncurses && tar xf ncurses-*.tar.* -C ncurses --strip-components 1
cd ncurses

./configure \
    --prefix=/tools \
    --with-shared \
    --build=${CLFS_HOST} \
    --host=${CLFS_TARGET} \
    --without-debug \
    --without-ada \
    --enable-overwrite \
    --with-build-cc=gcc \
    --libdir=/tools/lib64

make && make install

cd ${CLFSSOURCES} 
checkBuiltPackage 
rm -rf ncurses

#Bash
mkdir bash && tar xf bash-*.tar.* -C bash --strip-components 1
cd bash
patch -Np1 -i ../bash-4.4-branch_update-1.patch

cat > config.cache << "EOF"
ac_cv_func_mmap_fixed_mapped=yes
ac_cv_func_strcoll_works=yes
ac_cv_func_working_mktime=yes
bash_cv_func_sigsetjmp=present
bash_cv_getcwd_malloc=yes
bash_cv_job_control_missing=present
bash_cv_printf_a_format=yes
bash_cv_sys_named_pipes=present
bash_cv_ulimit_maxfds=yes
bash_cv_under_sys_siglist=yes
bash_cv_unusable_rtsigs=no
gt_cv_int_divbyzero_sigfpe=yes
EOF

./configure \
    --prefix=/tools \
    --build=${CLFS_HOST} \
    --host=${CLFS_TARGET} \
    --without-bash-malloc \
    --cache-file=config.cache

make && make install

cd ${CLFSSOURCES} 
checkBuiltPackage 
rm -rf bash

#Bzip2
mkdir bzip2 && tar xf bzip2-*.tar.* -C bzip2 --strip-components 1
cd bzip2

cp -v Makefile{,.orig}
sed -e 's@^\(all:.*\) test@\1@g' \
    -e 's@/lib\(/\| \|$\)@/lib64\1@g' Makefile.orig > Makefile
make CC="${CC}" AR="${AR}" RANLIB="${RANLIB}"
make PREFIX=/tools install

cd ${CLFSSOURCES} 
checkBuiltPackage 
rm -rf bzip2

#Check
mkdir check && tar xf check-*.tar.* -C check --strip-components 1
cd check

./configure \
    --prefix=/tools \
    --build=${CLFS_HOST} \
    --host=${CLFS_TARGET} \
    --libdir=/tools/lib64

make && make install

cd ${CLFSSOURCES} 
checkBuiltPackage 
rm -rf check

#Coreutils
mkdir coreutils && tar xf coreutils-*.tar.* -C coreutils --strip-components 1
cd coreutils

./configure \
    --prefix=/tools \
    --build=${CLFS_HOST} \
    --host=${CLFS_TARGET} \
    --enable-install-program=hostname \
    --cache-file=config.cache

sed -i -e 's/^man1_MANS/#man1_MANS/' Makefile
make && make install

cd ${CLFSSOURCES} 
checkBuiltPackage 
rm -rf coreutils

#Diffutils
mkdir diffutils && tar xf diffutils-*.tar.* -C diffutils --strip-components 1
cd diffutils

./configure \
    --prefix=/tools \
    --build=${CLFS_HOST} \
    --host=${CLFS_TARGET}

make && make install

cd ${CLFSSOURCES} 
checkBuiltPackage 
rm -rf diffutils

#File
mkdir file && tar xf file-*.tar.* -C file --strip-components 1
cd file

./configure \
    --prefix=/tools \
    --libdir=/tools/lib64 \
    --build=${CLFS_HOST} \
    --host=${CLFS_TARGET}

make && make install

cd ${CLFSSOURCES} 
checkBuiltPackage 
rm -rf file

#Findutils
mkdir findutils && tar xf findutils-*.tar.* -C findutils --strip-components 1
cd findutils

echo "gl_cv_func_wcwidth_works=yes" > config.cache
echo "ac_cv_func_fnmatch_gnu=yes" >> config.cache

./configure \
    --prefix=/tools \
    --build=${CLFS_HOST} \
    --host=${CLFS_TARGET} \
    --cache-file=config.cache

make && make install

cd ${CLFSSOURCES} 
checkBuiltPackage 
rm -rf findutils

#Gawk
mkdir gawk && tar xf gawk-*.tar.* -C gawk --strip-components 1
cd gawk

./configure \
    --prefix=/tools \
    --build=${CLFS_HOST} \
    --host=${CLFS_TARGET}

make && make install

cd ${CLFSSOURCES} 
checkBuiltPackage 
rm -rf gawk

#Gettext
mkdir gettext && tar xf gettext-*.tar.* -C gettext --strip-components 1
cd gettext

cd gettext-tools

EMACS="no" \
./configure \
    --prefix=/tools \
    --build=${CLFS_HOST} \
    --host=${CLFS_TARGET} \
    --disable-shared

make -C gnulib-lib
make -C intl pluralx.c
make -C src msgfmt msgmerge xgettext

cp -v src/{msgfmt,msgmerge,xgettext} /tools/bin

cd ${CLFSSOURCES} 
checkBuiltPackage 
rm -rf gettext

#Grep
mkdir grep && tar xf grep-*.tar.* -C grep --strip-components 1
cd grep

./configure \
    --prefix=/tools \
    --build=${CLFS_HOST} \
    --host=${CLFS_TARGET} \
    --without-included-regex

make && make install

cd ${CLFSSOURCES} 
checkBuiltPackage 
rm -rf grep

#Gzip
mkdir gzip && tar xf gzip-*.tar.* -C gzip --strip-components 1
cd gzip

./configure \
    --prefix=/tools \
    --build=${CLFS_HOST} \
    --host=${CLFS_TARGET}

make && make install

cd ${CLFSSOURCES} 
checkBuiltPackage 
rm -rf gzip

#Make
mkdir make && tar xf make-*.tar.* -C make --strip-components 1
cd make

./configure \
    --prefix=/tools \
    --build=${CLFS_HOST} \
    --host=${CLFS_TARGET}

make && make install

cd ${CLFSSOURCES} 
checkBuiltPackage 
rm -rf make

#Patch
mkdir patch && tar xf patch-*.tar.* -C patch --strip-components 1
cd patch

./configure \
    --prefix=/tools \
    --build=${CLFS_HOST} \
    --host=${CLFS_TARGET}

make && make install

cd ${CLFSSOURCES} 
checkBuiltPackage 
rm -rf patch

#Sed
mkdir sed && tar xf sed-*.tar.* -C sed --strip-components 1
cd sed

./configure \
    --prefix=/tools \
    --build=${CLFS_HOST} \
    --host=${CLFS_TARGET}

make && make install

cd ${CLFSSOURCES} 
checkBuiltPackage 
rm -rf sed

#Tar
mkdir tar && tar xf tar-*.tar.* -C tar --strip-components 1
cd tar

cat > config.cache << EOF
gl_cv_func_wcwidth_works=yes
gl_cv_func_btowc_eof=yes
ac_cv_func_malloc_0_nonnull=yes
gl_cv_func_mbrtowc_incomplete_state=yes
gl_cv_func_mbrtowc_nul_retval=yes
gl_cv_func_mbrtowc_null_arg1=yes
gl_cv_func_mbrtowc_null_arg2=yes
gl_cv_func_mbrtowc_retval=yes
gl_cv_func_wcrtomb_retval=yes
EOF

./configure \
    --prefix=/tools \
    --build=${CLFS_HOST} \
    --host=${CLFS_TARGET} \
    --cache-file=config.cache

make && make install

cd ${CLFSSOURCES} 
checkBuiltPackage 
rm -rf tar

#Texinfo
mkdir texinfo && tar xf texinfo-*.tar.* -C texinfo --strip-components 1
cd texinfo

PERL=/usr/bin/perl \
./configure \
    --prefix=/tools \
    --build=${CLFS_HOST} \
    --host=${CLFS_TARGET}

make && make install

cd ${CLFSSOURCES} 
checkBuiltPackage 
rm -rf texinfo

#Util-linux
mkdir util-linux && tar xf util-linux-*.tar.* -C util-linux --strip-components 1
cd util-linux

NCURSESW6_CONFIG=" " \
NCURSES6_CONFIG=" " \
NCURSESW5_CONFIG=" " \
NCURSES5_CONFIG=" " \
    ./configure \
    --prefix=/tools \
    --build=${CLFS_HOST} \
    --host=${CLFS_TARGET} \
    --libdir='${prefix}'/lib64 \
    --disable-makeinstall-chown \
    --disable-makeinstall-setuid \
    --disable-nologin \
    --without-python

make && make install

cd ${CLFSSOURCES} 
checkBuiltPackage 
rm -rf util-linux

#Vim
mkdir vim && tar xf vim-*.tar.* -C vim --strip-components 1
cd vim

patch -Np1 -i ../vim-8.0-branch_update-1.patch

cat > src/auto/config.cache << "EOF"
vim_cv_getcwd_broken=no
vim_cv_memmove_handles_overlap=yes
vim_cv_stat_ignores_slash=no
vim_cv_terminfo=yes
vim_cv_toupper_broken=no
vim_cv_tty_group=world
vim_cv_tgent=zero
EOF

echo '#define SYS_VIMRC_FILE "/tools/etc/vimrc"' >> src/feature.h

./configure \
    --build=${CLFS_HOST} \
    --host=${CLFS_TARGET} \
    --prefix=/tools \
    --enable-gui=no \
    --disable-gtktest \
    --disable-xim \
    --disable-gpm \
    --without-x \
    --disable-netbeans \
    --with-tlib=ncurses

make -j1 && make -j1 install

ln -sv vim /tools/bin/vi

cat > /tools/etc/vimrc << "EOF"
" Begin /tools/etc/vimrc

set nocompatible
set backspace=2
set ruler
syntax on

" End /tools/etc/vimrc
EOF

cd ${CLFSSOURCES} 
checkBuiltPackage 
rm -rf vim

#Nano
mkdir nano && tar xf nano-*.tar.* -C nano --strip-components 1
cd nano

./configure \
    --prefix=/tools \
    --build=${CLFS_HOST} \
    --host=${CLFS_TARGET} \
    --libdir=/tools/lib64 

make && make install

cat > ~/.nanorc << "EOF"
set autoindent
set const
set fill 72
set historylog
set multibuffer
set nohelp
set regexp
set smooth
set suspend
EOF

cd ${CLFSSOURCES} 
checkBuiltPackage 
rm -rf nano

#XZ Utils
mkdir xz && tar xf xz-*.tar.* -C xz --strip-components 1
cd xz

./configure \
    --prefix=/tools \
    --build=${CLFS_HOST} \
    --host=${CLFS_TARGET} \
    --libdir=/tools/lib64

make && make install

cd ${CLFSSOURCES} 
checkBuiltPackage 
rm -rf xz


#Echoing out some stuff to help you chose boot or chroot option

echo "Echoing out some stuff to help you chose boot or chroot option"
echo " "
echo " "
echo "Executing /tools/lib/libc.so.6 ..."
echo " "
echo " "
/tools/lib/libc.so.6
echo " "
echo " "
echo "Executing /tools/lib64/libc.so.6 ..."
echo " "
/tools/lib64/libc.so.6
echo " "
echo " "
echo "Executing /tools/bin/gcc -v ..."
/tools/bin/gcc -v
echo " "

echo " "
echo "If all 3 commands output reasonable messages without errors"
echo "You can chroot"
echo "However, you ONLY chroot if your TARGET architecture is the same as your SOURCE!"
echo " "
echo " "

echo " "
echo "The temporary system is done"
echo "If there were no errors continue"
echo " "
echo "Exit as CLFS back into your host's ROOT shell"
echo "Execute Script #4"
echo "Execute Script #5 inside CHROOT with BASH NOT SH!!!"
echo " "

exit
exit
