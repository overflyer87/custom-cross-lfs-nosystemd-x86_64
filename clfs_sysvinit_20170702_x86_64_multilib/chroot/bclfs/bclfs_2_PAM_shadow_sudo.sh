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

#Cracklib 64-bit
mkdir cracklib && tar xf cracklib-*.tar.* -C cracklib --strip-components 1
cd cracklib

sed -i '/skipping/d' util/packer.c

CC="gcc ${BUILD64}" USE_ARCH=64 ./configure --prefix=/usr \
  --libdir=/usr/lib64 --disable-static --with-default-dict=/lib/cracklib/pw_dict &&
sed -i 's@prefix}/lib@&64@g' dicts/Makefile doc/Makefile lib/Makefile \
     m4/Makefile Makefile python/Makefile util/Makefile &&
     
make PREFIX=/usr LIBDIR=/usr/lib64
make PREFIX=/usr LIBDIR=/usr/lib64 install 

mv -v /usr/lib64/libcrack.so.* /lib64
ln -sfv ../../lib64/$(readlink /usr/lib64/libcrack.so) /usr/lib64/libcrack.so

install -v -m644 -D    ../cracklib-words-2.9.6.gz \
                         /usr/share/dict/cracklib-words.gz     &&

gunzip -v                /usr/share/dict/cracklib-words.gz     &&
ln -v -sf cracklib-words /usr/share/dict/words                 &&
echo $(hostname) >>      /usr/share/dict/cracklib-extra-words  &&
install -v -m755 -d      /lib64/cracklib                         &&

create-cracklib-dict     /usr/share/dict/cracklib-words \
                         /usr/share/dict/cracklib-extra-words
                         
make test

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf cracklib

#Linux-PAM 64-bit
mkdir linuxpam && tar xf Linux-PAM-1.3.0.tar.* -C linuxpam --strip-components 1
cd linuxpam

CC="gcc ${BUILD64}" ./configure --sbindir=/lib64/security \
            --prefix=/usr                    \
            --sysconfdir=/etc                \
            --libdir=/usr/lib64              \
            --disable-regenerate-docu        \
            --enable-shared                  \
            --enable-read-both-confs         \
            --enable-securedir=/lib64/security \
            --docdir=/usr/share/doc/Linux-PAM-1.3.0

make PREFIX=/usr LIBDIR=/usr/lib64

install -v -m755 -d /etc/pam.d &&

cat > /etc/pam.d/other << "EOF"
auth     required       pam_deny.so
account  required       pam_deny.so
password required       pam_deny.so
session  required       pam_deny.so
EOF

make check
checkBuiltPackage

rm -fv /etc/pam.d/*

make PREFIX=/usr LIBDIR=/usr/lib64 install &&
chmod -v 4755 /sbin/unix_chkpwd &&

for file in pam pam_misc pamc
do
  mv -v /usr/lib/lib${file}.so.* /lib &&
  ln -sfv ../../lib/$(readlink /usr/lib/lib${file}.so) /usr/lib/lib${file}.so
done

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

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf linuxpam

#Shadow
mkdir shadow && tar xf shadow-*.tar.* -C shadow --strip-components 1
cd shadow

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf shadow

#Sudo
mkdir sudo && tar xf sudo-*.tar.* -C sudo --strip-components 1
cd sudo

CC="gcc ${BUILD64}" ./configure --prefix=/usr \
    --libdir=/usr/lib64 \
    --libexecdir=/usr/lib64 \
    --with-secure-path  \
    --enable-noargs-shell \
    --with-ignore-dot \
    --with-all-insults \
    --with-env-editor  \
    --enable-shell-sets-home \
    --docdir=/usr/share/doc/sudo-1.8.20p2 \
    --with-passprompt="[sudo] password for %p: "

make PREFIX=/usr LIBDIR=/usr/lib64
env LC_ALL=C make check 2>&1 | tee ../make-check.log
grep failed ../make-check.log
checkBuiltPackage
make PREFIX=/usr LIBDIR=/usr/lib64 install

ln -sfv libsudo_util.so.0.0.0 /usr/lib/sudo/libsudo_util.so.0

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

