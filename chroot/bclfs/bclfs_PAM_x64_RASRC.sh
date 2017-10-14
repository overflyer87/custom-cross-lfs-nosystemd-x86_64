#!/bin/bash

function checkBuiltPackage() {
echo " "
echo "Make sure you are able to continue... [Y/N]"
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
export CLFSSOURCES=/sources
export MAKEFLAGS="-j$(nproc)"
export BUILD32="-m32"
export BUILD64="-m64"
export CLFS_TARGET32="i686-pc-linux-gnu"
export PKG_CONFIG_PATH32=/usr/lib/pkgconfig
export PKG_CONFIG_PATH64=/usr/lib64/pkgconfig

echo " "
echo " "
echo "This is the last script that runs before you can reboot and enjoy you very OWN customized linux :)"
echo "This script runs after the kernel was compiled and installed"
echo "It installs sudo, shadow, cracklib and PAM to provide the system with a much more secure way to handle authentications"
echo " "
echo " "
echo "In the end it will finally CREATE A USER FOR YOU and open up /etc/sudoers for YOU TO EDIT!"
echo " "
echo " "
echo "Please CHOOSE YOUR USERNAME"

read myusername
YOURUSERNAME=$myusername
export YOURUSERNAME

cd ${CLFSSOURCES}

#Cracklib 64-bit
mkdir cracklib && tar xf cracklib-*.tar.* -C cracklib --strip-components 1
cd cracklib

sed -i '/skipping/d' util/packer.c

CC="gcc ${BUILD64}" USE_ARCH=64 ./configure --prefix=/usr \
  --libdir=/usr/lib64 --disable-static --with-default-dict=/lib/cracklib/pw_dict 
  
sed -i 's@prefix}/lib@&64@g' dicts/Makefile doc/Makefile lib/Makefile \
     m4/Makefile Makefile python/Makefile util/Makefile 
     
make PREFIX=/usr LIBDIR=/usr/lib64
make PREFIX=/usr LIBDIR=/usr/lib64 install 

mv -v /usr/lib64/libcrack.so.* /lib64
ln -sfv ../../lib64/$(readlink /usr/lib64/libcrack.so) /usr/lib64/libcrack.so

install -v -m644 -D    ../cracklib-words-2.9.6.gz \
                         /usr/share/dict/cracklib-words.gz     

gunzip -v                /usr/share/dict/cracklib-words.gz     
ln -v -sf cracklib-words /usr/share/dict/words                 
echo $(hostname) >>      /usr/share/dict/cracklib-extra-words  
install -v -m755 -d      /lib64/cracklib                         

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

make PREFIX=/usr LIBDIR=/usr/lib64 install 
chmod -v 4755 /sbin/unix_chkpwd 

for file in pam pam_misc pamc
do
  mv -v /usr/lib/lib${file}.so.* /lib 
  ln -sfv ../../lib/$(readlink /usr/lib/lib${file}.so) /usr/lib/lib${file}.so
done

install -vdm755 /etc/pam.d 
cat > /etc/pam.d/system-account << "EOF" 
# Begin /etc/pam.d/system-account

account   required    pam_unix.so

# End /etc/pam.d/system-account
EOF

cat > /etc/pam.d/system-auth << "EOF" 
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

sed -i 's@DICTPATH.*@DICTPATH\t/lib/cracklib/pw_dict@' etc/login.defs

#Shadow
mkdir shadow && tar xf shadow-*.tar.* -C shadow --strip-components 1
cd shadow

sed -i 's/groups$(EXEEXT) //' src/Makefile.in 

find man -name Makefile.in -exec sed -i '/groups\.1\.xml/d' '{}' \; 
find man -name Makefile.in -exec sed -i 's/groups\.1 / /'   {} \; 
find man -name Makefile.in -exec sed -i 's/getspnam\.3 / /' {} \; 
find man -name Makefile.in -exec sed -i 's/passwd\.5 / /'   {} \; 

sed -i -e 's@#ENCRYPT_METHOD DES@ENCRYPT_METHOD SHA512@' \
       -e 's@/var/spool/mail@/var/mail@' etc/login.defs 

sed -i 's/1000/999/' etc/useradd                           

sed -i 's/groups$(EXEEXT) //' src/Makefile.in

CC="gcc ${BUILD64}" ./configure --sysconfdir=/etc \
    --with-group-name-max-length=32 \
    --with-libpam \
    --with-libcrack \
    --without-audit \
    --without-selinux

make PREFIX=/usr LIBDIR=/usr/lib64
make PREFIX=/usr LIBDIR=/usr/lib64 install

sed -i /etc/login.defs \
    -e 's@#\(ENCRYPT_METHOD \).*@\1SHA512@' \
    -e 's@/var/spool/mail@/var/mail@'

sed -i 's/yes/no/' /etc/default/useradd

mv -v /usr/bin/passwd /bin

touch /var/log/{fail,last}log
chgrp -v utmp /var/log/{fail,last}log
chmod -v 664 /var/log/{fail,last}log

install -v -m644 /etc/login.defs /etc/login.defs.orig 
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

pwconv

grpconv

passwd root

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf shadow

#Sudo 64-bit
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

#Add the final regular user
groupadd users
groupadd storage
groupadd power
useradd -g users -G wheel,storage,power -m -s /bin/bash $YOURUSERNAME
passwd $YOURUSERNAME

#User should uncomment first line containing wheel now
visudo

#Get PKG_CONFIG_PATH to be loaded up automagically for both users
#Easier for later building of packages
cat >> /home/$YOURUSERNAME/.bashrc << "EOF"
export PKG_CONFIG_PATH64=/usr/lib64/pkgconfig
export PKG_CONFIG_PATH32=/usr/lib/pkgconfig
EOF

cat >> /root/.bashrc << "EOF"
export PKG_CONFIG_PATH64=/usr/lib64/pkgconfig
export PKG_CONFIG_PATH32=/usr/lib/pkgconfig
EOF

echo " "
echo "You may reboot now and try your new VERY OWN LINUX now ;)"
echo " "

#Clean up :)
rm -rf /tools
rm -rf /cross-tools

#Blacklist video modules that are not compatible with the proprietary NVIDIA driver
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

