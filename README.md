Simple Target Image Builder
===========================

This repository contains a simple but straightforward system to create a bootable
Linux system for the I2SE Duckbill and EVAchargeSE device series: for Duckbill
devices it compiles U-Boot as boot loader, for EVAchargeSE it uses Freescale/NXP's
imx-bootlets as bootloader, then it compiles a Linux kernel with device tree blobs
and creates a root filesystem based on Debian Jessie 8 (armel).
Then all is packed into a single disk image, ready to be used on the SD card
(for older Duckbills) and/or the internal eMMC.

This system is intended to be run on a recent Linux system, currently Debian Jessie 8
and Ubuntu 14.04 (LTS) is supported. The main reason for this is, that both distributions
come with precompiled cross compiler packages, however, if you have a working
cross compiler for 'armel' at hand, you can simply make it available in PATH and
change the CROSS_COMPILE setting in the Makefile.

Compared to other Embedded Linux build systems (e.g. ptxdist, OpenWrt...) this
system is limited by design. Please remember the following design decisions
when using it:
* This system is intended to be run on a developer (none-shared) host.
  No precautions are taken to prevent this system running in parallel with
  a second instance in the same base directory.
* This system heavily uses sudo to handle the file permissions of the target
  linux system properly. So ensure that the system user you are using has
  the required permissions.
* You need a working internet connection to download the Debian packages for the
  target system. Only some minor efforts are done to cache the downloaded files.

Docker Guest
------------

Mostly all steps can be done within a docker guest.
This allows to choose a version of GCC that is compatible with the Linux kernel
modified by In-Tech.
For example, GCC 8 generates assembly that don't compile.
See https://gcc.gnu.org/bugzilla/show_bug.cgi?id=85745

Only the steps that need to mount a filesystem (e.g. loop or dev) are more
easily done directly from the host.
To be sure no parts are compiled from the docker host (with a potentially
different version of the GCC compiler), it is advised to have no ARM compilers
installed within the host.

To ensure that your docker guest environment is setup correctly, we have
prepared a Makefile target which helps you to install the distro packages as
required. Simply issue a

```
docker$ make stretch-requirements
```

and see which packages are fetched and installed via apt.

Workflow to generate an image file
----------------------------------

### The root filesystem

This repository uses submodules to link/access various required sources and tools. So
after cloning this repo, you have to init these submodules first:

```
host$ make prepare
```

Since the linux kernel project size is around 1.2 GB, this can take a while; however, if you
do not delete this directory, this is only required once. Later, hoping between branches and
pulling new changesets in, is really fast.

After this, compile the required tools, linux kernel and imx-bootlets:

```
docker$ make tools linux imx-bootlets
```

Now it's time to create the basic Debian root filesystem with multistrap:

```
docker$ make rootfs-clean
docker$ make rootfs
```

And then, we want to customize it a little bit.

This step uses chroot & qemu to run ARM code within the host.
So you need binfmt-qemu-static & qemu-user-static to be installed.
See https://wiki.archlinux.org/index.php/QEMU#Chrooting_into_arm/arm64_environment_from_x86_64

```
docker$ make programs
host$ make install
```

### Additional Libraries

Now that the root filesystem is available, we can put additional libraries that
will be based on what already exists *inside* of the rootfs.

For example, we can now install Qt5.
Note that all the _git_ parts can be done _outside_ the docker guest.

```
host$ git clone git://code.qt.io/qt/qt5.git
host$ cd qt5
host$ QTVER=5.9
host$ git branch --track $QTVER origin/$QTVER
host$ git checkout $QTVER
host$ for MODULE in qtbase qtserialbus qtserialport qtwebsockets; do
        git submodule update --init --depth 15 $MODULE; done
host$ cd ..

host$ git clone https://salsa.debian.org/qt-kde-team/qt/qtbase.git qtbase_debian
host$ cd qtbase_debian
host$ git checkout debian/5.12.5+dfsg-9
host$ cd ..
host$ git apply qtbase_debian/debian/patches/armv4.diff --directory=qt5/qtbase
```

Then call the ad-hoc Qt configuration script to setup Qt according to what is needed.

```
docker$ ./QtConfig.zsh
```

Check the configuration result file in the build folder for any problem.
Then, you can launch the compilation:

```
docker$ cd qt5-build-$QTVER
docker$ make -j8 -Wfatal-errors
docker$ sudo make install
```

Note that the Qt _install_ rule doesn't update `/etc/ld.so.cache`.
A solution is to create a file (e.g. `rootfs/etc/ld.so.conf.d/qt.conf`) that
contains the path to the lib folder (e.g. `/usr/local/Qt-5.9.9/lib`).
And then run:

```
host$ make rootfs-ldconfig
```


### Flashable Image

And now, we pack all into a single SD card/eMMC image and split it into smaller chunks
so that we can deploy it during manufacturing process:

```
host$ make rootfs-image
docker$ make disk-image
```

The resulting images/image parts are here:

```
$ ls -la images
```

To clean up everything generated by this makefile, simply run:

```
docker$ make distclean
```

Device Tree — DTS
-----------------

Whenever you change something to the DTS file, you must issue the commands:

```
docker$ make dtbs (just to quickly check your changes — will be called automatically by command below)
docker$ make imx-bootlets
docker$ rm images/sdcard.img
docker$ make disk-image
```

SD card / eMMC partitioning
---------------------------

The target SD card/eMMC images contain two primary partitions:

```
Device         Boot Start     End Sectors  Size Id Type
/dev/mmcblk0p1 *     2048    4095    2048    1M 53 OnTrack DM6 Aux3
/dev/mmcblk0p2       6144 3751935 3745792  1.8G 83 Linux
```

The first partition is required for the Freescale i.MX28 platform as it contains the boot stream,
used by the i.MX28 internal ROM to bring up the device. In our case, this partition contains
U-Boot as bootloader. This partition is required to have the partition id 0x53 and is 1 MiB in size.

The second partition is a normal ext4 linux filesystem containing the root filesystem. It must also
contain a subdirectory `/boot` in which the kernel `zImage` and one or multiple device tree files
(e.g. `imx28-duckbill.dtb`) reside. Please note, that U-Boot will look after these files during boot,
so when renaming files in this directory also update the U-Boot environment variables `image` and
`fdt_file` accordingly.

Another important point to note is, that the second partition is created as a small partition
of around 340 MB (this may also vary depending on the product variant since various products
include various packages pre-installed). Then during the first boot, the partition is resized
on-the-fly to fill up the whole space available. This done to be able to distribute small images
and to not depend on the exact size of the eMMC or SD card used (e.g. even two SD cards labeled
both with 2 GB may differ in exact size). One drawback of this approach is, that the device
needs to reboot during this first boot because the new partition size is not recognized by
the linux kernel as the partition is busy.
