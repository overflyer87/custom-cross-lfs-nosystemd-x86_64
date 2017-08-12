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
MAKEFLAGS="-j$(nproc)"
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
export MAKEFLAGS="-j$(nproc)"
export BUILD32="-m32"
export BUILD64="-m64"
export CLFS_TARGET32="i686-pc-linux-gnu"

cd ${CLFSSOURCES}

#Chapter 11
#System Configuration
mkdir bootscripts
tar xf bootscripts-cross-lfs-3.0-20140710.tar.* -C bootscripts --strip-components 1
cd bootscripts

make install-bootscripts
make install-network

cd ${CLFSSOURCES}
#checkBuiltPackage
#NEED TO FIGURE OUT HOW THIS WORKS WITH OPENRC

cat > /etc/sysconfig/clock << "EOF"
# Begin /etc/sysconfig/clock

UTC=1

# End /etc/sysconfig/clock
EOF

cat >/etc/udev/rules.d/82-cdrom.rules << EOF

# Custom CD-ROM symlinks
SUBSYSTEM=="block", ENV{ID_TYPE}=="cd", \
    ENV{ID_PATH}=="pci-0000:00:07.1-ide-0:1", SYMLINK+="cdrom"
SUBSYSTEM=="block", ENV{ID_TYPE}=="cd", \
    ENV{ID_PATH}=="pci-0000:00:07.1-ide-1:1", SYMLINK+="cdrom1 dvd"

EOF

cat >> /etc/locale.conf << "EOF"

LC_ALL=de_DE.utf8 locale territory 
LC_ALL=en_US.utf8 locale language
LC_ALL=de_DE.utf8 locale charmap
LC_ALL=de_DE.utf8 locale int_curr_symbol
LC_ALL=de_DE.utf8 locale int_prefix
LANG=en_US.utf8

# End /etc/locale.conf
EOF

cat >> /etc/profile << "EOF"

export LANG=en_US.utf8

# End /etc/profile
EOF

cat > /etc/fstab << "EOF"
# Begin /etc/fstab

# file system  mount-point  type   options          dump  fsck
#                                                         order

/dev/sda1	     /boot/efi    vfat   rw,defaults	    0     0
/dev/sda4	     /            ext4   rw,defaults      0     0
/dev/sda5      /home        ext4   rw,defaults      0     0
devpts         /dev/pts     devpts gid=5,mode=620   0     0
shm            /dev/shm     tmpfs  defaults         0     0

# End /etc/fstab
EOF

echo "HOSTNAME=overflyer-main" > /etc/sysconfig/network

cat > /etc/hosts << "EOF"
# Begin /etc/hosts (network card version)

127.0.0.1 localhost
::1       localhost
192.168.0.143 overflyer-main.example.org overflyer-main

# End /etc/hosts (network card version)
EOF

cat > /etc/resolv.conf << "EOF"
# Begin /etc/resolv.conf

nameserver 192.168.0.1
nameserver 192.168.0.1

# End /etc/resolv.conf
EOF

#dhcpcd
mkdir dhcpcd && tar xf dhcpcd-*.tar.* -C dhcpcd --strip-components 1
cd dhcpcd

CC="gcc ${BUILD64}" ./configure \
    --prefix=/usr \
    --sbindir=/sbin \
    --sysconfdir=/etc \
    --dbdir=/var/lib/dhcpcd \
    --libexecdir=/usr/lib64/dhcpcd \
    --libdir=/usr/lib64

make && make install

cd ${CLFSSOURCES}
#checkBuiltPackage
rm -rf dhcpcd


cd ${CLFSSOURCES}/bootscripts
make install-service-dhcpcd
cd ${CLFSSOURCES}

cd /etc/sysconfig/network-devices &&
mkdir -v ifconfig.eth0 &&
cat > ifconfig.eth0/dhcpcd << "EOF"
ONBOOT="yes"
SERVICE="dhcpcd"

# Start Command for DHCPCD
DHCP_START="-q"

# Stop Command for DHCPCD
DHCP_STOP="-k"
EOF

#checkBuiltPackage

cd ${CLFSSOURCES}

sed -i 's/\/lib\//\/lib64\//' /etc/rc.dinit.d/*
sed -i 's/\/lib6464\//\/lib64\//' /etc/rc.dinit.d/*
sed -i 's/loadproc/start_daemon/' /etc/rc.dinit.d/*
sed -i 's/load_info_msg/echo/' /etc/rc.dinit.d/*
ln -sfv /etc/rc.d/init.d/functions /lib64/init-functions

#lsb-release
mkdir lsbrel && tar xf lsb-release-*.tar.* -C lsbrel --strip-components 1
cd lsbrel

sed -i "s|n/a|unavailable|" lsb_release

./help2man -N --include ./lsb_release.examples \
              --alt_version_key=program_version ./lsb_release > lsb_release.1

install -v -m 644 lsb_release.1 /usr/share/man/man1/lsb_release.1 &&
install -v -m 755 lsb_release /usr/bin/lsb_release

echo 8.0 > /etc/clfs-release

cat > /etc/lsb-release << "EOF"
DISTRIB_ID="CrossLFS"
DISTRIB_RELEASE="SYSVINIT-20170702-x86_64"
DISTRIB_CODENAME="overflyer"
DISTRIB_DESCRIPTION="CrossLFS"
EOF

cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf lsbrel

#Bash startup files according to BLFS
#And one multilib sh from CBLFS

install --directory --mode=0755 --owner=root --group=root /etc/profile.d

cat > /etc/profile.d/50-multilib.sh << "EOF"
# Begin /etc/profile.d/50-multilib.sh

export BUILD32="-m32"
export BUILD64="-m64"

export CLFS_TARGET32="i686-pc-linux-gnu"

export LD_BUILD32="-m elf_i386"
export LD_BUILD64="-m elf_x86_64"

# End /etc/profile.d/50-multilib.sh
EOF

#Now only BLFS scripts follow
cat > /etc/profile << "EOF"
# Begin /etc/profile
# Written for Beyond Linux From Scratch
# by James Robertson <jameswrobertson@earthlink.net>
# modifications by Dagmar d'Surreal <rivyqntzne@pbzpnfg.arg>

# System wide environment variables and startup programs.

# System wide aliases and functions should go in /etc/bashrc.  Personal
# environment variables and startup programs should go into
# ~/.bash_profile.  Personal aliases and functions should go into
# ~/.bashrc.

# Functions to help us manage paths.  Second argument is the name of the
# path variable to be modified (default: PATH)
pathremove () {
        local IFS=':'
        local NEWPATH
        local DIR
        local PATHVARIABLE=${2:-PATH}
        for DIR in ${!PATHVARIABLE} ; do
                if [ "$DIR" != "$1" ] ; then
                  NEWPATH=${NEWPATH:+$NEWPATH:}$DIR
                fi
        done
        export $PATHVARIABLE="$NEWPATH"
}

pathprepend () {
        pathremove $1 $2
        local PATHVARIABLE=${2:-PATH}
        export $PATHVARIABLE="$1${!PATHVARIABLE:+:${!PATHVARIABLE}}"
}

pathappend () {
        pathremove $1 $2
        local PATHVARIABLE=${2:-PATH}
        export $PATHVARIABLE="${!PATHVARIABLE:+${!PATHVARIABLE}:}$1"
}

export -f pathremove pathprepend pathappend

# Set the initial path
export PATH=/bin:/usr/bin

if [ $EUID -eq 0 ] ; then
        pathappend /sbin:/usr/sbin
        unset HISTFILE
fi

# Setup some environment variables.
export HISTSIZE=1000
export HISTIGNORE="&:[bf]g:exit"

# Set some defaults for graphical systems
export XDG_DATA_DIRS=/usr/share/
export XDG_CONFIG_DIRS=/etc/xdg/
export XDG_RUNTIME_DIR=/tmp/xdg-$USER

# Setup a red prompt for root and a green one for users.
NORMAL="\[\e[0m\]"
RED="\[\e[1;31m\]"
GREEN="\[\e[1;32m\]"
if [[ $EUID == 0 ]] ; then
  PS1="$RED\u [ $NORMAL\w$RED ]# $NORMAL"
else
  PS1="$GREEN\u [ $NORMAL\w$GREEN ]\$ $NORMAL"
fi

for script in /etc/profile.d/*.sh ; do
        if [ -r $script ] ; then
                . $script
        fi
done

unset script RED GREEN NORMAL

# End /etc/profile
EOF

cat > /etc/profile.d/bash_completion.sh << "EOF"
# Begin /etc/profile.d/bash_completion.sh
# Import bash completion scripts

for script in /etc/bash_completion.d/*.sh ; do
        if [ -r $script ] ; then
                . $script
        fi
done
# End /etc/profile.d/bash_completion.sh
EOF

install --directory --mode=0755 --owner=root --group=root /etc/bash_completion.d

cat > /etc/profile.d/dircolors.sh << "EOF"
# Setup for /bin/ls and /bin/grep to support color, the alias is in /etc/bashrc.
if [ -f "/etc/dircolors" ] ; then
        eval $(dircolors -b /etc/dircolors)
fi

if [ -f "$HOME/.dircolors" ] ; then
        eval $(dircolors -b $HOME/.dircolors)
fi

alias ls='ls --color=auto'
alias grep='grep --color=auto'
EOF

cat > /etc/profile.d/extrapaths.sh << "EOF"
if [ -d /usr/local/lib/pkgconfig ] ; then
        pathappend /usr/local/lib/pkgconfig PKG_CONFIG_PATH
fi
if [ -d /usr/local/bin ]; then
        pathprepend /usr/local/bin
fi
if [ -d /usr/local/sbin -a $EUID -eq 0 ]; then
        pathprepend /usr/local/sbin
fi

# Set some defaults before other applications add to these paths.
pathappend /usr/share/man  MANPATH
pathappend /usr/share/info INFOPATH
EOF

cat > /etc/profile.d/readline.sh << "EOF"
# Setup the INPUTRC environment variable.
if [ -z "$INPUTRC" -a ! -f "$HOME/.inputrc" ] ; then
        INPUTRC=/etc/inputrc
fi
export INPUTRC
EOF

cat > /etc/profile.d/umask.sh << "EOF"
# By default, the umask should be set.
if [ "$(id -gn)" = "$(id -un)" -a $EUID -gt 99 ] ; then
  umask 002
else
  umask 022
fi
EOF

cat > /etc/profile.d/i18n.sh << "EOF"
# Set up i18n variables
export LANG=en_US.UTF-8
EOF

cat > /etc/bashrc << "EOF"
# Begin /etc/bashrc
# Written for Beyond Linux From Scratch
# by James Robertson <jameswrobertson@earthlink.net>
# updated by Bruce Dubbs <bdubbs@linuxfromscratch.org>

# System wide aliases and functions.

# System wide environment variables and startup programs should go into
# /etc/profile.  Personal environment variables and startup programs
# should go into ~/.bash_profile.  Personal aliases and functions should
# go into ~/.bashrc

# Provides colored /bin/ls and /bin/grep commands.  Used in conjunction
# with code in /etc/profile.

alias ls='ls --color=auto'
alias grep='grep --color=auto'

# Provides prompt for non-login shells, specifically shells started
# in the X environment. [Review the LFS archive thread titled
# PS1 Environment Variable for a great case study behind this script
# addendum.]

NORMAL="\[\e[0m\]"
RED="\[\e[1;31m\]"
GREEN="\[\e[1;32m\]"
if [[ $EUID == 0 ]] ; then
  PS1="$RED\u [ $NORMAL\w$RED ]# $NORMAL"
else
  PS1="$GREEN\u [ $NORMAL\w$GREEN ]\$ $NORMAL"
fi

unset RED GREEN NORMAL

# End /etc/bashrc
EOF

cat > ~/.bash_profile << "EOF"
# Begin ~/.bash_profile
# Written for Beyond Linux From Scratch
# by James Robertson <jameswrobertson@earthlink.net>
# updated by Bruce Dubbs <bdubbs@linuxfromscratch.org>

# Personal environment variables and startup programs.

# Personal aliases and functions should go in ~/.bashrc.  System wide
# environment variables and startup programs are in /etc/profile.
# System wide aliases and functions are in /etc/bashrc.

if [ -f "$HOME/.bashrc" ] ; then
  source $HOME/.bashrc
fi

if [ -d "$HOME/bin" ] ; then
  pathprepend $HOME/bin
fi

# Having . in the PATH is dangerous
#if [ $EUID -gt 99 ]; then
#  pathappend .
#fi

# End ~/.bash_profile
EOF

cat > ~/.profile << "EOF"
# Begin ~/.profile
# Personal environment variables and startup programs.

if [ -d "$HOME/bin" ] ; then
  pathprepend $HOME/bin
fi

# Set up user specific i18n variables
#export LANG=<ll>_<CC>.<charmap><@modifiers>

# End ~/.profile
EOF

cat > ~/.bashrc << "EOF"
# Begin ~/.bashrc
# Written for Beyond Linux From Scratch
# by James Robertson <jameswrobertson@earthlink.net>

# Personal aliases and functions.

# Personal environment variables and startup programs should go in
# ~/.bash_profile.  System wide environment variables and startup
# programs are in /etc/profile.  System wide aliases and functions are
# in /etc/bashrc.

if [ -f "/etc/bashrc" ] ; then
  source /etc/bashrc
fi

# Set up user specific i18n variables
#export LANG=<ll>_<CC>.<charmap><@modifiers>

# End ~/.bashrc
EOF

cat > ~/.bash_logout << "EOF"
# Begin ~/.bash_logout
# Written for Beyond Linux From Scratch
# by James Robertson <jameswrobertson@earthlink.net>

# Personal items to perform on logout.

# End ~/.bash_logout
EOF

dircolors -p > /etc/dircolors

#For more tipps
#on Bash shell scripts
#http://www.caliban.org/bash/index.shtml

cat > /etc/sysconfig/console << "EOF"
# Begin /etc/sysconfig/console

UNICODE="1"
KEYMAP="de-latin1"

# End /etc/sysconfig/console
EOF

cat > /etc/vconsole.conf << "EOF"
# Begin /etc/vconsole.conf

UNICODE="1"
KEYMAP="de-latin1"

# End /etc/vconsole.conf
EOF

echo " "
echo "Bootloader is installed, debugging sysmbols are stripped"
echo "AND" 
echo "basic configuration files have been created"
echo "lsb release was installed and init-functions symlink has been created"
echo"LET'S BUILD THE KERNEL"
echo " "
echo "For that execute Script #10"
echo " "
echo "CONFIGURE THE KERNEL EXACTLY TO THESE INSTRUCTIONS"
echo " "
echo "http://www.linuxfromscratch.org/~krejzi/basic-kernel.txt"
echo "And if you installed UEFI bootloaders"
echo "Also according to this"
echo "http://www.linuxfromscratch.org/hints/downloads/files/lfs-uefi-20170207.txt"
echo "Register yourself as an Cross LFS user on"
echo "http://www.linuxfromscratch.org/cgi-bin/lfscounter.php. Choose clfs-svn"
echo " "


