#!/bin/bash

KVER="v6.12.8"
KURL=https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git
KDEST=linux-stable



if [ ! -d $KDEST ]
then
  echo "fetching kernel sources.."
  git clone --depth=1 -b $KVER $KURL $KDEST || exit -1
  cd $KDEST || exit -1
  echo "Patching kernel.."
  patch -p1 < ../panelfix.patch || exit -1
  cd ..
fi

echo "Cross-compiling kernel ..." 
# build kernel
mkdir -p modules
cp kernel_config linux-stable/.config
cd linux-stable
#make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- tegra_defconfig
#make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- menuconfig

make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- oldconfig || exit -1
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- -j16
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- modules_install INSTALL_MOD_PATH=../modules

echo "Done compiling."

cd ..


echo "Creating kernel partition file.."
# assemble kernel partition
dd if=/dev/zero of=bootloader.bin bs=512 count=1
cp ./linux-stable/arch/arm/boot/zImage ./zImage
cp ./linux-stable/arch/arm/boot/dts/nvidia/tegra124-nyan-big-fhd.dtb ./tegra124-nyan-big-fhd.dtb
mkimage -f ./kernel.its ./kernel.itb
vbutil_kernel --pack ./kernel.bin --keyblock /usr/share/vboot/devkeys/kernel.keyblock --version 1 --signprivate /usr/share/vboot/devkeys/kernel_data_key.vbprivk --config ./cmdline --vmlinuz ./kernel.itb --bootloader bootloader.bin

#cleanup
rm ./zImage ./tegra124-nyan-big-fhd.dtb ./bootloader.bin ./kernel.itb
echo "Done."
echo "copy kernel.bin to the kernel partition"
echo "The kernel cmdline expects it is installed on a USB attached disk."
echo "That disk should have a cgpt format with 2 partitions:"
echo "KERN_A 'ChromeOS Kernel' of at least 32MB"
echo "ROOT_A root partition for OS."

