#!/bin/bash
set -e
set -x

# make sure firmware is installed 
tce-load -wi firmware-amdgpu.tcz
tce-load -wi firmware-amd-ucode.tcz
tce-load -wi xf86-video-amdgpu.tcz
tce-load -wi python3.6-dev
tce-load -wi openssh
tce-load -wi firmware-radeon.tcz
tce-load -wi Xorg-7.7-bin.tcz
tce-load -wi Xorg-7.7-dev.tcz
tce-load -wi Xorg-7.7-lib.tcz
tce-load -wi Xorg-7.7.tcz
tce-load -wi xorg-proto.tcz
tce-load -wi xorg-server-dev.tcz
tce-load -wi xorg-server.tcz
tce-load -wi gnupg.tcz
tce-load -wi gnu-efi-dev.tcz 

# Installing Khronos OpenCL Headers
cd ~
git clone https://github.com/KhronosGroup/OpenCL-Headers.git
cd OpenCL-Headers
mkdir build 
cd build
cmake ..
make

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

git config --global user.email scremin49@gmail.com
git config --global user.name rino

#Installing the repo tool
cd ~
mkdir -p ~/bin/
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
sudo chmod a+x ~/bin/repo

#Downloading the ROCm source code
cd ~
mkdir -p ~/ROCm/
cd ~/ROCm/
y "" | ~/bin/repo init -u http://github.com/ROCm/ROCm.git -b roc-6.0.x
~/bin/repo sync

#build and install ROCm-OpenCL-Runtime
cd ~/ROCm/ROCm-OpenCL-Runtime/api/opencl/khronos/icd
mkdir build
cd build

#project(MyProjectName LANGUAGES C CXX)

# Correct the CMakeLists.txt file and test files for proper compilation
sudo sed -i 's/project (OPENCL_ICD_LOADER)/project (OPENCL_ICD_LOADER LANGUAGES C CXX)/' ../CMakeLists.txt

# Apply the corrections for 'ret_val'
set +e  # Allow errors
sudo sed -i 's/cl_int ret_val;/extern cl_int ret_val;/' ../test/loader_test/test_cl_runtime.c
sudo sed -i 's/cl_int ret_val;/extern cl_int ret_val;/' ../test/loader_test/test_clgl.c
sudo sed -i 's/int ret_val;/extern int ret_val;/' ../test/loader_test/test_image_objects.c
sudo sed -i 's/int ret_val;/extern int ret_val;/' ../test/loader_test/test_platforms.c
sudo sed -i 's/int ret_val;/extern int ret_val;/' ../test/loader_test/test_program_objects.c
sudo sed -i 's/int ret_val;/extern int ret_val;/' ../test/loader_test/test_sampler_objects.c
set -e  # Stop allowing errors

cmake -DOPENCL_ICD_LOADER_HEADERS_DIR=~/OpenCL-Headers/build/OpenCLHeaders ..
make clean 
make

# Copy the libraries
sudo cp libOpenCL.so.1.2 /usr/local/lib
sudo cp libOpenCL.so /usr/local/lib
sudo cp libOpenCL.so.1 /usr/local/lib

# Create the symbolic links
sudo ln -sf /usr/local/lib/libOpenCL.so.1.2 /usr/local/lib/libOpenCL.so
sudo ln -sf /usr/local/lib/libOpenCL.so.1.2 /usr/local/lib/libOpenCL.so.1

# Ensure the OpenCL ICD loader will find the ROCm OpenCL implementation
sudo mkdir -p /etc/OpenCL/vendors/
echo "/usr/local/lib/libOpenCL.so" | sudo tee /etc/OpenCL/vendors/amdocl64.icd

# Set OCL_ICD_FILENAMES for the current and future sessions
export OCL_ICD_FILENAMES=/etc/OpenCL/vendors/amdocl64.icd
echo "export OCL_ICD_FILENAMES=$OCL_ICD_FILENAMES" | sudo tee -a /etc/profile.d/rocm.sh

# Update the linker cache
sudo ldconfig

# Confirmation message
echo "ROCm-OpenCL-Runtime is now available!"
