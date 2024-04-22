#!/bin/bash

set -e
set -x

mkdir -p ~/src

#wget -P https://mirrors.edge.kernel.org/pub/linux/kernel/v6.x/linux-6.6.8.tar.gz /mnt/sdb/tce/
tar xzvf /mnt/sdb/tce/linux-6.6.8.tar.gz -C ~/src 

ln -sf ~/src/linux-6.6.8 ~/src/linux

sudo mkdir -p /usr/src

sudo mount --bind ~/src /usr/src

cd /usr/src/linux

sudo make mrproper
sudo yes "" | make oldconfig 
sudo make prepare   
sudo make scripts 

sudo ln -sf ~/src/linux /lib/modules/$(uname -r)/build

