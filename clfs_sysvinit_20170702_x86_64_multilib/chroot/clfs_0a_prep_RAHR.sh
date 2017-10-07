#!/bin/bash

function checkSanity() {
echo " "
echo "Does your system fullfil the requirements to build CLFS?: [Y/N]"
while read -n1 -r -p "" && [[ $REPLY != q ]]; do
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

#=======================
#RUN AS HOST'S root
#=======================

printf "\033c"

cat > version-check.sh << "EOF"
#!/bin/bash

# Simple script to list version numbers of critical development tools

echo " "
bash version-check.sh 2>errors.log &&
[ -s errors.log ] && echo -e "\nThe following packages could not be found:\n$(cat errors.log)"
echo " "

checkSanity

echo " "

printf "\033c"

echo "Starting interactive setting of vital variables through user input..."
echo " " 
echo "Here is the output of lsblk"
echo "This should help you with chosing the partitions"

echo " "
lsblk
echo " "

echo "What drive do you want to be your ROOT partition? Type in form of [/dev/sdX]. Make no typos. There is no failsafe, yet!"
echo " "

read clfsrootdev
printf "\033c"

echo " "
lsblk
echo " "

echo "Your CLFS ROOT partition is $clfsrootdev. It will be mounted to /mnt/clfs"
echo " "
echo " "

echo "What drive do you want to be your HOME partition? Type in form of /dev/sdX. Make no typos. There is no failsafe, yet!"
echo "If you just press ENTER I will ONLY use the ROOT partition!"

echo " "
read clfshomedev
printf "\033c"

echo "Your CLFS ROOT partition is $clfshomedev. It will be mounted to /mnt/clfs/home"
echo " "
echo " "

echo "Chose whether or not your home partition should be formatted.[Y/N/y/n/yes/no]"
echo " "

read clfsformathomedev
printf "\033c"

echo " "
echo "Now choose your file system. Both drives will be formatted with it. For now only [ext4] will be supported."
echo " "

read clfsfilesystem
printf "\033c"

echo "You chose to format $clfshomedev and $clfsrootdev with $clfsfilesystem. That's it for now."
echo " "

CLFS=/mnt/clfs
CLFSUSER=clfs
CLFSHOME=${CLFS}/home
CLFSSOURCES=${CLFS}/sources
CLFSTOOLS=${CLFS}/tools
CLFSCROSSTOOLS=${CLFS}/cross-tools

export CLFS=/mnt/clfs
export CLFSHOME=/mnt/clfs/home
export CLFSSOURCES=/mnt/clfs/sources
export CLFSTOOLS=/mnt/clfs/tools
export CLFSCROSSTOOLS=/mnt/clfs/cross-tools
export CLFSUSER=clfs

cat >> /root/.bashrc << EOF
export CLFS=/mnt/clfs
export CLFSHOME=/mnt/clfs/home
export CLFSSOURCES=/mnt/clfs/sources
export CLFSTOOLS=/mnt/clfs/tools
export CLFSCROSSTOOLS=/mnt/clfs/cross-tools
export CLFSUSER=clfs
EOF

echo " "
mkfs.${CLFSFILESYSTEM} -q ${CLFSROOTDEV}
echo " "

if [[ $clfsformathomedev = y || $clfsformathomedev = Y || $clfsformathomedev = yes ]]; then
	mkfs.${CLFSFILESYSTEM} -q ${CLFSHOMEDEV}
fi
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

#Download kernel and toolchain
wget http://ftp.gnu.org/gnu/binutils/binutils-2.29.1.tar.bz2 -P ${CLFSSOURCES}
wget ftp://gcc.gnu.org/pub/gcc/releases/gcc-7.2.0/gcc-7.2.0.tar.xz -P ${CLFSSOURCES}
wget https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.13.5.tar.xz -P ${CLFSSOURCES}
wget https://ftp.gnu.org/gnu/glibc/glibc-2.26.tar.xz -P ${CLFSSOURCES}

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
cp -rv bclfs ${CLFS}

chown -v ${CLFSUSER}:${CLFSUSER} /home/clfs

echo " "
echo "Check the screen output if everything looks fine"
echo "Compare it to the instructions of the book"
echo " "
echo "Execute Script #0b"
echo "To login as unprivilidged CLFS user"
echo " "
