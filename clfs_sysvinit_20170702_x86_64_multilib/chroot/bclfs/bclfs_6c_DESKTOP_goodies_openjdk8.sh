#!/bin/bash

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

function as_root()
{
  if   [ $EUID = 0 ];        then $*
  elif [ -x /usr/bin/sudo ]; then sudo $*
  else                            su -c \\"$*\\"
  fi
}

export -f as_root

function buildSingleXLib64() {
  PKG_CONFIG_PATH="${PKG_CONFIG_PATH64}" \
  USE_ARCH=64 CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" ./configure $XORG_CONFIG64
  make PREFIX=/usr LIBDIR=/usr/lib64
  as_root make PREFIX=/usr LIBDIR=/usr/lib64 install
}

export -f buildSingleXLib64

#Building the final CLFS System
CLFS=/
CLFSHOME=/home
CLFSSOURCES=/sources
CLFSTOOLS=/tools
CLFSCROSSTOOLS=/cross-tools
CLFSFILESYSTEM=ext4
CLFSROOTDEV=/dev/sda4
CLFSHOMEDEV=/dev/sda5
MAKEFLAGS='j8'
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
export MAKEFLAGS=j8
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

sudo install -vdm755 /opt/OpenJDK-1.8.0.141-bin &&
sudo mv -v * /opt/OpenJDK-1.8.0.141-bin         &&
sudo chown -R root:root /opt/OpenJDK-1.8.0.141-bin
sudo ln -sfn OpenJDK-1.8.0.141-bin /opt/jdk

sudo cat > /etc/profile.d/openjdk.sh << "EOF"
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
EOF

sudo cat >> /etc/man_db.conf << "EOF" &&
# Begin Java addition
MANDATORY_MANPATH     /opt/jdk/man
MANPATH_MAP           /opt/jdk/bin     /opt/jdk/man
MANDB_MAP             /opt/jdk/man     /var/cache/man/jdk
# End Java addition
EOF

sudo mkdir -p /var/cache/man
sudo mandb -c /opt/jdk/man

cd ..

mkdir jdk8 && tar xf jdk8*.tar.* -C jdk8 --strip-components 1
cd jdk8

mv ../OpenJDK .

cat > subprojects.md5 << EOF &&
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
done &&

md5sum -c subprojects.md5 &&

for subproject in corba hotspot jaxp jaxws langtools jdk nashorn; do
  mkdir -pv ${subproject} &&
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
find build/*/images/j2sdk-image -iname \*.diz -delete

sudo cp -RT build/*/images/j2sdk-image /opt/OpenJDK-1.8.0.141 &&
sudo chown -R root:root /opt/OpenJDK-1.8.0.141
sudo ln -v -nsf OpenJDK-1.8.0.141 /opt/jdk

sudo mkdir -pv /usr/share/applications 

sudo cat > /usr/share/applications/openjdk-8-policytool.desktop << "EOF" 
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
EOF

sudo install -v -Dm0644 javaws.png /usr/share/pixmaps/javaws.png

sudo install -vdm755 /etc/ssl/local &&
wget https://hg.mozilla.org/releases/mozilla-release/raw-file/default/security/nss/lib/ckfw/builtins/certdata.txt
wget http://www.cacert.org/certs/root.crt 
sudo openssl x509 -in root.crt -text -fingerprint -setalias "CAcert Class 1 root" \
        -addtrust serverAuth -addtrust emailProtection -addtrust codeSigning \
        > /etc/ssl/local/CAcert_Class_1_root.pem
wget http://www.cacert.org/certs/root.crt

sudo /usr/sbin/make-ca.sh
sudo ln -sfv /etc/ssl/java/cacerts /opt/jdk/jre/lib/security/cacerts

cd /opt/jdk
bin/keytool -list -keystore /etc/ssl/java/cacerts

#just pess enter there is no password

#Oracle JDK8
#install -d /etc/.java/.systemPrefs
#install -d /usr/lib64/jvm/java-8-jdk/bin
#install -d /usr/lib64/mozilla/plugins
#install -d /usr/share/licenses/java8jdk
#rm    db/bin/*.bat
#rm    db/3RDPARTY
#rm    db/LICENSE
#rm -r jre/lib/desktop/icons/HighContrast/
#rm -r jre/lib/desktop/icons/HighContrastInverse/
#rm -r jre/lib/desktop/icons/LowContrast/
#rm    jre/lib/fontconfig.*.bfc
#rm    jre/lib/fontconfig.*.properties.src
#rm -r jre/plugin/
#rm    jre/*.txt
#rm    jre/COPYRIGHT
#rm    jre/LICENSE
#rm    jre/README
#rm    man/ja
#sudo cp -rv * /usr/lib64/jvm/java-8-jdk/
#sudo cd /usr/lib64/jvm/java-8-jdk/
#sudo for i in $(ls jre/bin/); do
#        ln -sf "jre/bin/$i" "bin/$i"
#done
#
#sudo sed -e "s|Exec=|Exec=/usr/lib64/jvm/java-8-jdk/jre/bin/|" \
#        -e "s|.png|-jdk8.png|" \
#   -i jre/lib/desktop/applications/*
#
#sudo cp -rv jre/lib/desktop/* /usr/share/
#sudo install -m644 jre/lib/desktop/applications/*.desktop /usr/share/applications/
#
#sudo install -m644 -d /etc/java-jdk8
#sudo cp -rv jre/lib/* /etc/java-jdk8
#sudo rm -rf jre/lib/* 
#sudo ln -sfv /etc/* /usr/lib64/jvm/java-8-jdk/jre/lib/
#sudo ln -sfv jre/lib/amd64/libnpjp2.so /usr/lib64/mozilla/plugins/libnpjp2-jdk8.so
#sudo ln -sfv /etc/ssl/certs/java/cacerts jre/lib/security/cacerts
#
#sudo for i in $(find man/ -type f); do
#        mv "$i" "${i/.1}-jdk8.1"
#done
#
#sudo mv man/ja_JP.UTF-8/ man/ja
#sudo cp -rv man /usr/share
#sudo rm -r man
#sudo mkdir /usr/share/licenses/java-jdk8
#sudo mv db/NOTICE COPYRIGHT LICENSE *.txt /usr/share/licenses/java-jdk8
#
#"Installing Java Cryptography Extension (JCE) Unlimited Strength Jurisdiction Policy Files..."
#    # Replace default "strong", but limited, cryptography to get an "unlimited strength" one for
#    # things like 256-bit AES. Enabled by default in OpenJDK:
#    # - http://suhothayan.blogspot.com/2012/05/how-to-install-java-cryptography.html
#    # - http://www.eyrie.org/~eagle/notes/debian/jce-policy.html
#    install -m644 "$srcdir"/UnlimitedJCEPolicyJDK$_major/*.jar jre/lib/security/
#    install -Dm644 "$srcdir"/UnlimitedJCEPolicyJDK$_major/README.txt \
#                   "$pkgdir"/usr/share/doc/$pkgname/README_-_Java_JCE_Unlimited_Strength.txt
#
#export lineAwk=(awk '/permission/{a=NR}; END{print a}' /etc/java-jdk8/security/java.policy)
#lineAwk=(awk '/permission/{a=NR}; END{print a}' /etc/java-jdk8/security/java.policy) 
#
#sudo sed "$lineAwk a\\\\n \
#        // (AUR) Allow unsigned applets to read system clipboard, see:\n \
#        // - https://blogs.oracle.com/kyle/entry/copy_and_paste_in_java\n \
#        // - http://slightlyrandombrokenthoughts.blogspot.com/2011/03/oracle-java-applet-clipboard-injection.html\n \
#        permission java.awt.AWTPermission \"accessClipboard\";" \
#    -i /etc/java-jdk8/security/java.policy
