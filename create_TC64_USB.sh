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
echo -e "o\nY\nn\n\n\n\n\nEF00\nw\nY\n" | sudo gdisk /dev/sdb

# Format the new partition (assuming it is /dev/sdb1)
sudo mkfs.fat -F 32 -I /dev/sdb

# Mount the USB drive
sudo mkdir -p /mnt/usb
sudo mount /dev/sdb /mnt/usb

# Install GRUB
sudo grub-install --target=x86_64-efi --efi-directory=/mnt/usb --boot-directory=/mnt/usb/boot --removable

# Mount the ISO file
sudo mkdir -p /mnt/iso
sudo mount -o loop CorePure64-current.iso /mnt/iso

# Copy necessary files to the USB drive
sudo cp /mnt/iso/boot/vmlinuz64 /mnt/usb/boot/
sudo cp /mnt/iso/boot/corepure64.gz /mnt/usb/boot/

# Create and write GRUB configuration
nano <<EOF | sudo tee /mnt/usb/boot/grub/grub.cfg

set default=0
set timeout=10
set max_hd=10 # Maximum number of drives to check

# Function to find and set root to the drive with /boot directory
function find_and_set_root {
    for i in `seq 0 10`; do
        # Check if the drive exists by trying to list its contents
        if [ -e (hd${i}) ]; then
            echo "Checking (hd${i})..."
            # Check if /boot directory exists on this drive
            if [ -d (hd${i})/boot ]; then
                set root=(hd${i})
                echo "Found /boot on (hd${i})"
                break
            fi
        fi
    done
}

menuentry "Tiny Core64! XMRig" {
    find_and_set_root
    if [ "${root}" ]; then
        echo "Booting from ${root}..."
        linux /boot/vmlinuz64 quiet waitusb=5 restore=sdb/tce/mydata.tgz hugepagesz=1G hugepages=6 default_hugepagesz=1G restore=sdb/tce/mydata.tgz
        initrd /boot/corepure64.gz
    else
        echo "Failed to find /boot directory on any drives."
    fi
}

EOF

# Unmount the USB drive and ISO
sudo umount /mnt/usb
sudo umount /mnt/iso

# Complete setup
echo "Tiny Core Linux is ready on the USB drive!"

