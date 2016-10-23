#!/bin/bash

#1st Host System Requirements ch 2.2
cat > version-check.sh << "EOF"
#!/bin/bash
# Simple script to list version numbers of critical development tools
export LC_ALL=C
bash --version | head -n1 | cut -d" " -f2-4
MYSH=$(readlink -f /bin/sh)
echo "/bin/sh -> $MYSH"
echo $MYSH | grep -q bash || echo "ERROR: /bin/sh does not point to bash"
unset MYSH

echo -n "Binutils: "; ld --version | head -n1 | cut -d" " -f3-
bison --version | head -n1

if [ -h /usr/bin/yacc ]; then
  echo "/usr/bin/yacc -> `readlink -f /usr/bin/yacc`";
elif [ -x /usr/bin/yacc ]; then
  echo yacc is `/usr/bin/yacc --version | head -n1`
else
  echo "yacc not found" 
fi

bzip2 --version 2>&1 < /dev/null | head -n1 | cut -d" " -f1,6-
echo -n "Coreutils: "; chown --version | head -n1 | cut -d")" -f2
diff --version | head -n1
find --version | head -n1
gawk --version | head -n1

if [ -h /usr/bin/awk ]; then
  echo "/usr/bin/awk -> `readlink -f /usr/bin/awk`";
elif [ -x /usr/bin/awk ]; then
  echo awk is `/usr/bin/awk --version | head -n1`
else 
  echo "awk not found" 
fi

gcc --version | head -n1
g++ --version | head -n1
ldd --version | head -n1 | cut -d" " -f2-  # glibc version
grep --version | head -n1
gzip --version | head -n1
cat /proc/version
m4 --version | head -n1
make --version | head -n1
patch --version | head -n1
echo Perl `perl -V:version`
sed --version | head -n1
tar --version | head -n1
makeinfo --version | head -n1
xz --version | head -n1

echo 'int main(){}' > dummy.c && g++ -o dummy dummy.c
if [ -x dummy ]
  then echo "g++ compilation OK";
  else echo "g++ compilation failed"; fi
rm -f dummy.c dummy
EOF

bash version-check.sh

echo

cat > library-check.sh << "EOF"
#!/bin/bash
for lib in lib{gmp,mpfr,mpc}.la; do
  echo $lib: $(if find /usr/lib* -name $lib|
               grep -q $lib;then :;else echo not;fi) found
done
unset lib
EOF

bash library-check.sh
echo

#2nd Creating a File System on the Partition ch 2.5
mkfs -v -t ext4 /dev/sda3
echo

#3rd Setting The $LFS Variable ch 2.6
export LFS=/mnt/lfs
echo $LFS

#4th Mounting the New Partition ch 2.7
mkdir -pv $LFS
mount -v -t ext4 /dev/sda3 $LFS
echo 

#5th Creating directory for sources ch 3.1
mkdir -v $LFS/sources
chmod -v a+wt $LFS/sources
echo 

#6th Download sources ch 3.1 (tweaked)
echo "Where do you want to get you wget-list from?: "
echo "1) Type in link to your preferred linklist"
echo "2) Choose local wget-list typing in the path"
echo "3) Continue and use official wget-list"
echo "4) Specify path to sources: "
while read -n1 -r -p "[1-4]" && [[ $REPLY != q ]]; do
  case $REPLY in
    1) echo
       echo -e "Type in link to your wget-list \c"
       read linklinklist
       LINKLINKLIST=$linklinklist
       wget $LINKLINKLIST
       break 1;;
    2) echo    
       echo -e "Type in path to your local wget-list followed by \'/\' BUT NOT wget-list"
       read pathlinklist
       PATHLINKLIST=$pathlinklist
       wget $PATHLINKLIST
       echo
       echo "Downloading the packages from your local list to ${CLFS}/sources"
       wget --input-file=$PATHLINKLIST/wget-list --continue --directory-prefix=${CLFS}/sources
       echo "$EXIT"
       echo "Fix it!"
       break 1;;   
   3)  echo
       wget http://www.linuxfromscratch.org/lfs/view/20161022-systemd/wget-list
       wget http://www.linuxfromscratch.org/lfs/view/20161022-systemd/md5sums
       wget --input-file=wget-list --continue --directory-prefix=${CLFS}/sources
       pushd ${CLFS}/sources
       md5sum -c md5sums
       popd
       break 1;;
    4) echo
       echo -e "Specify path to sources: \c"
       read srcpath
       SRCPATH=$srcpath
       sudo cp -v $SRCPATH/*.tar* ${CLFS}/sources/
       sudo cp -v $SRCPATH/*.patch ${CLFS}/sources/
       sudo cp -v $SRCPATH/*.xz ${CLFS}/sources/
       break 1;;
    *) echo " Try again. Type y or n";;
  esac
done

#Final Preparations
#7th Creating the $LFS/tools Directory ch4.2
mkdir -v $LFS/tools
ln -sv $LFS/tools /

#8th Adding the LFS User ch4.3
groupadd lfs
useradd -s /bin/bash -g lfs -m -k /dev/null lfs
echo
passwd lfs
echo
chown -v lfs $LFS/tools
echo
chown -v lfs $LFS/sources
echo

cp *.sh /home/lfs/
cp *.sh /mnt/lfs/sources

su - lfs

