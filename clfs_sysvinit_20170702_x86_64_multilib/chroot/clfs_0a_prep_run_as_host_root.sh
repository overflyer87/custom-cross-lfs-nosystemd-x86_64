#!/bin/bash

function checkSanity() {

echo "Does your system fullfil the requirements to build CLFS?: [Y/N]"
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

#=======================
#RUN AS HOST'S root
#=======================

cat > version-check.sh << "EOF"
#!/bin/bash

# Simple script to list version numbers of critical development tools

bash --version | head -n1 | cut -d" " -f2-4
echo -n "Binutils: "; ld --version | head -n1 | cut -d" " -f3-
bison --version | head -n1
bzip2 --version 2>&1 < /dev/null | head -n1 | cut -d" " -f1,6-
echo -n "Coreutils: "; chown --version | head -n1 | cut -d")" -f2
diff --version | head -n1
find --version | head -n1
gawk --version | head -n1
gcc --version | head -n1
g++ --version | head -n1
ldd $(which ${SHELL}) | grep libc.so | cut -d ' ' -f 3 | ${SHELL} | head -n 1 | cut -d ' ' -f 1-7
grep --version | head -n1
gzip --version | head -n1
make --version | head -n1
tic -V
patch --version | head -n1
sed --version | head -n1
tar --version | head -n1
makeinfo --version | head -n1
xz --version | head -n1
echo 'int main(){}' | gcc -v -o /dev/null -x c - > dummy.log 2>&1
if ! grep -q ' error' dummy.log; then
  echo "Compilation successful" && rm dummy.log
else
  echo 1>&2  "Compilation FAILED - more development packages may need to be \
installed. If you like, you can also view dummy.log for more details."
fi
EOF

echo " "
bash version-check.sh 2>errors.log &&
[ -s errors.log ] && echo -e "\nThe following packages could not be found:\n$(cat errors.log)"
echo " "

checkSanity

echo " "

CLFS=/mnt/clfs
CLFSUSER=clfs
CLFSHOME=${CLFS}/home
CLFSSOURCES=${CLFS}/sources
CLFSTOOLS=${CLFS}/tools
CLFSCROSSTOOLS=${CLFS}/cross-tools
CLFSFILESYSTEM=ext4
CLFSROOTDEV=/dev/sda4
CLFSHOMEDEV=/dev/sda5

export CLFS=/mnt/clfs
export CLFSHOME=/mnt/clfs/home
export FILESYSTEM=ext4
export CLFSROOTDEV=/dev/sda4
export CLFSHOMEDEV=/dev/sda5
export CLFSSOURCES=/mnt/clfs/sources
export CLFSTOOLS=/mnt/clfs/tools
export CLFSCROSSTOOLS=/mnt/clfs/cross-tools
export CLFSUSER=clfs

cat >> /root/.bashrc << EOF
export CLFS=/mnt/clfs
export CLFSHOME=/mnt/clfs/home
export FILESYSTEM=ext4
export CLFSROOTDEV=/dev/sda4
export CLFSHOMEDEV=/dev/sda5
export CLFSSOURCES=/mnt/clfs/sources
export CLFSTOOLS=/mnt/clfs/tools
export CLFSCROSSTOOLS=/mnt/clfs/cross-tools
export CLFSUSER=clfs
EOF

echo " "
mkfs.${CLFSFILESYSTEM} -q ${CLFSROOTDEV}
echo " "
mkfs.${CLFSFILESYSTEM} -q ${CLFSHOMEDEV}
echo " "

mkdir -pv $CLFS
mount -v ${CLFSROOTDEV} ${CLFS}
mkdir -pv $CLFSHOME
mkdir -v $CLFSHOME
mount -v ${CLFSHOMEDEV} ${CLFSHOME}

mkdir -v ${CLFSSOURCES}
chmod -v a+wt ${CLFSSOURCES}

echo " "
#wget -i ../dl.list -P ${CLFSSOURCES}
cp sources/* ${CLFSSOURCES}

wget http://ftp.gnu.org/gnu/binutils/binutils-2.28.tar.bz2 -P ${CLFSSOURCES}
wget ftp://gcc.gnu.org/pub/gcc/releases/gcc-7.1.0/gcc-7.1.0.tar.bz2 -P ${CLFSSOURCES}
wget https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.12.2.tar.xz -P ${CLFSSOURCES}

echo " "
echo "source packages have been copied"
echo " "

install -dv ${CLFSTOOLS}
install -dv ${CLFSCROSSTOOLS}
ln -sv ${CLFSCROSSTOOLS} /
ln -sv ${CLFSTOOLS} / 

groupadd ${CLFSUSER}
useradd -s /bin/bash -g ${CLFSUSER} -d /home/${CLFSUSER} ${CLFSUSER}
mkdir -pv /home/${CLFSUSER}
chown -v ${CLFSUSER}:${CLFSUSER} /home/${CLFSUSER}
chown -v ${CLFSUSER}:${CLFSUSER} ${CLFSTOOLS}
chown -v ${CLFSUSER}:${CLFSUSER} ${CLFSCROSSTOOLS}

echo " "

chown -R ${CLFSUSER}:${CLFSUSER} ${CLFSSOURCES}

echo " "
echo "Sources are owned by clfs:clfs now"
echo " "

cp -v clfs_*.sh /home/${CLFSUSER}
cp -v clfs_*.sh ${CLFS}
chown -v ${CLFSUSER}:${CLFSUSER} /home/clfs

echo " "
echo "Check the screen output if everything looks fine"
echo "Compare it to the instructions of the book"
echo " "
echo "Execute Script #0b"
echo "To login as unprivilidged CLFS user"
echo " "
