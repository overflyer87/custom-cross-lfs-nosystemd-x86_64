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


#Gvfs
wget http://ftp.gnome.org/pub/gnome/sources/gvfs/1.32/gvfs-1.32.1.tar.xz
	gvfs-1.32.1.tar.xz 
#You need to recompile udev with this patch in order
#For Gvfs to support gphoto2
wget https://sourceforge.net/p/gphoto/patches/_discuss/thread/9180a667/9902/attachment/libgphoto2.udev-136.patch -O \
	libgphoto2.udev-136.patch

mkdir gvfs && tar xf gvfs-*.tar.* -C gvfs --strip-components 1
cd gvfs

LD_LIB_PATH="/usr/lib64" LIBRARY_PATH="/usr/lib64" CPPFLAGS="-I/usr/include" \
LD_LIBRARY_PATH="/usr/lib64" CC="gcc ${BUILD64} -L/usr/lib64 -lacl" \
CXX="g++ ${BUILD64} -lacl" USE_ARCH=64 \
PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
	--libdir=/usr/lib64 \
	--disable-static    \
	--sysconfdir=/etc    \
    --disable-gtk-doc \
    --disable-gtk-doc-pdf \
    --disable-gtk-doc-html \
    --disable-libsystemd-login \
    --disable-admin \
    --disable-gphoto2 \
    --disable-documentation
    
sudo ln -sfv /usr/lib64/libacl.so /lib64/
sudo ln -sfv /usr/lib64/libattr.so /lib64/
    
LD_LIB_PATH="/usr/lib64" LIBRARY_PATH="/usr/lib64" CPPFLAGS="-I/usr/include" \
LD_LIBRARY_PATH="/usr/lib64" CC="gcc ${BUILD64} -L/usr/lib64 -lacl" \
CXX="g++ ${BUILD64} -lacl" USE_ARCH=64 \
PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf gvfs

#libevent
wget https://github.com/libevent/libevent/releases/download/release-2.1.8-stable/libevent-2.1.8-stable.tar.gz -O \
	libevent-2.1.8-stable.tar.gz

mkdir libevent && tar xf libevent-*.tar.* -C libevent --strip-components 1
cd libevent

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
	--libdir=/usr/lib64 \
	--disable-static    \
	--sysconfdir=/etc    

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf libevent

#MariaDB
wget https://downloads.mariadb.org/interstitial/mariadb-10.2.7/source/mariadb-10.2.7.tar.gz
	mariadb-10.2.7.tar.gz

mkdir mariadb && tar xf mariadb-*.tar.* -C mariadb --strip-components 1
cd mariadb

sudo groupadd -g 40 mysql &&
sudo useradd -c "MySQL Server" -d /srv/mysql -g mysql -s /bin/false -u 40 mysql

sed -i "s@data/test@\${INSTALL_MYSQLTESTDIR}@g" sql/CMakeLists.txt &&
sed -i '/void..coc_malloc/{s/char ./&x/; s/int/& y/}' mysys_ssl/openssl.c &&

mkdir build 
cd build    

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} cmake -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=/usr                     \
      -LIBRARY_OUTPUT_PATH=/usr/lib64               \
      -DINSTALL_DOCDIR=share/doc/mariadb-10.2.7       \
      -DINSTALL_DOCREADMEDIR=share/doc/mariadb-10.2.7 \
      -DINSTALL_MANDIR=share/man                      \
      -DINSTALL_MYSQLSHAREDIR=share/mysql             \
      -DINSTALL_MYSQLTESTDIR=share/mysql/test         \
      -DINSTALL_PLUGINDIR=lib/mysql/plugin            \
      -DINSTALL_SBINDIR=sbin                          \
      -DINSTALL_SCRIPTDIR=bin                         \
      -DINSTALL_SQLBENCHDIR=share/mysql/bench         \
      -DINSTALL_SUPPORTFILESDIR=share/mysql           \
      -DMYSQL_DATADIR=/srv/mysql                      \
      -DMYSQL_UNIX_ADDR=/run/mysqld/mysqld.sock       \
      -DWITH_EXTRA_CHARSETS=complex                   \
      -DWITH_EMBEDDED_SERVER=ON                       \
      -DSKIP_TESTS=ON                                 \
      -DTOKUDB_OK=0                                   \
      ..
      
PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

sudo install -v -dm 755 /etc/mysql &&
sudo bash -c 'cat > /etc/mysql/my.cnf << "EOF"
# Begin /etc/mysql/my.cnf

# The following options will be passed to all MySQL clients
[client]
#password       = your_password
port            = 3306
socket          = /run/mysqld/mysqld.sock

# The MySQL server
[mysqld]
port            = 3306
socket          = /run/mysqld/mysqld.sock
datadir         = /srv/mysql
skip-external-locking
key_buffer_size = 16M
max_allowed_packet = 1M
sort_buffer_size = 512K
net_buffer_length = 16K
myisam_sort_buffer_size = 8M

# Don't listen on a TCP/IP port at all.
skip-networking

# required unique id between 1 and 2^32 - 1
server-id       = 1

# Uncomment the following if you are using BDB tables
#bdb_cache_size = 4M
#bdb_max_lock = 10000

# InnoDB tables are now used by default
innodb_data_home_dir = /srv/mysql
innodb_log_group_home_dir = /srv/mysql
# All the innodb_xxx values below are the default ones:
innodb_data_file_path = ibdata1:12M:autoextend
# You can set .._buffer_pool_size up to 50 - 80 %
# of RAM but beware of setting memory usage too high
innodb_buffer_pool_size = 128M
innodb_log_file_size = 48M
innodb_log_buffer_size = 16M
innodb_flush_log_at_trx_commit = 1
innodb_lock_wait_timeout = 50

[mysqldump]
quick
max_allowed_packet = 16M

[mysql]
no-auto-rehash
# Remove the next comment character if you are not familiar with SQL
#safe-updates

[isamchk]
key_buffer = 20M
sort_buffer_size = 20M
read_buffer = 2M
write_buffer = 2M

[myisamchk]
key_buffer_size = 20M
sort_buffer_size = 20M
read_buffer = 2M
write_buffer = 2M

[mysqlhotcopy]
interactive-timeout

# End /etc/mysql/my.cnf
EOF'

sudo mysql_install_db --basedir=/usr --datadir=/srv/mysql --user=mysql &&
sudo chown -R mysql:mysql /srv/mysql

sudo install -v -m755 -o mysql -g mysql -d /run/mysqld &&
sudo mysqld_safe --user=mysql 2>&1 >/dev/null &

sudo mysqladmin -u root password

sudo mysqladmin -p shutdown

cd${CLFSSOURCES}/blfs-bootscripts
sudo make install-mysql

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf mariadb

#libsigc++
wget http://ftp.gnome.org/pub/gnome/sources/libsigc++/2.10/libsigc++-2.10.0.tar.xz -O \
	libsigc++-2.10.0.tar.xz

mkdir libsigcpp && tar xf libsigc++-*.tar.* -C libsigcpp --strip-components 1
cd libsigcpp

sed -e '/^libdocdir =/ s/$(book_name)/libsigc++-2.10.0/' -i docs/Makefile.in

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
	--libdir=/usr/lib64 \
	--disable-static    

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

make check
checkBuiltPackage

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf libsigcpp

#Glibmm
wget http://ftp.gnome.org/pub/gnome/sources/glibmm/2.52/glibmm-2.52.0.tar.xz -O \
	glibmm-2.52.0.tar.xz
	
mkdir glibmm && tar xf glibmm-*.tar.* -C glibmm --strip-components 1
cd glibmm

sed -e '/^libdocdir =/ s/$(book_name)/glibmm-2.52.0/' \
    -i docs/Makefile.in

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
	--libdir=/usr/lib64 \
	--disable-static    

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

make check
checkBuiltPackage

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf glibmm

#Atkmm
wget http://ftp.gnome.org/pub/gnome/sources/atkmm/2.24/atkmm-2.24.2.tar.xz -O \
	atkmm-2.24.2.tar.xz

mkdir atkmm && tar xf atkmm-*.tar.* -C atkmm --strip-components 1
cd atkmm

sed -e '/^libdocdir =/ s/$(book_name)/atkmm-2.24.2/' \
    -i doc/Makefile.in

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
	--libdir=/usr/lib64 \
	--disable-static    

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

make check
checkBuiltPackage

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf atkmm

#Cairomm
wget http://cairographics.org/releases/cairomm-1.12.2.tar.gz -O \
	cairomm-1.12.2.tar.gz

mkdir cairomm && tar xf cairomm-*.tar.* -C cairomm --strip-components 1
cd cairomm

sed -e '/^libdocdir =/ s/$(book_name)/cairomm-1.12.2/' \
    -i docs/Makefile.in

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
	--libdir=/usr/lib64 \
	--disable-static    

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

make check
checkBuiltPackage

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf cairomm

#Pangomm
wget http://ftp.gnome.org/pub/gnome/sources/pangomm/2.40/pangomm-2.40.1.tar.xz -O \
	pangomm-2.40.1.tar.xz

mkdir pangomm && tar xf pangomm-*.tar.* -C pangomm --strip-components 1
cd pangomm

sed -e '/^libdocdir =/ s/$(book_name)/pangomm-2.40.1/' \
    -i docs/Makefile.in

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
	--libdir=/usr/lib64 \
	--disable-static    

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

make check
checkBuiltPackage

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf pangomm

#Gtkmm3
wget http://ftp.gnome.org/pub/gnome/sources/gtkmm/3.22/gtkmm-3.22.1.tar.xz -O \
	gtkmm-3.22.1.tar.xz

mkdir gtkmm && tar xf gtkmm-3*.tar.* -C gtkmm --strip-components 1
cd gtkmm

sed -e '/^libdocdir =/ s/$(book_name)/gtkmm-3.22.1/' \
    -i docs/Makefile.in

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
	--libdir=/usr/lib64 \
	--disable-static    

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

make check
checkBuiltPackage

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf gtkmm

#gtkmm2
wget http://ftp.gnome.org/pub/gnome/sources/gtkmm/2.24/gtkmm-2.24.5.tar.xz -O \
	gtkmm-2.24.5.tar.xz

mkdir gtkmm-2 && tar xf gtkmm-2*.tar.* -C gtkmm-2 --strip-components 1
cd gtkmm-2

sed -e '/^libdocdir =/ s/$(book_name)/gtkmm-3.22.1/' \
    -i docs/Makefile.in

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
	--libdir=/usr/lib64 \
	--disable-static    

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

make check
checkBuiltPackage

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf gtkmm-2

#xmlto
wget http://anduin.linuxfromscratch.org/BLFS/xmlto/xmlto-0.0.28.tar.bz2 -O \
	xmlto-0.0.28.tar.bz2

mkdir xmlto && tar xf xmlto-*.tar.* -C xmlto --strip-components 1
cd xmlto

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
LINKS="/usr/bin/links" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
	--libdir=/usr/lib64 \

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf xmlto

#xdg-su
wget https://github.com/tarakbumba/xdg-su/archive/xdg-su-1.2.3.tar.gz -O \
	xdg-su-1.2.3.tar.gz

mkdir xdg-su && tar xf xdg-su-*.tar.* -C xdg-su --strip-components 1
cd xdg-su

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
	--libdir=/usr/lib64 
	
sed -i 's/http\:\/\/www\.oasis\-open\.org\/docbook\/xml\/4.1.2\/docbookx.dtd/\/usr\/share\/yelp\/dtd\/docbookx.dtd/' scripts/desc/xdg-su.xml
sed -i 's/\/usr\/bin\/xmlto/\/usr\/bin\/xmlto -vv --skip-validation --noclean --searchpath=\/usr\/share\/xml\/docbook\/xsl-stylesheets-1.79.1\/html/' scripts/Makefile
sed -i 's/http\:\/\/docbook.sourceforge.net\/release\/xsl\/current\/manpages\/docbook.xsl/\/usr\/share\/xml\/docbook\/xsl-stylesheets-1.79.1\/manpages\/docbook\.xsl/' scripts/desc/xdg-su.xml

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64
sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf xdg-su

#libgksu
wget http://people.debian.org/~kov/gksu/libgksu-2.0.12.tar.gz -O \
	libgksu-2.0.12.tar.gz

mkdir libgksu && tar xf libgksu-*.tar.* -C libgksu --strip-components 1
cd libgksu

LD_LIB_PATH="/usr/lib64" LD_LIBRARY_PATH=/usr/lib64/ \
LIBRARY_PATH="/usr/lib64/" \
PKG_CONFIG_PATH=/usr/lib64/pkgconfig \
CC="gcc -m64 -lglib-2.0 -lgtk-x11-2.0" USE_ARCH=64 \
CXX="g++ ${BUILD64} -lglib-2.0 -lgtk-x11" ./configure --prefix=/usr \
	--libdir=/usr/lib64 \
	--disable-static  \
	--disable-gtk-doc \
	--without-html-dir

echo "#first fix the 8 spaces infront of the if in line 732. make it a TAB!"
nano -c Makefile

LD_LIB_PATH="/usr/lib64" LD_LIBRARY_PATH=/usr/lib64/ \
LIBRARY_PATH="/usr/lib64/" \
PKG_CONFIG_PATH=/usr/lib64/pkgconfig \
CC="gcc -m64 -lglib-2.0 -lgtk-x11-2.0" USE_ARCH=64 \
CXX="g++ ${BUILD64} -lglib-2.0 -lgtk-x11" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

sudo mv libgksu/gksu-run-helper /usr/bin/
#sudo mv libgksu/test-gksu /usr/bin/
sudo mv libgksu/gksu-properties /usr/bin/

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf libgksu

#gksu
wget https://people.debian.org/~kov/gksu/gksu-2.0.2.tar.gz -O \
	gksu-2.0.2.tar.gz

mkdir gksu && tar xf gksu-*.tar.* -C gksu --strip-components 1
cd gksu

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
	--libdir=/usr/lib64 \
	--disable-static    \
	--disable-gtk-doc   \
	--without-html-dir \
	--disable-nautilus-extension

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

make check
checkBuiltPackage

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf gksu

#Gparted
wget http://downloads.sourceforge.net/gparted/gparted-0.28.1.tar.gz -O \
	gparted-0.28.1.tar.gz
	
mkdir gparted && tar xf gparted-*.tar.* -C gparted --strip-components 1
cd gparted

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
	--libdir=/usr/lib64 \
	--disable-doc \
	--disable-static \
	--enable-libparted-dmraid

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf gparted

#libtirpc
wget http://downloads.sourceforge.net/project/libtirpc/libtirpc/1.0.1/libtirpc-1.0.1.tar.bz2 -O \
	libtirpc-1.0.1.tar.bz2

mkdir libtirpc && tar xf libtirpc-*.tar.* -C libtirpc --strip-components 1
cd libtirpc

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr \
	--libdir=/usr/lib64 \
	--sysconfdir=/etc \
	--disable-static \
	--disable-gssapi

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install
sudo mv -v /usr/lib64/libtirpc.so.* /lib64
sudo ln -sfv ../../lib64/libtirpc.so.3.0.0 /usr/lib64/libtirpc.so

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf libtirpc

#Parse::Yapp-1.2
wget http://www.cpan.org/authors/id/W/WB/WBRASWELL/Parse-Yapp-1.2.tar.gz -O \
	Parse-Yapp-1.2.tar.gz
	
mkdir Parse-Yapp && tar xf Parse-Yapp-*.tar.* -C Parse-Yapp --strip-components 1
cd Parse-Yapp

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} perl-64 Makefile.PL PREFIX=/usr 
CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} make PREFIX=/usr LIBDIR=/usr/lib64
make test
checkBuiltPackage

sudo make install PREFIX=/usr LIBDIR=/usr/lib64

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf Parse-Yapp

#PyCrypto
wget https://pypi.python.org/packages/60/db/645aa9af249f059cc3a368b118de33889219e0362141e75d4eaf6f80f163/pycrypto-2.6.1.tar.gz -O \
	pycrypto-2.6.1.tar.gz

mkdir pycrypto && tar xf pycrypto-*.tar.* -C pycrypto --strip-components 1
cd pycrypto

sudo python2.7 setup.py build 
sudo python2.7 setup.py install --verbose --prefix=/usr/lib64 --install-lib=/usr/lib64/python2.7/site-packages --optimize=1
sudo python3.6 setup.py build
sudo python3.6 setup.py install --verbose --prefix=/usr/lib64 --install-lib=/usr/lib64/python3.6/site-packages --optimize=1

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf pycrypto

#Cyrus SASL
wget ftp://ftp.cyrusimap.org/cyrus-sasl/cyrus-sasl-2.1.26.tar.gz -O \
	cyrus-sasl-2.1.26.tar.gz

wget http://www.linuxfromscratch.org/patches/blfs/svn/cyrus-sasl-2.1.26-fixes-3.patch -O \
 Cyrus-sasl-2.1.26-fixes-3.patch
 
wget http://www.linuxfromscratch.org/patches/blfs/svn/cyrus-sasl-2.1.26-openssl-1.1.0-1.patch -O \
	Cyrus-Sasl-2.1.26-openssl-1.1.0-1.patch

mkdir cyrus && tar xf cyrus-*.tar.* -C cyrus --strip-components 1
cd cyrus

patch -Np1 -i ../Cyrus-sasl-2.1.26-fixes-3.patch
patch -Np1 -i ../Cyrus-Sasl-2.1.26-openssl-1.1.0-1.patch

autoreconf -fi

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" ./configure --prefix=/usr \
            --sysconfdir=/etc    \
            --enable-auth-sasldb \
            --with-dbpath=/var/lib/sasl/sasldb2 \
            --with-saslauthd=/var/run/saslauthd \
            --libdir=/usr/lib64
            
PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo install -v -dm755 /usr/share/doc/cyrus-sasl-2.1.26
sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/blfs-bootscripts
sudo make install-saslauthd

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf cyrus

#openLDAP
wget ftp://ftp.openldap.org/pub/OpenLDAP/openldap-release/openldap-2.4.45.tgz -O \
	openldap-2.4.45.tgz

wget http://www.linuxfromscratch.org/patches/blfs/svn/openldap-2.4.45-consolidated-1.patch -O \
	Openldap-2.4.45-consolidated-1.patch

mkdir openldap && tar xf openldap-*.tgz -C openldap --strip-components 1
cd openldap

sudo groupadd -g 83 ldap 
sudo useradd  -c "OpenLDAP Daemon Owner" \
         -d /var/lib/openldap -u 83 \
         -g ldap -s /bin/false ldap

patch -Np1 -i ../Openldap-2.4.45-consolidated-1.patch
autoreconf

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr  \
            --sysconfdir=/etc     \
            --localstatedir=/var  \
            --libdir=/usr/lib64   \
            --libexecdir=/usr/lib64 \
            --disable-static      \
            --disable-debug       \
            --with-tls=openssl    \
            --with-cyrus-sasl     \
            --enable-dynamic      \
            --enable-crypt        \
            --enable-spasswd      \
            --enable-slapd        \
            --enable-modules      \
            --enable-rlookups     \
            --enable-backends=mod \
            --disable-ndb         \
            --disable-sql         \
            --disable-shell       \
            --disable-bdb         \
            --disable-hdb         \
            --enable-overlays=mod 

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make depend PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

sudo install -v -dm700 -o ldap -g ldap /var/lib64/openldap    

sudo install -v -dm700 -o ldap -g ldap /etc/openldap/slapd.d
sudo chmod   -v    640     /etc/openldap/slapd.{conf,ldif}  
sudo chown   -v  root:ldap /etc/openldap/slapd.{conf,ldif}  

cd ${CLFSSOURCES}/blfs-bootscripts
sudo make install-slapd

sudo /etc/rc.d/init.d/slapd start
sudo ldapsearch -x -b '' -s base '(objectclass=*)' namingContexts

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf openldap

#Samba
wget https://download.samba.org/pub/samba/stable/samba-4.6.6.tar.gz -O \
	samba-4.6.6.tar.gz

mkdir samba && tar xf samba-*.tar.* -C samba --strip-components 1
cd samba

echo "^samba4.rpc.echo.*on.*ncacn_np.*with.*object.*nt4_dc" >> selftest/knownfail

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr  \
        --sysconfdir=/etc     \
        --localstatedir=/var  \
        --libdir=/usr/lib64   \
        --with-piddir=/run/samba           \
        --with-pammodulesdir=/lib64/security \
    	--enable-fhs                       \
    	--without-ad-dc                    \
    	--without-systemd                  \
    	--enable-selftest     \
    	--without-ldap        \
    	--without-ads

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

sudo mv -v /usr/lib64/libnss_win{s,bind}.so*   /lib64                      
sudo ln -v -sf ../../lib64/libnss_winbind.so.2 /usr/lib64/libnss_winbind.so 
sudo ln -v -sf ../../lib64/libnss_wins.so.2    /usr/lib64/libnss_wins.so    

sudo install -v -m644    examples/smb.conf.default /etc/samba 

sudo mkdir -pv /etc/openldap/schema                        

sudo install -v -m644    examples/LDAP/README              \
                    /etc/openldap/schema/README.LDAP  

sudo install -v -m644    examples/LDAP/samba*              \
                    /etc/openldap/schema              

sudo install -v -m755    examples/LDAP/{get*,ol*} \
                    /etc/openldap/schema

sudo ln -v -sf /usr/bin/smbspool /usr/lib/cups/backend/smb

sudo bash -c 'cat > /etc/samba/smb.con << "EOF"
[global]
workgroup = WORKGROUP
dos charset = cp850
unix charset = UTF-8
EOF'

sudo groupadd -g 99 nogroup &&
sudo useradd -c "Unprivileged Nobody" -d /dev/null -g nogroup \
    -s /bin/false -u 99 nobody


cd ${CLFSSOURCES}/blfs-bootscripts
sudo make install-samba
sudo make install-winbindd
sudo /etc/rc.d/init.d/samba start
sudo /etc/rc.d/init.d/winbind start

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf samba

#libndp
wget http://libndp.org/files/libndp-1.6.tar.gz -O \
	libndp-1.6.tar.gz
	
mkdir libndp && tar xf libndp-*.tar.* -C libndp --strip-components 1
cd libndp

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr  \
            --sysconfdir=/etc     \
            --localstatedir=/var  \
            --libdir=/usr/lib64   \
            --disable-static

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf libndp

#libnl
wget https://github.com/thom311/libnl/releases/download/libnl3_3_0/libnl-3.3.0.tar.gz -O \
	libnl-3.3.0.tar.gz

mkdir libnl && tar xf libnl-*.tar.* -C libndp --strip-components 1
cd libnl

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr  \
            --sysconfdir=/etc     \
            --localstatedir=/var  \
            --libdir=/usr/lib64   \
            --disable-static

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf libnl

#ConsoleKit
#elogind
wget https://github.com/wingo/elogind/archive/v219.12.tar.gz -O \
	elogind-219.12.tar.gz

mkdir elogind && tar xf elogind-*.tar.* -C elogind --strip-components 1
cd elogind

autoreconf -fi 
intltoolize --force 

CPPFLAGS="-I/usr/include" LD_LIBRARY_PATH="/usr/lib64" \
LD_LIB_PATH="/usr/lib64" LIBRARY_PATH="/usr/lib64" \
CC="gcc ${BUILD64} -lrt" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr  \
            --sysconfdir=/etc     \
            --localstatedir=/var  \
            --libdir=/usr/lib64   \
            --disable-static      \
            --libexecdir=/usr/lib64   \
            --enable-split-usr \
            --disable-gtk-doc \
            --disable-tests   \
            --disable-gtk-pdf \
            --disable-gtk-html \
            --enable-pam \
            --with-pamlibdir=/lib64/security \
            --with-pamconfdir=/etc/pam.d \
            --disable-static \
            --enable-shared \
            --disable-manpages

CPPFLAGS="-I/usr/include" LD_LIBRARY_PATH="/usr/lib64" \
LD_LIB_PATH="/usr/lib64" LIBRARY_PATH="/usr/lib64" \
PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64} -lrt" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install
sudo mkdir -pv /run/systemd
sudo chmod 755 /run/systemd

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf elogind

#Iptables
wget http://www.netfilter.org/projects/iptables/files/iptables-1.6.1.tar.bz2 -O \
	iptables-1.6.1.tar.bz2

mkdir iptables && tar xf iptables-*.tar.* -C iptables --strip-components 1
cd iptables

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr  \
            --sysconfdir=/etc     \
            --localstatedir=/var  \
            --libdir=/lib64       \
            --sbindir=/sbin       \
            --enable-libipq       \
            --disable-nftables    \
            --with-xtlibdir=/lib64/xtables

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install
sudo ln -sfv ../../sbin/xtables-multi /usr/bin/iptables-xml


for file in ip4tc ip6tc ipq iptc xtables
do
  sudo mv -v /usr/lib64/lib${file}.so.* /lib64 &&
  sudo ln -sfv ../../lib64/$(readlink /usr/lib64/lib${file}.so) /usr/lib64/lib${file}.so
done

cd ${CLFSSOURCES}/blfs-bootscripts
sudo make install-iptables

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf iptables

#slang
wget http://www.jedsoft.org/releases/slang/slang-2.3.1.tar.bz2 -O 
	slang-2.3.1.tar.bz2

mkdir slang && tar xf slang-*.tar.* -C slang --strip-components 1
cd slang

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr  \
            --sysconfdir=/etc     \
            --with-readline=gnu  \
            --libdir=/usr/lib64
            
PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make -j1 PREFIX=/usr LIBDIR=/usr/lib64

sudo make -j1 PREFIX=/usr LIBDIR=/usr/lib64 install_doc_dir=/usr/share/doc/slang-2.3.1   \
     SLSH_DOC_DIR=/usr/share/doc/slang-2.3.1/slsh install-all

sudo chmod -v 755 /usr/lib64/libslang.so.2.3.1 
sudo chmod -v 755 /usr/lib64/slang/v2/modules/*.so

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf slang

#newt
wget https://releases.pagure.org/newt/newt-0.52.20.tar.gz -O \
	newt-0.52.20.tar.gz  

mkdir newt && tar xf newt-*.tar.* -C newt --strip-components 1
cd newt

sed -e 's/^LIBNEWT =/#&/' \
    -e '/install -m 644 $(LIBNEWT)/ s/^/#/' \
    -e 's/$(LIBNEWT)/$(LIBNEWTSONAME)/g' \
    -i Makefile.in                
    
CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr  \
            --sysconfdir=/etc     \
            --libdir=/usr/lib64   \
            --with-gpm-support

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf newt

#NetworkManager
wget http://ftp.gnome.org/pub/gnome/sources/NetworkManager/1.8/NetworkManager-1.8.0.tar.xz -O \
	NetworkManager-1.8.0.tar.xz

mkdir NetworkManager && tar xf NetworkManager-*.tar.* -C NetworkManager --strip-components 1
cd NetworkManager

CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" \
USE_ARCH=64 PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} ./configure --prefix=/usr  \
            --sysconfdir=/etc     \
            --libdir=/usr/lib64   
	    --localstatedir=/var           \
            --with-nmtui                   \
            --disable-ppp                  \
            --disable-json-validation      \
            --with-systemdsystemunitdir=no \
            --without-systemd \
            --disable-systemd \
            --disable-gtk-doc \
            --disable-manpages \
            --disable-gtk-doc-pdf \
            --disable-gtk-doc-html

PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} CC="gcc ${BUILD64}" USE_ARCH=64 \
CXX="g++ ${BUILD64}" make PREFIX=/usr LIBDIR=/usr/lib64

sudo make PREFIX=/usr LIBDIR=/usr/lib64 install

sudo bash -c 'cat >> /etc/NetworkManager/NetworkManager.conf << "EOF"
[main]
plugins=keyfile
EOF'

sudo groupadd -fg 86 netdev 
sudo /usr/sbin/usermod -a -G netdev overflyer

sudo bash -c 'cat > /usr/share/polkit-1/rules.d/org.freedesktop.NetworkManager.rules << "EOF"
polkit.addRule(function(action, subject) {
    if (action.id.indexOf("org.freedesktop.NetworkManager.") == 0 && subject.isInGroup("netdev")) {
        return polkit.Result.YES;
    }
});
EOF'

cd ${CLFSSOURCES}/blfs-bootscripts
sudo make install-networkmanager
sudo /etc/rc.d/init.d/networkmanager start

cd ${CLFSSOURCES}/xc/mate
checkBuiltPackage
rm -rf NetworkManager
