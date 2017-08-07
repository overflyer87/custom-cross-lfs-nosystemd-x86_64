!/bin/bash

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
CLFSHOME=/home
CLFSSOURCES=/sources
CLFSTOOLS=/tools
CLFSCROSSTOOLS=/cross-tools
CLFSFILESYSTEM=ext4
CLFSROOTDEV=/dev/sda4
CLFSHOMEDEV=/dev/sda5
MAKEFLAGS="-j$(nproc)"
BUILD32="-m32"
BUILD64="-m64"
CLFS_TARGET32="i686-pc-linux-gnu"
PKG_CONFIG_PATH32=/usr/lib/pkgconfig
PKG_CONFIG_PATH64=/usr/lib64/pkgconfig

export CLFS=/
export CLFSUSER=clfs
export CLFSHOME=/home
export CLFSSOURCES=/sources
export CLFSTOOLS=/tools
export CLFSCROSSTOOLS=/cross-tools
export CLFSFILESYSTEM=ext4
export CLFSROOTDEV=/dev/sda4
export CLFSHOMEDEV=/dev/sda5
export MAKEFLAGS="-j$(nproc)"
export BUILD32="-m32"
export BUILD64="-m64"
export CLFS_TARGET32="i686-pc-linux-gnu"
export PKG_CONFIG_PATH32=/usr/lib/pkgconfig
export PKG_CONFIG_PATH64=/usr/lib64/pkgconfig

#EXPERIMENTAL Script for using openRC with CLFS

#Sysvinit
#mkdir sysvinit && tar xf sysvinit*.tar.* -C sysvinit --strip-components 1
#cd sysvinit
#
#sed -i -e 's/\ sulogin[^ ]*//' -e 's/pidof\.8//' -e '/ln .*pidof/d' \
#    -e '/utmpdump/d' -e '/mountpoint/d' -e '/mesg/d' src/Makefile
#
#make -C src clobber
#make -C src CC="gcc ${BUILD64}"
#
#make -C src install
#
#cd ${CLFSSOURCES} 
#checkBuiltPackage
#rm -rf sysvinit

#Openrc-sysvinit
mkdir openrc-sysvinit && tar xf sysvinit*.tar.* -C openrc-sysvinit --strip-components 1
cd openrc-sysvinit/src

patch -Np1 -i ${CLFSSOURCES}/0001-simplify-writelog-openrc.patch
patch -Np1 -i ${CLFSSOURCES}/0002-remove-ansi-escape-codes-from-log-file-openrc.patch

#use /etc/openrc/inittab instead of /etc/inittab
patch -Np1 -i ${CLFSSOURCES}/openrc-init.patch

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

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} \
BRANDING='CLFS-20170702-x86_64-multilib' \ 
MKPAM=pam \
MKSELINUX=no \
MKTERMCAP=ncurses \
PKG_PREFIX="" \
PREFIX="/usr" \
LIBDIR="/usr/lib64" \
LIBMODE=0644 \
SHLIBDIR=/usr/lib64 \
LIBEXECDIR=/usr/lib64/openrc \
BINDIR=/usr/bin \
SBINDIR=/usr/bin \
SYSCONFDIR=/etc/openrc \
CC="gcc ${BUILD64}" make &&
CC="gcc ${BUILD64}" make install

install -m644 support/sysvinit/inittab /etc/openrc/inittab
install -m644 /etc/logrotate.d/openrc
install -Dm0644 openrc.logrotate /etc/logrotate.d/openrc

cat > /etc/logrotate.d/openrc << "EOF"
/var/log/rc.log {
  compress
  rotate 4
  weekly 
  missingok 
  notifempty 
}
EOF

 sed -e 's/#unicode="NO"/unicode="YES"/' \
     -e 's/#rc_logger="NO"/rc_logger="YES"/' \
     -i "${pkgdir}/etc/rc.conf"

install -d /usr/lib/rc/cache

install -m755 -d /usr/share/licenses/openrc
install -m644 LICENSE AUTHORS /usr/share/licenses/openrc/
install -m644 -d /etc/conf.d
cp -r conf.d/* /etc/conf.d/
install -m644 -d /etc/init.d
cp -r init.d/* /etc/init.d/
install -m644 -d /etc/local.d
cp -r local.d/* /etc/local.d/
cp etc/* /etc/
rm /etc/Makefile

ldconfig

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf openrc

cat > /etc/openrc/inittab << "EOF"
# /etc/inittab:  This file describes how the INIT process should set up
#                the system in a certain run-level.

# Default runlevel.
id:3:initdefault:

# System initialization, mount local filesystems, etc.
si::sysinit:/usr/bin/openrc sysinit

# Further system initialization, brings up the boot runlevel.
rc::bootwait:/usr/bin/openrc boot

l0:0:wait:/usr/bin/openrc shutdown
l0s:0:wait:/usr/bin/halt -dhip
l1:S1:wait:/usr/bin/openrc single
l2:2:wait:/usr/bin/openrc nonetwork
l3:3:wait:/usr/bin/openrc default
l4:4:wait:/usr/bin/openrc default
l5:5:wait:/usr/bin/openrc default
l6:6:wait:/usr/bin/openrc reboot
l6r:6:wait:/usr/bin/reboot -d
#z6:6:respawn:/usr/bin/sulogin

# new-style single-user
su0:S:wait:/usr/bin/openrc single
su1:S:wait:/usr/bin/sulogin

# TERMINALS
c1:12345:respawn:/usr/bin/agetty 38400 tty1 linux
c2:2345:respawn:/usr/bin/agetty 38400 tty2 linux
c3:2345:respawn:/usr/bin/agetty 38400 tty3 linux
c4:2345:respawn:/usr/bin/agetty 38400 tty4 linux
c5:2345:respawn:/usr/bin/agetty 38400 tty5 linux
c6:2345:respawn:/usr/bin/agetty 38400 tty6 linux

# SERIAL CONSOLES
#s0:12345:respawn:/usr/bin/agetty 9600 ttyS0 vt100
#s1:12345:respawn:/usr/bin/agetty 9600 ttyS1 vt100

# What to do at the "Three Finger Salute".
ca:12345:ctrlaltdel:/usr/bin/shutdown -r now

EOF
