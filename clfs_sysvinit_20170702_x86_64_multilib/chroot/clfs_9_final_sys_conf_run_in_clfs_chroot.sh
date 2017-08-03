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

cat > /etc/profile << "EOF"
# Begin /etc/profile

for f in /etc/bash_completion.d/*
do
  if [ -e ${f} ]; then source ${f}; fi
done
unset f

export INPUTRC=/etc/inputrc
EOF

cat > /etc/profile << "EOF"
# Begin /etc/profile

for script in /etc/profile.d/*.sh
do
  source $script
done
unset script

# End /etc/profile
EOF

install -d -m755 /etc/profile.d

cat > /etc/profile.d/05-i18n.sh << "EOF"
# Begin /etc/profile.d/05-i18n.sh

export LANG=[ll]_[CC].[charset]
export G_FILENAME_ENCODING=@locale
 
# End /etc/profile.d/05-i18n.sh
EOF

cat > /etc/profile.d/10-path.sh << "EOF"
# Begin /etc/profile.d/10-path.sh

if [ "$EUID" -eq 0 ]; then
  export PATH="/sbin:/bin:/usr/sbin:/usr/bin"
  if [ -d "/usr/local/sbin" ]; then
    export PATH="$PATH:/usr/local/sbin"
  fi
else
  export PATH="/bin:/usr/bin"
fi

if [ -d "/usr/local/bin" ]; then
  export PATH="$PATH:/usr/local/bin"
fi

if [ -d "$HOME/bin" ]; then
  export PATH="$HOME/bin:$PATH"
fi

# End /etc/profile.d/10-path.sh
EOF

cat > /etc/profile.d/10-pkg_config_path.sh << "EOF"
# Begin /etc/profile.d/10-pkg_config_path.sh

export PKG_CONFIG_PATH32="/usr/lib/pkgconfig"
export PKG_CONFIG_PATHN32="/usr/lib32/pkgconfig"
export PKG_CONFIG_PATH64="/usr/lib64/pkgconfig"

# End /etc/profile.d/10-pkg_config_path.sh
EOF

cat > /etc/profile.d/10-xdg.sh << "EOF"
# Begin /etc/profild.d/10-xdg.sh

export XDG_DATA_DIRS="/usr/share"
export XDG_CONFIG_DIRS="/etc/xdg:/usr/share"

# End /etc/profild.d/10-xdg.sh
EOF

cat > /etc/profile.d/50-dircolors.sh << "EOF"
# Begin /etc/profile.d/50-dircolors.sh

alias ls='ls --color=auto'
if [ -f "$HOME/.dircolors" ]; then
  eval `dircolors -b "$HOME/.dircolors"`
else
  if [ -f "/etc/dircolors" ]; then
    eval `dircolors -b "/etc/dircolors"`
  fi
fi

# End /etc/profile.d/50-dircolors.sh
EOF

dircolors -p > /etc/dircolors

cat > /etc/profile.d/50-history.sh << "EOF"
# Begin /etc/profile.d/50-history.sh

export HISTSIZE=1000
export HISTIGNORE="&:[bf]g:exit"

# End /etc/profile.d/50-history.sh
EOF

cat > /etc/profile.d/50-prompt.sh << "EOF"
# Begin /etc/profile.d/50-prompt.sh

export PS1="\u:\w\$ "
if [ "${TERM:0:5}" = "xterm" ]; then
  export PS1="\[\e]2;\u@\H :: \w\a\]$PS1"
fi

shopt -s checkwinsize

# End /etc/profile.d/50-prompt.sh
EOF

cat > /etc/profile.d/50-readline.sh << "EOF"
# Begin /etc/profile.d/50-readline.sh

if [ -z "$INPUTRC" ]; then
  if [ -f "$HOME/.inputrc" ]; then
    export INPUTRC="$HOME/.inputrc"
  else
    if [ -f "/etc/inputrc" ]; then
      export INPUTRC="/etc/inputrc"
    fi
  fi
fi

# End /etc/profile.d/50-readline.sh
EOF

cat > /etc/profile.d/50-umask.sh << "EOF"
# Begin /etc/profile.d/50-umask.sh

if [ "`id -un`" = "`id -gn`" -a $EUID -gt 99 ]; then
  umask 002
else
  umask 022
fi

# End /etc/profile.d/50-umask.sh
EOF

cat > /etc/profile.d/50-multilib.sh << "EOF"
# Begin /etc/profile.d/50-multilib.sh

export BUILD32="-m32"
export BUILD64="-m64"

export CLFS_TARGET32="i686-pc-linux-gnu"

export LD_BUILD32="-m elf_i386"
export LD_BUILD64="-m elf_x86_64"

# End /etc/profile.d/50-multilib.sh
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

cat > /etc/inputrc << "EOF"
# Begin /etc/inputrc
# Modified by Chris Lynn <roryo@roryo.dynup.net>

# Allow the command prompt to wrap to the next line
set horizontal-scroll-mode Off

# Enable 8bit input
set meta-flag On
set input-meta On

# Turns off 8th bit stripping
set convert-meta Off

# Keep the 8th bit for display
set output-meta On

# none, visible or audible
set bell-style none

# All of the following map the escape sequence of the
# value contained inside the 1st argument to the
# readline specific functions

"\eOd": backward-word
"\eOc": forward-word

# for linux console
"\e[1~": beginning-of-line
"\e[4~": end-of-line
"\e[5~": beginning-of-history
"\e[6~": end-of-history
"\e[3~": delete-char
"\e[2~": quoted-insert

# for xterm
"\eOH": beginning-of-line
"\eOF": end-of-line

# for Konsole
"\e[H": beginning-of-line
"\e[F": end-of-line

# End /etc/inputrc
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

ln -sfv /etc/rc.d/init.d/functions /lib/init-functions
ln -sfv /etc/rc.d/init.d/functions /lib64/init-functions

#lsb-release
wget http://sourceforge.net/projects/lsb/files/lsb_release/1.4/lsb-release-1.4.tar.gz -O \
    lsb-release-1.4.tar.gz
    
mkdir lsbrel && tar xf lsb-release-*.tar.* -C lsbrel --strip-components 1
cd lsbrel

sed -i "s|n/a|unavailable|" lsb_release

./help2man -N --include ./lsb_release.examples \
              --alt_version_key=program_version ./lsb_release > lsb_release.1

install -v -m 644 lsb_release.1 /usr/share/man/man1/lsb_release.1 &&
install -v -m 755 lsb_release /usr/bin/lsb_release

echo 8.0 > /etc/clfs-release

cat > /etc/lsb-release << "EOF"
DISTRIB_ID="Cross Linux From Scratch"
DISTRIB_RELEASE="SYSVINIT-20170702-x86_64"
DISTRIB_CODENAME="overflyer"
DISTRIB_DESCRIPTION="Cross Linux From Scratch"
EOF


cd ${CLFSSOURCES} 
checkBuiltPackage
rm -rf lsbrel

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


