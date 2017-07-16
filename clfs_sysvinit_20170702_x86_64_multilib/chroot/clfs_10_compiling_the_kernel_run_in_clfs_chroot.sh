#=================
#LET'S BUILD THE KERNEL
#
#CONFIGURE THE KERNEL EXACTLY TO THESE
#INSTRUCTIONS:
#
#http://www.linuxfromscratch.org/~krejzi/basic-kernel.txt 
#http://www.linuxfromscratch.org/hints/downloads/files/lfs-uefi-20170207.txt

#=====================

mkdir /etc/modprobe.d

#LINUX KERNEL
mkdir linux && tar xf linux-*.tar.* -C linux --strip-components 1
cd linux

make mrproper
cp ../manjaro_4.12_my_kernel_config .
#make defaultconfig
make menuconfig
make
make modules_install
make firmware_install
cp -v arch/x86_64/boot/bzImage /boot/efi/vmlinuz-clfs-4.12.1
cp -v System.map /boot/efi/System.map-4.12.1
cp -v .config /boot/efi/config-4.12.1

cd ${CLFSSOURCES}
#checkBuiltPackage
mv linux /lib/modules/CLFS-4.12.1_ORIGINAL

mkdir -v /etc/modprobe.d

cat > /etc/modprobe.d/blacklist-nouveau.conf << "EOF"
blacklist nouveau
EOF

