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

#qt 4.8.7
wget http://download.qt-project.org/official_releases/qt/4.8/4.8.7/qt-everywhere-opensource-src-4.8.7.tar.gz _O \
	qt-everywhere-opensource-src-4.8.7.tar.gz
	
wget http://download.kde.org/stable/qtwebkit-2.3/2.3.4/src/qtwebkit-2.3.4.tar.gz -O \
	qtwebkit-2.3.4.tar.gz	
	
export QT4PREFIX=/opt/qt4
QT4PREFIX=/opt/qt4

as_root mkdir -pv /opt/qt-4.8.7
as_root ln -sfnv qt-4.8.7 /opt/qt4

wget https://aur.archlinux.org/cgit/aur.git/plain/disable-sslv3.patch?h=lib32-qt4 -O \
	disable-sslv3.patch
wget https://aur.archlinux.org/cgit/aur.git/plain/glib-honor-ExcludeSocketNotifiers-flag.diff?h=lib32-qt4 -O \
	glib-honor-ExcludeSocketNotifiers-flag.diff
wget https://aur.archlinux.org/cgit/aur.git/plain/improve-cups-support.patch?h=lib32-qt4 -O \
	improve-cups-support.patch
wget https://aur.archlinux.org/cgit/aur.git/plain/kde4-settings.patch?h=lib32-qt4 -O \
	kde4-settings.patch
wget https://aur.archlinux.org/cgit/aur.git/plain/kubuntu_14_systemtrayicon.diff?h=lib32-qt4 -O \
	kubuntu_14_systemtrayicon.diff
wget https://aur.archlinux.org/cgit/aur.git/plain/l-qclipboard_delay.patch?h=lib32-qt4 -O \
	l-qclipboard_delay.patch
wget https://aur.archlinux.org/cgit/aur.git/plain/l-qclipboard_fix_recursive.patch?h=lib32-qt4 -O \
	l-qclipboard_fix_recursive.patch
wget https://aur.archlinux.org/cgit/aur.git/plain/moc-boost-workaround.patch?h=lib32-qt4 -O \
	moc-boost-workaround.patch
wget https://aur.archlinux.org/cgit/aur.git/plain/qt4-gcc6.patch?h=lib32-qt4 -O \
	qt4-gcc6.patch
wget https://aur.archlinux.org/cgit/aur.git/plain/qt4-glibc-2.25.patch?h=lib32-qt4 -O \
	qt4-glibc-2.25.patch
wget https://aur.archlinux.org/cgit/aur.git/plain/qt4-icu59.patch?h=lib32-qt4 -O \
	qt4-icu59.patch
wget https://aur.archlinux.org/cgit/aur.git/plain/qt4-openssl-1.1.patch?h=lib32-qt4 -O \
	qt4-openssl-1.1.patch

mkdir qt4 && tar xf qt-everywhere-opensource-src-*.tar.* -C qt4 --strip-components 1
cd qt4

patch -p1 -i ../moc-boost-workaround.patch

# http://blog.martin-graesslin.com/blog/2014/06/where-are-my-systray-icons/
patch -p1 -i ../kubuntu_14_systemtrayicon.diff

# FS#45106
patch -p0 -i ../kde4-settings.patch

# fixes for LibreOffice from the upstream Qt bug tracker FS#46436, FS#41648, FS#39819
# https://bugreports.qt.io/browse/QTBUG-37380
patch -p1 -i ../glib-honor-ExcludeSocketNotifiers-flag.diff
# https://bugreports.qt.io/browse/QTBUG-34614
patch -p0 -i ../l-qclipboard_fix_recursive.patch
# https://bugreports.qt.io/browse/QTBUG-38585
patch -p0 -i ../l-qclipboard_delay.patch

# React to OpenSSL's OPENSSL_NO_SSL3 define
patch -p1 -i ../disable-sslv3.patch

sed -i "s|-O2|${CXXFLAGS} -m64|" mkspecs/common/{g++,gcc}-base.conf
sed -i "/^QMAKE_LFLAGS_RPATH/s| -Wl,-rpath,||g" mkspecs/common/gcc-base-unix.conf
sed -i "/^QMAKE_LFLAGS\s/s|+=|+= ${LDFLAGS} -m64|g" mkspecs/common/gcc-base.conf
sed -i "/^QMAKE_LINK\s/s|g++|g++ -m64|g" mkspecs/common/g++-base.conf
sed -i "s|-Wl,-O1|-m64 -Wl,-O1|" mkspecs/common/g++-unix.conf
sed -e "s|-O2|${CXXFLAGS} -m64|" \
    -e "/^QMAKE_RPATH/s| -Wl,-rpath,||g" \
    -e "/^QMAKE_LINK\s/s|g++|g++ -m64|g" \
    -e "/^QMAKE_LFLAGS\s/s|+=|+= ${LDFLAGS} -m64|g" \
    -i mkspecs/common/g++.conf

# Fix build with GCC6 (Fedora)
patch -p1 -i ../qt4-gcc6.patch

# Fix build of Qt4 applications with glibc 2.25 (Fedora)
patch -p1 -i ../qt4-glibc-2.25.patch

# Fix build with ICU 59 (pld-linux)
patch -p1 -i ../qt4-icu59.patch

# Fix build with OpenSSL 1.1 (Debian + OpenMandriva)
patch -p1 -i ../qt4-openssl-1.1.patch

export LD_LIBRARY_PATH=${QT4PREFIX}/lib:/usr/lib64
export CXXFLAGS+=" -std=gnu++98" # Fix build with GCC 6
export PKG_CONFIG_PATH="/usr/lib64/pkgconfig"

LD_LIBRARY_PATH=${QT4PREFIX}/lib:/usr/lib64
CXXFLAGS+=" -std=gnu++98" # Fix build with GCC 6
PKG_CONFIG_PATH="/usr/lib64/pkgconfig"

CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64} -std=gnu++98" \
PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure -prefix $QT4PREFIX \
            -sysconfdir       /etc/xdg   \
            -libdir $QT4PREFIX/lib64     \
            -plugindir $QT4PREFIX/lib64/qt4/plugins \
            -importdir $QT4PREFIX/lib64/qt4/imports \
            -confirm-license             \
            -opensource                  \
            -release                     \
            -dbus-linked                 \
            -openssl-linked              \
            -system-sqlite               \
            -no-phonon                   \
            -no-phonon-backend           \
            -no-openvg                   \
            -nomake demos                \
            -nomake examples             \
            -nomake docs                 \
            -optimized-qmake             \
            -graphicssystem raster       \
            -silent                      \
            -no-rpath                    \
            -no-reduce-relocations       \
            -no-webkit
            
CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64} -std=gnu++98" \
PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} make PREFIX=${QT4PREFIX} install 

as_root PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} make PREFIX=${QT4PREFIX} install 

as_root rm -rf $QT4PREFIX/tests
as_root find $QT4PREFIX/lib64/pkgconfig -name "*.pc" -exec perl -pi -e "s, -L$PWD/?\S+,,g" {} \;

sudo sed -r -e '/^QMAKE_PRL_BUILD_DIR/d' -e 's/(QMAKE_PRL_LIBS =).*/\1/' /opt/qt4/lib64/libQt*.prl

wget https://aur.archlinux.org/cgit/aur.git/plain/gcc-5.patch?h=qtwebkit -O \
	gcc-5.patch
#wget https://aur.archlinux.org/cgit/aur.git/plain/fix-build-in-usr.patch?h=qtwebkit -O \
#	fix-build-in-usr.patch
wget https://aur.archlinux.org/cgit/aur.git/plain/qwebview.patch?h=qtwebkit -O \
	qwebview.patch
wget https://aur.archlinux.org/cgit/aur.git/plain/use-python2.patch?h=qtwebkit -O \
	use-python2.patch

#Install webkit seperately

mkdir qtwebkit-2.3.4 
pushd qtwebkit-2.3.4 
tar -xf ../../qtwebkit-2.3.4.tar.gz             
patch -Np0 -i ../gcc-5.patch
#patch -Np1 -i ../fix-build-in-usr.patch
#patch -Np1 -i ../qwebview.patch
patch -Np1 -i ../use-python2.patch

QTDIR=/opt/qt4 QT4PREFIX=/opt/qt4 PERL=/usr/bin/perl-64 \
CXXFLAGS+=" -std=gnu++98" CXX="g++ -std=gnu++98 -m64" \
PKG_CONFIG_PATH=/usr/lib64/pkgconfig/ Tools/Scripts/build-webkit --qt \
	--makeargs="qmake"  --prefix=/opt/qt4$QT4PREFIX

QTDIR=/opt/qt4 QT4PREFIX=/opt/qt4 PERL=/usr/bin/perl-64 CXXFLAGS+=" -std=gnu++98" CXX="g++ -std=gnu++98 -m64" PKG_CONFIG_PATH=/usr/lib64/pkgconfig as_root make -j9 -C WebKitBuild/Release install 

popd

QT4BINDIR=$QT4PREFIX/bin
export QT4BINDIR=$QT4PREFIX/bin

as_root install -v -Dm644 src/gui/dialogs/images/qtlogo-64.png \
                  /usr/share/pixmaps/qt4logo.png       &&

as_root install -v -Dm644 tools/assistant/tools/assistant/images/assistant-128.png \
                  /usr/share/pixmaps/assistant-qt4.png &&

as_root install -v -Dm644 tools/designer/src/designer/images/designer.png \
                  /usr/share/pixmaps/designer-qt4.png  &&

as_root install -v -Dm644 tools/linguist/linguist/images/icons/linguist-128-32.png \
                  /usr/share/pixmaps/linguist-qt4.png  &&

as_root install -v -Dm644 tools/qdbus/qdbusviewer/images/qdbusviewer-128.png \
                  /usr/share/pixmaps/qdbusviewer-qt4.png &&

as_root install -dm755 /usr/share/applications &&

as_root cat > /usr/share/applications/assistant-qt4.desktop << EOF
[Desktop Entry]
Name=Qt4 Assistant
Comment=Shows Qt4 documentation and examples
Exec=$QT4BINDIR/assistant
Icon=assistant-qt4.png
Terminal=false
Encoding=UTF-8
Type=Application
Categories=Qt;Development;Documentation;
EOF

as_root cat > /usr/share/applications/designer-qt4.desktop << EOF
[Desktop Entry]
Name=Qt4 Designer
Comment=Design GUIs for Qt4 applications
Exec=$QT4BINDIR/designer
Icon=designer-qt4.png
MimeType=application/x-designer;
Terminal=false
Encoding=UTF-8
Type=Application
Categories=Qt;Development;
EOF

as_root cat > /usr/share/applications/linguist-qt4.desktop << EOF
[Desktop Entry]
Name=Qt4 Linguist
Comment=Add translations to Qt4 applications
Exec=$QT4BINDIR/linguist
Icon=linguist-qt4.png
MimeType=text/vnd.trolltech.linguist;application/x-linguist;
Terminal=false
Encoding=UTF-8
Type=Application
Categories=Qt;Development;
EOF

as_root cat > /usr/share/applications/qdbusviewer-qt4.desktop << EOF
[Desktop Entry]
Name=Qt4 QDbusViewer
GenericName=D-Bus Debugger
Comment=Debug D-Bus applications
Exec=$QT4BINDIR/qdbusviewer
Icon=qdbusviewer-qt4.png
Terminal=false
Encoding=UTF-8
Type=Application
Categories=Qt;Development;Debugger;
EOF

as_root cat > /usr/share/applications/qtconfig-qt4.desktop << EOF
[Desktop Entry]
Name=Qt4 Config
Comment=Configure Qt4 behavior, styles, fonts
Exec=$QT4BINDIR/qtconfig
Icon=qt4logo.png
Terminal=false
Encoding=UTF-8
Type=Application
Categories=Qt;Settings;
EOF

for file in moc uic rcc qmake lconvert lrelease lupdate; do
  as_root ln -sfrvn $QT4BINDIR/$file /usr/bin/$file-qt4
done

as_root export LD_LIBRARY_PATH=/lib:/lib64:/usr/lib/:/usr/lib64:/usr/local/lib/:/usr/local/lib64:/opt/qt4/lib64:/opt/jdk/lib

as_root ldconfig -v

as_root cat > /etc/profile.d/qt4.sh << "EOF"
# Begin /etc/profile.d/qt4.sh

QT4DIR=/opt/qt4
QTDIR=$QT4DIR
export QT4DIR QTDIR

# End /etc/profile.d/qt4.sh
EOF

as_root cat >> /etc/ld.so.conf << EOF
# Begin Qt addition

/opt/qt4/lib

# End Qt addition
EOF

ldconfig

as_root cat > /etc/profile.d/qt4.sh << "EOF"
# Begin /etc/profile.d/qt4.sh

QT4DIR=/opt/qt4
QTDIR=$QT4DIR

pathappend $QT4DIR/bin           PATH
pathappend $QT4DIR/lib/pkgconfig PKG_CONFIG_PATH

export QT4DIR QTDIR

# End /etc/profile.d/qt4.sh
EOF

as_root cat > /usr/bin/setqt4 << 'EOF'
if [ "x$QT5DIR" != "x/usr" ] && [ "x$QT5DIR" != "x" ]; then pathremove  $QT5DIR/bin; fi

if [ "x$QT4DIR" != "x/usr" ]; then pathprepend $QT4DIR/bin; fi
echo $PATH
EOF

as_root cat > /usr/bin/setqt5 << 'EOF'
if [ "x$QT4DIR" != "x/usr" ] && [ "x$QT4DIR" != "x" ]; then pathremove  $QT4DIR/bin; fi
if [ "x$QT5DIR" != "x/usr" ]; then pathprepend $QT5DIR/bin; fi
echo $PATH
EOF

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf qt4
