#!/bin/bash

function checkBuiltPackage() {

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

#Building the final CLFS System
CLFS=/
CLFSHOME=/home
CLFSSOURCES=/sources
CLFSTOOLS=/tools
CLFSCROSSTOOLS=/cross-tools
CLFSFILESYSTEM=ext4
CLFSROOTDEV=/dev/sda4
CLFSHOMEDEV=/dev/sda5
MAKEFLAGS=j8
BUILD32="-m32"
BUILD64="-m64"
CLFS_TARGET32="i686-pc-linux-gnu"

export CLFS=/
export CLFSUSER=clfs
export CLFSHOME=/home
export CLFSSOURCES=/sources
export CLFSTOOLS=/tools
export CLFSCROSSTOOLS=/cross-tools
export CLFSFILESYSTEM=ext4
export CLFSROOTDEV=/dev/sda4
export CLFSHOMEDEV=/dev/sda5
export MAKEFLAGS=j8
export BUILD32="-m32"
export BUILD64="-m64"
export CLFS_TARGET32="i686-pc-linux-gnu"

#=================
#YOUR SYSTEM STANDS AND BOOTS UP?
#NOW THEN, let's install some useful packages
#to make further progress easier
#=================

cd ${CLFSSOURCES}

#Autoconf
mkdir autoconf && tar xf autoconf-*.tar.* -C autoconf --strip-components 1
cd autoconf

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
CC="gcc ${BUILD64}" \
./configure \
    --prefix=/usr

make
#make check VERBOSE=yes
#checkBuiltPackage
make install

cd ${CLFSSOURCES} 
#checkBuiltPackage
rm -rf autoconf

#Automake
mkdir automake && tar xf automake-*.tar.* -C automake --strip-components 1
cd automake

patch -Np1 -i ../automake-1.15-perl_5_26-1.patch

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
CC="gcc ${BUILD64}" \
./configure \
    --prefix=/usr \
    --docdir=/usr/share/doc/automake-1.15

make
#make check
#checkBuiltPackage
make install

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf automake


#Linux-PAM 32-bit
mkdir linuxpam && tar xf Linux-PAM-1.3.0.tar.* -C linuxpam --strip-components 1
cd linuxpam

autoreconf

PKG_CONFIG_PATH="${PKG_CONFIG_PATH32}" \
CC="gcc ${BUILD32}" ./configure --libdir=/usr/lib \
           --sbindir=/lib/security \
           --enable-securedir=/lib/security \
           --docdir=/usr/share/doc/Linux-PAM-1.3.0\
           --enable-shared \
           --enable-read-both-confs \
           --sysconfdir=/etc \
           --disable-regenerate-docu

make && make install
chmod -v 4755 /sbin/unix_chkpwd 
chmod -v 4755 /lib/security/unix_chkpwd

for file in pam pam_misc pamc
do
  mv -v /usr/lib/lib${file}.so.* /lib &&
  ln -sfv ../../lib/$(readlink /usr/lib/lib${file}.so) /usr/lib/lib${file}.so
done

cd ${CLFSSOURCES} 
#checkBuiltPackage
rm -rf linuxpam

#Linux-PAM 64-bit
mkdir linuxpam && tar xf Linux-PAM-1.3.0.tar.* -C linuxpam --strip-components 1
cd linuxpam

autoreconf

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}"
CC="gcc ${BUILD64}" ./configure --libdir=/usr/lib64 \
           --sbindir=/lib64/security \
           --enable-securedir=/lib64/security \
           --docdir=/usr/share/doc/Linux-PAM-1.3.0\
           --enable-shared \
           --enable-read-both-confs \
           --sysconfdir=/etc \
           --disable-regenerate-docu

make && install -v -m755 -d /etc/pam.d 

cat > /etc/pam.d/other << "EOF"
auth     required       pam_deny.so
account  required       pam_deny.so
password required       pam_deny.so
session  required       pam_deny.so
EOF

make check
#checkBuiltPackage

rm -fv /etc/pam.d/*

make install 
chmod -v 4755 /sbin/unix_chkpwd 
chmod -v 4755 /lib64/security/unix_chkpwd

for file in pam pam_misc pamc
do
  mv -v /usr/lib64/lib${file}.so.* /lib64 &&
  ln -sfv ../../lib64/$(readlink /usr/lib64/lib${file}.so) /usr/lib64/lib${file}.so
done

cat > /etc/security/console.handlers << "EOF"
# Begin /etc/security/console.handlers
console consoledevs tty[0-9][0-9]* vc/[0-9][0-9]* :[0-9]\.[0-9] :[0-9]
EOF

cat > /etc/securetty << "EOF"
# /etc/securetty: list of terminals on which root is allowed to login.
# See securetty(5) and login(1).
console
tty0
tty1
tty2
tty3
tty4
tty5
tty6
tty7
tty8
tty9
tty10
tty11
tty12
ttyp0
ttyp1
ttyp2
ttyp3
ttyp4
ttyp5
ttyp6
ttyp7
ttyp8
ttyp9
ttyp10
ttyp11
ttyp12
ttyS0
EOF

echo > /etc/environment

cat > /etc/shells << "EOF"
# Begin /etc/shells

/bin/sh
/bin/bash

# End /etc/shells
EOF

install -vdm755 /etc/pam.d

cat > /etc/pam.d/system-account << "EOF" &&
# Begin /etc/pam.d/system-account

account   required    pam_unix.so

# End /etc/pam.d/system-account
EOF

cat > /etc/pam.d/other << "EOF"

# Begin /etc/pam.d/other

auth            required        pam_unix.so     nullok
account         required        pam_unix.so
session         required        pam_unix.so
password        required        pam_unix.so     nullok

# End /etc/pam.d/other
EOF

cat > /etc/pam.d/system-auth << "EOF"
#%PAM-1.0
#
# The PAM configuration file for system authentication
#

auth       required     pam_env.so
auth       sufficient   pam_unix.so try_first_pass nullok
auth       required     pam_deny.so

account    required     pam_unix.so

password   required     pam_cracklib.so difok=2 minlen=8 dcredit=2 ocredit=2 retry=3
password   sufficient   pam_unix.so try_first_pass use_authtok nullok md5 shadow
password   required     pam_deny.so

session    required     pam_limits.so
session    required     pam_unix.so
EOF

cat > /etc/pam.d/system-session << "EOF"
# Begin /etc/pam.d/system-session

session   required    pam_unix.so

# End /etc/pam.d/system-session
EOF

cat > /etc/pam.d/system-password << "EOF"
# Begin /etc/pam.d/system-password

# check new passwords for strength (man pam_cracklib)
password  required    pam_cracklib.so   type=Linux retry=3 difok=5 \
                                        difignore=23 minlen=9 dcredit=1 \
                                        ucredit=1 lcredit=1 ocredit=1 \
                                        dictpath=/lib/cracklib/pw_dict
# use sha512 hash for encryption, use shadow, and use the
# authentication token (chosen password) set by pam_cracklib
# above (or any previous modules)
password  required    pam_unix.so       sha512 shadow use_authtok

# End /etc/pam.d/system-password
EOF

cat > /etc/pam.d/other << "EOF"
# Begin /etc/pam.d/other

auth        required        pam_warn.so
auth        required        pam_deny.so
account     required        pam_warn.so
account     required        pam_deny.so
password    required        pam_warn.so
password    required        pam_deny.so
session     required        pam_warn.so
session     required        pam_deny.so

# End /etc/pam.d/other
EOF

for file in halt poweroff reboot; do
       cat > /etc/pam.d/$file << "EOF"
#%PAM-1.0
#
# The common PAM configuration file for shutdown operations
#
auth       sufficient   pam_rootok.so
auth       required     pam_console.so

account    required     pam_permit.so
EOF
done

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf linuxpam

#Shadow
mkdir shadow && tar xf shadow-*.tar.* -C shadow --strip-components 1
cd shadow

sed -i 's@\(DICTPATH.\).*@\1/lib/cracklib/pw_dict@' etc/login.defs

sed -i src/Makefile.in \
  -e 's/groups$(EXEEXT) //'
find man -name Makefile.in -exec sed -i \
  -e 's/man1\/groups\.1 //' \
  -e 's/man3\/getspnam\.3 //' \
  -e 's/man5\/passwd\.5 //' '{}' \;

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} \
CC="gcc ${BUILD64}" ./configure \
    --sysconfdir=/etc \
    --with-group-name-max-length=32

make && make install

sed -i /etc/login.defs \
    -e 's@#\(ENCRYPT_METHOD \).*@\1SHA512@' \
    -e 's@/var/spool/mail@/var/mail@'

mv -v /usr/bin/passwd /bin

touch /var/log/{fail,last}log
chgrp -v utmp /var/log/{fail,last}log
chmod -v 664 /var/log/{fail,last}log

pwconv
grpconv

passwd root

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf shadow

#Sudo
mkdir sudo && tar xf sudo-*.tar.* -C sudo --strip-components 1
cd sudo 

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
CC="gcc ${BUILD64}" ./configure --prefix=/usr  \
            --libexecdir=/usr/lib64    \
            --with-libdir=/usr/lib64   \
            --with-secure-path         \
            --with-all-insults         \
            --with-env-editor          \
            --docdir=/usr/share/doc/sudo-1.8.20p2 \
            --enable-noargs-shell      \
            --enable-shell-sets-home   \
            --with-passprompt="[sudo] password for %p: "

make
env LC_ALL=C make check 2>&1 | tee ../make-check.log
grep failed ../make-check.log

#checkBuiltPackage

make install
ln -sfv libsudo_util.so.0.0.0 /usr/lib64/sudo/libsudo_util.so.0

cat > /etc/pam.d/sudo << "EOF"
# Begin /etc/pam.d/sudo

# include the default auth settings
auth      include     system-auth

# include the default account settings
account   include     system-account

# Set default environment variables for the service user
session   required    pam_env.so

# include system session defaults
session   include     system-session

# End /etc/pam.d/sudo
EOF
chmod 644 /etc/pam.d/sudo

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf sudo 
