#!/bin/bash

# Set strict error handling
set -euo pipefail

# Install necessary packages
tce-load -wi tc-install
tce-load -wi grub2-multi.tcz
tce-load -wi wget
tce-load -wi nano
tce-load -wi gdisk

# Download the ISO, check for successful download
#wget http://tinycorelinux.net/15.x/x86_64/release/CorePure64-current.iso || { echo "Download failed"; exit 1; }

# Automatically configure disk partitioning
echo -e "o\nY\nn\n\n\n\nEF00\nw\nY\n" | sudo gdisk $1

# Format the new partition (assuming it is /dev/sdb1)
sudo mkfs.fat -F 32 -I $1

# Mount the USB drive
sudo mkdir -p /mnt/usb
sudo mount $1 /mnt/usb

# Install GRUB
sudo grub-install --target=x86_64-efi --efi-directory=/mnt/usb --boot-directory=/mnt/usb/boot --removable

#sudo mkdir -p /mnt/iso
#sudo mount -o loop CorePure64-current.iso /mnt/iso
# Copy necessary files to the USB drive
sudo cp /mnt/sdb/boot/vmlinuz64 /mnt/usb/boot/
sudo cp /mnt/sdb/boot/corepure64.gz /mnt/usb/boot/
sudo cp /mnt/sdb/boot/grub/grub.cfg /mnt/usb/boot/grub/
sudo cp -r /mnt/sdb/tce /mnt/usb
# Unmount the USB drive and ISO
sudo umount /mnt/usb
#sudo umount /mnt/iso
# Complete setup
echo "Tiny Core Linux is ready on the USB drive!"

