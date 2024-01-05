#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Illegal number of parameters"
	echo usage $0 device 
	exit
fi

rootfs_tarball="ArchLinuxARM-armv7-latest.tar.gz"
rootfs_tarball_url="http://os.archlinuxarm.org/os/${rootfs_tarball}"

rootfs_tarball_md5=${rootfs_tarball}.md5
rootfs_tarball_md5_url="http://os.archlinuxarm.org/os/${rootfs_tarball_md5}"

sdcard_device=${1}

echo SD Card Device  ${sdcard_device}
echo Root FS tarball ${rootfs_tarball} 
echo Download URL    ${rootfs_tarball_url}

download_tarball() {
	wget -nc ${rootfs_tarball_url}
}

verify_tarball() {
	echo md5sum ${rootfs_tarball}
	tarball_md5=$(md5sum ${rootfs_tarball});
	echo tarball md5 is     ${tarball_md5};
	expected_md5=$(wget -q -O - ${rootfs_tarball_md5_url})
	echo expected md5 is    ${expected_md5};
	if [ "${tarball_md5}" == "${expected_md5}" ]; then
		echo "MD5 ok"
		return 0
	else
		echo "MD5 failed. Corrupted or outdated image"
		return -1
	fi
}

if [ -f "$rootfs_tarball" ]; then
	echo "$rootfs_tarball exists."
	if  verify_tarball ; then
		echo verification succeeded
	else
		echo verification failed. old or corrupt tarball?
		echo redownloading
		rm -f $rootfs_tarball
		download_tarball;
		if  verify_tarball ; then
			echo verification succeeded
		else
			echo verification failed
			exit
		fi
	fi
else
	echo "$rootfs_tarball does not exists.";
	echo "Downloading"
	download_tarball;
	if  verify_tarball ; then
		echo verification succeeded
	else
		echo verification failed
	fi
fi

# as downloading may take a while, the user might not be watching all the time
# and sudo might time out, thus we ask for an Enter to continue
read -p "Press Enter to continue"

sudo umount root
rm -rf root boot 

set -e 

sudo sfdisk ${sdcard_device} < ./sd.sfdisk 

bootfs_device=${sdcard_device}1
rootfs_device=${sdcard_device}2

sudo mkfs.vfat ${bootfs_device}
sudo mkdir -p boot
sudo mount -o sync ${bootfs_device} boot

sudo mkfs.ext4 ${rootfs_device}
sudo mkdir -p root
sudo mount -o sync ${rootfs_device} root

# Disable write cache on SD card
sudo hdparm -W0 ${sdcard_device}

sudo bsdtar -xpvf ${rootfs_tarball} -C ./root
echo "Syncing, this might take several minutes, be patient"
sync
echo "Syncing, done"

# as extracting takes a while, the user might not be watching all the time
# and sudo might time out, thus we ask for an Enter to continue
read -p "Press Enter to continue"

echo "Installing u-boot"
uboot_tag=v2023.10
git clone -b ${uboot_tag} https://github.com/u-boot/u-boot/
cd u-boot
make CROSS_COMPILE=arm-none-eabi- omap3_beagle_defconfig 
make CROSS_COMPILE=arm-none-eabi-

# as building takes a while, the user might not be watching all the time
# and sudo might time out, thus we ask for an Enter to continue
read -p "Press Enter to continue"

sudo cp MLO ../boot
sudo cp u-boot.img ../boot
sync 
cd ..

sudo mv root/boot/* boot
sudo umount boot
sudo mount ${bootfs_device} root/boot

# assuming qmeu static and binfmt are configured, we arch-chroot into it
sudo cp configure_target.sh root
sudo chmod +x root/configure_target.sh
sudo arch-chroot root /configure_target.sh

# as updating takes a while, the user might not be watching all the time
# and sudo might time out, thus we ask for an Enter to continue
read -p "Press Enter to continue"


sudo rm root/configure_target.sh

# generate UUID based fstab, so we don't need to differentiate between pi models
genfstab -U  root | grep -v swap | sudo tee root/etc/fstab > /dev/null

./mkscr
sudo cp boot.* mkscr root/boot

sudo umount root/boot
sudo umount root
sync

echo done
