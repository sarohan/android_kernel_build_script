# Android Kernel Building Script by sagar846

## To use

Read the kernel-build.sh source file and give the proper paths and stuff and change whatever you require.
Recommended you copy the all files and folders except '.git' folder and README.md to you kernel source directory.
After that 'cd' to kernel directory and make the scipt executable.


$ chmod a+xr kernel-build.sh

$ ./kernel-build.sh

Note : Rememeber to give the proper paths to your directories otherwise the build script will exit (fail safe I included, can be removed).

## Information :

1.) kernel-build.sh : the build script uses bash.

2.) lazyflasher : this is the lazyflasher flashable zip file craetion tool made by @jcadduono

3.) signzip : this is where the zip is signed automatically using the script.

4.) out : the newly signed flashable zip is placed here.

## Useful Links

lazyflasher : https://github.com/jcadduono/lazyflasher

anykernel2  : https://github.com/osm0sis/AnyKernel2

UKM-unified : https://github.com/yarpiin/UKM-unified
