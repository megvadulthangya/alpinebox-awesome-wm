#!/bin/sh

set -e

echo "ALPINEBOX: Changing Repositories and Installing alpine in /mnt/newroot"

cat /dev/null /etc/apk/repositories &&

cat > /etc/apk/repositories << EOF
/media/cdrom/apks
http://dl-cdn.alpinelinux.org/alpine/v3.20/main
http://dl-cdn.alpinelinux.org/alpine/v3.20/community
EOF

apk update &&

mkdir -p /mnt/newroot/etc/apk
cp /etc/apk/repositories /mnt/newroot/etc/apk

apk --allow-untrusted -U --root /mnt/newroot --initdb add \
    alpine-base \
    linux-firmware-none linux-lts openssh-server openssh-client chrony acpid syslinux sgdisk partx mount zfs wireless-tools wpa_supplicant &&

apk add doas sudo lightdm lightdm-gtk-greeter xfce4-terminal awesome wireplumber pipewire-pulse pipewire-alsa pavucontrol thunar thunar-archive-plugin imagemagick rofi picom xautolock polkit-gnome i3lock-color hd-idle feh git &&


git clone https://github.com/lcpz/awesome-freedesktop.git /mnt/newroot/etc/xdg/awesome/freedesktop &&

cp -f files/cfgs/rc.lua /mnt/newroot/etc/xdg/awesome/rc.lua &&

cp files/cfgs/picom.conf /mnt/newroot/etc/xdg/picom.conf &&

cp files/cfgs/locker.sh /mnt/newroot/etc/xdg/awesome/locker.sh &&

mkdir /mnt/newroot/usr/share/wallpapers &&


tar -xvzf files/wallpapers/wallpapers.tgz -C /mnt/newroot/usr/share/wallpapers &&

cp /etc/hostid /mnt/newroot/etc
cp /etc/resolv.conf /mnt/newroot/etc
if [[ -e /etc/network/interfaces ]]; then
    cp /etc/network/interfaces /mnt/newroot/etc/network
else
    cp files/interfaces /mnt/newroot/etc/network
fi

mount --rbind /dev /mnt/newroot/dev
mount --rbind /sys /mnt/newroot/sys
mount --rbind /proc /mnt/newroot/proc

# Blacklist GPUs (issue #3)
cp files/blacklist-gpu.conf /mnt/newroot/etc/modprobe.d

# zfs stuff
echo "/etc/hostid" >>/mnt/newroot/etc/mkinitfs/features.d/zfshost.files
echo 'features="ata base keymap kms mmc nvme scsi usb virtio zfs zfshost"' >/mnt/newroot/etc/mkinitfs/mkinitfs.conf

# rebuild initfs for above two things
chroot /mnt/newroot mkinitfs $(ls /mnt/newroot/lib/modules)

# services
chroot /mnt/newroot rc-update add hwdrivers sysinit
chroot /mnt/newroot rc-update add networking boot
chroot /mnt/newroot rc-update add hostname boot
chroot /mnt/newroot rc-update add sshd default
chroot /mnt/newroot rc-update add swap default
chroot /mnt/newroot rc-update add acpid default
chroot /mnt/newroot rc-update add crond default
chroot /mnt/newroot rc-update add syslog default
chroot /mnt/newroot rc-update add chronyd default
chroot /mnt/newroot rc-update add zfs-mount default
#chroot /mnt/newroot rc-update add lightdm
#chroot /mnt/newroot rc-update add dbus
# chroot /mnt/newroot rc-update add zfs-import default

# fstab
SWAPDEV=$INSTALL_SWAP_DEV
cat >/mnt/newroot/etc/fstab <<EOF
tmpfs	/tmp	tmpfs	nosuid,nodev	0	0
#$SWAPDEV none swap sw 0 0
EOF

echo "ALPINEBOX: done"
