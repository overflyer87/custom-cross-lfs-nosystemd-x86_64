#!/bin/bash

CLFS=/
CLFSSOURCES=/sources
MAKEFLAGS="-j$(nproc)"
BUILD32="-m32"
BUILD64="-m64"
CLFS_TARGET32="i686-pc-linux-gnu"
PKG_CONFIG_PATH=/usr/lib64/pkgconfig
PKG_CONFIG_PATH64=/usr/lib64/pkgconfig
ACLOCAL="aclocal -I $XORG_PREFIX/share/aclocal"

export CLFS=/
export CLFSSOURCES=/sources
export MAKEFLAGS="-j$(nproc)"
export BUILD32="-m32"
export BUILD64="-m64"
export CLFS_TARGET32="i686-pc-linux-gnu"
export PKG_CONFIG_PATH=/usr/lib64/pkgconfig
export PKG_CONFIG_PATH64=/usr/lib64/pkgconfig
export ACLOCAL="aclocal -I $XORG_PREFIX/share/aclocal"

cd ${CLFSSOURCES}
cd ${CLFSSOURCES/xc}

export XORG_PREFIX="/usr"
export XORG_CONFIG64="--prefix=$XORG_PREFIX --sysconfdir=/etc --localstatedir=/var \
  --libdir=$XORG_PREFIX/lib64"

XORG_PREFIX="/usr"
XORG_CONFIG64="--prefix=$XORG_PREFIX --sysconfdir=/etc --localstatedir=/var \
  --libdir=$XORG_PREFIX/lib64"

#Blacklist Modules that are not compatible
#With the proprietary NVIDIA driver
sudo mkdir -v /etc/modprobe.d

sudo bash -c 'cat > /etc/modprobe.d/blacklist-nouveau.conf << "EOF"
blacklist nouveau
EOF'

sudo bash -c 'cat > /etc/modprobe.d/blacklist-nouveaufb.conf << "EOF"
blacklist nouveaufb
EOF'

sudo bash -c 'cat > /etc/modprobe.d/blacklist-nvidiafb.conf << "EOF"
blacklist nvidiafb
EOF'

#NVIDIA PROPRIETARY DRIVER
wget http://us.download.nvidia.com/XFree86/Linux-x86_64/384.90/NVIDIA-Linux-x86_64-384.90.run -O \
  NVIDIA-Linux-x86_64-384.90.run

sudo chmod +x NVIDIA-Linux-x86_64-384.90.run
sudo bash -c 'PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" CC="gcc" CXX="g++" ./NVIDIA-Linux-x86_64-384.90.run'


