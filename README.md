# make_arch_sd

Scripts to create SD cards with ArchLinux (ARM) for SBCs. 
At the moment only for ArchLinux ARM but RISC-V support will be added at some
point in the future.

Be warned, this is a work in progress, results may not be stable yet. 
Don't blame me if it formats your hard disk in stead of the SD card! 

These scripts will download the rootfs tarball for the appopiate architectute,
partition and format the SD card, extract the tarball to the root file system,
install bootloaders where applicable to the SBC, then arch-chroot into the
rootfs (this requires qemu-user-static and qemu-user-static-binfmt when running
on an x86-64 host), create an UUID based fstab and install the latest updates.

For SBCs not officially supported by ArchLinux ARM, the script will build the
appropiate bootloader from upstream u-boot sources (Banana Pi, Le Potato).
When building u-boot, an appropiate cross-compiler is required. 
For 32-bit ARM targets, arm-none-eabi-gcc will do. For 64-bit ARM targets
aarch64-linux-gnu is used. While the 32-bit compiler is intended for embedded
and the 64-bit compiler is for Linux, the choise is what is available in the
Arch repositories. For building u-boot this difference does not matter.

Supported so far
* Banana Pi (no official support, building mainline u-boot)
* Le Potato (no official support, building mainline u-boot)
* Raspberry Pi aarch64 (official support from archlinuxarm)
* Raspberry Pi armv7 (official support from archlinuxarm)


Requirements:
This script is designed to run on Arch Linux

Packages: 
* aarch64-linux-gnu
* arch-install-scripts
* arm-none-eabi-gcc
* bash
* coreutils
* hdparm
* libarchive
* sudo 
* uboot-tools
* util-linux
* qemu-user-static
* qemu-user-static-binfmt

A thanks to @sehraf. Their project builds ArchLinux RISCV sd cards for the Nezha board. This was the inspiration to start a project for building sd cards for various boards, as the official ArchLinux ARM SD card creation is a manual process. 



