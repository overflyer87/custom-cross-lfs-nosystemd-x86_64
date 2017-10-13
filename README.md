# my-clfs-svn-nosystemd-x86_64

## This customized version of CLFS SVN multilib x86_64 is libre and gratis for anyone to have, use, download, adjust, modify, distribute and redistribute!

### General Announcement
I did **not** use the adjective **free** since I do not midn if linux systems use any proprietary binary blobs. IMHO Especially for high-performance GPUs and some firmware that is inevidable.

I for my part will make this "distro" only a customized version for very modern systems. That is just because I can put just so many hours into this. And you dont wanna know how many hours since end of July 2017 went into this ;-).

I will ONLY support **openRC** (this question for me is also one of principle)!
SysVinit as a standalone init system is just too old and the bootup scripts were outdated. OpenRC runs successfully as of        2017-10-13. Now I am more indendent from the CLFS guys. I updated the toolchain to binutils 2.29.1, GCC 7.2.0 and glibc 2.26 by myself. CLFS is has not come that far, yet. **_I will delete sysvinit scripts in a few weeks!_**

I will ONLY make this bootable for **UEFI** systems.
This "distro" will start with kernel 4.12.10.
I will try to use openrc-elogind and NOT consolekit. Elogind however is suddenly failing on me although it worled before
I will ONLY provide scripts for **XCFCE** and **MATE** as Desktop environments.
I will ONLY provide Xorg drivers for **Intel/NVIDIA** Systems.
I will deactivate nouveau and nouveau fb (framebuffer) by default and provide an NVIDIA install script
This might change if I will ever build a AMD Ryzen+Vega RIG __*__**_**__*__

**I do not provide all Xorg drivers by default!!!**

If I ever find out how, I will ditch Xorg and will switch to Wayland. Since I have no experience whatsoever with Wayland that might take some time. Also XFCE and MATE need to support it first.

### Run codes in file names have the following meaning:

RAHU - Run as (regular) user of your host distro

RAHR - Run as root user of your host distro

RASUN - Run as (regular) user of your final CLFS system NATIVELY (booted or via ssh)

RASRC - Run as root user of your final system in CHROOT

RASRN - Run as root user of your final system NATIVELY (booted or via ssh)

RACU - Run as the CLFS-user (the special, under-priviledged user on your host distro to build the temporary system)

### Major pain points I could need help with
