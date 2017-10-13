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

CLFS=/
CLFSSOURCES=/sources
MAKEFLAGS="-j$(nproc)"
BUILD32="-m32"
BUILD64="-m64"
CLFS_TARGET32="i686-pc-linux-gnu"
PKG_CONFIG_PATH32=/usr/lib/pkgconfig
PKG_CONFIG_PATH64=/usr/lib64/pkgconfig

export CLFS=/
export CLFSUSER=clfs
export CLFSSOURCES=/sources
export MAKEFLAGS="-j$(nproc)"
export BUILD32="-m32"
export BUILD64="-m64"
export CLFS_TARGET32="i686-pc-linux-gnu"
export PKG_CONFIG_PATH32=/usr/lib/pkgconfig
export PKG_CONFIG_PATH64=/usr/lib64/pkgconfig

cd ${CLFSSOURCES} 

#Sysvinit
mkdir sysvinit && tar xf sysvinit*.tar.* -C sysvinit --strip-components 1
cd sysvinit

sed -i -e 's/\ sulogin[^ ]*//' -e 's/pidof\.8//' -e '/ln .*pidof/d' \
    -e '/utmpdump/d' -e '/mountpoint/d' -e '/mesg/d' src/Makefile

make -C src clobber
make -C src CC="gcc ${BUILD64}"

sudo make -C src install

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf sysvinit

#Openrc-sysvinit
mkdir openrc-sysvinit && tar xf sysvinit*.tar.* -C openrc-sysvinit --strip-components 1
cd openrc-sysvinit/src

patch -Np1 -i ${CLFSSOURCES}/0001-simplify-writelog-openrc.patch
patch -Np1 -i ${CLFSSOURCES}/0002-remove-ansi-escape-codes-from-log-file-openrc.patch

#use /etc/openrc/inittab instead of /etc/inittab
#patch -Np1 -i ${CLFSSOURCES}/openrc-init.patch

cd ${CLFSSOURCES}/openrc-sysvinit

make -C src CC="gcc ${BUILD64}" init

sudo install -m 755 ${CLFSSOURCES}/openrc-sysvinit/src/init /usr/bin/init-openrc

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf openrc-sysvinit

#Openrc
mkdir openrc && tar xf openrc-*.tar.* -C openrc --strip-components 1
cd openrc

sed -e "s|/sbin|/usr/bin|g" -i support/sysvinit/inittab
sed -i 's:0444:0644:' mk/sys.mk

patch -Np1 -i ${CLFSSOURCES}/openrc-quiet.patch

sudo install -dm644 /etc/logrotate.d

#explicitely declare CC=gcc -m64 in the following two files
nano mk/lib.mk
nano mk/cc.mk

export BRANDING='CLFS-SVN-x86_64-multilib' 
export SYSCONFDIR=/etc 
export PREFIX=/usr 
export SBINDIR=/usr/bin 
export LIBEXECDIR=/usr/lib64/openrc 
export MKSELINUX=no 
export MKPAM=pam
export MKTERMCAP=ncurses 
export MKNET=no 
export MKSYSVINIT=yes 

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} \
BRANDING='CLFS-SVN-x86_64-multilib' \ 
SYSCONFDIR=/etc \
PREFIX=/usr \
SBINDIR=/usr/bin \
LIBEXECDIR=/usr/lib64/openrc \
MKSELINUX=no \
MKPAM=pam \
MKTERMCAP=ncurses \
MKNET=no \
MKSYSVINIT=yes \
CC="gcc ${BUILD64}" make 

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} \
BRANDING='CLFS-SVN-x86_64-multilib' \ 
SYSCONFDIR=/etc \
PREFIX=/usr \
SBINDIR=/usr/bin \
LIBEXECDIR=/usr/lib64/openrc \
MKSELINUX=no \
MKPAM=pam \
MKTERMCAP=ncurses \
MKNET=no \
MKSYSVINIT=yes \
CC="gcc ${BUILD64}" sudo make install

sudo install -m644 support/sysvinit/inittab /etc/inittab

sudo bash -c 'cat > /etc/logrotate.d/openrc << "EOF"
/var/log/rc.log {
  compress
  rotate 4
  weekly 
  missingok 
  notifempty 
}
EOF'

sudo mv -v /usr/lib/pkgconfig/openrc.pc /usr/lib64/pkgconfig/

sed -e 's/#unicode="NO"/unicode="YES"/' \
     -e 's/#rc_logger="NO"/rc_logger="YES"/' \
     -i "/etc/rc.conf"
 
sed -e 's|#baud=""|baud="38400"|' \
        -e 's|#term_type="linux"|term_type="linux"|' \
        -e 's|#agetty_options=""|agetty_options=""|' \
        -i /etc/conf.d/agetty

sudo bash -c 'for num in 1 2 3 4 5 6;do
        cp -v /etc/conf.d/agetty /etc/conf.d/agetty.tty$num
        ln -sfv /etc/init.d/agetty /etc/init.d/agetty.tty$num
        ln -sfv /etc/init.d/agetty.tty$num /etc/runlevels/default/agetty.tty$num
done'

sudo groupadd uucp
sudo usermod -a -G uucp root

sudo ldconfig

sudo install -m755 -d /usr/share/licenses/openrc
sudo install -m644 LICENSE AUTHORS /usr/share/licenses/openrc/
sudo cp -rv /libexec/rc /usr/lib64/
sudo mv /usr/lib64/rc /usr/lib64/openrc
sudo rm -rf /libexec/rc

mkdir my-clfs-openrc-services && tar xf my-clfs-openrc-services.tar.* -C my-clfs-openrc-services --strip-components 1
cd myclfs-openrc-services

sudo cp -v  etc/init.d/* /etc/init.d/
cd ..

sudo chmod 777 /etc/init.d/*

sed -i 's/\/usr\/bin\//\/sbin\//' /etc/init.d/*
sed -i 's/\/usr\/bin\//\/sbin\//' /usr/lib64/openrc
sed -i 's/\/usr\/bin\//\/sbin\//' /etc/inittab
sed -i 's/\/usr\/lib\//\/usr\/lib64\//' /etc/init.d/*
sed -i 's/\/usr\/lib6464\//\/usr\/lib64\//' /etc/init.d/*
sed -i 's/\/usr\/lib\//\/usr\/lib64\//' /usr/lib64/rc/sh/*
sed -i 's/\/usr\/lib6464\//\/usr\/lib64\//' /usr/lib64/rc/sh/*

ln -sfv /usr/lib64/openrc/sh/functions.sh /etc/init.d/functions.sh

ln -sfv /etc/init.d/kmod-static-nodes /etc/runlevels/sysinit/kmod-static-nodes
ln -sfv /etc/init.d/opentmpfiles-dev /etc/runlevels/sysinit/opentmpfiles-dev
ln -sfv /etc/init.d/udev /etc/runlevels/sysinit/udev
ln -sfv /etc/init.d/udev-trigger /etc/runlevels/sysinit/udev-trigger

ln -sfv /etc/init.d/net.lo /etc/runlevels/boot/net.lo
ln -sfv /etc/init.d/opentmpfiles-setup /etc/runlevels/boot/opentmpfiles-setup

ln -sfv /etc/init.d/sshd /etc/runlevels/default/sshd
ln -sfv /etc/init.d/acpid /etc/runlevels/default/acpid
ln -sfv /etc/init.d/dhcpd /etc/runlevels/default/dhcpd
ln -sfv /etc/init.d/cronie /etc/runlevels/default/cronie
ln -sfv /etc/init.d/syslog-ng /etc/runlevels/default/syslog-ng

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf openrc
