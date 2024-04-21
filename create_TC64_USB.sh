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
wget http://tinycorelinux.net/15.x/x86_64/release/CorePure64-current.iso || { echo "Download failed"; exit 1; }

# Automatically configure disk partitioning
echo -e "o\nY\nn\n\n\n\nEF00\nw\nY\n" | sudo gdisk /dev/sdb

# Format the new partition (assuming it is /dev/sdb1)
sudo mkfs.fat -F 32 -I /dev/sdb

# Mount the USB drive
sudo mkdir -p /mnt/usb
sudo mount /dev/sdb /mnt/usb

# Install GRUB
sudo grub-install --target=x86_64-efi --efi-directory=/mnt/usb --boot-directory=/mnt/usb/boot --removable

cat <<EOF | sudo tee /mnt/usb/boot/grub/grub.cfg
set default=0
set timeout=10
menuentry "Tiny Core64" {
    set root=(hd0)
    linux /boot/vmlinuz64 quiet waitusb=5 restore=sdb/tce/mydata.tgz
    initrd /boot/corepure64.gz
}
EOF

# Mount the ISO file
sudo mkdir -p /mnt/iso
sudo mount -o loop CorePure64-current.iso /mnt/iso

# Copy necessary files to the USB drive
sudo cp /mnt/iso/boot/vmlinuz64 /mnt/usb/boot/
sudo cp /mnt/iso/boot/corepure64.gz /mnt/usb/boot/

# Unmount the USB drive and ISO
sudo umount /mnt/usb
sudo umount /mnt/iso

# Complete setup
echo "Tiny Core Linux is ready on the USB drive!"

