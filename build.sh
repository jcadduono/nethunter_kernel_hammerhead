#!/bin/bash
# simple bash script for executing build

# root directory of NetHunter hammerhead git repo (default is this script's location)
RDIR=$(pwd)

[ $VER ] || \
# version number
VER=$(cat $RDIR/VERSION)

# directory containing cross-compile arm toolchain
TOOLCHAIN=$HOME/build/toolchain/arm-cortex_a15-linux-gnueabihf-linaro_4.9.4-2015.06

# amount of cpu threads to use in kernel make process
THREADS=5

############## SCARY NO-TOUCHY STUFF ###############

export ARCH=arm
export CROSS_COMPILE=$TOOLCHAIN/bin/arm-cortex_a15-linux-gnueabihf-
export LOCALVERSION=$VER

cd $RDIR

[ "$TARGET" ] || TARGET=nethunter
[ "$1" ] && {
	DEVICE=$1
} || {
	DEVICE=hammerhead
}
DEFCONFIG=${TARGET}_${DEVICE}_defconfig

[ -f "$RDIR/arch/$ARCH/configs/${DEFCONFIG}" ] || {
	echo "Config $DEFCONFIG not found in $ARCH configs!"
	exit 1
}

KDIR=$RDIR/build/arch/$ARCH/boot

CLEAN_BUILD()
{
	echo "Cleaning build..."
	cd $RDIR
	rm -rf build
}

BUILD_KERNEL()
{
	echo "Creating kernel config..."
	cd $RDIR
	mkdir -p build
	make -C $RDIR O=build $DEFCONFIG
	echo "Starting build for ${TARGET}-${DEVICE}-${LOCALVERSION}..."
	make -C $RDIR O=build -j"$THREADS"
}

CLEAN_BUILD && BUILD_KERNEL && echo "Finished building ${TARGET}-${DEVICE}-${LOCALVERSION}!"
