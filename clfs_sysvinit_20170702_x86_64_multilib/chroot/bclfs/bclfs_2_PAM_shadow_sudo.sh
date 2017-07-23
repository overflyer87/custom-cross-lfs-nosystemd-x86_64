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
export MAKEFLAGS=j8
export BUILD32="-m32"
export BUILD64="-m64"
export CLFS_TARGET32="i686-pc-linux-gnu"
export PKG_CONFIG_PATH32=/usr/lib/pkgconfig
export PKG_CONFIG_PATH64=/usr/lib64/pkgconfig

cd ${CLFSSOURCES}

#Cracklib 32-bit
#mkdir cracklib && tar xf cracklib-*.tar.* -C cracklib --strip-components 1
#cd cracklib
#
#sed -i '/skipping/d' util/packer.c
#
#PKG_CONFIG_PATH=${PKG_CONFIG_PATH32} \
#CC="gcc ${BUILD32}" USE_ARCH=32 ./configure \
#            --prefix=/usr    \
#            --disable-static \
#            --libdir=/usr/lib \
#            --with-default-dict=/lib/cracklib/pw_dict
#
#make PREFIX=/usr LIBDIR=/usr/lib
#make PREFIX=/usr LIBDIR=/usr/lib install   
#
#mv -v /usr/lib/libcrack.so.* /lib
#ln -sfv ../../lib/$(readlink /usr/lib/libcrack.so) /usr/lib/libcrack.so
#
#ldconfig
#
#install -v -m644 -D    ../cracklib-words-2.9.6.gz \
#                         /usr/share/dict/cracklib-words.gz     &&
#
#gunzip -v                /usr/share/dict/cracklib-words.gz     &&
#ln -v -sf cracklib-words /usr/share/dict/words                 &&
#echo $(hostname) >>      /usr/share/dict/cracklib-extra-words  &&
#install -v -m755 -d      /lib/cracklib                         &&
#
#create-cracklib-dict     /usr/share/dict/cracklib-words \
#                         /usr/share/dict/cracklib-extra-words
#
##make test
##checkBuiltPackage
#
#cd ${CLFSSOURCES} 
##checkBuiltPackage
#rm -rf cracklib

#Cracklib 64-bit
mkdir cracklib && tar xf cracklib-*.tar.* -C cracklib --strip-components 1
cd cracklib

sed -i '/skipping/d' util/packer.c &&

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
CC="gcc ${BUILD64}" USE_ARCH=64 ./configure \
            --prefix=/usr    \
            --disable-static \
            --libdir=/usr/lib64  \
            --with-default-dict=/lib64/cracklib/pw_dict

sed -i 's@prefix}/lib@&64@g' dicts/Makefile doc/Makefile lib/Makefile \
     m4/Makefile Makefile python/Makefile util/Makefile

make PREFIX=/usr LIBDIR=/usr/lib64
make PREFIX=/usr LIBDIR=/usr/lib64 install   

mv -v /usr/lib64/libcrack.so.* /lib64 &&
ln -sfv ../../lib64/$(readlink /usr/lib64/libcrack.so) /usr/lib64/libcrack.so

ldconfig

install -v -m644 -D    ../cracklib-words-2.9.6.gz \
                         /usr/share/dict/cracklib-words.gz     &&

gunzip -v                /usr/share/dict/cracklib-words.gz     &&
ln -v -sf cracklib-words /usr/share/dict/words                 &&
echo $(hostname) >>      /usr/share/dict/cracklib-extra-words  &&
install -v -m755 -d      /lib64/cracklib                        &&

create-cracklib-dict     /usr/share/dict/cracklib-words \
                         /usr/share/dict/cracklib-extra-words

#make test
#checkBuiltPackage

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf cracklib


#Linux-PAM 32-bit
mkdir linuxpam && tar xf Linux-PAM-1.3.0.tar.* -C linuxpam --strip-components 1
cd linuxpam

USE_ARCH=32 PKG_CONFIG_PATH="${PKG_CONFIG_PATH32}" \
CC="gcc ${BUILD32}" CXX="g++ ${BUILD32}"\

autoreconf

./configure \
        --sbindir=/usr/lib/security \
        --enable-securedir=/usr/lib/security \
        --docdir=/usr/share/doc/Linux-PAM-1.3.0\
        --enable-shared \
        --libdir=/usr/lib \
        --enable-read-both-confs \
        --sysconfdir=/etc \
        --disable-regenerate-docu

make PREFIX=/usr LIBDIR=/usr/lib

install -v -m755 -d /etc/pam.d

cat > /etc/pam.d/other << "EOF"
auth     required       pam_deny.so
account  required       pam_deny.so
password required       pam_deny.so
session  required       pam_deny.so
EOF

make check
checkBuiltPackage
make PREFIX=/usr LIBDIR=/usr/lib install

chmod -v 4755 /sbin/unix_chkpwd 
chmod -v 4755 /lib/security/unix_chkpwd

for file in pam pam_misc pamc
do
  mv -v /usr/lib/lib${file}.so.* /lib &&
  ln -sfv ../../lib/$(readlink /usr/lib/lib${file}.so) /usr/lib/lib${file}.so
done

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf linuxpam

#Linux-PAM 64-bit
mkdir linuxpam && tar xf Linux-PAM-1.3.0.tar.* -C linuxpam --strip-components 1
cd linuxpam

autoreconf

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}"
CC="gcc ${BUILD64}" ./configure --libdir=/usr/lib64 \
           --sbindir=/usr/lib64/security \
           --enable-securedir=/usr/lib64/security \
           --docdir=/usr/share/doc/Linux-PAM-1.3.0\
           --enable-shared \
           --enable-read-both-confs \
           --sysconfdir=/etc \
           --disable-regenerate-docu

make PREFIX=/usr LIBDIR=/usr/lib64

#Config
install -v -m755 -d /etc/pam.d 

cat > /etc/pam.d/other << "EOF"
auth     required       pam_deny.so
account  required       pam_deny.so
password required       pam_deny.so
session  required       pam_deny.so
EOF

make check
checkBuiltPackage

rm -fv /etc/pam.d/*

make PREFIX=/usr LIBDIR=/usr/lib64 install 
chmod -v 4755 /sbin/unix_chkpwd 
chmod -v 4755 /lib64/security/unix_chkpwd

for file in pam pam_misc pamc
do
  mv -v /usr/lib64/lib${file}.so.* /lib64 &&
  ln -sfv ../../lib64/$(readlink /usr/lib64/lib${file}.so) /usr/lib64/lib${file}.so
done

cat > /etc/pam.d/system-auth << "EOF"
# Begin /etc/pam.d/other

auth            required        pam_unix.so     nullok
account         required        pam_unix.so
session         required        pam_unix.so
password        required        pam_unix.so     nullok

# End /etc/pam.d/other
EOF

install -vdm755 /etc/pam.d 

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf linuxpam

#Shadow
mkdir shadow && tar xf shadow-*.tar.* -C shadow --strip-components 1
cd shadow

sed -i 's@DICTPATH.*@DICTPATH\t/lib/cracklib/pw_dict@' etc/login.defs
sed -i 's/groups$(EXEEXT) //' src/Makefile.in &&

find man -name Makefile.in -exec sed -i 's/groups\.1 / /'   {} \; &&
find man -name Makefile.in -exec sed -i 's/getspnam\.3 / /' {} \; &&
find man -name Makefile.in -exec sed -i 's/passwd\.5 / /'   {} \; &&

sed -i -e 's@#ENCRYPT_METHOD DES@ENCRYPT_METHOD SHA512@' \
       -e 's@/var/spool/mail@/var/mail@' etc/login.defs &&

sed -i 's/1000/999/' etc/useradd                           &&

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} \
CC="gcc ${BUILD64}" ./configure \
    --sysconfdir=/etc \
    --libdir=/usr/lib64 \
    --with-group-name-max-length=32 \
    --with-libcrack 

make PREFIX=/usr LIBDIR=/usr/lib64
make PREFIX=/usr LIBDIR=/usr/lib64 install   

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

#Conf to work properly with PAM
install -v -m644 /etc/login.defs /etc/login.defs.orig &&
for FUNCTION in FAIL_DELAY               \
                FAILLOG_ENAB             \
                LASTLOG_ENAB             \
                MAIL_CHECK_ENAB          \
                OBSCURE_CHECKS_ENAB      \
                PORTTIME_CHECKS_ENAB     \
                QUOTAS_ENAB              \
                CONSOLE MOTD_FILE        \
                FTMP_FILE NOLOGINS_FILE  \
                ENV_HZ PASS_MIN_LEN      \
                SU_WHEEL_ONLY            \
                CRACKLIB_DICTPATH        \
                PASS_CHANGE_TRIES        \
                PASS_ALWAYS_WARN         \
                CHFN_AUTH ENCRYPT_METHOD \
                ENVIRON_FILE
do
    sed -i "s/^${FUNCTION}/# &/" /etc/login.defs
done

cat > /etc/pam.d/login << "EOF"
# Begin /etc/pam.d/login

# Set failure delay before next prompt to 3 seconds
auth      optional    pam_faildelay.so  delay=3000000

# Check to make sure that the user is allowed to login
auth      requisite   pam_nologin.so

# Check to make sure that root is allowed to login
# Disabled by default. You will need to create /etc/securetty
# file for this module to function. See man 5 securetty.
#auth      required    pam_securetty.so

# Additional group memberships - disabled by default
#auth      optional    pam_group.so

# include the default auth settings
auth      include     system-auth

# check access for the user
account   required    pam_access.so

# include the default account settings
account   include     system-account

# Set default environment variables for the user
session   required    pam_env.so

# Set resource limits for the user
session   required    pam_limits.so

# Display date of last login - Disabled by default
#session   optional    pam_lastlog.so

# Display the message of the day - Disabled by default
#session   optional    pam_motd.so

# Check user's mail - Disabled by default
#session   optional    pam_mail.so      standard quiet

# include the default session and password settings
session   include     system-session
password  include     system-password

# End /etc/pam.d/login
EOF

cat > /etc/pam.d/passwd << "EOF"
# Begin /etc/pam.d/passwd
password  include     system-password
# End /etc/pam.d/passwd
EOF

cat > /etc/pam.d/su << "EOF"
# Begin /etc/pam.d/su

# always allow root
auth      sufficient  pam_rootok.so
auth      include     system-auth

# include the default account settings
account   include     system-account

# Set default environment variables for the service user
session   required    pam_env.so

# include system session defaults
session   include     system-session

# End /etc/pam.d/su
EOF

cat > /etc/pam.d/chage << "EOF"
# Begin /etc/pam.d/chage

# always allow root
auth      sufficient  pam_rootok.so

# include system defaults for auth account and session
auth      include     system-auth
account   include     system-account
session   include     system-session

# Always permit for authentication updates
password  required    pam_permit.so

# End /etc/pam.d/chage
EOF

for PROGRAM in chfn chgpasswd chpasswd chsh groupadd groupdel \
               groupmems groupmod newusers useradd userdel usermod
do
    install -v -m644 /etc/pam.d/chage /etc/pam.d/${PROGRAM}
    sed -i "s/chage/$PROGRAM/" /etc/pam.d/${PROGRAM}
done

[ -f /etc/login.access ] && mv -v /etc/login.access{,.NOUSE}

[ -f /etc/limits ] && mv -v /etc/limits{,.NOUSE}

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf shadow

#Sudo
mkdir sudo && tar xf sudo-*.tar.* -C sudo --strip-components 1
cd sudo 

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
CC="gcc ${BUILD64}" ./configure --prefix=/usr  \
            --libexecdir=/usr/lib64    \
            --libdir=/usr/lib64   \
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

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf sudo 

#Create PAM config files
install -vdm755 /etc/pam.d &&
cat > /etc/pam.d/system-account << "EOF" &&
# Begin /etc/pam.d/system-account

account   required    pam_unix.so

# End /etc/pam.d/system-account
EOF

cat > /etc/pam.d/system-auth << "EOF" &&
# Begin /etc/pam.d/system-auth

auth      required    pam_unix.so

# End /etc/pam.d/system-auth
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
