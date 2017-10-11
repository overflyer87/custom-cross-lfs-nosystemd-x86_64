#!/bin/bash

CLFS=/mnt/clfs
HOME=${HOME}
TERM=${TERM}
PS1='\u:\w\$ '
LC_ALL=POSIX
PATH=/cross-tools/bin:/bin:/usr/bin
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
export HOME=${HOME}
export TERM=${TERM}
export PS1='\u:\w\$ '
export LC_ALL=POSIX
export PATH=/cross-tools/bin:/bin:/usr/bin

unset CFLAGS CXXFLAGS PKG_CONFIG_PATH

cat > ~/.bash_profile << "EOF"
exec env -i HOME=${HOME} TERM=${TERM} PS1='\u:\w\$ ' /bin/bash
EOF

cat > ~/.bashrc << "EOF"
set +h
umask 022
CLFS=/mnt/clfs
LC_ALL=POSIX
PATH=/cross-tools/bin:/bin:/usr/bin
export CLFS LC_ALL PATH
unset CFLAGS CXXFLAGS PKG_CONFIG_PATH
EOF

cat >> ~/.bashrc << EOF
export CLFS_HOST="${CLFS_HOST}"
export CLFS_TARGET="${CLFS_TARGET}"
export CLFS_TARGET32="${CLFS_TARGET32}"
export BUILD32="${BUILD32}"
export BUILD64="${BUILD64}"
export CLFS=/mnt/clfs
export CLFSHOME=/mnt/clfs/home
export FILESYSTEM=ext4
export CLFSROOTDEV=/dev/sda4
export CLFSHOMEDEV=/dev/sda5
export CLFSSOURCES=/mnt/clfs/sources
export CLFSTOOLS=/mnt/clfs/tools
export CLFSCROSSTOOLS=/mnt/clfs/cross-tools
export CLFSUSER=clfs
export MAKEFLAGS=j8
EOF

echo " "
echo "Variables have been exported"
echo "~/.bash_profile has been sourced"
echo "Continue with Script #2"
echo "Maybe execute env first and check if everything looks good"
echo " "

source ~/.bash_profile
