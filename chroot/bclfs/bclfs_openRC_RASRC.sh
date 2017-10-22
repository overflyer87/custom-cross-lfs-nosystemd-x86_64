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

#syslog-ng
#wget https://github.com/balabit/syslog-ng/archive/syslog-ng-3.12.1.tar.gz -O \
#  syslog-ng-3.12.1.tar.gz
#
#mkdir syslog-ng && tar xf syslog-ng*.tar.* -C syslog-ng --strip-components 1
#cd syslog-ng
#PKG_CONFIG_PATH=/usr/lib64/pkgconfig/ CC="gcc -m64" ./configure --prefix=/usr --libdir=/usr/lib64 \
#  --with-systemdsystemunitdir=no --disable-systemd --disable-python \
#  --enable-dynamic-linking --enable-extra-warnings --disable-env-wrapper  \
#  --disable-java --disable-gprof --enable-native --disable-librabbitmq \
#  --disable-jsonc --disable-docbook-docs --disable-valgrind --disable-riemann \
#  --disable-geoip --disable-geoip2 --disable-http --disable-java-modules \
#  --disable-redis --disable-amqp --disable-mongodb --disable-ssl \
#  --disable-tcp-wrapper --disable-spoof-source --enable-shared --enable-legacy-mongodb-options=no \
#  --with-mongoc=no --disable-stomp --enable-json=no --with-jsonc=no --with-pidfile-dir=/run \
#  --libexecdir=/usr/lib64 --sysconfdir=/etc/syslog-ng --sbindir=/usr/bin \
#  --localstatedir=/var/lib64/syslog-ng  --datadir=/usr/share
# Gave up! would not install to /usr/lib64 no matter what. Another reason to reconfigure the standard CLFS instructions for the toolchain
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
cp -rv /libexec/rc /usr/lib64/
mv /usr/lib64/rc /usr/lib64/openrc
rm -rf /libexec/rc

mkdir cclfs-openrc-services && tar xf cclfs-openrc-services.tar.* -C cclfs-openrc-services --strip-components 1
cd cclfs-openrc-services

cp -v --no-clobber * /etc/init.d/
cd ..

chmod 777 /etc/init.d/*

#Let see if at the next test installation the following sed commands will still be neccessary

sed -i 's/\/usr\/bin\//\/sbin\//' /etc/init.d/*
sed -i 's/\/usr\/bin\//\/sbin\//' /usr/lib64/openrc
sed -i 's/\/usr\/bin\//\/sbin\//' /etc/inittab
sed -i 's/\/usr\/lib\//\/usr\/lib64\//' /etc/init.d/*
sed -i 's/\/usr\/lib6464\//\/usr\/lib64\//' /etc/init.d/*
sed -i 's/\/usr\/lib\//\/usr\/lib64\//' /usr/lib64/rc/sh/*
sed -i 's/\/usr\/lib6464\//\/usr\/lib64\//' /usr/lib64/rc/sh/*

ln -sfv /usr/lib64/openrc/sh/functions.sh /etc/init.d/functions.sh

#Create basic symlinks from services to bootlevels
ln -sfv /etc/init.d/kmod-static-nodes /etc/runlevels/sysinit/kmod-static-nodes
ln -sfv /etc/init.d/udev /etc/runlevels/sysinit/udev
ln -sfv /etc/init.d/udev-trigger /etc/runlevels/sysinit/udev-trigger

ln -sfv /etc/init.d/termencoding /etc/runlevels/boot/termnencoding
ln -sfv /etc/init.d/sysctl /etc/runlevels/boot/sysctl

ln -sfv /etc/init.d/sshd /etc/runlevels/default/sshd
ln -sfv /etc/init.d/dhcpd /etc/runlevels/default/dhcpd
ln -sfv /etc/init.d/haveged /etc/runlevels/default/haveged

#todo: get rsyslog-openrc init script

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf openrc

#netifrc
wget https://github.com/gentoo/netifrc/archive/0.5.1.tar.gz -O \
  netifrc-0.5.1.tar.gz
  
mkdir netifrc && tar xf netifrc-*.tar.* -C netifrc --strip-components 1
cd netifrc

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} \
  CC="gcc ${BUILD64}" USE_ARCH=64 CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64
PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} \
  CC="gcc ${BUILD64}" USE_ARCH=64 CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64 install

ln -sfv /etc/init.d/net.{lo,eth0}
  
cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf netifrc
