## Whole-system customized version of CLFS multilib with openRC (x86_64)

###### Beards of Gentoo user's suddenly seem so short ;-D

### *This customized version of CLFS SVN multilib x86_64 is gratis for anyone to have, use, download, adjust, modify, distribute and redistribute! However if you write scripts for more packages you have to provide the code back to this repo or whereever this project will be located. This is probably conform to GPLv2 but right now I am to lazy to copy and paste it. See this linux system grow would be nice and to see it get more and more packages and in the end there can be one installer where a user choses from. With dependency and collision check of course. I dont want to create a new major branch of Linux! We have enough distros. However having a from source compiled linux that is highly customizable to your needs and also beelding edge and ALSO NOT GENTOO is a great vision. :-P How would Lunduke say... "That would be totally rat..."*

### General Announcement
I did **not** use the adjective **free** since I do not mind linux systems using proprietary binary blobs. IMHO especially for high-performance GPUs and some firmware that is inevidable.

I for my part will make this "distro" only a customized version for very modern systems. That is just because I can put just so many hours into this. And you dont wanna know how many hours since end of July 2017 went into this ;-).

I will ONLY support **openRC** (this question for me is also one of principle)!
SysVinit as a standalone init system is just too old and the bootup scripts were outdated. OpenRC runs successfully as of        2017-10-13. Now I am more indendent from the CLFS guys. I updated the toolchain to binutils 2.29.1, GCC 7.2.0 and glibc 2.26 by myself. CLFS is has not come that far, yet. **_I will delete sysvinit scripts in a few weeks!_**

I will ONLY make this bootable for **UEFI** systems.

I will ONLY provide a script for one bootloader - **goofiboot**. (gummiboot -> systemd-boot -> goofiboot)
Goofiboot however is deprecated, maybe I will switch to grub when it stops working or I will find a way to use systemd-boot as standalone.

This "distro" will start with kernel 4.12.10.
I will try to use openrc-elogind and NOT consolekit. Elogind however is suddenly failing on me although it worled before
I will ONLY provide scripts for **XCFCE** and **MATE** as Desktop environments.
I will ONLY provide Xorg drivers for **Intel/NVIDIA** Systems.
I will deactivate nouveau and nouveaufb (framebuffer) by default and provide an NVIDIA install script.

This might change if I will ever build a AMD Ryzen+Vega RIG __*__**_**__*__

**I do not provide all Xorg drivers by default!!!**

If I ever find out how, I will ditch Xorg and will switch to Wayland. Since I have no experience whatsoever with Wayland that might take some time. Also XFCE and MATE need to support it first.

### Pain points

#### Major pain points 

*If you can solve any of the following problems, please let me know on reddit __/u/overflyer87__ or __YouTube @PenguinsLoveTech__!*

* The multilib """capability""" of Python is just utterly ridiculous. 3.6 works a little better than 2.7. They both sometimes work and sometimes don't. The very common dependcy of linux packages from Python nowadays is sad. I never noticed that until I did this project. Please keep coding in C, C++, C#, Rust, or Java, developers. The abstraction layers caused by script and web languages should not serve as a way to provide very core functionalities in an operating system  </rant>. High level user applications or browers of course, but bluetooth and Xorg...Come on! :-D

* So since even patches that I tracked down with a lot of effort wont make Python work well in /usr/lib64 (standard is /usr/lib), I am thinking to restructure the toolchain and tell GCC and Binutils that my 32-bit folders will be named lib32 and my 64-bit folders lib. lib can then be symlinked to lib64 named folders.

* If I fix Python I would solve many problems, such as Bluettoth functionality and finally the capability to compile a decent version of MozJS. Until now only 17 is possible. 38 would be nice. 52 would be awesome.

#### Medium pain points

* Alsa behaves way better with openRC. Even pulseaudio starts. However I still have no sound. I had to copy asound.state from my host distro. Don't know why that does not get created for me when building alsa. Did not change anything. Still get these messages also pulseaudio and openrc-alsasound run: 
ALSA lib control.c:1373:(snd_ctl_open_noupdate) Invalid CTL hw:2 (also hw:0 and hw:1)
aplay: device_list:279: control open (2): No such file or directory

* Display managers like lightdm or lxdm failed miserably with sysvinit. Let's checkout how this goes with openrc.

#### Minor paint points

* Since openrc I know get a boring prompt after boot up saying localhost login: I have to figure out How to get a correct prompt again like I had with sysvinit. BUT HEY...openRC fixed my keyboard layout issues.

* Since toolchain update libpam, libreadline and libhistory (supposedly the 32-bit versions from /usr/lib) throw ldconfig errors "Connot find mmap ....". need to fix that.

* Want to make a live ISO image from an install. Have to figure out and how to generalize configuration then. I want that LiveISO to boot up and then open a terminal and greet the user with a ready to go folder with install scipts and packages.

#### Abbreviations at the end of file names have the following meaning:

RAHU - Run as (regular) user of your host distro

RAHR - Run as root user of your host distro

RASUN - Run as (regular) user of your final CLFS system NATIVELY (booted or via ssh)

RASRC - Run as root user of your final system in CHROOT

RASRN - Run as root user of your final system NATIVELY (booted or via ssh)

RACU - Run as the CLFS-user (the special, under-priviledged user on your host distro to build the temporary system)
