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
PKG_CONFIG_PATH=/usr/lib64/pkgconfig
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
export PKG_CONFIG_PATH=/usr/lib64/pkgconfig
export PKG_CONFIG_PATH64=/usr/lib64/pkgconfig

cd ${CLFSSOURCES}
cd ${CLFSSOURCES}/xc/mate

#We will only do 64-bit builds in this script
#We compiled Xorg with 32-bit libraries
#That should suffice

PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" 
USE_ARCH=64 
CXX="g++ ${BUILD64}" 
CC="gcc ${BUILD64}"

export PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" 
export USE_ARCH=64 
export CXX="g++ ${BUILD64}" 
export CC="gcc ${BUILD64}"

#JAVA 8
wget http://anduin.linuxfromscratch.org/BLFS/OpenJDK/OpenJDK-1.8.0.141/OpenJDK-1.8.0.141-x86_64-bin.tar.xz -O \
	OpenJDK-1.8.0.141-x86_64-bin.tar.xz

wget http://hg.openjdk.java.net/jdk8u/jdk8u/archive/jdk8u141-b15.tar.bz2 -O \
	jdk8u141-b15.tar.bz2

mkdir OpenJDK && tar xf OpenJDK-*.tar.* -C OpenJDK --strip-components 1
cd OpenJDK

sudo install -vdm755 /opt/OpenJDK-1.8.0.121-bin 
sudo mv -v * /opt/OpenJDK-1.8.0.121-bin         
sudo chown -R root:root /opt/OpenJDK-1.8.0.121-bin

sudo ln -sfn OpenJDK-1.8.0.121-bin /opt/jdk

checkBuiltPackage

sudo bash -c 'cat > /etc/profile.d/openjdk.sh << "EOF"
# Begin /etc/profile.d/openjdk.sh

# Set JAVA_HOME directory
JAVA_HOME=/opt/jdk

# Adjust PATH
pathappend $JAVA_HOME/bin

# Add to MANPATH
pathappend $JAVA_HOME/man MANPATH

# Auto Java CLASSPATH: Copy jar files to, or create symlinks in, the
# /usr/share/java directory. Note that having gcj jars with OpenJDK 8
# may lead to errors.

AUTO_CLASSPATH_DIR=/usr/share/java

pathprepend . CLASSPATH

for dir in `find ${AUTO_CLASSPATH_DIR} -type d 2>/dev/null`; do
    pathappend $dir CLASSPATH
done

for jar in `find ${AUTO_CLASSPATH_DIR} -name "*.jar" 2>/dev/null`; do
    pathappend $jar CLASSPATH
done

export JAVA_HOME
unset AUTO_CLASSPATH_DIR dir jar

# End /etc/profile.d/openjdk.sh
EOF'

ls /etc/profile.d | grep openjdk
checkBuiltPackage

sudo bash -c 'cat >> /etc/man_db.conf << "EOF" 
# Begin Java addition
MANDATORY_MANPATH     /opt/jdk/man
MANPATH_MAP           /opt/jdk/bin     /opt/jdk/man
MANDB_MAP             /opt/jdk/man     /var/cache/man/jdk
# End Java addition
EOF'

ls /etc/ | grep man
checkBuiltPackage

sudo mkdir -p /var/cache/man
sudo mandb -c /opt/jdk/man

cd ..

mkdir jdk8 && tar xf jdk8*.tar.* -C jdk8 --strip-components 1
cd jdk8

mv ../OpenJDK .

cat > subprojects.md5 << EOF 
4061c0f2dc553cf92847e4a39a03ea4e  corba.tar.bz2
269a0fde90b9ab5ca19fa82bdb3d6485  hotspot.tar.bz2
a1dfcd15119dd10db6e91dc2019f14e7  jaxp.tar.bz2
16f904d990cb6a3c84ebb81bd6bea1e7  jaxws.tar.bz2
4fb652cdd6fee5f2873b00404e9a01f3  langtools.tar.bz2
c4a99c9c5293bb5c174366664843c8ce  jdk.tar.bz2
c2f06cd8d6e90f3dcc57bec53f419afe  nashorn.tar.bz2
EOF

for subproject in corba hotspot jaxp jaxws langtools jdk nashorn; do
  wget -c http://hg.openjdk.java.net/jdk8u/jdk8u/${subproject}/archive/jdk8u141-b15.tar.bz2 \
       -O ${subproject}.tar.bz2
done

md5sum -c subprojects.md5 

for subproject in corba hotspot jaxp jaxws langtools jdk nashorn; do
  mkdir -pv ${subproject} 
  tar -xf ${subproject}.tar.bz2 --strip-components=1 -C ${subproject}
done

unset JAVA_HOME               

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} sh ./configure --prefix=/usr  \
   --with-update-version=141  \
   --libdir=/usr/lib64        \
   --with-build-number=b15    \
   --with-milestone=BLFS      \
   --enable-unlimited-crypto  \
   --with-zlib=system         \
   --with-giflib=system       \
   --with-extra-cflags="-std=c++98 -Wno-error -fno-delete-null-pointer-checks -fno-lifetime-dse" \
   --with-extra-cxxflags="-std=c++98 -fno-delete-null-pointer-checks -fno-lifetime-dse" \
   --with-boot-jdk=/opt/jdk

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} make PREFIX=/usr \
	LIBDIR=/usr/lib64 DEBUG_BINARIES=true SCTP_WERROR= all JOBS=4 
	
sudo find build/*/images/j2sdk-image -iname \*.diz -delete

sudo cp -RT build/*/images/j2sdk-image /opt/OpenJDK-1.8.0.141 &&
sudo chown -R root:root /opt/OpenJDK-1.8.0.141
sudo ln -v -nsf OpenJDK-1.8.0.141 /opt/jdk

sudo mkdir -pv /usr/share/applications 

sudo bash -c 'cat > /usr/share/applications/openjdk-8-policytool.desktop << "EOF" 
[Desktop Entry]
Name=OpenJDK Java Policy Tool
Name[pt_BR]=OpenJDK Java - Ferramenta de Política
Comment=OpenJDK Java Policy Tool
Comment[pt_BR]=OpenJDK Java - Ferramenta de Política
Exec=/opt/jdk/bin/policytool
Terminal=false
Type=Application
Icon=javaws
Categories=Settings;
EOF'

sudo install -v -Dm0644 javaws.png /usr/share/pixmaps/javaws.png

sudo install -vdm755 /etc/ssl/local &&
wget https://hg.mozilla.org/releases/mozilla-release/raw-file/default/security/nss/lib/ckfw/builtins/certdata.txt
wget http://www.cacert.org/certs/root.crt 
sudo openssl x509 -in root.crt -text -fingerprint -setalias "CAcert Class 1 root" \
        -addtrust serverAuth -addtrust emailProtection -addtrust codeSigning \
        > /etc/ssl/local/CAcert_Class_1_root.pem
wget http://www.cacert.org/certs/root.crt

sudo /usr/sbin/make-ca.sh --force
sudo ln -sfv /etc/ssl/java/cacerts /opt/jdk/jre/lib/security/cacerts

cd /opt/jdk
bin/keytool -list -keystore /etc/ssl/java/cacerts

#just pess enter there is no password

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
