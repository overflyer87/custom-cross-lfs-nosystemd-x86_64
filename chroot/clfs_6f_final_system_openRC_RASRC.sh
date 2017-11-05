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

#Rsyslog
mkdir rsyslog && tar xf rsyslog-*.tar.* -C rsyslog --strip-components 1
cd rsyslog

CC="gcc ${BUILD64}" \
    PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
    USE_ARCH=64 \
    ./configure --prefix=/usr \
    --libdir=/usr/lib64 && 

make
make check
checkBuiltPackage
make install

install -dv /etc/rsyslog.d

cat > /etc/rsyslog.conf << "EOF"
# Begin /etc/rsyslog.conf

# CLFS configuration of rsyslog. For more info use man rsyslog.conf

#######################################################################
# Rsyslog Modules

# Support for Local System Logging
$ModLoad imuxsock.so

# Support for Kernel Logging
$ModLoad imklog.so

#######################################################################
# Global Options

# Use traditional timestamp format.
$ActionFileDefaultTemplate RSYSLOG_TraditionalFileFormat

# Set the default permissions for all log files.
$FileOwner root
$FileGroup root
$FileCreateMode 0640
$DirCreateMode 0755

# Provides UDP reception
$ModLoad imudp
$UDPServerRun 514

# Disable Repeating of Entries
$RepeatedMsgReduction on

#######################################################################
# Include Rsyslog Config Snippets

$IncludeConfig /etc/rsyslog.d/*.conf

#######################################################################
# Standard Log Files

auth,authpriv.*                 /var/log/auth.log
*.*;auth,authpriv.none          -/var/log/syslog
daemon.*                        -/var/log/daemon.log
kern.*                          -/var/log/kern.log
lpr.*                           -/var/log/lpr.log
mail.*                          -/var/log/mail.log
user.*                          -/var/log/user.log

# Catch All Logs
*.=debug;\
        auth,authpriv.none;\
        news.none;mail.none     -/var/log/debug
*.=info;*.=notice;*.=warn;\
        auth,authpriv.none;\
        cron,daemon.none;\
        mail,news.none          -/var/log/messages

# Emergencies are shown to everyone
*.emerg                         *

# End /etc/rsyslog.conf
EOF

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf rsyslog

#Sysvinit
mkdir sysvinit && tar xf sysvinit*.tar.* -C sysvinit --strip-components 1
cd sysvinit

sed -i -e 's/\ sulogin[^ ]*//' -e 's/pidof\.8//' -e '/ln .*pidof/d' \
    -e '/utmpdump/d' -e '/mountpoint/d' -e '/mesg/d' src/Makefile

make -C src clobber
make -C src CC="gcc ${BUILD64}"

make -C src install

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

install -m 755 ${CLFSSOURCES}/openrc-sysvinit/src/init /usr/bin/init-openrc

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf openrc-sysvinit

#Openrc
mkdir openrc && tar xf openrc-*.tar.* -C openrc --strip-components 1
cd openrc

sed -e "s|/sbin|/usr/bin|g" -i support/sysvinit/inittab
sed -i 's:0444:0644:' mk/sys.mk

patch -Np1 -i ${CLFSSOURCES}/openrc-quiet.patch

install -dm644 /etc/logrotate.d

#explicitely declare CC=gcc -m64 in the following two files
sed -i 's/${CC}/gcc -m64/' mk/lib.mk
sed -i 's/${CC}/gcc -m64/' mk/cc.mk

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
CC="gcc ${BUILD64}" make install

install -m644 support/sysvinit/inittab /etc/inittab

cat > /etc/logrotate.d/openrc << "EOF"
/var/log/rc.log {
  compress
  rotate 4
  weekly 
  missingok 
  notifempty 
}
EOF

mv -v /usr/lib/pkgconfig/openrc.pc /usr/lib64/pkgconfig/

sed -e 's/#unicode="NO"/unicode="YES"/' \
     -e 's/#rc_logger="NO"/rc_logger="YES"/' \
     -i "/etc/rc.conf"
 
sed -e 's|#baud=""|baud="38400"|' \
        -e 's|#term_type="linux"|term_type="linux"|' \
        -e 's|#agetty_options=""|agetty_options=""|' \
        -i /etc/conf.d/agetty

for num in 1 2 3 4 5 6;do
        cp -v /etc/conf.d/agetty /etc/conf.d/agetty.tty$num
        ln -sfv /etc/init.d/agetty /etc/init.d/agetty.tty$num
        ln -sfv /etc/init.d/agetty.tty$num /etc/runlevels/default/agetty.tty$num
done

groupadd uucp
usermod -a -G uucp root

ldconfig

install -m755 -d /usr/share/licenses/openrc
install -m644 LICENSE AUTHORS /usr/share/licenses/openrc/

mkdir cclfs-openrc-scripts && tar xf ${CLFSSOURCES}/cclfs-openrc-scripts.tar.* -C cclfs-openrc-scripts --strip-components 1
cd cclfs-openrc-scripts

cp -v --no-clobber * /etc/init.d/
cd ..

chmod 777 /etc/init.d/*

#Let see if at the next test installation the following sed commands will still be neccessary

#Create basic symlinks from services to bootlevels
ln -sfv /etc/init.d/kmod-static-nodes /etc/runlevels/sysinit/kmod-static-nodes
ln -sfv /etc/init.d/udev /etc/runlevels/sysinit/udev
ln -sfv /etc/init.d/udev-trigger /etc/runlevels/sysinit/udev-trigger

ln -sfv /etc/init.d/termencoding /etc/runlevels/boot/termencoding
ln -sfv /etc/init.d/sysctl /etc/runlevels/boot/sysctl

ln -sfv /etc/init.d/sshd /etc/runlevels/default/sshd
ln -sfv /etc/init.d/dhcpd /etc/runlevels/default/dhcpd
ln -sfv /etc/init.d/haveged /etc/runlevels/default/haveged

#todo: get rsyslog-openrc init script

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf openrc

#netifrc
mkdir netifrc && tar xf netifrc-*.tar.* -C netifrc --strip-components 1
cd netifrc

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} \
CC="gcc ${BUILD64}" \
USE_ARCH=64 \
CXX="g++ ${BUILD64}" \
SYSCONFDIR=/etc \
PREFIX=/usr \
SBINDIR=/usr/bin \
LIBEXECDIR=/usr/lib64/netifrc \
MKSELINUX=no \
MKPAM=pam \
MKTERMCAP=ncurses \
MKNET=no \
MKSYSVINIT=yes \
PREFIX=/usr \  
LIBDIR=/usr/lib64 \
make

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} \
CC="gcc ${BUILD64}" \
USE_ARCH=64 \
CXX="g++ ${BUILD64}" \
SYSCONFDIR=/etc \
PREFIX=/usr \
SBINDIR=/usr/bin \
LIBEXECDIR=/usr/lib64/netifrc \
MKSELINUX=no \
MKPAM=pam \
MKTERMCAP=ncurses \
MKNET=no \
MKSYSVINIT=yes \
PREFIX=/usr \  
LIBDIR=/usr/lib64 \
make install

ln -sfv /etc/init.d/net.{lo,eth0}

cp -rv /usr/libexec/netifrc /usr/lib64/
rm -rf /usr/libexec/netifrc
  
cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf netifrc

echo " "
echo "Fixing some stuff with openrc paths"

sed -i 's/\/usr\/bin\/openrc-run/\/usr\/sbin\/openrc-run/' /etc/init.d/*
sed -i 's/\/usr\/bin\/openrc-run/\/usr\/sbin\/openrc/' /usr/lib64/openrc/sh/*
sed -i 's/\/usr\/bin\//\/usr\/sbin\//' /etc/inittab
sed -i 's/\/usr\/sbin\/agetty/\/sbin\/agetty/' /etc/inittab
sed -i 's/\/usr\/sbin\/agetty/\/sbin\/halt/' /etc/inittab
sed -i 's/\/usr\/sbin\/agetty/\/sbin\/shutdown/' /etc/inittab
sed -i 's/\/usr\/sbin\/agetty/\/sbin\/reboot/' /etc/inittab
sed -i 's/\/usr\/sbin\/agetty/\/sbin\/sulogin/' /etc/inittab
sed -i 's/\/usr\/lib\//\/usr\/lib64\//' /etc/init.d/*
sed -i 's/\/usr\/lib6464\//\/usr\/lib64\//' /etc/init.d/*
sed -i 's/\/usr\/lib\//\/usr\/lib64\//' /usr/lib64/openrc/sh/*
sed -i 's/\/usr\/lib6464\//\/usr\/lib64\//' /usr/lib64/openrc/sh/*
sed -i 's/\/usr\/bin\/sshd/\/usr\/sbin\/sshd/' /etc/init.d/sshd
sed -i 's/\/usr\/bin\/udev/\/sbin\/udev/' /etc/init.d/udev*

ln -sfv /usr/lib64/openrc/sh/functions.sh /etc/init.d/functions.sh

echo " "
