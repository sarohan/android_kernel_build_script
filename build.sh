# Just a small script to compile only the zImage

export ARCH=arm
export CROSS_COMPILE=~/toolchains/gcc-linaro-4.9-2016.02-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-
export NRCPUS=`grep 'processor' /proc/cpuinfo | wc -l`;
make enigma_defconfig
make -j$NRCPUS

