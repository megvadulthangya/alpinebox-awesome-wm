#!/bin/sh
set -e

DISK=$1
if ! [ "$DISK" ]; then
    echo "Usage: $0 <disk>"
    echo "Will install Alpine Box on your system."

    echo "Will WIPE existing DATA!"
    exit 1
fi

export INSTALL_DISK=$DISK
export INSTALL_EFI_DEV=$DISK""2
export INSTALL_SWAP_DEV=$DISK""3
export INSTALL_ZPOOL_DEV=$DISK""4
export INSTALL_POOL=${INSTALL_RPOOL:-rpool}


./1-prepare.sh
./2-partition-disk.sh 
./3-install-bootloader.sh 
./4-create-zpool.sh 
./5-install-alpine.sh 

echo "ALPINEBOX: All done, will reboot in 5 seconds.."
sleep 5
reboot
