#!/bin/sh

set -e


IMAGE_SIZE=3G
IMAGE=/tmp/alpine.img

#cleanup old stuff
losetup -d /dev/loop1 &>/dev/null || true
rm $IMAGE &>/dev/null || true

#prepare image
truncate -s $IMAGE_SIZE $IMAGE
losetup -P /dev/loop1 $IMAGE

export INSTALL_DISK=/dev/loop1
export INSTALL_EFI_DEV=$INSTALL_DISK""p2
export INSTALL_SWAP_DEV=$INSTALL_DISK""p3
export INSTALL_ZPOOL_DEV=$INSTALL_DISK""p4
export INSTALL_ZPOOL=${INSTALL_ZPOOL:-rpool}


cd ../install
./1-prepare.sh
./2-partition-disk.sh 
./3-install-bootloader.sh 
./4-create-zpool.sh 
./5-install-alpine.sh 
./6-install-extras.sh 
./7-cleanup.sh

echo "ALPINEBOX: Compressing image..."
losetup -d /dev/loop1 
rm $IMAGE"".gz &>/dev/null || true
gzip $IMAGE

echo "ALPINEBOX: Done, $IMAGE"".gz created."

