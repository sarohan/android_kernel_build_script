#!/bin/bash

# Android Kernel Build Script for Enigma Kernel by sagar846 @xda-developers
# Can be modified for other devices easily.

# This isn't licenced but you can freely edit and share without my permission
# Just don't make it forget the original author, i.e , me.

# v1 : Initial release.
#
# v2 : Incorporate lazy flasher stuff + other modifications
#
# v3 : Some changes here and there + new stuff
#
# v4 : Implement signing zip + some changes
#
# v5 : Add Colors Support

# Just a side note : even if your kernel build fails and you don't make a clean build
# The zip file will be created nonetheless if a zImage exists.

clear

# Global Delay funtion
DELAY()
{
	sleep 1;
}

# Colors support
export txtbld=$(tput bold)
export txtrst=$(tput sgr0)
export red=$(tput setaf 1)
export grn=$(tput setaf 2)
export blu=$(tput setaf 4)
export cya=$(tput setaf 6)
export bldred=${txtbld}$(tput setaf 1)
export bldgrn=${txtbld}$(tput setaf 2)
export bldblu=${txtbld}$(tput setaf 4)
export bldcya=${txtbld}$(tput setaf 6)

#Resources- Change according to your device and needs
NAME="enigma"
KERNEL="kernel"
VERSION="rX"
DEVICE="athene"
ZIP="$NAME-$KERNEL-$DEVICE-$VERSION"
export NRCPUS=`grep 'processor' /proc/cpuinfo | wc -l`;
DEVICE="athene"
DEVICE_NAME="Moto G4 Plus"
DEFCONFIG="enigma_defconfig"
KERNEL="zImage"
FLASHABLE_ZIP="*.zip"

# Kernel Build Details
export ARCH=arm
# Give the complete path to your toolchain like so
# ~/folder-containing-toolchain/name-of-toolchain-folder/bin/arm-eabi-
export CROSS_COMPILE=~/toolchains/gcc-linaro-4.9-2016.02-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-

#Paths - Very Important that you give the right paths
KERNEL_DIR="${HOME}/kernel_athene"
ZIMAGE_DIR="$KERNEL_DIR/arch/arm/boot" #Dont change this
LAZYFLASHER_DIR="$KERNEL_DIR/lazyflasher"
KERNEL_OUT_DIR="$KERNEL_DIR/out"
SIGN_ZIP_DIR="$KERNEL_DIR/signzip"

######################## No touchy stuff ########################
############## Unless you know what you're doing ################

#Functions
function check_gcc
{
	echo "${bldcya}***** Checking for GCC...${txtrst}";
	DELAY;
	if [ ! -f ${CROSS_COMPILE}gcc ]; then
		echo "${bldred}***** ERROR: Cannot find GCC!${txtrst}";
		DELAY;
		exit 1;
	fi
	echo "${bldgrn}***** Checked!${txtrst}";
	DELAY;
}

function clean_out {
	cd $KERNEL_OUT_DIR
	echo
	make clean
	cd $SIGN_ZIP_DIR
	rm -f *.zip
}

function clean_all {
	cd $KERNEL_DIR
	echo "${bldcya}***** Cleaning up source...${txtrst}";
	DELAY;
	# Main cleaning
	make clean;

	echo "${bldgrn}***** Cleaned!${txtrst}";
	DELAY;
}

function make_kernel {
	cd $KERNEL_DIR
	make $DEFCONFIG;

	echo "${bldcya}***** Building -> Kernel${txtrst}";
	DELAY;

	make -j$NRCPUS
}

function sign_zip {
	mv $LAZYFLASHER_DIR/$FLASHABLE_ZIP $SIGN_ZIP_DIR
	cd $SIGN_ZIP_DIR
	echo
	java -jar signapk.jar testkey.x509.pem testkey.pk8 "$ZIP".zip "$ZIP-signed".zip
}

# The action starts here

echo -e ">>>>> Kernel building script for Moto G4 Plus (athene)"
echo -e ">>>>> Version 5, March 2017"
echo -e ">>>>> Written by sagar846 @ github (https://github.com/sagar846/)"
echo -e ">>>>> AKA sagar846 @ xda-developers"
echo -e " "
echo -e " "

while read -p "${bldblu}Executing Kernel Build Script. Continue (y/N)? ${txtbld}" achoice
do
case "$achoice" in
	y|Y)
		echo
		break
		;;
	n|N)
		echo
		echo "${bldred}Exiting build script${txtrst}"
		echo
		exit
		;;
	* )
		echo
		echo "Invalid Input try again!"
		echo
		;;
esac
done

while read -p "${bldcya}Do you want to clean out directory (y/N)? ${txtrst}" bchoice
do
case "$bchoice" in
	y|Y)
		clean_out
		echo "Out directory cleaned."
		echo
		break
		;;
	n|N)
		echo
		echo "Out directory has not been touched"
		echo
		break
		;;
	* )
		echo
		echo "${bldred}Invalid input try again!${txtrst}"
		echo
		;;
esac
done

while read -p "${bldcya}Do you want to perform a clean build (y/N)? ${txtrst}" cchoice
do
case "$cchoice" in
	y|Y)
		echo
		check_gcc
		echo
		clean_all
		echo "Cleansed your kernel's soul"
		echo
		break
		;;
	n|N)
		echo
		echo "Dirty build it is then."
		echo
		break
		;;
	* )
		echo
		echo "${bldred}Invalid input try again!${txtrst}"
		echo
		;;
esac
done

echo "${bldgrn}You are building Enigma kernel for $DEVICE_NAME ($DEVICE)${txtrst}";
echo

while read -p "Do you want to build the kernel (y/N)? " dchoice
do
case "$dchoice" in
	y|Y)
		DATE_START=$(date +"%s")
		make_kernel
		if [ -f $ZIMAGE_DIR/$KERNEL ];
		then
			echo
			echo "Kernel Build was Successful"
			echo "Check /arch/arm/boot for zImage, that is the kernel"
			echo
		else
			echo
			echo "${bldred}Kernel Build failed${txtrst}"
			echo "Try building kernel without this script and see what went wrong."
			echo 
			echo "Do you want to run 'make' (y/N) ? " echoice
			if [ $echoice == 'y' || $echoice == 'Y' ]
			then
					echo
					make
					echo
		        else
					echo
					echo "Exiting build script"
					exit
					echo
			fi
			echo
		fi
		break
		;;
	n|N)
		echo "${bldred}Exiting build script${txtrst}"
		echo
		exit
		;;
	* )
		echo
		echo "${bldred}Invalid input try again!${txtrst}"
		echo
		;;
esac
done

# If you want to use anykernel instead of lazyflasher then you will
# have to change everything from here onwards with proper commands.
# Remember Google is your friend though it can be a bitch sometimes.

echo "${bldcya}Moving all necessary files to lazyflasher directory...${txtrst}"
echo

if [ -f $LAZYFLASHER_DIR/$KERNEL ];
then
	echo "Removing existing zImage in lazyflasher directory....done"
	echo
	rm $LAZYFLASHER_DIR/$KERNEL
	echo "Copying new zImage to lazyflasher directory"
	cp $ZIMAGE_DIR/$KERNEL $LAZYFLASHER_DIR
	echo "Finished"
	echo
else
	echo
	echo "Copying new zImage to lazyflasher directory"
	echo "Note: this is done only if there is no zImage already present"
	cp $ZIMAGE_DIR/$KERNEL $LAZYFLASHER_DIR
	echo "Finished"
	echo
fi

echo "Removing flashable zip in lazyflasher directory if present"
echo "Dont worry about any errors here"
echo

cd $LAZYFLASHER_DIR
if [[ -f $FLASHABLE_ZIP ]];
then
	rm -f $LAZYFLASHER_DIR/*.zip
	rm -f $LAZYFLASHER_DIR/*.sha1
	echo "Finished"
	echo
else
	echo "$LAZYFLASHER_DIR is clean."
	echo "Nothing to do"
	echo
fi

echo "Creating flashable zip file using lazy flasher"
echo

if [ -f $LAZYFLASHER_DIR/$KERNEL ];
then
	cd $LAZYFLASHER_DIR
	make
	echo
else
	echo
	echo "${bldred}Error: could not create zip file${txtrst}"
	echo "zImage does not exist in lazyflasher root directory"
	echo "Fix compile errors and rerun script to compile the kernel again"
	echo "Aborting script"
	exit
	echo
fi

# You can remove this if you want but it's good knowing how long the entire process takes.
DATE_END=$(date +"%s")
DIFF=$(($DATE_END - $DATE_START))
echo "Total Time: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
echo

echo "Signing the newly generated zip file.."
sign_zip
echo "Finished"
echo

echo "Moving newly signed flashable zip to out directory"
mv $SIGN_ZIP_DIR/$FLASHABLE_ZIP $KERNEL_OUT_DIR
echo
echo "Finished"
echo

cd $KERNEL_OUT_DIR
if [ -f "$ZIP-signed".zip ];
then
	rm "$ZIP".zip
fi

echo "${bldblu}###### Script Execution Completed ######${txtrst}"
echo

