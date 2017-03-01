#!/bin/bash
#
# Android Kernel Build Script for Enigma Kernel by sagar846 @xda-developers
# Can be modified for other devices easily.

# This isn't licenced but you can freely edit and share without my permission
# Just don't make it forget the original author, i.e , me.
#
# v1 : Initial release.
#
# v2 : Incorporate lazy flasher stuff + other modifications
#
# v3 : Some changes here and there + new stuff
#
# v4 : implement signing zip + some changes

# Just a side note : even if your kernel build fails and you don't make a clean build
# The zip file will  be created nonetheless if a zImage exists that is.

clear

#Resources- Change according to your device and needs
NAME="enigma"
KERNEL="kernel"
VERSION="rX"
DEVICE="athene"
ZIP="$NAME-$KERNEL-$DEVICE-$VERSION"
THREAD="-j4"
DEVICE="athene"
DEVICE_NAME="Moto G4 Plus"
DEFCONFIG="athene_defconfig"
KERNEL="zImage"
FLASHABLE_ZIP="*.zip"

# Kernel Build Details
export ARCH=arm
# Give the complete path to your toolchain like so
# ~/folder-containing-toolchain/name-of-toolchain-folder/bin/arm-eabi-
export CROSS_COMPILE=~/toolchains/UBERTC-arm-eabi-4.9/bin/arm-eabi-

#Paths - Very Important that you give the right paths
KERNEL_DIR="${HOME}/kernel_athene"
ZIMAGE_DIR="$KERNEL_DIR/arch/arm/boot" #Dont change this
LAZYFLASHER_DIR="$KERNEL_DIR/lazyflasher"
KERNEL_OUT_DIR="$KERNEL_DIR/out"
SIGN_ZIP_DIR="$KERNEL_DIR/signzip"

######################## No touchy stuff ########################
############## Unless you know what you're doing ################

#Functions
function clean_out {
	cd $KERNEL_OUT_DIR
	echo
	make clean
	cd $SIGN_ZIP_DIR
	rm -f *.zip
}

function clean_all {
	cd $KERNEL_DIR
	echo
	make clean
}

function make_kernel {
	cd $KERNEL_DIR
	echo
	make $DEFCONFIG
	make $THREAD
}

function sign_zip {
	mv $LAZYFLASHER_DIR/$FLASHABLE_ZIP $SIGN_ZIP_DIR
	cd $SIGN_ZIP_DIR
	echo
	java -jar signapk.jar testkey.x509.pem testkey.pk8 "$ZIP".zip "$ZIP-signed".zip
}

# The action starts here

echo -e ">>>>> Kernel building script for Moto G4 Plus (athene)"
echo -e ">>>>> Version 4, February 2017"
echo -e ">>>>> Written by sagar846 @ github (https://github.com/sagar846/)"
echo -e ">>>>> AKA sagar846 @ xda-developers"
echo -e " "
echo -e " "

while read -p "Executing Kernel Build Script. Continue (y/N)? " achoice
do
case "$achoice" in
	y|Y)
		echo
		break
		;;
	n|N)
		echo
		echo "Exiting build script"
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

while read -p "Do you want to clean out directory (y/N)? " bchoice
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
		echo "Invalid input try again!"
		echo
		;;
esac
done

while read -p "Do you want to perform a clean build (y/N)? " cchoice
do
case "$cchoice" in
	y|Y)
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
		echo "Invalid input try again!"
		echo
		;;
esac
done

echo "You are building Enigma kernel for $DEVICE_NAME ($DEVICE)";
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
			echo "Kernel Build failed"
			echo "Try building kernel without this script and see what went wrong."
			echo "Exiting script"
			exit
			echo
		fi
		break
		;;
	n|N)
		echo "Exiting build script"
		echo
		exit
		;;
	* )
		echo
		echo "Invalid input try again!"
		echo
		;;
esac
done

# If you want to use anykernel instead of lazyflasher then you will
# have to change everything from here onwards with proper commands.
# Remember Google is your friend though it can be a bitch sometimes.

echo "Moving all necessary files to lazyflasher directory..."
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
	echo "Error: could not create zip file."
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

echo "###### Script Execution Completed ######"
echo

