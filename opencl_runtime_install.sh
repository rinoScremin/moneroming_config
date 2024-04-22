#!/bin/bash
set -e

# make sure firmware is installed 
tce-load -wi firmware-amdgpu.tcz
tce-load -wi firmware-amd-ucode.tcz
tce-load -wi xf86-video-amdgpu.tcz
tce-load -wi python3.6-dev

# Installing git-lfs 
#download git-lfs files 
cd ~
curl -L -o git-lfs.tar.gz https://github.com/git-lfs/git-lfs/releases/download/v3.5.1/git-lfs-linux-amd64-v3.5.1.tar.gz
#extract git-lfs tar.gz
tar -xvzf git-lfs.tar.gz
cd git-lfs-3.5.1
#Move the git-lfs binary to a directory in your PATH and Make sure it's executable
sudo mv git-lfs /usr/local/bin/
sudo chmod +x /usr/local/bin/git-lfs

#Installing the repo tool
cd ~
mkdir -p ~/bin/
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
sudo chmod a+x ~/bin/repo

#Downloading the ROCm source code
cd ~
mkdir -p ~/ROCm/
cd ~/ROCm/
~/bin/repo init -u http://github.com/ROCm/ROCm.git -b roc-6.0.x
~/bin/repo sync

#build and install ROCm-OpenCL-Runtime
cd ~/ROCm/ROCm-OpenCL-Runtime
mkdir build
cd build
cmake -DOPENCL_ICD_LOADER_HEADERS_DIR=/tmp/tcloop/opencl-headers/usr/local/include/CL ..
make

# Copy the libraries
sudo cp libOpenCL.so.1.2 /usr/local/lib
sudo cp libOpenCL.so /usr/local/lib
sudo cp libOpenCL.so.1 /usr/local/lib

# Create the symbolic links
sudo ln -sf /usr/local/lib/libOpenCL.so.1.2 /usr/local/lib/libOpenCL.so
sudo ln -sf /usr/local/lib/libOpenCL.so.1.2 /usr/local/lib/libOpenCL.so.1

# Update the linker cache
sudo ldconfig

echo "ROCm-OpenCL-Runtime now available!"

